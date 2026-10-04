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
     * @description Retrieves state summary DTOs for all regional states in an analysis.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of StateSummaryDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<StateSummaryDTO> getStateSummaries(Id analysisId) {
        if (analysisId == null) {
            return new List<StateSummaryDTO>();
        }
        return EconomyAnalysisService.getStateSummaries(analysisId);
    }

    /**
     * @description Retrieves factory summary DTOs for all factories in a state snapshot.
     * @param stateEconomyId Parent State_Economy__c Id.
     * @return List of FactorySummaryDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<FactorySummaryDTO> getFactorySummaries(Id stateEconomyId) {
        if (stateEconomyId == null) {
            return new List<FactorySummaryDTO>();
        }
        return EconomyAnalysisService.getFactorySummaries(stateEconomyId);
    }

    /**
     * @description Retrieves artisan summary DTOs for all artisans in a province snapshot.
     * @param provinceEconomyId Parent Province_Economy__c Id.
     * @return List of ArtisanSummaryDTO.
     */
    @AuraEnabled(cacheable=true)
    public static List<ArtisanSummaryDTO> getArtisanSummaries(Id provinceEconomyId) {
        if (provinceEconomyId == null) {
            return new List<ArtisanSummaryDTO>();
        }
        return EconomyAnalysisService.getArtisanSummaries(provinceEconomyId);
    }

    /**
     * @description Compares two analysis snapshots and returns structured delta DTO.
     * @param baseAnalysisId Baseline Economy_Analysis__c Id.
     * @param compareAnalysisId Comparison Economy_Analysis__c Id.
     * @return AnalysisComparisonDTO or null.
     */
    @AuraEnabled(cacheable=true)
    public static AnalysisComparisonDTO compareAnalyses(Id baseAnalysisId, Id compareAnalysisId) {
        if (baseAnalysisId == null || compareAnalysisId == null || baseAnalysisId == compareAnalysisId) {
            return null;
        }
        return EconomyAnalysisService.compareAnalyses(baseAnalysisId, compareAnalysisId);
    }

    /**
     * @description Retrieves multi-save world trend time series analysis DTO.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param analysisIds List of Economy_Analysis__c Ids (capped at 12).
     * @return WorldTrendDTO.
     */
    @AuraEnabled(cacheable=true)
    public static WorldTrendDTO getWorldTrend(List<Id> analysisIds) {
        if (analysisIds == null || analysisIds.isEmpty()) {
            return new WorldTrendDTO();
        }
        return EconomyAnalysisService.getWorldTrend(analysisIds);
    }

    /**
     * @description Retrieves multi-save country trend time series analysis DTO.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param countryTags List of country tags to filter by (optional).
     * @param analysisIds List of Economy_Analysis__c Ids (capped at 12).
     * @return CountryTrendDTO.
     */
    @AuraEnabled(cacheable=true)
    public static CountryTrendDTO getCountryTrend(List<String> countryTags, List<Id> analysisIds) {
        if (analysisIds == null || analysisIds.isEmpty()) {
            return new CountryTrendDTO();
        }
        Set<String> tagSet = (countryTags != null) ? new Set<String>(countryTags) : new Set<String>();
        return EconomyAnalysisService.getCountryTrend(tagSet, analysisIds);
    }

    /**
     * @description Retrieves multi-save product trend time series analysis DTO.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param productCodes List of product codes to filter by (optional).
     * @param analysisIds List of Economy_Analysis__c Ids (capped at 12).
     * @return ProductTrendDTO.
     */
    @AuraEnabled(cacheable=true)
    public static ProductTrendDTO getProductTrend(List<String> productCodes, List<Id> analysisIds) {
        if (analysisIds == null || analysisIds.isEmpty()) {
            return new ProductTrendDTO();
        }
        Set<String> codeSet = (productCodes != null) ? new Set<String>(productCodes) : new Set<String>();
        return EconomyAnalysisService.getProductTrend(codeSet, analysisIds);
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
        } else if (normalizedScope == 'goods') {
            List<ProductSummaryDTO> dtos = EconomyAnalysisService.getProductSummaries(analysisId);
            List<String> lines = new List<String>{ 'Good,Price' };
            for (ProductSummaryDTO p : dtos) {
                lines.add(String.format('{0},{1}', new List<Object>{
                    p.productCode != null ? p.productCode : '',
                    p.price != null ? String.valueOf(p.price.setScale(5)) : '0.00000'
                }));
            }
            return String.join(lines, '\n');
        } else if (normalizedScope == 'countries') {
            List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(analysisId);
            List<Country_Product_Economy__c> junctions = EconomyAnalysisSelector.selectCountryProductEconomiesByAnalysis(analysisId);

            Map<String, Decimal> unpivotMap = new Map<String, Decimal>();
            for (Country_Product_Economy__c j : junctions) {
                String tag = (j.Country_Economy__r != null && j.Country_Economy__r.Country_Tag__c != null) ? j.Country_Economy__r.Country_Tag__c : '';
                String code = j.Product_Code__c != null ? j.Product_Code__c : '';
                Decimal qty = j.Sold_Domestic__c != null ? j.Sold_Domestic__c : 0.0;
                if (String.isNotBlank(tag) && String.isNotBlank(code)) {
                    unpivotMap.put(tag + '_' + code, qty);
                }
            }

            List<String> goldenCommodities = new List<String>{
                'ammunition', 'small_arms', 'artillery', 'canned_food', 'barrels', 'aeroplanes',
                'cotton', 'dye', 'wool', 'silk', 'coal', 'sulphur', 'iron', 'timber', 'tropical_wood',
                'rubber', 'oil', 'precious_metal', 'precious_goods', 'steel', 'cement', 'machine_parts',
                'glass', 'fuel', 'fertilizer', 'explosives', 'clipper_convoy', 'steamer_convoy',
                'electric_gear', 'fabric', 'lumber', 'paper', 'cattle', 'fish', 'fruit', 'grain',
                'tobacco', 'tea', 'coffee', 'opium', 'automobiles', 'telephones', 'wine', 'liquor',
                'regular_clothes', 'luxury_clothes', 'furniture', 'luxury_furniture', 'radio'
            };

            List<String> headerCols = new List<String>{
                'Rank', 'ID', 'Name', 'Population', 'Colony_Population', 'Total_Population', 'FGDP', 'PGDP', 'AGDP', 'GDP', 'GDPperCapita'
            };
            headerCols.addAll(goldenCommodities);
            List<String> lines = new List<String>{ String.join(headerCols, ',') };

            for (Country_Economy__c c : countries) {
                String tag = c.Country_Tag__c != null ? c.Country_Tag__c : '';
                List<String> row = new List<String>{
                    c.GDP_Rank__c != null ? String.valueOf(c.GDP_Rank__c.intValue()) : '',
                    tag,
                    tag,
                    c.Core_Population__c != null ? String.valueOf(c.Core_Population__c.setScale(1)) : '0.0',
                    c.Colony_Population__c != null ? String.valueOf(c.Colony_Population__c.setScale(1)) : '0.0',
                    c.Population__c != null ? String.valueOf(c.Population__c.setScale(1)) : '0.0',
                    formatCurrency(c.Factory_GDP__c),
                    formatCurrency(c.Province_GDP__c),
                    formatCurrency(c.Artisan_GDP__c),
                    formatCurrency(c.GDP__c),
                    c.GDP_Per_Capita__c != null ? '$' + String.valueOf(c.GDP_Per_Capita__c.setScale(2)) : '$0.00'
                };

                for (String comm : goldenCommodities) {
                    String key = tag + '_' + comm;
                    Decimal val = unpivotMap.containsKey(key) ? unpivotMap.get(key) : 0.0;
                    row.add(String.valueOf(val.setScale(1)));
                }

                lines.add(String.join(row, ','));
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
            List<Province_Economy__c> provinces = EconomyAnalysisSelector.selectProvinceEconomiesByAnalysis(analysisId);
            List<String> lines = new List<String>{
                'ID,Provid,Name,Owner,Country,State,Colony,Pop,Goods_type,RGO_Production,Last_income,GDP,Last_Spending,Production_Income,AGDP'
            };
            for (Province_Economy__c pe : provinces) {
                String provId = pe.Province_r != null && pe.Province__r.External_Province_Id__c != null ? pe.Province__r.External_Province_Id__c : '';
                String name = pe.Province_r != null && pe.Province__r.Name != null ? pe.Province__r.Name : '';
                String tag = pe.Country_Economy__r != null && pe.Country_Economy__r.Country_Tag__c != null ? pe.Country_Economy__r.Country_Tag__c : '';
                lines.add(String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}', new List<Object>{
                    provId,
                    provId,
                    escapeCsv(name),
                    tag,
                    tag,
                    'blank',
                    pe.Colony__c != null && pe.Colony__c ? 'True' : 'False',
                    pe.Population__c != null ? String.valueOf(pe.Population__c.setScale(1)) : '0.0',
                    '',
                    pe.RGO_Production__c != null ? String.valueOf(pe.RGO_Production__c.setScale(6)) : '0.000000',
                    pe.RGO_Income__c != null ? String.valueOf(pe.RGO_Income__c.setScale(8)) : '0.00000000',
                    pe.RGO_GDP__c != null ? String.valueOf(pe.RGO_GDP__c.setScale(8)) : '0.00000000',
                    pe.Artisan_Spending__c != null ? String.valueOf(pe.Artisan_Spending__c.setScale(6)) : '0.000000',
                    pe.Artisan_Income__c != null ? String.valueOf(pe.Artisan_Income__c.setScale(6)) : '0.000000',
                    pe.Artisan_GDP__c != null ? String.valueOf(pe.Artisan_GDP__c.setScale(16)) : '0.0000000000000000'
                }));
            }
            return String.join(lines, '\n');
        } else if (normalizedScope == 'states') {
            List<State_Economy__c> states = EconomyAnalysisSelector.selectStateEconomies(analysisId);
            List<String> lines = new List<String>{
                'Rank,Name,Country,Population,GDP,GDP_PerCapita,RGO_Income,PGDP,AGDP,FGDP,Employees,Revenue,Profit'
            };
            for (State_Economy__c se : states) {
                String stateCode = se.State_r != null && se.State__r.State_Code__c != null ? se.State__r.State_Code__c : 'blank';
                String tag = se.Country_Economy__r != null && se.Country_Economy__r.Country_Tag__c != null ? se.Country_Economy__r.Country_Tag__c : '';
                lines.add(String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}', new List<Object>{
                    se.GDP_Rank__c != null ? String.valueOf(se.GDP_Rank__c.intValue()) : '',
                    escapeCsv(stateCode),
                    tag,
                    se.Population__c != null ? String.valueOf(se.Population__c.setScale(1)) : '0.0',
                    formatCurrency(se.GDP__c),
                    se.GDP_Per_Capita__c != null ? '$' + String.valueOf(se.GDP_Per_Capita__c.setScale(2)) : '$0.00',
                    formatCurrency(se.RGO_Income__c),
                    formatCurrency(se.PGDP__c),
                    formatCurrency(se.AGDP__c),
                    formatCurrency(se.FGDP__c),
                    se.Factory_Employees__c != null ? String.valueOf(se.Factory_Employees__c.intValue()) : '0',
                    formatCurrency(se.Factory_Revenue__c),
                    formatCurrency(se.Factory_Profit__c)
                }));
            }
            return String.join(lines, '\n');
        } else if (normalizedScope == 'factories' || normalizedScope == 'factory') {
            List<Factory_Economy__c> factories = EconomyAnalysisSelector.selectFactoryEconomiesByAnalysis(analysisId);
            List<String> lines = new List<String>{
                'Rank,State,Tag,Country,Building,Level,Employees,Produces,Leftover,Money,Revenue,Input Costs,Pops_paychecks,Profit,GDP,Productivity,AvgWage'
            };
            for (Factory_Economy__c fe : factories) {
                String stateCode = fe.State_Economy__r != null && fe.State_Economy__r.State__r != null && fe.State_Economy__r.State__r.State_Code__c != null ? fe.State_Economy__r.State__r.State_Code__c : '';
                String tag = fe.Country_Economy__r != null && fe.Country_Economy__r.Country_Tag__c != null ? fe.Country_Economy__r.Country_Tag__c : '';
                lines.add(String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16}', new List<Object>{
                    fe.Profit_Rank__c != null ? String.valueOf(fe.Profit_Rank__c.intValue()) : '',
                    escapeCsv(stateCode),
                    tag,
                    tag,
                    fe.Building_Type__c != null ? fe.Building_Type__c : '',
                    fe.Level__c != null ? String.valueOf(fe.Level__c.intValue()) : '1',
                    fe.Employees__c != null ? String.valueOf(fe.Employees__c.setScale(1)) : '0.0',
                    fe.Output_Quantity__c != null ? String.valueOf(fe.Output_Quantity__c.setScale(5)) : '0.00000',
                    fe.Unsold_Quantity__c != null ? String.valueOf(fe.Unsold_Quantity__c.setScale(5)) : '0.00000',
                    formatCurrency(fe.Capital_Reserves__c),
                    formatCurrency(fe.Revenue__c),
                    formatCurrency(fe.Input_Cost__c),
                    formatCurrency(fe.Wages_Paid__c),
                    formatCurrency(fe.Profit__c),
                    fe.Factory_GDP__c != null ? String.valueOf(fe.Factory_GDP__c.setScale(8)) : '0.00000000',
                    fe.Productivity__c != null ? String.valueOf(fe.Productivity__c.setScale(16)) : '0.0000000000000000',
                    fe.Average_Wage__c != null ? String.valueOf(fe.Average_Wage__c.setScale(16)) : '0.0000000000000000'
                }));
            }
            return String.join(lines, '\n');
        } else if (normalizedScope == 'artisans') {
            List<Artisan_Economy__c> artisans = EconomyAnalysisSelector.selectArtisanEconomiesByAnalysis(analysisId);
            List<String> lines = new List<String>{
                'ID,Provid,Name,Country,State,artisan_type,last_spending,production_income,AGDP,Production'
            };
            for (Artisan_Economy__c ae : artisans) {
                String provId = ae.Province_Economy__r != null && ae.Province_Economy__r.Province__r != null && ae.Province_Economy__r.Province__r.External_Province_Id__c != null ? ae.Province_Economy__r.Province__r.External_Province_Id__c : '';
                String name = ae.Province_Economy__r != null && ae.Province_Economy__r.Province__r != null && ae.Province_Economy__r.Province__r.Name != null ? ae.Province_Economy__r.Province__r.Name : '';
                String tag = ae.Country_Economy__r != null && ae.Country_Economy__r.Country_Tag__c != null ? ae.Country_Economy__r.Country_Tag__c : '';
                String stateCode = ae.State_Economy__r != null && ae.State_Economy__r.State__r != null && ae.State_Economy__r.State__r.State_Code__c != null ? ae.State_Economy__r.State__r.State_Code__c : 'blank';
                lines.add(String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}', new List<Object>{
                    provId,
                    provId,
                    escapeCsv(name),
                    tag,
                    escapeCsv(stateCode),
                    ae.Artisan_Type__c != null ? ae.Artisan_Type__c : '',
                    ae.Spending__c != null ? String.valueOf(ae.Spending__c.setScale(8)) : '0.00000000',
                    ae.Income__c != null ? String.valueOf(ae.Income__c.setScale(8)) : '0.00000000',
                    ae.AGDP__c != null ? String.valueOf(ae.AGDP__c.setScale(16)) : '0.0000000000000000',
                    ae.Production_Quantity__c != null ? String.valueOf(ae.Production_Quantity__c.setScale(16)) : '0.0000000000000000'
                }));
            }
            return String.join(lines, '\n');
        }

        return '';
    }

    private static String formatCurrency(Decimal val) {
        if (val == null) {
            return '$0.00';
        }
        Decimal scaled = val.setScale(2);
        String formatted = String.valueOf(Math.abs(scaled));
        return scaled < 0 ? '-$' + formatted : '$' + formatted;
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
