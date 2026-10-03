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
}
