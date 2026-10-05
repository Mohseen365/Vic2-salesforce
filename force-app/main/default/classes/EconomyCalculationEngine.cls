/**
 * @description Pure-function domain calculation engine for Victoria 2 Economy Analyzer.
 * Computes derived Apex-written fields for Country_Product_Economy__c, Country_Economy__c,
 * and Economy_Analysis__c records without SOQL or DML side effects.
 */
public with sharing class EconomyCalculationEngine {

    /**
     * @description Inner comparator class for sorting Country_Economy__c records deterministically.
     * Primary Sort: GDP__c descending.
     * Tie-breaker: Country_Tag__c ascending.
     */
    public class CountryGdpComparator implements Comparable {
        public Country_Economy__c country;

        public CountryGdpComparator(Country_Economy__c country) {
            this.country = country;
        }

        public Integer compareTo(Object compareTo) {
            CountryGdpComparator other = (CountryGdpComparator) compareTo;
            Decimal thisGdp = (this.country != null && this.country.GDP__c != null) ? this.country.GDP__c : 0.0;
            Decimal otherGdp = (other.country != null && other.country.GDP__c != null) ? other.country.GDP__c : 0.0;

            if (thisGdp > otherGdp) {
                return -1; // Descending order
            } else if (thisGdp < otherGdp) {
                return 1;
            } else {
                // Tie-breaker: Country_Tag__c ascending
                String thisTag = (this.country != null && this.country.Country_Tag__c != null) ? this.country.Country_Tag__c : '';
                String otherTag = (other.country != null && other.country.Country_Tag__c != null) ? other.country.Country_Tag__c : '';
                return thisTag.compareTo(otherTag);
            }
        }
    }

    /**
     * @description Computes trade, supply/demand monetary values, and GDP contribution for each junction record.
     * @param junctions List of Country_Product_Economy__c records to compute.
     * @param productEconomyById Map of parent Product_Economy__c records by Id.
     */
    public static void calculateProductStorageContributions(
        List<Country_Product_Economy__c> junctions,
        Map<Id, Product_Economy__c> productEconomyById
    ) {
        if (junctions == null || junctions.isEmpty()) {
            return;
        }

        for (Country_Product_Economy__c junction : junctions) {
            Product_Economy__c prodEcon = null;
            if (productEconomyById != null && junction.Product_Economy__c != null) {
                prodEcon = productEconomyById.get(junction.Product_Economy__c);
            }

            Decimal price = 0.0;
            if (prodEcon != null && prodEcon.Price__c != null) {
                price = prodEcon.Price__c;
            }

            String productCode = junction.Product_Code__c;
            if (String.isBlank(productCode) && prodEcon != null) {
                productCode = prodEcon.Product_Code__c;
            }

            Boolean isPreciousMetal = (productCode != null && productCode.trim().equalsIgnoreCase('precious_metal'));

            Decimal soldDomestic = (junction.Sold_Domestic__c != null) ? junction.Sold_Domestic__c : 0.0;
            Decimal boughtQty = (junction.Bought_Quantity__c != null) ? junction.Bought_Quantity__c : 0.0;
            Decimal thrownToMarket = (junction.Thrown_To_Market__c != null) ? junction.Thrown_To_Market__c : 0.0;
            Decimal actualSoldWorld = (junction.Actual_Sold_World__c != null) ? junction.Actual_Sold_World__c : 0.0;
            Decimal worldmarketPool = (junction.Worldmarket_Pool__c != null) ? junction.Worldmarket_Pool__c : 0.0;
            Decimal intermediateConsumption = (junction.Intermediate_Consumption__c != null) ? junction.Intermediate_Consumption__c : 0.0;

            Decimal totalSupplyQty = soldDomestic + thrownToMarket;

            Decimal soldUnits = 0.0;
            if (isPreciousMetal) {
                soldUnits = totalSupplyQty;
            } else if (thrownToMarket <= 0) {
                soldUnits = totalSupplyQty;
            } else if (worldmarketPool > 0) {
                soldUnits = soldDomestic + (thrownToMarket * actualSoldWorld / worldmarketPool);
            } else {
                soldUnits = soldDomestic;
            }

            Decimal totalPounds = totalSupplyQty * price;
            Decimal actualSupplyPounds = soldUnits * price;
            Decimal actualDemandPounds = boughtQty * price;
            Decimal domesticSalesValue = soldDomestic * price;
            Decimal importValue = Math.max(boughtQty - soldUnits, 0.0) * price;

            Decimal exportValue = 0.0;
            if (!isPreciousMetal) {
                exportValue = Math.max(soldUnits - boughtQty, 0.0) * price;
            }

            Decimal unclampedGdpUnits = soldUnits - intermediateConsumption;
            Decimal clampedGdpUnits = Math.max(unclampedGdpUnits, 0.0);
            Decimal gdpContribution = clampedGdpUnits * price;

            junction.Total_Supply_Pounds__c = totalPounds;
            junction.Actual_Supply_Pounds__c = actualSupplyPounds;
            junction.Actual_Demand_Pounds__c = actualDemandPounds;
            junction.Domestic_Sales_Value__c = domesticSalesValue;
            junction.Import_Value__c = importValue;
            junction.Export_Value__c = exportValue;
            junction.GDP_Contribution__c = gdpContribution;
        }
    }

    /**
     * @description Calculates country total GDP based on product GDP contributions and gold income.
     * Prevents double counting by checking if precious_metal junction is present in child junctions.
     * @param countries List of Country_Economy__c records to update.
     * @param junctionsByCountryId Map of child Country_Product_Economy__c records grouped by parent Country_Economy__c Id.
     */
    public static void calculateCountryTotals(
        List<Country_Economy__c> countries,
        Map<Id, List<Country_Product_Economy__c>> junctionsByCountryId
    ) {
        if (countries == null || countries.isEmpty()) {
            return;
        }

        for (Country_Economy__c country : countries) {
            Decimal sumGdp = 0.0;
            Boolean hasPreciousMetalJunction = false;
            Decimal goldIncome = (country.Gold_Income__c != null) ? country.Gold_Income__c : 0.0;

            List<Country_Product_Economy__c> junctions = null;
            if (junctionsByCountryId != null && country.Id != null) {
                junctions = junctionsByCountryId.get(country.Id);
            }

            if (junctions != null) {
                for (Country_Product_Economy__c j : junctions) {
                    if (j.GDP_Contribution__c != null) {
                        sumGdp += j.GDP_Contribution__c;
                    }
                    if (j.Product_Code__c != null && j.Product_Code__c.trim().equalsIgnoreCase('precious_metal')) {
                        hasPreciousMetalJunction = true;
                    }
                }
            }

            // If junctions contain precious_metal, its GDP contribution is already included in sumGdp.
            // If precious_metal junction is absent, add goldIncome directly.
            country.GDP__c = hasPreciousMetalJunction ? sumGdp : (sumGdp + goldIncome);
        }
    }

    /**
     * @description Sorts countries by GDP descending (with Country_Tag__c ascending tie-breaker) and assigns sequential GDP ranks.
     * @param countries List of Country_Economy__c records to rank.
     */
    public static void assignGdpRanks(List<Country_Economy__c> countries) {
        if (countries == null || countries.isEmpty()) {
            return;
        }

        List<CountryGdpComparator> wrappers = new List<CountryGdpComparator>();
        for (Country_Economy__c c : countries) {
            wrappers.add(new CountryGdpComparator(c));
        }

        wrappers.sort();

        Integer rank = 1;
        for (CountryGdpComparator w : wrappers) {
            w.country.GDP_Rank__c = rank++;
        }
    }

    /**
     * @description Computes top-level analysis world imports and world exports totals across countries.
     * @param analysis The parent Economy_Analysis__c record.
     * @param countries List of Country_Economy__c records in the analysis.
     */
    public static void calculateAnalysisTotals(Economy_Analysis__c analysis, List<Country_Economy__c> countries) {
        if (analysis == null) {
            return;
        }

        Decimal totalImports = 0.0;
        Decimal totalExports = 0.0;

        if (countries != null) {
            for (Country_Economy__c country : countries) {
                if (country.Total_Imports_Value__c != null) {
                    totalImports += country.Total_Imports_Value__c;
                }
                if (country.Total_Exports_Value__c != null) {
                    totalExports += country.Total_Exports_Value__c;
                }
            }
        }

        analysis.Total_World_Imports__c = totalImports;
        analysis.Total_World_Exports__c = totalExports;
    }

    /**
     * @description Utility helper to perform division with an explicit zero/null guard fallback.
     * @param numerator Numerator decimal.
     * @param denominator Denominator decimal.
     * @param fallback Default value if denominator is null or zero.
     * @return Safe division result or fallback.
     */
    public static Decimal safeDivide(Decimal numerator, Decimal denominator, Decimal fallback) {
        if (denominator == null || denominator == 0.0 || numerator == null) {
            return fallback;
        }
        return numerator / denominator;
    }
}
