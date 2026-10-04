@isTest
private class EconomyAnalysisServiceTest {

    @isTest
    static void testServiceWithNullInputs() {
        Test.startTest();
        EconomyAnalysisService.recalculateAnalysis(null);
        AnalysisSummaryDTO eaDto = EconomyAnalysisService.getAnalysisSummary(null);
        CountrySummaryDTO cDto = EconomyAnalysisService.getCountrySummary(null, null);
        List<CountrySummaryDTO> cDtos = EconomyAnalysisService.getCountrySummaries(null);
        ProductSummaryDTO pDto = EconomyAnalysisService.getProductSummary(null, null);
        List<ProductSummaryDTO> pDtos = EconomyAnalysisService.getProductSummaries(null);
        List<CountryProductSummaryDTO> cpeDtos = EconomyAnalysisService.getCountryProductSummaries(null);
        List<StateSummaryDTO> stDtos = EconomyAnalysisService.getStateSummaries(null);
        List<FactorySummaryDTO> fDtos = EconomyAnalysisService.getFactorySummaries(null);
        List<ArtisanSummaryDTO> aDtos = EconomyAnalysisService.getArtisanSummaries(null);
        AnalysisComparisonDTO cmpDto = EconomyAnalysisService.compareAnalyses(null, null);
        Test.stopTest();

        System.assertEquals(null, eaDto, 'Analysis summary should be null for null Id');
        System.assertEquals(null, cDto, 'Country summary should be null for null Ids');
        System.assertEquals(0, cDtos.size(), 'Country summaries list should be empty');
        System.assertEquals(null, pDto, 'Product summary should be null for null Ids');
        System.assertEquals(0, pDtos.size(), 'Product summaries list should be empty');
        System.assertEquals(0, cpeDtos.size(), 'Junction summaries list should be empty');
        System.assertEquals(0, stDtos.size(), 'State summaries list should be empty');
        System.assertEquals(0, fDtos.size(), 'Factory summaries list should be empty');
        System.assertEquals(0, aDtos.size(), 'Artisan summaries list should be empty');
        System.assertNotEquals(null, cmpDto, 'Comparison DTO should not be null');
        System.assertEquals(0.0, cmpDto.gdpGrowthPercent, 'Growth percent should be 0');
    }

    @isTest
    static void testRecalculateAnalysisAndReadServiceMethods() {
        // Insert Master Records
        Country__c masterCountry = new Country__c(
            Tag__c = 'ENG'
        );
        insert masterCountry;

        Product__c masterProduct = new Product__c(
            Code__c = 'grain',
            Base_Price__c = 10.0
        );
        insert masterProduct;

        State__c masterState = new State__c(
            State_Code__c = 'ENG_London',
            Name = 'London',
            Country__c = masterCountry.Id
        );
        insert masterState;

        Province__c masterProv = new Province__c(
            External_Province_Id__c = '101',
            Country__c = masterCountry.Id
        );
        insert masterProv;

        // Insert Base Analysis Header
        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Save_File_Name__c = 'england_1848.v2',
            Ingame_Date__c = Date.newInstance(1848, 1, 1),
            Import_Status__c = 'RECEIVED'
        );
        insert analysis;

