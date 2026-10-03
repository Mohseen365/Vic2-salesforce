/**
 * @description Lightning Controller Facade exposing cached read operations to LWC components.
 * Delegates directly to EconomyAnalysisService and EconomyAnalysisSelector without duplicating business logic.
 * Enforces `with sharing` and FLS compliance through underlying service and selector layers.
 */
public with sharing class EconomyAnalysisController {

    /**
     * @description Retrieves recent Economy_Analysis__c records for selection comboboxes.
     * @param limitCount Maximum records to return (defaults to 50 if null).
     * @return List of recent Economy_Analysis__c records.
     */
    @AuraEnabled(cacheable=true)
    public static List<Economy_Analysis__c> getRecentAnalyses(Integer limitCount) {
        return EconomyAnalysisSelector.selectAllRecent(limitCount);
    }

    /**
     * @description Retrieves header summary DTO for a specific analysis.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return AnalysisSummaryDTO or null.
     */
    @AuraEnabled(cacheable=true)
    public static AnalysisSummaryDTO getAnalysisSummary(Id analysisId) {
        if (analysisId == null) {
            return null;
        }
        return EconomyAnalysisService.getAnalysisSummary(analysisId);
    }

    /**
     * @description Retrieves country summary DTOs for all countries in an analysis.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of CountrySummaryDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<CountrySummaryDTO> getCountrySummaries(Id analysisId) {
        if (analysisId == null) {
            return new List<CountrySummaryDTO>();
        }
        return EconomyAnalysisService.getCountrySummaries(analysisId);
    }

    /**
     * @description Retrieves country summary DTO for a specific country snapshot.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @param countryEconomyId Target Country_Economy__c Id.
     * @return CountrySummaryDTO or null.
     */
    @AuraEnabled(cacheable=true)
    public static CountrySummaryDTO getCountrySummary(Id analysisId, Id countryEconomyId) {
        if (analysisId == null || countryEconomyId == null) {
            return null;
        }
        return EconomyAnalysisService.getCountrySummary(analysisId, countryEconomyId);
    }

    /**
     * @description Retrieves country-product trade breakdown DTOs for a country snapshot.
     * @param countryEconomyId Target Country_Economy__c Id.
     * @return List of CountryProductSummaryDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<CountryProductSummaryDTO> getCountryProductSummaries(Id countryEconomyId) {
        if (countryEconomyId == null) {
            return new List<CountryProductSummaryDTO>();
        }
        return EconomyAnalysisService.getCountryProductSummaries(countryEconomyId);
    }

    /**
     * @description Retrieves product summary DTOs for all commodities in an analysis.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of ProductSummaryDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<ProductSummaryDTO> getProductSummaries(Id analysisId) {
        if (analysisId == null) {
            return new List<ProductSummaryDTO>();
        }
        return EconomyAnalysisService.getProductSummaries(analysisId);
    }

    /**
     * @description Retrieves product summary DTO for a specific commodity snapshot.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @param productEconomyId Target Product_Economy__c Id.
     * @return ProductSummaryDTO or null.
     */
    @AuraEnabled(cacheable=true)
    public static ProductSummaryDTO getProductSummary(Id analysisId, Id productEconomyId) {
        if (analysisId == null || productEconomyId == null) {
            return null;
        }
        return EconomyAnalysisService.getProductSummary(analysisId, productEconomyId);
    }

    /**
     * @description Retrieves country-product trade breakdown DTOs for a specific product snapshot.
     * @param productEconomyId Target Product_Economy__c Id.
     * @return List of CountryProductSummaryDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<CountryProductSummaryDTO> getCountryProductSummariesByProduct(Id productEconomyId) {
        if (productEconomyId == null) {
            return new List<CountryProductSummaryDTO>();
        }
        return EconomyAnalysisService.getCountryProductSummariesByProduct(productEconomyId);
    }

    /**
     * @description Generates a CSV string for the specified analysis and scope.
     * Used as Apex fallback for high row-count datasets or server-side CSV generation.
     * @param analysisId Target Economy_Analysis__c Id.
     * @param scope Scope of export ('Summary', 'Countries', 'Products', 'CountryProducts', 'Provinces').
     * @return CSV formatted String.
     */
    @AuraEnabled
    public static String exportCsv(Id analysisId, String scope) {
        if (analysisId == null || String.isBlank(scope)) {
            return '';
        }

        String normalizedScope = scope.trim().toLowerCase();

        if (normalizedScope == 'summary') {
            AnalysisSummaryDTO summary = EconomyAnalysisService.getAnalysisSummary(analysisId);
            if (summary == null) return '';
            List<String> lines = new List<String>{
                'Analysis ID,Save File Name,Source File Name,Ingame Date,Player Country,Total World GDP (£),Total World Population,Total World Imports (£),Total World Exports (£),Import Status',
                String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}', new List<Object>{
                    summary.analysisId != null ? String.valueOf(summary.analysisId) : '',
                    escapeCsv(summary.saveFileName),
                    escapeCsv(summary.sourceSaveFileName),
                    summary.ingameDate != null ? String.valueOf(summary.ingameDate) : '',
                    summary.playerCountryTag != null ? summary.playerCountryTag : '',
                    summary.totalWorldGdp != null ? String.valueOf(summary.totalWorldGdp.setScale(2)) : '0.00',
                    summary.totalWorldPopulation != null ? String.valueOf(summary.totalWorldPopulation) : '0',
                    summary.totalWorldImports != null ? String.valueOf(summary.totalWorldImports.setScale(2)) : '0.00',
                    summary.totalWorldExports != null ? String.valueOf(summary.totalWorldExports.setScale(2)) : '0.00',
                    summary.importStatus != null ? summary.importStatus : ''
                })
            };
            return String.join(lines, '\n');
        } else if (normalizedScope == 'countries') {
            List<CountrySummaryDTO> dtos = EconomyAnalysisService.getCountrySummaries(analysisId);
            List<String> lines = new List<String>{
                'Tag,Official Name,GDP Rank,GDP (£),GDP Per Capita (£),GDP Share %,Population,Workforce,Employment,Unemployment Rate %,Total Imports (£),Total Exports (£),Gold Income (£)'
            };
            for (CountrySummaryDTO c : dtos) {
                lines.add(String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}', new List<Object>{
                    c.countryTag != null ? c.countryTag : '',
                    escapeCsv(c.countryName),
                    c.gdpRank != null ? String.valueOf(c.gdpRank) : '',
                    c.gdp != null ? String.valueOf(c.gdp.setScale(2)) : '0.00',
                    c.gdpPerCapita != null ? String.valueOf(c.gdpPerCapita.setScale(2)) : '0.00',
                    c.gdpShare != null ? String.valueOf(c.gdpShare.setScale(4)) : '0.0000',
                    c.population != null ? String.valueOf(c.population) : '0',
                    c.workforce != null ? String.valueOf(c.workforce) : '0',
                    c.employment != null ? String.valueOf(c.employment) : '0',
                    c.unemploymentRate != null ? String.valueOf(c.unemploymentRate.setScale(2)) : '0.00',
                    c.totalImports != null ? String.valueOf(c.totalImports.setScale(2)) : '0.00',
                    c.totalExports != null ? String.valueOf(c.totalExports.setScale(2)) : '0.00',
                    c.goldIncome != null ? String.valueOf(c.goldIncome.setScale(2)) : '0.00'
                }));
            }
            return String.join(lines, '\n');
        } else if (normalizedScope == 'products') {
            List<ProductSummaryDTO> dtos = EconomyAnalysisService.getProductSummaries(analysisId);
            List<String> lines = new List<String>{
                'Product Code,Product Name,Price (£),Base Price (£),Total World Supply,Real Demand,Max Demand,Inflation %,Overproduction %'
            };
            for (ProductSummaryDTO p : dtos) {
                lines.add(String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8}', new List<Object>{
                    p.productCode != null ? p.productCode : '',
                    escapeCsv(p.productName),
                    p.price != null ? String.valueOf(p.price.setScale(4)) : '0.0000',
                    p.basePrice != null ? String.valueOf(p.basePrice.setScale(4)) : '0.0000',
                    p.totalWorldSupply != null ? String.valueOf(p.totalWorldSupply.setScale(4)) : '0.0000',
                    p.realDemand != null ? String.valueOf(p.realDemand.setScale(4)) : '0.0000',
                    p.maxDemand != null ? String.valueOf(p.maxDemand.setScale(4)) : '0.0000',
                    p.inflationPercent != null ? String.valueOf(p.inflationPercent.setScale(2)) : '0.00',
                    p.overproductionPercent != null ? String.valueOf(p.overproductionPercent.setScale(2)) : '0.00'
                }));
            }
            return String.join(lines, '\n');
        } else if (normalizedScope == 'countryproducts') {
            List<Country_Product_Economy__c> junctions = EconomyAnalysisSelector.selectCountryProductEconomiesByAnalysis(analysisId);
            List<String> lines = new List<String>{
                'Country Tag,Product Code,Sold Domestic Qty,Bought Qty,Thrown To Market Qty,Actual Sold World Qty,Domestic Sales Value (£),Import Value (£),Export Value (£),GDP Contribution (£)'
            };
            for (Country_Product_Economy__c cp : junctions) {
                lines.add(String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}', new List<Object>{
                    cp.Country_Economy__r != null && cp.Country_Economy__r.Country_Tag__c != null ? cp.Country_Economy__r.Country_Tag__c : '',
                    cp.Product_Code__c != null ? cp.Product_Code__c : '',
                    cp.Sold_Domestic__c != null ? String.valueOf(cp.Sold_Domestic__c.setScale(4)) : '0.0000',
                    cp.Bought_Quantity__c != null ? String.valueOf(cp.Bought_Quantity__c.setScale(4)) : '0.0000',
                    cp.Thrown_To_Market__c != null ? String.valueOf(cp.Thrown_To_Market__c.setScale(4)) : '0.0000',
                    cp.Actual_Sold_World__c != null ? String.valueOf(cp.Actual_Sold_World__c.setScale(4)) : '0.0000',
                    cp.Domestic_Sales_Value__c != null ? String.valueOf(cp.Domestic_Sales_Value__c.setScale(2)) : '0.00',
                    cp.Import_Value__c != null ? String.valueOf(cp.Import_Value__c.setScale(2)) : '0.00',
                    cp.Export_Value__c != null ? String.valueOf(cp.Export_Value__c.setScale(2)) : '0.00',
                    cp.GDP_Contribution__c != null ? String.valueOf(cp.GDP_Contribution__c.setScale(2)) : '0.00'
                }));
            }
            return String.join(lines, '\n');
        } else if (normalizedScope == 'provinces') {
            List<Province_Economy__c> provinces = [
                SELECT Id, External_Province_Id__c, Country_Economy__r.Country_Tag__c, Population__c, RGO_Production__c
                FROM Province_Economy__c
                WHERE Country_Economy__r.Economy_Analysis__c = :analysisId
                WITH SECURITY_ENFORCED
                LIMIT 50000
            ];
            List<String> lines = new List<String>{
                'Province ID,Country Tag,Population,RGO Production'
            };
            for (Province_Economy__c pe : provinces) {
                lines.add(String.format('{0},{1},{2},{3}', new List<Object>{
                    pe.External_Province_Id__c != null ? pe.External_Province_Id__c : '',
                    pe.Country_Economy__r != null && pe.Country_Economy__r.Country_Tag__c != null ? pe.Country_Economy__r.Country_Tag__c : '',
                    pe.Population__c != null ? String.valueOf(pe.Population__c) : '0',
                    pe.RGO_Production__c != null ? String.valueOf(pe.RGO_Production__c.setScale(4)) : '0.0000'
                }));
            }
            return String.join(lines, '\n');
        }

        return '';
    }

    private static String escapeCsv(String val) {
        if (String.isBlank(val)) {
            return '';
        }
        if (val.contains('"') || val.contains(',') || val.contains('\n') || val.contains('\r')) {
            return '"' + val.replace('"', '""') + '"';
        }
        return val;
    }
}
