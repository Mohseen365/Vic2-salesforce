/**
 * @description Transactional service layer for Economy_Analysis__c records and economic calculations.
 * Composes EconomyAnalysisSelector and EconomyCalculationEngine with strict FLS checks and bulkified DML.
 */
public with sharing class EconomyAnalysisService {

    /**
     * @description Recalculates derived fields for an entire analysis snapshot and persists changes in bulk.
     * @param analysisId Id of the Economy_Analysis__c record.
     */
    public static void recalculateAnalysis(Id analysisId) {
        if (analysisId == null) {
            return;
        }

        Economy_Analysis__c analysis = EconomyAnalysisSelector.selectById(analysisId);
        if (analysis == null) {
            return;
        }

        // Status transition: CALCULATING
        if (Schema.sObjectType.Economy_Analysis__c.fields.Import_Status__c.isUpdateable()) {
            analysis.Import_Status__c = 'CALCULATING';
            if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                update new Economy_Analysis__c(
                    Id = analysis.Id,
                    Import_Status__c = 'CALCULATING'
                );
                EconomyImportService.publishImportEvent(analysis.Id, 'CALCULATING', null, null);
            }
        }

        // 1. Select Product Economies & Map
        List<Product_Economy__c> productEconomies = EconomyAnalysisSelector.selectProductEconomies(analysisId);
        Map<Id, Product_Economy__c> prodMap = new Map<Id, Product_Economy__c>(productEconomies);

        // 2. Select Junctions & Calculate Storage Contributions
        List<Country_Product_Economy__c> allJunctions = EconomyAnalysisSelector.selectCountryProductEconomiesByAnalysis(analysisId);
        EconomyCalculationEngine.calculateProductStorageContributions(allJunctions, prodMap);

        // 3. Group Junctions by Country_Economy__c Id
        Map<Id, List<Country_Product_Economy__c>> junctionsByCountryId = new Map<Id, List<Country_Product_Economy__c>>();
        for (Country_Product_Economy__c j : allJunctions) {
            if (j.Country_Economy__c != null) {
                if (!junctionsByCountryId.containsKey(j.Country_Economy__c)) {
                    junctionsByCountryId.put(j.Country_Economy__c, new List<Country_Product_Economy__c>());
                }
                junctionsByCountryId.get(j.Country_Economy__c).add(j);
            }
        }

        // 4. Select Countries & Calculate Country Totals & Assign Ranks
        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(analysisId);
        EconomyCalculationEngine.calculateCountryTotals(countries, junctionsByCountryId);
        EconomyCalculationEngine.assignGdpRanks(countries);

        // 5. Calculate Analysis Totals
        EconomyCalculationEngine.calculateAnalysisTotals(analysis, countries);

        // Status transition: COMPLETED
        if (Schema.sObjectType.Economy_Analysis__c.fields.Import_Status__c.isUpdateable()) {
            analysis.Import_Status__c = 'COMPLETED';
        }

        // 6. Bulk DML Updates with Clean SObjects (stripping relationship fields to avoid SObjectException)
        if (!allJunctions.isEmpty() && Schema.sObjectType.Country_Product_Economy__c.isUpdateable()) {
            List<Country_Product_Economy__c> junctionsToUpdate = new List<Country_Product_Economy__c>();
            for (Country_Product_Economy__c j : allJunctions) {
                if (j.Id != null) {
                    junctionsToUpdate.add(new Country_Product_Economy__c(
                        Id = j.Id,
                        Total_Supply_Pounds__c = j.Total_Supply_Pounds__c,
                        Actual_Supply_Pounds__c = j.Actual_Supply_Pounds__c,
                        Actual_Demand_Pounds__c = j.Actual_Demand_Pounds__c,
                        Domestic_Sales_Value__c = j.Domestic_Sales_Value__c,
                        Import_Value__c = j.Import_Value__c,
                        Export_Value__c = j.Export_Value__c,
                        GDP_Contribution__c = j.GDP_Contribution__c
                    ));
                }
            }
            if (!junctionsToUpdate.isEmpty()) {
                update junctionsToUpdate;
            }
        }

        if (!countries.isEmpty() && Schema.sObjectType.Country_Economy__c.isUpdateable()) {
            List<Country_Economy__c> countriesToUpdate = new List<Country_Economy__c>();
            for (Country_Economy__c c : countries) {
                if (c.Id != null) {
                    countriesToUpdate.add(new Country_Economy__c(
                        Id = c.Id,
                        GDP__c = c.GDP__c,
                        GDP_Rank__c = c.GDP_Rank__c
                    ));
                }
            }
            if (!countriesToUpdate.isEmpty()) {
                update countriesToUpdate;
            }
        }

        if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
            update new Economy_Analysis__c(
                Id = analysis.Id,
                Total_World_Imports__c = analysis.Total_World_Imports__c,
                Total_World_Exports__c = analysis.Total_World_Exports__c,
                Import_Status__c = 'COMPLETED'
            );
            EconomyImportService.publishImportEvent(analysis.Id, 'COMPLETED', null, null);
        }

        // Evaluate and publish Layer 4 real-time anomaly alerts
        try {
            DerivedIntelligenceEngine.evaluateAndPublishAnomalies(analysisId, null);
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'Anomaly evaluation warning: ' + ex.getMessage());
        }
    }

    /**
     * @description Retrieves header summary DTO for a single Economy_Analysis__c record.
     * @param analysisId Id of the analysis record.
     * @return AnalysisSummaryDTO or null.
     */
    public static AnalysisSummaryDTO getAnalysisSummary(Id analysisId) {
        Economy_Analysis__c ea = EconomyAnalysisSelector.selectById(analysisId);
        return (ea != null) ? new AnalysisSummaryDTO(ea) : null;
    }

    /**
     * @description Retrieves country summary DTO for a specific country in an analysis.
     * @param analysisId Parent analysis Id.
     * @param countryEconomyId Target Country_Economy__c Id.
     * @return CountrySummaryDTO or null.
     */
    public static CountrySummaryDTO getCountrySummary(Id analysisId, Id countryEconomyId) {
        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(analysisId);
        for (Country_Economy__c ce : countries) {
            if (ce.Id == countryEconomyId) {
                return new CountrySummaryDTO(ce);
            }
        }
        return null;
    }

    /**
     * @description Retrieves country summary DTOs for all countries in an analysis.
     * @param analysisId Parent analysis Id.
     * @return List of CountrySummaryDTO.
     */
    public static List<CountrySummaryDTO> getCountrySummaries(Id analysisId) {
        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(analysisId);
        List<CountrySummaryDTO> dtos = new List<CountrySummaryDTO>();
        for (Country_Economy__c ce : countries) {
            dtos.add(new CountrySummaryDTO(ce));
        }
        return dtos;
    }

    /**
     * @description Retrieves country-product junction summary DTOs for a specific product snapshot.
     * @param productEconomyId Parent Product_Economy__c Id.
     * @return List of CountryProductSummaryDTO.
     */
    public static List<CountryProductSummaryDTO> getCountryProductSummariesByProduct(Id productEconomyId) {
        List<Country_Product_Economy__c> junctions = EconomyAnalysisSelector.selectCountryProductEconomiesByProduct(productEconomyId);
        List<CountryProductSummaryDTO> dtos = new List<CountryProductSummaryDTO>();
        for (Country_Product_Economy__c cpe : junctions) {
            dtos.add(new CountryProductSummaryDTO(cpe));
        }
        return dtos;
    }

    /**
     * @description Retrieves product summary DTO for a specific commodity in an analysis.
     * @param analysisId Parent analysis Id.
     * @param productEconomyId Target Product_Economy__c Id.
     * @return ProductSummaryDTO or null.
     */
    public static ProductSummaryDTO getProductSummary(Id analysisId, Id productEconomyId) {
        List<Product_Economy__c> products = EconomyAnalysisSelector.selectProductEconomies(analysisId);
        for (Product_Economy__c pe : products) {
            if (pe.Id == productEconomyId) {
                return new ProductSummaryDTO(pe);
            }
        }
        return null;
    }

    /**
     * @description Retrieves product summary DTOs for all commodities in an analysis.
     * @param analysisId Parent analysis Id.
     * @return List of ProductSummaryDTO.
     */
    public static List<ProductSummaryDTO> getProductSummaries(Id analysisId) {
        List<Product_Economy__c> products = EconomyAnalysisSelector.selectProductEconomies(analysisId);
        List<ProductSummaryDTO> dtos = new List<ProductSummaryDTO>();
        for (Product_Economy__c pe : products) {
            dtos.add(new ProductSummaryDTO(pe));
        }
        return dtos;
    }

    /**
     * @description Retrieves country-product junction summary DTOs for a specific country snapshot.
     * @param countryEconomyId Parent Country_Economy__c Id.
     * @return List of CountryProductSummaryDTO.
     */
    public static List<CountryProductSummaryDTO> getCountryProductSummaries(Id countryEconomyId) {
        List<Country_Product_Economy__c> junctions = EconomyAnalysisSelector.selectCountryProductEconomies(countryEconomyId);
        List<CountryProductSummaryDTO> dtos = new List<CountryProductSummaryDTO>();
        for (Country_Product_Economy__c cpe : junctions) {
            dtos.add(new CountryProductSummaryDTO(cpe));
        }
        return dtos;
    }

    /**
     * @description Retrieves state summary DTOs for all regional states in an analysis.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of StateSummaryDTO.
     */
    public static List<StateSummaryDTO> getStateSummaries(Id analysisId) {
        List<State_Economy__c> states = EconomyAnalysisSelector.selectStateEconomies(analysisId);
        List<StateSummaryDTO> dtos = new List<StateSummaryDTO>();
        for (State_Economy__c se : states) {
            dtos.add(new StateSummaryDTO(se));
        }
        return dtos;
    }

    /**
     * @description Retrieves factory summary DTOs for all factories in a state snapshot.
     * @param stateEconomyId Parent State_Economy__c Id.
     * @return List of FactorySummaryDTO.
     */
    public static List<FactorySummaryDTO> getFactorySummaries(Id stateEconomyId) {
        List<Factory_Economy__c> factories = EconomyAnalysisSelector.selectFactoryEconomies(stateEconomyId);
        List<FactorySummaryDTO> dtos = new List<FactorySummaryDTO>();
        for (Factory_Economy__c fe : factories) {
            dtos.add(new FactorySummaryDTO(fe));
        }
        return dtos;
    }

    /**
     * @description Retrieves artisan summary DTOs for all artisans in a province snapshot.
     * @param provinceEconomyId Parent Province_Economy__c Id.
     * @return List of ArtisanSummaryDTO.
     */
    public static List<ArtisanSummaryDTO> getArtisanSummaries(Id provinceEconomyId) {
        List<Artisan_Economy__c> artisans = EconomyAnalysisSelector.selectArtisanEconomies(provinceEconomyId);
        List<ArtisanSummaryDTO> dtos = new List<ArtisanSummaryDTO>();
        for (Artisan_Economy__c ae : artisans) {
            dtos.add(new ArtisanSummaryDTO(ae));
        }
        return dtos;
    }

    /**
     * @description Compares two analysis snapshots (base vs compare) and computes GDP and price deltas.
     * @param baseAnalysisId Base Economy_Analysis__c Id.
     * @param compareAnalysisId Compare Economy_Analysis__c Id.
     * @return AnalysisComparisonDTO containing growth percentages and per-country/product deltas.
     */
    public static AnalysisComparisonDTO compareAnalyses(Id baseAnalysisId, Id compareAnalysisId) {
        AnalysisComparisonDTO comparison = new AnalysisComparisonDTO();
        comparison.baseAnalysisId = baseAnalysisId;
        comparison.compareAnalysisId = compareAnalysisId;

        Economy_Analysis__c baseAnalysis = EconomyAnalysisSelector.selectById(baseAnalysisId);
        Economy_Analysis__c compareAnalysis = EconomyAnalysisSelector.selectById(compareAnalysisId);

        Decimal baseGdp = (baseAnalysis != null && baseAnalysis.Total_World_GDP__c != null) ? baseAnalysis.Total_World_GDP__c : 0.0;
        Decimal compareGdp = (compareAnalysis != null && compareAnalysis.Total_World_GDP__c != null) ? compareAnalysis.Total_World_GDP__c : 0.0;

        comparison.baseGdp = baseGdp;
        comparison.compareGdp = compareGdp;
        Decimal gdpDelta = compareGdp - baseGdp;
        comparison.gdpGrowthPercent = EconomyCalculationEngine.safeDivide(gdpDelta, baseGdp, 0.0) * 100.0;

        // Country Deltas
        List<Country_Economy__c> baseCountries = EconomyAnalysisSelector.selectCountryEconomies(baseAnalysisId);
        List<Country_Economy__c> compareCountries = EconomyAnalysisSelector.selectCountryEconomies(compareAnalysisId);

        Map<String, Decimal> baseCountryGdpMap = new Map<String, Decimal>();
        for (Country_Economy__c c : baseCountries) {
            if (c.Country_Tag__c != null) {
                baseCountryGdpMap.put(c.Country_Tag__c, (c.GDP__c != null) ? c.GDP__c : 0.0);
            }
        }

        for (Country_Economy__c c : compareCountries) {
            if (c.Country_Tag__c != null) {
                Decimal baseCountryGdp = baseCountryGdpMap.containsKey(c.Country_Tag__c) ? baseCountryGdpMap.get(c.Country_Tag__c) : 0.0;
                Decimal compCountryGdp = (c.GDP__c != null) ? c.GDP__c : 0.0;
                Decimal cDelta = compCountryGdp - baseCountryGdp;

                AnalysisComparisonDTO.CountryDelta cd = new AnalysisComparisonDTO.CountryDelta();
                cd.countryTag = c.Country_Tag__c;
                cd.baseGdp = baseCountryGdp;
                cd.compareGdp = compCountryGdp;
                cd.gdpDelta = cDelta;
                cd.gdpGrowthPercent = EconomyCalculationEngine.safeDivide(cDelta, baseCountryGdp, 0.0) * 100.0;
                comparison.countryDeltas.add(cd);
            }
        }

        // Product Deltas
        List<Product_Economy__c> baseProducts = EconomyAnalysisSelector.selectProductEconomies(baseAnalysisId);
        List<Product_Economy__c> compareProducts = EconomyAnalysisSelector.selectProductEconomies(compareAnalysisId);

        Map<String, Decimal> baseProductPriceMap = new Map<String, Decimal>();
        for (Product_Economy__c p : baseProducts) {
            if (p.Product_Code__c != null) {
                baseProductPriceMap.put(p.Product_Code__c, (p.Price__c != null) ? p.Price__c : 0.0);
            }
        }

        for (Product_Economy__c p : compareProducts) {
            if (p.Product_Code__c != null) {
                Decimal baseProdPrice = baseProductPriceMap.containsKey(p.Product_Code__c) ? baseProductPriceMap.get(p.Product_Code__c) : 0.0;
                Decimal compProdPrice = (p.Price__c != null) ? p.Price__c : 0.0;
                Decimal pDelta = compProdPrice - baseProdPrice;

                AnalysisComparisonDTO.ProductDelta pd = new AnalysisComparisonDTO.ProductDelta();
                pd.productCode = p.Product_Code__c;
                pd.basePrice = baseProdPrice;
                pd.comparePrice = compProdPrice;
                pd.priceDelta = pDelta;
                pd.priceGrowthPercent = EconomyCalculationEngine.safeDivide(pDelta, baseProdPrice, 0.0) * 100.0;
                comparison.productDeltas.add(pd);
            }
        }

        return comparison;
    }

    /**
     * @description Retrieves multi-save world trend time series analysis DTO.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param analysisIds List of Economy_Analysis__c Ids (capped at 12).
     * @return WorldTrendDTO.
     */
    public static WorldTrendDTO getWorldTrend(List<Id> analysisIds) {
        WorldTrendDTO dto = new WorldTrendDTO();
        if (analysisIds == null || analysisIds.isEmpty()) {
            return dto;
        }

        List<Economy_Analysis__c> records = EconomyAnalysisSelector.selectWorldTrend(analysisIds);
        for (Economy_Analysis__c ea : records) {
            WorldTrendDTO.TrendPointDTO pt = new WorldTrendDTO.TrendPointDTO();
            pt.analysisId = ea.Id;
            pt.saveFileName = ea.Save_File_Name__c;
            pt.ingameDate = ea.Ingame_Date__c;
            pt.totalWorldGdp = (ea.Total_World_GDP__c != null) ? ea.Total_World_GDP__c : 0.0;
            pt.totalWorldPopulation = (ea.Total_World_Population__c != null) ? ea.Total_World_Population__c : 0;
            pt.totalWorldImports = (ea.Total_World_Imports__c != null) ? ea.Total_World_Imports__c : 0.0;
            pt.totalWorldExports = (ea.Total_World_Exports__c != null) ? ea.Total_World_Exports__c : 0.0;
            dto.points.add(pt);
        }

        return dto;
    }

    /**
     * @description Retrieves multi-save country trend time series analysis DTO.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param countryTags Set of country tags to filter by (optional).
     * @param analysisIds List of Economy_Analysis__c Ids (capped at 12).
     * @return CountryTrendDTO.
     */
    public static CountryTrendDTO getCountryTrend(Set<String> countryTags, List<Id> analysisIds) {
        CountryTrendDTO dto = new CountryTrendDTO();
        if (analysisIds == null || analysisIds.isEmpty()) {
            return dto;
        }

        List<Country_Economy__c> records = EconomyAnalysisSelector.selectCountryTrend(countryTags, analysisIds);
        Map<String, CountryTrendDTO.CountryTrendSeriesDTO> seriesMap = new Map<String, CountryTrendDTO.CountryTrendSeriesDTO>();

        for (Country_Economy__c ce : records) {
            String tag = ce.Country_Tag__c;
            if (String.isBlank(tag)) {
                continue;
            }

            if (!seriesMap.containsKey(tag)) {
                CountryTrendDTO.CountryTrendSeriesDTO series = new CountryTrendDTO.CountryTrendSeriesDTO();
                series.countryTag = tag;
                series.countryName = (ce.Country__r != null && String.isNotBlank(ce.Country__r.Name)) ? ce.Country__r.Name : tag;
                seriesMap.put(tag, series);
            }

            CountryTrendDTO.TrendPointDTO pt = new CountryTrendDTO.TrendPointDTO();
            pt.analysisId = ce.Economy_Analysis__c;
            pt.ingameDate = (ce.Economy_Analysis__r != null) ? ce.Economy_Analysis__r.Ingame_Date__c : null;
            pt.gdp = (ce.GDP__c != null) ? ce.GDP__c : 0.0;
            pt.gdpPerCapita = (ce.GDP_Per_Capita__c != null) ? ce.GDP_Per_Capita__c : 0.0;
            pt.gdpRank = (ce.GDP_Rank__c != null) ? ce.GDP_Rank__c.intValue() : 0;
            pt.imports = (ce.Total_Imports_Value__c != null) ? ce.Total_Imports_Value__c : 0.0;
            pt.exports = (ce.Total_Exports_Value__c != null) ? ce.Total_Exports_Value__c : 0.0;

            seriesMap.get(tag).points.add(pt);
        }

        dto.series.addAll(seriesMap.values());
        return dto;
    }

    /**
     * @description Retrieves multi-save product trend time series analysis DTO.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param productCodes Set of product codes to filter by (optional).
     * @param analysisIds List of Economy_Analysis__c Ids (capped at 12).
     * @return ProductTrendDTO.
     */
    public static ProductTrendDTO getProductTrend(Set<String> productCodes, List<Id> analysisIds) {
        ProductTrendDTO dto = new ProductTrendDTO();
        if (analysisIds == null || analysisIds.isEmpty()) {
            return dto;
        }

        List<Product_Economy__c> records = EconomyAnalysisSelector.selectProductTrend(productCodes, analysisIds);
        Map<String, ProductTrendDTO.ProductTrendSeriesDTO> seriesMap = new Map<String, ProductTrendDTO.ProductTrendSeriesDTO>();

        for (Product_Economy__c pe : records) {
            String code = pe.Product_Code__c;
            if (String.isBlank(code)) {
                continue;
            }

            if (!seriesMap.containsKey(code)) {
                ProductTrendDTO.ProductTrendSeriesDTO series = new ProductTrendDTO.ProductTrendSeriesDTO();
                series.productCode = code;
                series.productName = code;
                seriesMap.put(code, series);
            }

            ProductTrendDTO.TrendPointDTO pt = new ProductTrendDTO.TrendPointDTO();
            pt.analysisId = pe.Economy_Analysis__c;
            pt.ingameDate = (pe.Economy_Analysis__r != null) ? pe.Economy_Analysis__r.Ingame_Date__c : null;
            pt.price = (pe.Price__c != null) ? pe.Price__c : 0.0;
            pt.totalWorldSupply = (pe.Total_World_Supply__c != null) ? pe.Total_World_Supply__c : 0.0;
            pt.realDemand = (pe.Real_Demand__c != null) ? pe.Real_Demand__c : 0.0;
            pt.inflationPercent = (pe.Inflation_Percent__c != null) ? pe.Inflation_Percent__c : 0.0;
            pt.overproductionPercent = (pe.Overproduction_Percent__c != null) ? pe.Overproduction_Percent__c : 0.0;

            seriesMap.get(code).points.add(pt);
        }

        dto.series.addAll(seriesMap.values());
        return dto;
    }
}