        // Insert Country Economy Snapshot
        Country_Economy__c countrySnapshot = new Country_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country__c = masterCountry.Id,
            Country_Tag__c = 'ENG',
            Population__c = 1000000,
            Gold_Income__c = 50.0,
            Unique_Snapshot_Key__c = 'england_1848.v2_ENG'
        );
        insert countrySnapshot;

        // Insert Product Economy Snapshot
        Product_Economy__c productSnapshot = new Product_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Product__c = masterProduct.Id,
            Product_Code__c = 'grain',
            Price__c = 10.0,
            Base_Price__c = 10.0,
            Total_World_Supply__c = 100.0,
            Real_Demand__c = 80.0,
            Max_Demand__c = 100.0,
            Unique_Snapshot_Key__c = 'england_1848.v2_grain'
        );
        insert productSnapshot;

        // Insert State Economy Snapshot
        State_Economy__c stateSnapshot = new State_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country_Economy__c = countrySnapshot.Id,
            State__c = masterState.Id,
            Population__c = 500000,
            GDP__c = 50000.0,
            Unique_Snapshot_Key__c = 'england_1848.v2_ENG_London'
        );
        insert stateSnapshot;

        // Insert Province Economy Snapshot
        Province_Economy__c provinceSnapshot = new Province_Economy__c(
            Country_Economy__c = countrySnapshot.Id,
            Province__c = masterProv.Id,
            Population__c = 100000,
            RGO_Production__c = 50.0,
            Unique_Snapshot_Key__c = 'england_1848.v2_101'
        );
        insert provinceSnapshot;

        // Insert Factory Economy Snapshot
        Factory_Economy__c factorySnapshot = new Factory_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country_Economy__c = countrySnapshot.Id,
            State_Economy__c = stateSnapshot.Id,
            Product__c = masterProduct.Id,
            Building_Type__c = 'glass_factory',
            Employees__c = 1000,
            Profit__c = 500.0,
            Unique_Snapshot_Key__c = 'england_1848.v2_ENG_London_glass_factory_1'
        );
        insert factorySnapshot;

        // Insert Artisan Economy Snapshot
        Artisan_Economy__c artisanSnapshot = new Artisan_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country_Economy__c = countrySnapshot.Id,
            Province_Economy__c = provinceSnapshot.Id,
            State_Economy__c = stateSnapshot.Id,
            Product__c = masterProduct.Id,
            Artisan_Type__c = 'grain',
            AGDP__c = 200.0,
            Unique_Snapshot_Key__c = 'england_1848.v2_101_grain'
        );
        insert artisanSnapshot;

        // Insert Country Product Junction Snapshot
        Country_Product_Economy__c junction = new Country_Product_Economy__c(
            Country_Economy__c = countrySnapshot.Id,
            Product_Economy__c = productSnapshot.Id,
            Product__c = masterProduct.Id,
            Product_Code__c = 'grain',
            Sold_Domestic__c = 5.0,
            Bought_Quantity__c = 2.0,
            Thrown_To_Market__c = 10.0,
            Actual_Sold_World__c = 8.0,
            Worldmarket_Pool__c = 10.0,
            Intermediate_Consumption__c = 3.0,
            Unique_Snapshot_Key__c = 'england_1848.v2_ENG_grain'
        );
        insert junction;

        Test.startTest();
        EconomyAnalysisService.recalculateAnalysis(analysis.Id);

        AnalysisSummaryDTO analysisSummary = EconomyAnalysisService.getAnalysisSummary(analysis.Id);
        CountrySummaryDTO countrySummary = EconomyAnalysisService.getCountrySummary(analysis.Id, countrySnapshot.Id);
        List<CountrySummaryDTO> countrySummaries = EconomyAnalysisService.getCountrySummaries(analysis.Id);
        ProductSummaryDTO productSummary = EconomyAnalysisService.getProductSummary(analysis.Id, productSnapshot.Id);
        List<ProductSummaryDTO> productSummaries = EconomyAnalysisService.getProductSummaries(analysis.Id);
        List<CountryProductSummaryDTO> cpeSummaries = EconomyAnalysisService.getCountryProductSummaries(countrySnapshot.Id);
        List<CountryProductSummaryDTO> cpeByProd = EconomyAnalysisService.getCountryProductSummariesByProduct(productSnapshot.Id);
        List<StateSummaryDTO> stateSummaries = EconomyAnalysisService.getStateSummaries(analysis.Id);
        List<FactorySummaryDTO> factorySummaries = EconomyAnalysisService.getFactorySummaries(stateSnapshot.Id);
        List<ArtisanSummaryDTO> artisanSummaries = EconomyAnalysisService.getArtisanSummaries(provinceSnapshot.Id);
        Test.stopTest();

        // Verify Analysis
        System.assertEquals('COMPLETED', analysisSummary.importStatus, 'Import status should transition to COMPLETED');

        // Verify Junction calculation:
        System.assertEquals(1, cpeSummaries.size(), 'Junction summary count should be 1');
        System.assertEquals(100.0, cpeSummaries[0].gdpContribution, 'GDP contribution should be 100');
        System.assertEquals(1, cpeByProd.size(), 'Junction by product count should be 1');

        // Verify State, Factory, Artisan
        System.assertEquals(1, stateSummaries.size(), 'State summaries count should be 1');
        System.assertEquals(1, factorySummaries.size(), 'Factory summaries count should be 1');
        System.assertEquals(1, artisanSummaries.size(), 'Artisan summaries count should be 1');

        // Verify Country total GDP = 100 (junction) + 50 (gold) = 150
        System.assertEquals(1, countrySummaries.size(), 'Country summary count should be 1');
        System.assertEquals(150.0, countrySummary.gdp, 'Country total GDP should be 150');
        System.assertEquals(1, countrySummary.gdpRank, 'Country GDP rank should be 1');

        // Verify Product Summary
        System.assertEquals(1, productSummaries.size(), 'Product summary count should be 1');
        System.assertEquals('grain', productSummary.productCode, 'Product code should match');
    }

    @isTest
    static void testCompareAnalysesWithData() {
        // Base Analysis
        Economy_Analysis__c baseAnalysis = new Economy_Analysis__c(
            Save_File_Name__c = 'england_1840.v2',
            Ingame_Date__c = Date.newInstance(1840, 1, 1),
            Import_Status__c = 'COMPLETED'
        );
        insert baseAnalysis;

        Country_Economy__c baseCountry = new Country_Economy__c(
            Economy_Analysis__c = baseAnalysis.Id,
            Country_Tag__c = 'ENG',
            GDP__c = 100.0,
            Unique_Snapshot_Key__c = 'england_1840.v2_ENG'
        );
        insert baseCountry;

        Product_Economy__c baseProd = new Product_Economy__c(
            Economy_Analysis__c = baseAnalysis.Id,
            Product_Code__c = 'grain',
            Price__c = 10.0,
            Unique_Snapshot_Key__c = 'england_1840.v2_grain'
        );
        insert baseProd;

        // Compare Analysis
        Economy_Analysis__c compareAnalysis = new Economy_Analysis__c(
            Save_File_Name__c = 'england_1850.v2',
            Ingame_Date__c = Date.newInstance(1850, 1, 1),
            Import_Status__c = 'COMPLETED'
        );
        insert compareAnalysis;

        Country_Economy__c compareCountry = new Country_Economy__c(
            Economy_Analysis__c = compareAnalysis.Id,
            Country_Tag__c = 'ENG',
            GDP__c = 150.0,
            Unique_Snapshot_Key__c = 'england_1850.v2_ENG'
        );
        insert compareCountry;

        Product_Economy__c compareProd = new Product_Economy__c(
            Economy_Analysis__c = compareAnalysis.Id,
            Product_Code__c = 'grain',
            Price__c = 12.0,
            Unique_Snapshot_Key__c = 'england_1850.v2_grain'
        );
        insert compareProd;

        Test.startTest();
        AnalysisComparisonDTO comparison = EconomyAnalysisService.compareAnalyses(baseAnalysis.Id, compareAnalysis.Id);
        WorldTrendDTO wt = EconomyAnalysisService.getWorldTrend(new List<Id>{ baseAnalysis.Id, compareAnalysis.Id });
        CountryTrendDTO ct = EconomyAnalysisService.getCountryTrend(new Set<String>{ 'ENG' }, new List<Id>{ baseAnalysis.Id, compareAnalysis.Id });
        ProductTrendDTO pt = EconomyAnalysisService.getProductTrend(new Set<String>{ 'grain' }, new List<Id>{ baseAnalysis.Id, compareAnalysis.Id });
        Test.stopTest();

        System.assertEquals(baseAnalysis.Id, comparison.baseAnalysisId, 'Base Analysis Id should match');
        System.assertEquals(compareAnalysis.Id, comparison.compareAnalysisId, 'Compare Analysis Id should match');
        System.assertEquals(1, comparison.countryDeltas.size(), 'Country deltas count should be 1');
        System.assertEquals('ENG', comparison.countryDeltas[0].countryTag, 'Country tag should match');
        System.assertEquals(50.0, comparison.countryDeltas[0].gdpDelta, 'GDP delta should be 50');
        System.assertEquals(50.0, comparison.countryDeltas[0].gdpGrowthPercent, 'GDP growth percent should be 50%');

        System.assertEquals(2, wt.points.size());
        System.assertEquals(1, ct.series.size());
        System.assertEquals(1, pt.series.size());
    }
}
