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
}
