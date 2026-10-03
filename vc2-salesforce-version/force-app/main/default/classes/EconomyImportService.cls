/**
 * @description Service-layer entry point for inbound economy save-game imports.
 * Orchestrates analysis header creation, master-data resolution (Country, Product, Province),
 * snapshot child record upserts, and handoff to EconomyAnalysisService.recalculateAnalysis.
 */
public with sharing class EconomyImportService {

    public static final Integer BATCH_THRESHOLD = 2000;

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

        if (request == null || request.analysis == null || String.isBlank(request.analysis.saveGameName)) {
            response.success = false;
            response.importStatus = 'FAILED';
            response.errorMessage = 'Invalid payload: Analysis header and saveGameName are required.';
            return response;
        }

        Economy_Analysis__c analysisHeader = null;

        try {
            // 1. Resolve / Create Master Data (Audit Section Q Rules)
            Map<String, Country__c> masterCountryMap = resolveMasterCountries(request.countries);
            Map<String, Product__c> masterProductMap = resolveMasterProducts(request.products);
            Map<String, Province__c> masterProvinceMap = resolveMasterProvinces(request.provinces, masterCountryMap);

            response.recordCounts.put('countries', request.countries != null ? request.countries.size() : 0);
            response.recordCounts.put('products', request.products != null ? request.products.size() : 0);
            response.recordCounts.put('provinces', request.provinces != null ? request.provinces.size() : 0);

            // 2. Create / Upsert Economy_Analysis__c Header
            String analysisKey = request.analysis.saveGameName;
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

            // 5. Construct Country_Product_Economy__c & Province_Economy__c Child Records
            List<Country_Product_Economy__c> junctionRecords = buildCountryProductRecords(
                analysisKey,
                request.countryProducts,
                countryEconomyMap,
                productEconomyMap,
                masterProductMap
            );

            List<Province_Economy__c> provinceRecords = buildProvinceRecords(
                analysisKey,
                request.provinces,
                countryEconomyMap,
                masterProvinceMap
            );

            response.recordCounts.put('countryProducts', junctionRecords.size());

            Integer totalChildRecords = junctionRecords.size() + provinceRecords.size();

            if (forceBatch || totalChildRecords > BATCH_THRESHOLD) {
                // Asynchronous / Chunked execution via EconomyImportBatch
                EconomyImportBatch batchJob = new EconomyImportBatch(
                    analysisHeader.Id,
                    junctionRecords,
                    provinceRecords
                );
                Database.executeBatch(batchJob, 2000);

                response.importStatus = 'PROCESSING';
                response.success = true;
                return response;
            } else {
                // Synchronous insertion
                if (!junctionRecords.isEmpty() && Schema.sObjectType.Country_Product_Economy__c.isCreateable()) {
                    upsert junctionRecords Unique_Snapshot_Key__c;
                }

                if (!provinceRecords.isEmpty() && Schema.sObjectType.Province_Economy__c.isCreateable()) {
                    upsert provinceRecords Unique_Snapshot_Key__c;
                }

                // 6. Handoff to EconomyAnalysisService recalculateAnalysis
                EconomyAnalysisService.recalculateAnalysis(analysisHeader.Id);

                // Fetch final status
                Economy_Analysis__c finalAnalysis = EconomyAnalysisSelector.selectById(analysisHeader.Id);
                response.importStatus = (finalAnalysis != null) ? finalAnalysis.Import_Status__c : 'COMPLETED';
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
     * @description Resolves master Country__c records, creating missing tags dynamically per Audit Section Q.
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
     * @description Resolves master Product__c records, creating missing codes dynamically per Audit Section Q.
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
                helper.basePrice = p.basePrice != null ? p.basePrice : (p.price != null ? p.price : 1.0);
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
     * @description Resolves master Province__c records, creating missing external IDs dynamically per Audit Section Q.
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

        if (header == null) {
            header = new Economy_Analysis__c(
                Name = analysisDTO.saveGameName,
                Save_File_Name__c = analysisDTO.saveGameName,
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
                Workforce__c = c.workforce,
                Employment__c = c.employment,
                Gold_Income__c = c.goldIncome,
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
     * @description Constructs Province_Economy__c records ready for insertion.
     */
    private static List<Province_Economy__c> buildProvinceRecords(
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
