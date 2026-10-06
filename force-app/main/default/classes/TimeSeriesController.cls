/**
 * @description Controller for multi-save time series comparisons and narrow long-format queries.
 * Capped by RSK-03 (max 12 snapshots per query) and RSK-14/15 (Guest user read-only safe).
 */
public with sharing class TimeSeriesController {

    private static final Integer MAX_SNAPSHOTS = 12;

    /**
     * @description Fetches narrow time series points for world or country or product metrics across up to 12 snapshots.
     * @param analysisIds List of Economy_Analysis__c IDs (capped at 12).
     * @param metricType Metric requested ('WORLD_GDP', 'WORLD_POPULATION', 'WORLD_IMPORTS', 'WORLD_EXPORTS', 'COUNTRY_GDP', 'COUNTRY_IMPORT', 'COUNTRY_EXPORT', 'PRODUCT_PRICE', 'PRODUCT_DEMAND', 'PRODUCT_SUPPLY').
     * @param targetKey Optional entity tag or code (e.g., 'EGY' for country, 'grain' for product).
     * @return List of NarrowMetricDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<NarrowMetricDTO> getNarrowTimeSeries(List<Id> analysisIds, String metricType, String targetKey) {
        List<NarrowMetricDTO> results = new List<NarrowMetricDTO>();
        if (analysisIds == null || analysisIds.isEmpty() || String.isBlank(metricType)) {
            return results;
        }

        List<Id> cappedAnalysisIds = new List<Id>();
        for (Integer i = 0; i < Math.min(analysisIds.size(), MAX_SNAPSHOTS); i++) {
            if (analysisIds[i] != null) {
                cappedAnalysisIds.add(analysisIds[i]);
            }
        }

        if (cappedAnalysisIds.isEmpty()) {
            return results;
        }

        String upperMetric = metricType.toUpperCase();

        if (upperMetric.startsWith('WORLD_')) {
            List<Economy_Analysis__c> analyses = EconomyAnalysisSelector.selectWorldTrend(cappedAnalysisIds);
            for (Economy_Analysis__c ea : analyses) {
                Decimal val = 0.0;
                if (upperMetric == 'WORLD_GDP') val = (ea.Total_World_GDP__c != null) ? ea.Total_World_GDP__c : 0.0;
                else if (upperMetric == 'WORLD_POPULATION') val = (ea.Total_World_Population__c != null) ? Decimal.valueOf(ea.Total_World_Population__c) : 0.0;
                else if (upperMetric == 'WORLD_IMPORTS') val = (ea.Total_World_Imports__c != null) ? ea.Total_World_Imports__c : 0.0;
                else if (upperMetric == 'WORLD_EXPORTS') val = (ea.Total_World_Exports__c != null) ? ea.Total_World_Exports__c : 0.0;

                results.add(new NarrowMetricDTO(metricType, ea.Id, ea.Ingame_Date__c, 'WORLD', val));
            }
        } else if (upperMetric.startsWith('COUNTRY_')) {
            Set<String> tagSet = (String.isNotBlank(targetKey)) ? new Set<String>{ targetKey } : new Set<String>();
            List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryTrend(tagSet, cappedAnalysisIds);

            for (Country_Economy__c ce : countries) {
                Decimal val = 0.0;
                if (upperMetric == 'COUNTRY_GDP') val = (ce.GDP__c != null) ? ce.GDP__c : 0.0;
                else if (upperMetric == 'COUNTRY_IMPORT') val = (ce.Total_Imports_Value__c != null) ? ce.Total_Imports_Value__c : 0.0;
                else if (upperMetric == 'COUNTRY_EXPORT') val = (ce.Total_Exports_Value__c != null) ? ce.Total_Exports_Value__c : 0.0;
                else if (upperMetric == 'COUNTRY_RANK') val = (ce.GDP_Rank__c != null) ? ce.GDP_Rank__c : 0.0;

                Date d = (ce.Economy_Analysis__r != null) ? ce.Economy_Analysis__r.Ingame_Date__c : null;
                results.add(new NarrowMetricDTO(metricType, ce.Economy_Analysis__c, d, ce.Country_Tag__c, val));
            }
        } else if (upperMetric.startsWith('PRODUCT_')) {
            Set<String> codeSet = (String.isNotBlank(targetKey)) ? new Set<String>{ targetKey } : new Set<String>();
            List<Product_Economy__c> products = EconomyAnalysisSelector.selectProductTrend(codeSet, cappedAnalysisIds);

            for (Product_Economy__c pe : products) {
                Decimal val = 0.0;
                if (upperMetric == 'PRODUCT_PRICE') val = (pe.Price__c != null) ? pe.Price__c : 0.0;
                else if (upperMetric == 'PRODUCT_DEMAND') val = (pe.Real_Demand__c != null) ? pe.Real_Demand__c : 0.0;
                else if (upperMetric == 'PRODUCT_SUPPLY') val = (pe.Total_World_Supply__c != null) ? pe.Total_World_Supply__c : 0.0;

                Date d = (pe.Economy_Analysis__r != null) ? pe.Economy_Analysis__r.Ingame_Date__c : null;
                results.add(new NarrowMetricDTO(metricType, pe.Economy_Analysis__c, d, pe.Product_Code__c, val));
            }
        }

        return results;
    }

    /**
     * @description Fetches event ticks (wars, reforms, crises, major events) associated with snapshots.
     * @param analysisIds List of Economy_Analysis__c IDs (capped at 12).
     * @return List of EventTickDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<NarrowMetricDTO.EventTickDTO> getEventTicks(List<Id> analysisIds) {
        List<NarrowMetricDTO.EventTickDTO> ticks = new List<NarrowMetricDTO.EventTickDTO>();
        if (analysisIds == null || analysisIds.isEmpty()) {
            return ticks;
        }

        List<Id> cappedAnalysisIds = new List<Id>();
        for (Integer i = 0; i < Math.min(analysisIds.size(), MAX_SNAPSHOTS); i++) {
            if (analysisIds[i] != null) {
                cappedAnalysisIds.add(analysisIds[i]);
            }
        }

        List<Economy_Analysis__c> analyses = EconomyAnalysisSelector.selectWorldTrend(cappedAnalysisIds);
        for (Economy_Analysis__c ea : analyses) {
            // Generate deterministic event ticks or query associated Save_Game / Diagnostic logs if present
            Date dt = ea.Ingame_Date__c;
            String name = ea.Save_File_Name__c;
            if (String.isNotBlank(name)) {
                if (name.containsIgnoreCase('war') || name.containsIgnoreCase('battle')) {
                    ticks.add(new NarrowMetricDTO.EventTickDTO(ea.Id, dt, 'WAR', 'Active Conflict', 'Major military engagement recorded in snapshot ' + name));
                } else if (name.containsIgnoreCase('reform') || name.containsIgnoreCase('law')) {
                    ticks.add(new NarrowMetricDTO.EventTickDTO(ea.Id, dt, 'REFORM', 'Political Reform Passed', 'Legislative reform enacted in snapshot ' + name));
                } else if (name.containsIgnoreCase('crisis') || name.containsIgnoreCase('rebel')) {
                    ticks.add(new NarrowMetricDTO.EventTickDTO(ea.Id, dt, 'CRISIS', 'Diplomatic / Domestic Crisis', 'Crisis event active in snapshot ' + name));
                }
            }
        }

        return ticks;
    }

    /**
     * @description Fetches head-to-head comparison summary between two snapshots / players.
     * @param baseSnapshotId Base snapshot ID.
     * @param compareSnapshotId Comparison snapshot ID.
     * @return Map<String, Object> containing side-by-side metric comparison.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getHeadToHeadComparison(Id baseSnapshotId, Id compareSnapshotId) {
        Map<String, Object> comparison = new Map<String, Object>();
        if (baseSnapshotId == null || compareSnapshotId == null) {
            return comparison;
        }

        Economy_Analysis__c base = EconomyAnalysisSelector.selectById(baseSnapshotId);
        Economy_Analysis__c comp = EconomyAnalysisSelector.selectById(compareSnapshotId);

        if (base == null || comp == null) {
            return comparison;
        }

        comparison.put('baseId', base.Id);
        comparison.put('baseName', base.Save_File_Name__c);
        comparison.put('baseDate', base.Ingame_Date__c);
        comparison.put('baseGdp', (base.Total_World_GDP__c != null) ? base.Total_World_GDP__c : 0.0);
        comparison.put('basePopulation', (base.Total_World_Population__c != null) ? base.Total_World_Population__c : 0);
        comparison.put('baseImports', (base.Total_World_Imports__c != null) ? base.Total_World_Imports__c : 0.0);
        comparison.put('baseExports', (base.Total_World_Exports__c != null) ? base.Total_World_Exports__c : 0.0);

        comparison.put('compareId', comp.Id);
        comparison.put('compareName', comp.Save_File_Name__c);
        comparison.put('compareDate', comp.Ingame_Date__c);
        comparison.put('compareGdp', (comp.Total_World_GDP__c != null) ? comp.Total_World_GDP__c : 0.0);
        comparison.put('comparePopulation', (comp.Total_World_Population__c != null) ? comp.Total_World_Population__c : 0);
        comparison.put('compareImports', (comp.Total_World_Imports__c != null) ? comp.Total_World_Imports__c : 0.0);
        comparison.put('compareExports', (comp.Total_World_Exports__c != null) ? comp.Total_World_Exports__c : 0.0);

        return comparison;
    }
}
