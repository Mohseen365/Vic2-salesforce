/**
 * @description Service-layer entry point for inbound economy save-game imports.
 * Orchestrates analysis header creation, master-data resolution (Country, Product, Province, State),
 * snapshot child record upserts, and invocation of EconomyCalculationEngine.
 * LEGACY (Phase 5/6 Pre-commit) behavior retained: accepts saveGameName alias, BATCH_THRESHOLD_LEGACY=2000,
 * buildProvinceRecords() method, and EconomyAnalysisService.recalculateAnalysis() handoff in synchronous path.
 */
public with sharing class EconomyImportService {

    public static final Integer BATCH_THRESHOLD = 200;

    // LEGACY (Phase 5/6 Pre-commit): Original batch threshold for junction + province record volume
    public static final Integer BATCH_THRESHOLD_LEGACY = 2000;

    /**
     * @description Processes an inbound EconomyImportRequestDTO payload synchronously or delegates to EconomyImportBatch.
     * @param request The inbound import payload DTO.
     * @return EconomyImportResponseDTO containing results and record counts.
     */
    public static EconomyImportResponseDTO processImport(EconomyImportRequestDTO request) {
        return processImportInternal(request, false);
    }

    /**
     * @description Processes an inbound import with explicit control over whether to force batch execution.
     * @param request The inbound import payload DTO.
     * @param forceBatch If true, forces asynchronous EconomyImportBatch processing regardless of record count.
     * @return EconomyImportResponseDTO containing results and record counts.
     */
    public static EconomyImportResponseDTO processImport(EconomyImportRequestDTO request, Boolean forceBatch) {
        return processImportInternal(request, forceBatch);
    }

    private static EconomyImportResponseDTO processImportInternal(EconomyImportRequestDTO request, Boolean forceBatch) {
        EconomyImportResponseDTO response = new EconomyImportResponseDTO();

        if (request == null || request.analysis == null ||
            (String.isBlank(request.analysis.saveFileName) && String.isBlank(request.analysis.saveGameName))) {
            response.success = false;
            response.importStatus = 'FAILED';
            response.errorMessage = 'Invalid payload: Analysis header and saveFileName (or saveGameName) are required.';
            return response;
        }

        // Contract Version Validation (Enforce 1.x.x) — LEGACY: absent contractVersion is tolerated for backward compatibility
        String contractVer = request.analysis.contractVersion;
        if (contractVer != null && !contractVer.startsWith('1.')) {
            response.success = false;
            response.importStatus = 'FAILED';
            response.errorMessage = 'Contract version mismatch: Expected major version 1.x.x, received: ' + contractVer;
            return response;
        }

        Economy_Analysis__c analysisHeader = null;

        try {
            // 1. Resolve / Create Master Data in strict order: Country -> Product -> Province -> State
            Map<String, Country__c> masterCountryMap = resolveMasterCountries(request.countries);
            Map<String, Product__c> masterProductMap = resolveMasterProducts(request.products);
            Map<String, Province__c> masterProvinceMap = resolveMasterProvinces(request.provinces, masterCountryMap);
            Map<String, State__c> masterStateMap = resolveMasterStates(request.states, masterCountryMap);

            response.recordCounts.put('countries', request.countries != null ? request.countries.size() : 0);
            response.recordCounts.put('products', request.products != null ? request.products.size() : 0);
            response.recordCounts.put('provinces', request.provinces != null ? request.provinces.size() : 0);
            response.recordCounts.put('states', request.states != null ? request.states.size() : 0);

            // 2. Create / Upsert Economy_Analysis__c Header
            String analysisKey = (request.analysis.saveFileName != null) ? request.analysis.saveFileName : request.analysis.saveGameName;
            analysisHeader = getOrCreateAnalysisHeader(request.analysis, analysisKey);
            response.analysisId = analysisHeader.Id;

            // Transition status to PROCESSING
            updateAnalysisStatus(analysisHeader.Id, 'PROCESSING', null);

            // 3. Create / Upsert Country_Economy__c Records
            Map<String, Country_Economy__c> countryEconomyMap = upsertCountryEconomies(
                analysisHeader.Id,
                analysisKey,
                request.countries,
                masterCountryMap
            );

            // 4. Create / Upsert Product_Economy__c Records
            Map<String, Product_Economy__c> productEconomyMap = upsertProductEconomies(
                analysisHeader.Id,
                analysisKey,
                request.products,
                masterProductMap
            );

            // 5. Create / Upsert State_Economy__c Records
            Map<String, State_Economy__c> stateEconomyMap = upsertStateEconomies(
                analysisHeader.Id,
                analysisKey,
                request.states,
                countryEconomyMap,
                masterStateMap
            );

            // 6. Create / Upsert Province_Economy__c Records
            Map<String, Province_Economy__c> provinceEconomyMap = upsertProvinceEconomies(
                analysisHeader.Id,
                analysisKey,
                request.provinces,
                countryEconomyMap,
                stateEconomyMap,
                masterProvinceMap
            );

            // 7. Construct Country_Product_Economy__c Child Records
            List<Country_Product_Economy__c> junctionRecords = buildCountryProductRecords(
                analysisKey,
                request.countryProducts,
                countryEconomyMap,
                productEconomyMap,
                masterProductMap
            );

            response.recordCounts.put('countryProducts', junctionRecords.size());

            if (!junctionRecords.isEmpty() && Schema.sObjectType.Country_Product_Economy__c.isCreateable()) {
                upsert junctionRecords Unique_Snapshot_Key__c;
            }

            // 8. Transition status to CALCULATING and invoke EconomyCalculationEngine
            updateAnalysisStatus(analysisHeader.Id, 'CALCULATING', null);

            if (!junctionRecords.isEmpty()) {
                EconomyCalculationEngine.calculateProductStorageContributions(
                    junctionRecords,
                    productEconomyMap
                );
                if (Schema.sObjectType.Country_Product_Economy__c.isUpdateable()) {
                    update junctionRecords;
                }
            }

            List<Country_Economy__c> countryList = countryEconomyMap.values();
            Map<Id, List<Country_Product_Economy__c>> junctionsByCountryId = new Map<Id, List<Country_Product_Economy__c>>();
            for (Country_Product_Economy__c j : junctionRecords) {
                if (!junctionsByCountryId.containsKey(j.Country_Economy__c)) {
                    junctionsByCountryId.put(j.Country_Economy__c, new List<Country_Product_Economy__c>());
                }
                junctionsByCountryId.get(j.Country_Economy__c).add(j);
            }

            EconomyCalculationEngine.calculateCountryTotals(countryList, junctionsByCountryId);
            EconomyCalculationEngine.assignGdpRanks(countryList);

            if (!countryList.isEmpty() && Schema.sObjectType.Country_Economy__c.isUpdateable()) {
                update countryList;
            }

            EconomyCalculationEngine.calculateAnalysisTotals(analysisHeader, countryList);
            if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                update analysisHeader;
            }

            // LEGACY (Phase 5/6 Pre-commit): Handoff to recalculation engine
            // New code above performs inline calculations on in-memory objects; this recalculation
            // re-fetches from DB and re-calculates, preserving the legacy recalculation path.
            EconomyAnalysisService.recalculateAnalysis(analysisHeader.Id);

            // 9. Process Factory & Artisan Snapshots
            List<Factory_Economy__c> factoryRecords = buildFactoryRecords(
                analysisHeader.Id,
                analysisKey,
                request.factories,
                countryEconomyMap,
                stateEconomyMap,
                masterProductMap
            );

            List<Artisan_Economy__c> artisanRecords = buildArtisanRecords(
                analysisHeader.Id,
                analysisKey,
                request.artisans,
                countryEconomyMap,
                stateEconomyMap,
                provinceEconomyMap,
                masterProductMap,
                response
            );

            response.recordCounts.put('factories', factoryRecords.size());
            response.recordCounts.put('artisans', artisanRecords.size());

            // GATE-3 Chunk Size Resolution Check
            if (forceBatch || factoryRecords.size() > BATCH_THRESHOLD || artisanRecords.size() > BATCH_THRESHOLD) {
                // Delegate factory and artisan snapshot insertion to async batch
                EconomyImportBatch batchJob = new EconomyImportBatch(
                    analysisHeader.Id,
                    factoryRecords,
                    artisanRecords
                );
                Database.executeBatch(batchJob, 200);

                response.importStatus = 'PROCESSING';
                response.success = true;
                return response;
            } else {
                if (!factoryRecords.isEmpty() && Schema.sObjectType.Factory_Economy__c.isCreateable()) {
                    upsert factoryRecords Unique_Snapshot_Key__c;
                }

                if (!artisanRecords.isEmpty() && Schema.sObjectType.Artisan_Economy__c.isCreateable()) {
                    upsert artisanRecords Unique_Snapshot_Key__c;
                }

                String diagMsg = (response.warnings != null && !response.warnings.isEmpty()) ? String.join(response.warnings, '; ') : null;
                updateAnalysisStatus(analysisHeader.Id, 'COMPLETED', diagMsg);

                response.importStatus = 'COMPLETED';
                response.success = true;
                return response;
            }

        } catch (Exception ex) {
            response.success = false;
            response.importStatus = 'FAILED';
            response.errorMessage = ex.getMessage();

            if (analysisHeader != null && analysisHeader.Id != null) {
                String diagnostic = ex.getMessage() + '\n' + ex.getStackTraceString();
                updateAnalysisStatus(analysisHeader.Id, 'FAILED', diagnostic);
            }

            return response;
        }
    }

    /**
     * @description Resolves master Country__c records, creating missing tags dynamically per GATE-1.
     */
    private static Map<String, Country__c> resolveMasterCountries(List<EconomyImportRequestDTO.CountryDTO> countryDTOs) {
        Map<String, Country__c> countryMap = new Map<String, Country__c>();
        if (countryDTOs == null || countryDTOs.isEmpty()) {
            return countryMap;
        }

        Set<String> tags = new Set<String>();
        Map<String, String> tagToName = new Map<String, String>();
        for (EconomyImportRequestDTO.CountryDTO c : countryDTOs) {
            if (String.isNotBlank(c.tag)) {
                tags.add(c.tag);
                tagToName.put(c.tag, String.isNotBlank(c.name) ? c.name : c.tag);
            }
        }

        List<Country__c> existingCountries = CountrySelector.selectByTag(tags);
        for (Country__c c : existingCountries) {
            countryMap.put(c.Tag__c, c);
        }

        List<Country__c> countriesToInsert = new List<Country__c>();
        for (String tag : tags) {
            if (!countryMap.containsKey(tag)) {
                Country__c newC = new Country__c(
                    Tag__c = tag,
                    Name = tagToName.get(tag)
                );
                countriesToInsert.add(newC);
            }
        }

        if (!countriesToInsert.isEmpty() && Schema.sObjectType.Country__c.isCreateable()) {
            insert countriesToInsert;
            for (Country__c c : countriesToInsert) {
                countryMap.put(c.Tag__c, c);
            }
        }

        return countryMap;
    }

    /**
     * @description Resolves master Product__c records, auto-provisioning missing codes dynamically per GATE-1 (Base_Price__c = 0.0).
     */
    private static Map<String, Product__c> resolveMasterProducts(List<EconomyImportRequestDTO.ProductDTO> productDTOs) {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        if (productDTOs == null || productDTOs.isEmpty()) {
            return productMap;
        }

        Set<String> codes = new Set<String>();
        Map<String, ProductDTOHelper> codeToHelper = new Map<String, ProductDTOHelper>();
        for (EconomyImportRequestDTO.ProductDTO p : productDTOs) {
            if (String.isNotBlank(p.code)) {
                codes.add(p.code);
                ProductDTOHelper helper = new ProductDTOHelper();
                helper.name = String.isNotBlank(p.name) ? p.name : p.code;
                helper.basePrice = p.basePrice != null ? p.basePrice : 0.0;
                codeToHelper.put(p.code, helper);
            }
        }

        List<Product__c> existingProducts = ProductSelector.selectByCode(codes);
        for (Product__c p : existingProducts) {
            productMap.put(p.Code__c, p);
        }

        List<Product__c> productsToInsert = new List<Product__c>();
        for (String code : codes) {
            if (!productMap.containsKey(code)) {
                ProductDTOHelper helper = codeToHelper.get(code);
                Product__c newP = new Product__c(
                    Code__c = code,
                    Name = helper.name,
                    Base_Price__c = helper.basePrice
                );
                productsToInsert.add(newP);
            }
        }

        if (!productsToInsert.isEmpty() && Schema.sObjectType.Product__c.isCreateable()) {
            insert productsToInsert;
            for (Product__c p : productsToInsert) {
                productMap.put(p.Code__c, p);
            }
        }

        return productMap;
    }

    private class ProductDTOHelper {
        public String name;
        public Decimal basePrice;
    }

    /**
     * @description Resolves master Province__c records, creating missing external IDs dynamically.
     */
    private static Map<String, Province__c> resolveMasterProvinces(
        List<EconomyImportRequestDTO.ProvinceDTO> provinceDTOs,
        Map<String, Country__c> masterCountryMap
    ) {
        Map<String, Province__c> provinceMap = new Map<String, Province__c>();
        if (provinceDTOs == null || provinceDTOs.isEmpty()) {
            return provinceMap;
        }

        Set<String> provIds = new Set<String>();
        Map<String, String> provToCountryTag = new Map<String, String>();
        for (EconomyImportRequestDTO.ProvinceDTO p : provinceDTOs) {
            String pId = p.getProvinceIdAsString();
            if (String.isNotBlank(pId)) {
                provIds.add(pId);
                if (String.isNotBlank(p.countryTag)) {
                    provToCountryTag.put(pId, p.countryTag);
                }
            }
        }

        if (provIds.isEmpty() || !Schema.sObjectType.Province__c.isAccessible()) {
            return provinceMap;
        }

        List<Province__c> existingProvinces = [
            SELECT Id, External_Province_Id__c, Country__c
            FROM Province__c
            WHERE External_Province_Id__c IN :provIds
            LIMIT 5000
        ];

        for (Province__c pr : existingProvinces) {
            provinceMap.put(pr.External_Province_Id__c, pr);
        }

        List<Province__c> provincesToInsert = new List<Province__c>();
        for (String pId : provIds) {
            if (!provinceMap.containsKey(pId)) {
                String tag = provToCountryTag.get(pId);
                Country__c masterCountry = (tag != null) ? masterCountryMap.get(tag) : null;
                Province__c newPr = new Province__c(
                    External_Province_Id__c = pId,
                    Country__c = (masterCountry != null) ? masterCountry.Id : null
                );
                provincesToInsert.add(newPr);
            }
        }

        if (!provincesToInsert.isEmpty() && Schema.sObjectType.Province__c.isCreateable()) {
            insert provincesToInsert;
            for (Province__c pr : provincesToInsert) {
                provinceMap.put(pr.External_Province_Id__c, pr);
            }
        }

        return provinceMap;
    }

    /**
     * @description Resolves master State__c records, creating missing State_Code__c (<CountryTag>_<StateName>) dynamically per GATE-2.
     */
    private static Map<String, State__c> resolveMasterStates(
        List<EconomyImportRequestDTO.StateDTO> stateDTOs,
        Map<String, Country__c> masterCountryMap
    ) {
        Map<String, State__c> stateMap = new Map<String, State__c>();
        if (stateDTOs == null || stateDTOs.isEmpty()) {
            return stateMap;
        }

        Set<String> stateCodes = new Set<String>();
        Map<String, StateDTOHelper> helperMap = new Map<String, StateDTOHelper>();
        for (EconomyImportRequestDTO.StateDTO s : stateDTOs) {
            if (String.isNotBlank(s.stateCode)) {
                stateCodes.add(s.stateCode);
                StateDTOHelper helper = new StateDTOHelper();
                helper.name = String.isNotBlank(s.stateName) ? s.stateName : s.stateCode;
                helper.countryTag = s.countryTag;
                helperMap.put(s.stateCode, helper);
            }
        }

        if (stateCodes.isEmpty() || !Schema.sObjectType.State__c.isAccessible()) {
            return stateMap;
        }

        List<State__c> existingStates = [
            SELECT Id, State_Code__c, Country__c
            FROM State__c
            WHERE State_Code__c IN :stateCodes
            LIMIT 5000
        ];

        for (State__c st : existingStates) {
            stateMap.put(st.State_Code__c, st);
        }

        List<State__c> statesToInsert = new List<State__c>();
        for (String sCode : stateCodes) {
            if (!stateMap.containsKey(sCode)) {
                StateDTOHelper helper = helperMap.get(sCode);
                Country__c masterCountry = (helper.countryTag != null) ? masterCountryMap.get(helper.countryTag) : null;
                State__c newSt = new State__c(
                    State_Code__c = sCode,
                    Name = helper.name,
                    Country__c = (masterCountry != null) ? masterCountry.Id : null
                );
                statesToInsert.add(newSt);
            }
        }

        if (!statesToInsert.isEmpty() && Schema.sObjectType.State__c.isCreateable()) {
            insert statesToInsert;
            for (State__c st : statesToInsert) {
                stateMap.put(st.State_Code__c, st);
            }
        }

        return stateMap;
    }

    private class StateDTOHelper {
        public String name;
        public String countryTag;
    }

    /**
     * @description Fetches existing analysis header or creates a new one with RECEIVED status.
     */
    private static Economy_Analysis__c getOrCreateAnalysisHeader(
        EconomyImportRequestDTO.AnalysisDTO analysisDTO,
        String analysisKey
    ) {
        Economy_Analysis__c header = null;

        if (Schema.sObjectType.Economy_Analysis__c.isAccessible()) {
            List<Economy_Analysis__c> existing = [
                SELECT Id, Name, Save_File_Name__c, Unique_Snapshot_Key__c, Import_Status__c
                FROM Economy_Analysis__c
                WHERE Unique_Snapshot_Key__c = :analysisKey OR Save_File_Name__c = :analysisKey
                LIMIT 1
            ];

            if (!existing.isEmpty()) {
                header = existing[0];
            }
        }

        Date ingameDateVal = parseIngameDate(analysisDTO.ingameDate);

        String effectiveSaveFileName = (analysisDTO.saveFileName != null) ? analysisDTO.saveFileName : analysisDTO.saveGameName;

        if (header == null) {
            header = new Economy_Analysis__c(
                Name = effectiveSaveFileName,
                Save_File_Name__c = effectiveSaveFileName,
                Unique_Snapshot_Key__c = analysisKey,
                Source_Save_File_Name__c = analysisDTO.sourceFileName,
                Player_Country_Tag__c = analysisDTO.playerCountryTag,
                Ingame_Date__c = ingameDateVal,
                Analysis_Timestamp__c = Datetime.now(),
                Import_Status__c = 'RECEIVED'
            );
            if (Schema.sObjectType.Economy_Analysis__c.isCreateable()) {
                insert header;
            }
        } else {
            header.Source_Save_File_Name__c = analysisDTO.sourceFileName;
            header.Player_Country_Tag__c = analysisDTO.playerCountryTag;
            header.Ingame_Date__c = ingameDateVal;
            header.Analysis_Timestamp__c = Datetime.now();
            header.Import_Status__c = 'RECEIVED';
            if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                update header;
            }
        }

        return header;
    }

    private static void updateAnalysisStatus(Id analysisId, String status, String diagnosticMessage) {
        if (analysisId == null || !Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
            return;
        }

        Economy_Analysis__c record = new Economy_Analysis__c(
            Id = analysisId,
            Import_Status__c = status
        );

        if (diagnosticMessage != null) {
            record.Import_Diagnostic_Message__c = diagnosticMessage;
        } else {
            record.Import_Diagnostic_Message__c = '';
        }

        update record;
        publishImportEvent(analysisId, status, diagnosticMessage, null);
    }

    /**
     * @description Publishes Economy_Import_Event__e platform event safely without throwing exceptions.
     */
    public static void publishImportEvent(Id analysisId, String status, String diagnosticMessage, Integer recordCount) {
        if (analysisId == null || String.isBlank(status)) {
            return;
        }

        try {
            Economy_Import_Event__e eventRecord = new Economy_Import_Event__e(
                Analysis_Id__c = String.valueOf(analysisId),
                Status__c = status,
                Diagnostic_Message__c = (diagnosticMessage != null) ? diagnosticMessage.left(255) : '',
                Record_Count__c = (recordCount != null) ? Decimal.valueOf(recordCount) : null
            );
            EventBus.publish(eventRecord);
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'Failed to publish Economy_Import_Event__e: ' + ex.getMessage());
        }
    }

    /**
     * @description Creates/upserts Country_Economy__c snapshot records for the analysis.
     */
    private static Map<String, Country_Economy__c> upsertCountryEconomies(
        Id analysisId,
        String analysisKey,
        List<EconomyImportRequestDTO.CountryDTO> countryDTOs,
        Map<String, Country__c> masterCountryMap
    ) {
        Map<String, Country_Economy__c> resultMap = new Map<String, Country_Economy__c>();
        if (countryDTOs == null || countryDTOs.isEmpty()) {
            return resultMap;
        }

        List<Country_Economy__c> records = new List<Country_Economy__c>();
        for (EconomyImportRequestDTO.CountryDTO c : countryDTOs) {
            if (String.isBlank(c.tag)) {
                continue;
            }
            Country__c masterCountry = masterCountryMap.get(c.tag);
            String snapshotKey = analysisKey + '_' + c.tag;

            Country_Economy__c ce = new Country_Economy__c(
                Economy_Analysis__c = analysisId,
                Country__c = (masterCountry != null) ? masterCountry.Id : null,
                Country_Tag__c = c.tag,
                Population__c = c.population,
                Core_Population__c = c.corePopulation,
                Colony_Population__c = c.colonyPopulation,
                Workforce__c = c.workforce,
                Employment__c = c.employment,
                Gold_Income__c = c.goldIncome,
                Factory_GDP__c = c.factoryGdp,
                Province_GDP__c = c.provinceGdp,
                Artisan_GDP__c = c.artisanGdp,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(ce);
        }

        if (!records.isEmpty() && Schema.sObjectType.Country_Economy__c.isCreateable()) {
            upsert records Unique_Snapshot_Key__c;
            for (Country_Economy__c ce : records) {
                resultMap.put(ce.Country_Tag__c, ce);
            }
        }

        return resultMap;
    }

    /**
     * @description Creates/upserts Product_Economy__c snapshot records for the analysis.
     */
    private static Map<String, Product_Economy__c> upsertProductEconomies(
        Id analysisId,
        String analysisKey,
        List<EconomyImportRequestDTO.ProductDTO> productDTOs,
        Map<String, Product__c> masterProductMap
    ) {
        Map<String, Product_Economy__c> resultMap = new Map<String, Product_Economy__c>();
        if (productDTOs == null || productDTOs.isEmpty()) {
            return resultMap;
        }

        List<Product_Economy__c> records = new List<Product_Economy__c>();
        for (EconomyImportRequestDTO.ProductDTO p : productDTOs) {
            if (String.isBlank(p.code)) {
                continue;
            }
            Product__c masterProduct = masterProductMap.get(p.code);
            String snapshotKey = analysisKey + '_' + p.code;

            Product_Economy__c pe = new Product_Economy__c(
                Economy_Analysis__c = analysisId,
                Product__c = (masterProduct != null) ? masterProduct.Id : null,
                Product_Code__c = p.code,
                Price__c = p.price,
                Base_Price__c = (p.basePrice != null) ? p.basePrice : (masterProduct != null ? masterProduct.Base_Price__c : p.price),
                Total_World_Supply__c = p.totalWorldSupply,
                Real_Demand__c = p.realDemand,
                Max_Demand__c = p.maxDemand,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(pe);
        }

        if (!records.isEmpty() && Schema.sObjectType.Product_Economy__c.isCreateable()) {
            upsert records Unique_Snapshot_Key__c;
            for (Product_Economy__c pe : records) {
                resultMap.put(pe.Product_Code__c, pe);
            }
        }

        return resultMap;
    }

    /**
     * @description Creates/upserts State_Economy__c snapshot records for the analysis.
     */
    private static Map<String, State_Economy__c> upsertStateEconomies(
        Id analysisId,
        String analysisKey,
        List<EconomyImportRequestDTO.StateDTO> stateDTOs,
        Map<String, Country_Economy__c> countryEconomyMap,
        Map<String, State__c> masterStateMap
    ) {
        Map<String, State_Economy__c> resultMap = new Map<String, State_Economy__c>();
        if (stateDTOs == null || stateDTOs.isEmpty()) {
            return resultMap;
        }

        List<State_Economy__c> records = new List<State_Economy__c>();
        for (EconomyImportRequestDTO.StateDTO s : stateDTOs) {
            if (String.isBlank(s.stateCode)) {
                continue;
            }
            Country_Economy__c countryEcon = (s.countryTag != null) ? countryEconomyMap.get(s.countryTag) : null;
            State__c masterState = masterStateMap.get(s.stateCode);
            String snapshotKey = analysisKey + '_' + s.stateCode;

            State_Economy__c se = new State_Economy__c(
                Economy_Analysis__c = analysisId,
                Country_Economy__c = (countryEcon != null) ? countryEcon.Id : null,
                State__c = (masterState != null) ? masterState.Id : null,
                Population__c = s.population,
                GDP__c = s.gdp,
                GDP_Rank__c = s.gdpRank,
                RGO_Income__c = s.rgoIncome,
                PGDP__c = s.pgdp,
                AGDP__c = s.agdp,
                FGDP__c = s.fgdp,
                Factory_Employees__c = s.factoryEmployees,
                Factory_Revenue__c = s.factoryRevenue,
                Factory_Profit__c = s.factoryProfit,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(se);
        }

        if (!records.isEmpty() && Schema.sObjectType.State_Economy__c.isCreateable()) {
            upsert records Unique_Snapshot_Key__c;
            for (State_Economy__c se : records) {
                resultMap.put(se.Unique_Snapshot_Key__c, se);
            }
        }

        return resultMap;
    }

    /**
     * @description Creates/upserts Province_Economy__c snapshot records for the analysis.
     */
    private static Map<String, Province_Economy__c> upsertProvinceEconomies(
        Id analysisId,
        String analysisKey,
        List<EconomyImportRequestDTO.ProvinceDTO> provinceDTOs,
        Map<String, Country_Economy__c> countryEconomyMap,
        Map<String, State_Economy__c> stateEconomyMap,
        Map<String, Province__c> masterProvinceMap
    ) {
        Map<String, Province_Economy__c> resultMap = new Map<String, Province_Economy__c>();
        if (provinceDTOs == null || provinceDTOs.isEmpty()) {
            return resultMap;
        }

        List<Province_Economy__c> records = new List<Province_Economy__c>();
        for (EconomyImportRequestDTO.ProvinceDTO prov : provinceDTOs) {
            String pId = prov.getProvinceIdAsString();
            if (String.isBlank(pId) || String.isBlank(prov.countryTag)) {
                continue;
            }

            Country_Economy__c countryEcon = countryEconomyMap.get(prov.countryTag);
            State_Economy__c stateEcon = (prov.stateCode != null) ? stateEconomyMap.get(analysisKey + '_' + prov.stateCode) : null;
            Province__c masterProv = masterProvinceMap.get(pId);

            if (countryEcon == null) {
                continue;
            }

            String snapshotKey = analysisKey + '_' + pId;

            Province_Economy__c pe = new Province_Economy__c(
                Country_Economy__c = countryEcon.Id,
                Province__c = (masterProv != null) ? masterProv.Id : null,
                Population__c = prov.population,
                RGO_Production__c = prov.rgoProduction,
                Colony__c = (prov.colony != null) ? prov.colony : false,
                RGO_Income__c = prov.rgoIncome,
                RGO_GDP__c = prov.rgoGdp,
                Artisan_Spending__c = prov.artisanSpending,
                Artisan_Income__c = prov.artisanIncome,
                Artisan_GDP__c = prov.artisanGdp,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(pe);
        }

        if (!records.isEmpty() && Schema.sObjectType.Province_Economy__c.isCreateable()) {
            upsert records Unique_Snapshot_Key__c;
            for (Province_Economy__c pe : records) {
                resultMap.put(pe.Unique_Snapshot_Key__c, pe);
            }
        }

        return resultMap;
    }

    /**
     * @description Constructs Country_Product_Economy__c records ready for insertion.
     */
    private static List<Country_Product_Economy__c> buildCountryProductRecords(
        String analysisKey,
        List<EconomyImportRequestDTO.CountryProductDTO> cpDTOs,
        Map<String, Country_Economy__c> countryEconomyMap,
        Map<String, Product_Economy__c> productEconomyMap,
        Map<String, Product__c> masterProductMap
    ) {
        List<Country_Product_Economy__c> records = new List<Country_Product_Economy__c>();
        if (cpDTOs == null || cpDTOs.isEmpty()) {
            return records;
        }

        for (EconomyImportRequestDTO.CountryProductDTO cp : cpDTOs) {
            if (String.isBlank(cp.countryTag) || String.isBlank(cp.productCode)) {
                continue;
            }

            Country_Economy__c countryEcon = countryEconomyMap.get(cp.countryTag);
            Product_Economy__c productEcon = productEconomyMap.get(cp.productCode);
            Product__c masterProd = masterProductMap.get(cp.productCode);

            if (countryEcon == null) {
                continue;
            }

            String snapshotKey = analysisKey + '_' + cp.countryTag + '_' + cp.productCode;

            Country_Product_Economy__c junction = new Country_Product_Economy__c(
                Country_Economy__c = countryEcon.Id,
                Product_Economy__c = (productEcon != null) ? productEcon.Id : null,
                Product__c = (masterProd != null) ? masterProd.Id : null,
                Product_Code__c = cp.productCode,
                Sold_Domestic__c = cp.soldDomestic,
                Bought_Quantity__c = cp.boughtQuantity,
                Thrown_To_Market__c = cp.thrownToMarket,
                Actual_Sold_World__c = cp.actualSoldWorld,
                Worldmarket_Pool__c = cp.worldmarketPool,
                Intermediate_Consumption__c = cp.intermediateConsumption,
                Total_Supply_Pounds__c = cp.totalSupplyPounds,
                Actual_Supply_Pounds__c = cp.actualSupplyPounds,
                Actual_Demand_Pounds__c = cp.actualDemandPounds,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(junction);
        }

        return records;
    }

    /**
     * @description Constructs Factory_Economy__c records ready for insertion.
     */
    private static List<Factory_Economy__c> buildFactoryRecords(
        Id analysisId,
        String analysisKey,
        List<EconomyImportRequestDTO.FactoryDTO> factoryDTOs,
        Map<String, Country_Economy__c> countryEconomyMap,
        Map<String, State_Economy__c> stateEconomyMap,
        Map<String, Product__c> masterProductMap
    ) {
        List<Factory_Economy__c> records = new List<Factory_Economy__c>();
        if (factoryDTOs == null || factoryDTOs.isEmpty()) {
            return records;
        }

        for (EconomyImportRequestDTO.FactoryDTO f : factoryDTOs) {
            if (String.isBlank(f.stateCode) || String.isBlank(f.buildingType)) {
                continue;
            }

            Country_Economy__c countryEcon = (f.countryTag != null) ? countryEconomyMap.get(f.countryTag) : null;
            State_Economy__c stateEcon = stateEconomyMap.get(analysisKey + '_' + f.stateCode);
            Product__c masterProd = (f.productCode != null) ? masterProductMap.get(f.productCode) : null;

            Integer occIdx = (f.occurrenceIndex != null && f.occurrenceIndex > 0) ? f.occurrenceIndex : 1;
            String snapshotKey = analysisKey + '_' + f.stateCode + '_' + f.buildingType + '_' + occIdx;

            Factory_Economy__c fe = new Factory_Economy__c(
                Economy_Analysis__c = analysisId,
                Country_Economy__c = (countryEcon != null) ? countryEcon.Id : null,
                State_Economy__c = (stateEcon != null) ? stateEcon.Id : null,
                Product__c = (masterProd != null) ? masterProd.Id : null,
                Building_Type__c = f.buildingType,
                Occurrence_Index__c = occIdx,
                Level__c = f.level,
                Employees__c = f.employees,
                Output_Quantity__c = f.outputQuantity,
                Unsold_Quantity__c = f.unsoldQuantity,
                Capital_Reserves__c = f.capitalReserves,
                Revenue__c = f.revenue,
                Input_Cost__c = f.inputCost,
                Wages_Paid__c = f.wagesPaid,
                Injected_Money__c = f.injectedMoney,
                Factory_GDP__c = f.factoryGdp,
                Profit_Rank__c = f.profitRank,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(fe);
        }

        return records;
    }

    /**
     * @description Constructs Artisan_Economy__c records ready for insertion, logging GATE-1 warnings for unmapped artisan types.
     */
    private static List<Artisan_Economy__c> buildArtisanRecords(
        Id analysisId,
        String analysisKey,
        List<EconomyImportRequestDTO.ArtisanDTO> artisanDTOs,
        Map<String, Country_Economy__c> countryEconomyMap,
        Map<String, State_Economy__c> stateEconomyMap,
        Map<String, Province_Economy__c> provinceEconomyMap,
        Map<String, Product__c> masterProductMap,
        EconomyImportResponseDTO response
    ) {
        List<Artisan_Economy__c> records = new List<Artisan_Economy__c>();
        if (artisanDTOs == null || artisanDTOs.isEmpty()) {
            return records;
        }

        for (EconomyImportRequestDTO.ArtisanDTO a : artisanDTOs) {
            String pId = a.externalProvinceId;
            String prodCode = (a.productCode != null) ? a.productCode : a.artisanType;

            if (String.isBlank(pId) || String.isBlank(prodCode)) {
                String warn = 'Skipping artisan record with missing province ID or product code/type.';
                response.warnings.add(warn);
                continue;
            }

            Country_Economy__c countryEcon = (a.countryTag != null) ? countryEconomyMap.get(a.countryTag) : null;
            Province_Economy__c provEcon = provinceEconomyMap.get(analysisKey + '_' + pId);
            State_Economy__c stateEcon = (a.stateCode != null) ? stateEconomyMap.get(analysisKey + '_' + a.stateCode) : null;
            Product__c masterProd = masterProductMap.get(prodCode);

            if (masterProd == null) {
                // GATE-1: Unmapped artisan type logged and skipped
                String warn = 'GATE-1 Warning: Unmapped artisan type [' + prodCode + '] in province [' + pId + ']. Record skipped.';
                response.warnings.add(warn);
                continue;
            }

            String snapshotKey = analysisKey + '_' + pId + '_' + prodCode;

            Artisan_Economy__c ae = new Artisan_Economy__c(
                Economy_Analysis__c = analysisId,
                Country_Economy__c = (countryEcon != null) ? countryEcon.Id : null,
                Province_Economy__c = (provEcon != null) ? provEcon.Id : null,
                State_Economy__c = (stateEcon != null) ? stateEcon.Id : null,
                Product__c = masterProd.Id,
                Artisan_Type__c = a.artisanType,
                Spending__c = a.spending,
                Income__c = a.income,
                AGDP__c = a.agdp,
                Production_Quantity__c = a.productionQuantity,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(ae);
        }

        return records;
    }

    /**
     * @description Constructs Province_Economy__c records ready for insertion.
     * LEGACY (Phase 5/6 Pre-commit): Original province record builder, retained for backward compatibility.
     * The new upsertProvinceEconomies() method persists these immediately; this builder returns records
     * for deferred persistence via EconomyImportBatch (legacy junction/province batch path).
     */
    private static List<Province_Economy__c> buildProvinceRecords(
        Id analysisId,
        String analysisKey,
        List<EconomyImportRequestDTO.ProvinceDTO> provinceDTOs,
        Map<String, Country_Economy__c> countryEconomyMap,
        Map<String, Province__c> masterProvinceMap
    ) {
        List<Province_Economy__c> records = new List<Province_Economy__c>();
        if (provinceDTOs == null || provinceDTOs.isEmpty()) {
            return records;
        }

        for (EconomyImportRequestDTO.ProvinceDTO prov : provinceDTOs) {
            String pId = prov.getProvinceIdAsString();
            if (String.isBlank(pId) || String.isBlank(prov.countryTag)) {
                continue;
            }

            Country_Economy__c countryEcon = countryEconomyMap.get(prov.countryTag);
            Province__c masterProv = masterProvinceMap.get(pId);

            if (countryEcon == null) {
                continue;
            }

            String snapshotKey = analysisKey + '_' + pId;

            Province_Economy__c pe = new Province_Economy__c(
                Economy_Analysis__c = analysisId,
                Country_Economy__c = countryEcon.Id,
                Province__c = (masterProv != null) ? masterProv.Id : null,
                Population__c = prov.population,
                RGO_Production__c = prov.rgoProduction,
                Unique_Snapshot_Key__c = snapshotKey
            );
            records.add(pe);
        }

        return records;
    }

    private static Date parseIngameDate(String dateStr) {
        if (String.isBlank(dateStr)) {
            return Date.today();
        }
        try {
            return Date.valueOf(dateStr);
        } catch (Exception e) {
            List<String> parts = dateStr.split('-');
            if (parts.size() == 3) {
                return Date.newInstance(Integer.valueOf(parts[0].trim()), Integer.valueOf(parts[1].trim()), Integer.valueOf(parts[2].trim()));
            }
            return Date.today();
        }
    }
}
