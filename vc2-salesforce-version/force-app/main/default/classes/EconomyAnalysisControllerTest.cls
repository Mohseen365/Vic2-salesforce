@IsTest
private class EconomyAnalysisControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create mock Economy_Analysis__c
        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Save_File_Name__c = 'prussia_1848.v2',
            Source_Save_File_Name__c = 'prussia_1848.v2',
            Ingame_Date__c = Date.newInstance(1848, 1, 1),
            Player_Country_Tag__c = 'PRU',
            Total_World_Exports__c = 1000.0,
            Total_World_Imports__c = 950.0,
            Import_Status__c = 'COMPLETED',
            Unique_Snapshot_Key__c = 'prussia_1848.v2'
        );
        insert analysis;

        // Create Master Country__c
        Country__c country = new Country__c(
            Tag__c = 'PRU'
        );
        insert country;

        // Create Master Product__c
        Product__c prod = new Product__c(
            Code__c = 'small_arms',
            Base_Price__c = 10.0
        );
        insert prod;

        // Create Master State__c
        State__c st = new State__c(
            State_Code__c = 'Silesia',
            Country__c = country.Id
        );
        insert st;

        // Create Master Province__c
        Province__c prov = new Province__c(
            External_Province_Id__c = '101',
            Country__c = country.Id
        );
        insert prov;

        // Create Country_Economy__c
        Country_Economy__c countryEco = new Country_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country__c = country.Id,
            Country_Tag__c = 'PRU',
            Population__c = 1000000,
            Core_Population__c = 900000,
            Colony_Population__c = 100000,
            Workforce__c = 250000,
            Employment__c = 240000,
            GDP__c = 500000.0,
            Factory_GDP__c = 200000.0,
            Province_GDP__c = 280000.0,
            Artisan_GDP__c = 20000.0,
            GDP_Rank__c = 1,
            Gold_Income__c = 50.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_PRU'
        );
        insert countryEco;

        // Create Product_Economy__c
        Product_Economy__c prodEco = new Product_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Product__c = prod.Id,
            Product_Code__c = 'small_arms',
            Price__c = 12.0,
            Base_Price__c = 10.0,
            Total_World_Supply__c = 500.0,
            Real_Demand__c = 480.0,
            Max_Demand__c = 600.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_small_arms'
        );
        insert prodEco;

        // Create Country_Product_Economy__c
        Country_Product_Economy__c cpEco = new Country_Product_Economy__c(
            Country_Economy__c = countryEco.Id,
            Product_Economy__c = prodEco.Id,
            Product__c = prod.Id,
            Product_Code__c = 'small_arms',
            Sold_Domestic__c = 100.0,
            Bought_Quantity__c = 80.0,
            Thrown_To_Market__c = 20.0,
            Actual_Sold_World__c = 20.0,
            Domestic_Sales_Value__c = 1200.0,
            Import_Value__c = 0.0,
            Export_Value__c = 240.0,
            GDP_Contribution__c = 1440.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_PRU_small_arms'
        );
        insert cpEco;

        // Create State_Economy__c
        State_Economy__c stateEco = new State_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country_Economy__c = countryEco.Id,
            State__c = st.Id,
            Population__c = 500000,
            GDP__c = 200000.0,
            GDP_Rank__c = 1,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_PRU_Silesia'
        );
        insert stateEco;

        // Create Province_Economy__c
        Province_Economy__c provEco = new Province_Economy__c(
            Country_Economy__c = countryEco.Id,
            Province__c = prov.Id,
            Population__c = 50000,
            RGO_Production__c = 150.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_101'
        );
        insert provEco;

        // Create Factory_Economy__c
        Factory_Economy__c factoryEco = new Factory_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country_Economy__c = countryEco.Id,
            State_Economy__c = stateEco.Id,
            Product__c = prod.Id,
            Building_Type__c = 'glass_factory',
            Occurrence_Index__c = 1,
            Level__c = 1,
            Employees__c = 1000,
            Output_Quantity__c = 50.0,
            Unsold_Quantity__c = 5.0,
            Capital_Reserves__c = 1000.0,
            Revenue__c = 500.0,
            Input_Cost__c = 200.0,
            Wages_Paid__c = 100.0,
            Profit_Rank__c = 1,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_PRU_Silesia_glass_factory_1'
        );
        insert factoryEco;

        // Create Artisan_Economy__c
        Artisan_Economy__c artisanEco = new Artisan_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country_Economy__c = countryEco.Id,
            Province_Economy__c = provEco.Id,
            State_Economy__c = stateEco.Id,
            Product__c = prod.Id,
            Artisan_Type__c = 'small_arms_artisan',
            Spending__c = 50.0,
            Income__c = 80.0,
            AGDP__c = 30.0,
            Production_Quantity__c = 10.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_101_small_arms_artisan'
        );
        insert artisanEco;
    }

    @IsTest
    static void testGetRecentAnalyses() {
        Test.startTest();
        List<Economy_Analysis__c> results = EconomyAnalysisController.getRecentAnalyses(10);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return 1 recent analysis');
        System.assertEquals('prussia_1848.v2', results[0].Save_File_Name__c, 'Save file name should match');
    }

    @IsTest
    static void testGetAnalysisSummary() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        AnalysisSummaryDTO summary = EconomyAnalysisController.getAnalysisSummary(analysis.Id);
        AnalysisSummaryDTO nullSummary = EconomyAnalysisController.getAnalysisSummary(null);
        Test.stopTest();

        System.assertNotEquals(null, summary, 'Summary should not be null');
        System.assertEquals('prussia_1848.v2', summary.saveFileName, 'Save file name should match DTO');
        System.assertEquals('PRU', summary.playerCountryTag, 'Player country tag should match DTO');
        System.assertEquals(500000.0, summary.totalWorldGdp, 'Total world GDP should match DTO');
        System.assertEquals(1000000, summary.totalWorldPopulation, 'Total world population should match DTO');
        System.assertEquals(null, nullSummary, 'Null input should return null DTO');
    }

    @IsTest
    static void testGetCountrySummariesAndSummary() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        Country_Economy__c countryEco = [SELECT Id FROM Country_Economy__c LIMIT 1];

        Test.startTest();
        List<CountrySummaryDTO> listSummaries = EconomyAnalysisController.getCountrySummaries(analysis.Id);
        CountrySummaryDTO singleSummary = EconomyAnalysisController.getCountrySummary(analysis.Id, countryEco.Id);
        List<CountrySummaryDTO> emptyList = EconomyAnalysisController.getCountrySummaries(null);
        CountrySummaryDTO nullSingle = EconomyAnalysisController.getCountrySummary(null, countryEco.Id);
        Test.stopTest();

        System.assertEquals(1, listSummaries.size(), 'List should contain 1 country summary DTO');
        System.assertEquals('PRU', listSummaries[0].countryTag, 'Country tag should be PRU');
        System.assertEquals(1, listSummaries[0].gdpRank, 'GDP Rank should be 1');

        System.assertNotEquals(null, singleSummary, 'Single country summary should not be null');
        System.assertEquals('PRU', singleSummary.countryTag, 'Single country tag should be PRU');

        System.assertEquals(0, emptyList.size(), 'Null analysis should return empty list');
        System.assertEquals(null, nullSingle, 'Null analysis should return null DTO');
    }

    @IsTest
    static void testGetCountryProductSummaries() {
        Country_Economy__c countryEco = [SELECT Id FROM Country_Economy__c LIMIT 1];

        Test.startTest();
        List<CountryProductSummaryDTO> summaries = EconomyAnalysisController.getCountryProductSummaries(countryEco.Id);
        List<CountryProductSummaryDTO> emptySummaries = EconomyAnalysisController.getCountryProductSummaries(null);
        Test.stopTest();

        System.assertEquals(1, summaries.size(), 'Should return 1 country product summary DTO');
        System.assertEquals('PRU', summaries[0].countryTag, 'Country tag should match');
        System.assertEquals('small_arms', summaries[0].productCode, 'Product code should match');
        System.assertEquals(100.0, summaries[0].soldDomesticQuantity, 'Sold domestic quantity should match');

        System.assertEquals(0, emptySummaries.size(), 'Null input should return empty list');
    }

    @IsTest
    static void testGetProductSummariesAndSummary() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        Product_Economy__c prodEco = [SELECT Id FROM Product_Economy__c LIMIT 1];

        Test.startTest();
        List<ProductSummaryDTO> listSummaries = EconomyAnalysisController.getProductSummaries(analysis.Id);
        ProductSummaryDTO singleSummary = EconomyAnalysisController.getProductSummary(analysis.Id, prodEco.Id);
        List<ProductSummaryDTO> emptyList = EconomyAnalysisController.getProductSummaries(null);
        ProductSummaryDTO nullSingle = EconomyAnalysisController.getProductSummary(null, prodEco.Id);
        Test.stopTest();

        System.assertEquals(1, listSummaries.size(), 'List should contain 1 product summary DTO');
        System.assertEquals('small_arms', listSummaries[0].productCode, 'Product code should match');
        System.assertEquals(12.0, listSummaries[0].price, 'Price should match');

        System.assertNotEquals(null, singleSummary, 'Single product summary should not be null');
        System.assertEquals('small_arms', singleSummary.productCode, 'Single product code should match');

        System.assertEquals(0, emptyList.size(), 'Null analysis should return empty list');
        System.assertEquals(null, nullSingle, 'Null analysis should return null DTO');
    }

    @IsTest
    static void testGetCountryProductSummariesByProduct() {
        Product_Economy__c prodEco = [SELECT Id FROM Product_Economy__c LIMIT 1];

        Test.startTest();
        List<CountryProductSummaryDTO> summaries = EconomyAnalysisController.getCountryProductSummariesByProduct(prodEco.Id);
        List<CountryProductSummaryDTO> emptySummaries = EconomyAnalysisController.getCountryProductSummariesByProduct(null);
        Test.stopTest();

        System.assertEquals(1, summaries.size(), 'Should return 1 country product summary DTO by product');
        System.assertEquals('small_arms', summaries[0].productCode, 'Product code should match');

        System.assertEquals(0, emptySummaries.size(), 'Null input should return empty list');
    }

    @IsTest
    static void testGetStateSummaries() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        List<StateSummaryDTO> stateSummaries = EconomyAnalysisController.getStateSummaries(analysis.Id);
        List<StateSummaryDTO> emptySummaries = EconomyAnalysisController.getStateSummaries(null);
        Test.stopTest();

        System.assertEquals(1, stateSummaries.size(), 'Should return 1 state summary DTO');
        System.assertEquals('Silesia', stateSummaries[0].stateCode, 'State code should match');

        System.assertEquals(0, emptySummaries.size(), 'Null input should return empty list');
    }

    @IsTest
    static void testGetFactorySummaries() {
        State_Economy__c stateEco = [SELECT Id FROM State_Economy__c LIMIT 1];

        Test.startTest();
        List<FactorySummaryDTO> factorySummaries = EconomyAnalysisController.getFactorySummaries(stateEco.Id);
        List<FactorySummaryDTO> emptySummaries = EconomyAnalysisController.getFactorySummaries(null);
        Test.stopTest();

        System.assertEquals(1, factorySummaries.size(), 'Should return 1 factory summary DTO');
        System.assertEquals('glass_factory', factorySummaries[0].buildingType, 'Building type should match');

        System.assertEquals(0, emptySummaries.size(), 'Null input should return empty list');
    }

    @IsTest
    static void testGetArtisanSummaries() {
        Province_Economy__c provEco = [SELECT Id FROM Province_Economy__c LIMIT 1];

        Test.startTest();
        List<ArtisanSummaryDTO> artisanSummaries = EconomyAnalysisController.getArtisanSummaries(provEco.Id);
        List<ArtisanSummaryDTO> emptySummaries = EconomyAnalysisController.getArtisanSummaries(null);
        Test.stopTest();

        System.assertEquals(1, artisanSummaries.size(), 'Should return 1 artisan summary DTO');
        System.assertEquals('small_arms_artisan', artisanSummaries[0].artisanType, 'Artisan type should match');

        System.assertEquals(0, emptySummaries.size(), 'Null input should return empty list');
    }

    @IsTest
    static void testCompareAnalyses() {
        Economy_Analysis__c analysis1 = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Economy_Analysis__c analysis2 = new Economy_Analysis__c(
            Save_File_Name__c = 'prussia_1860.v2',
            Source_Save_File_Name__c = 'prussia_1860.v2',
            Ingame_Date__c = Date.newInstance(1860, 1, 1),
            Player_Country_Tag__c = 'PRU',
            Total_World_Exports__c = 1500.0,
            Total_World_Imports__c = 1400.0,
            Import_Status__c = 'COMPLETED',
            Unique_Snapshot_Key__c = 'prussia_1860.v2'
        );
        insert analysis2;

        Test.startTest();
        AnalysisComparisonDTO comparison = EconomyAnalysisController.compareAnalyses(analysis1.Id, analysis2.Id);
        AnalysisComparisonDTO nullComparison = EconomyAnalysisController.compareAnalyses(analysis1.Id, analysis1.Id);
        Test.stopTest();

        System.assertNotEquals(null, comparison, 'Comparison DTO should not be null');
        System.assertEquals('prussia_1848.v2', comparison.baseSummary.saveFileName, 'Base save file name should match');
        System.assertEquals('prussia_1860.v2', comparison.compareSummary.saveFileName, 'Compare save file name should match');

        System.assertEquals(null, nullComparison, 'Same base and compare analysis should return null');
    }

    @IsTest
    static void testTrendAnalysisMethods() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        List<Id> ids = new List<Id>{ analysis.Id };

        Test.startTest();
        WorldTrendDTO worldTrend = EconomyAnalysisController.getWorldTrend(ids);
        WorldTrendDTO emptyWorldTrend = EconomyAnalysisController.getWorldTrend(new List<Id>());

        CountryTrendDTO countryTrend = EconomyAnalysisController.getCountryTrend(new List<String>{ 'PRU' }, ids);
        CountryTrendDTO emptyCountryTrend = EconomyAnalysisController.getCountryTrend(null, new List<Id>());

        ProductTrendDTO productTrend = EconomyAnalysisController.getProductTrend(new List<String>{ 'small_arms' }, ids);
        ProductTrendDTO emptyProductTrend = EconomyAnalysisController.getProductTrend(null, new List<Id>());
        Test.stopTest();

        System.assertNotEquals(null, worldTrend, 'World trend should not be null');
        System.assertEquals(1, worldTrend.points.size(), 'World trend should have 1 point');

        System.assertNotEquals(null, countryTrend, 'Country trend should not be null');
        System.assertEquals(1, countryTrend.series.size(), 'Country trend should have 1 series');

        System.assertNotEquals(null, productTrend, 'Product trend should not be null');
        System.assertEquals(1, productTrend.series.size(), 'Product trend should have 1 series');

        System.assertEquals(0, emptyWorldTrend.points.size(), 'Empty IDs should return empty trend');
        System.assertEquals(0, emptyCountryTrend.series.size(), 'Empty IDs should return empty trend');
        System.assertEquals(0, emptyProductTrend.series.size(), 'Empty IDs should return empty trend');
    }

    @IsTest
    static void testExportCsv() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        String summaryCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Summary');
        String goodsCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Goods');
        String countriesGoldenCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Countries');
        String countriesLegacyCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'CountriesSummary');
        String productsCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Products');
        String cpCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'CountryProducts');
        String provincesGoldenCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Provinces');
        String provincesLegacyCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'ProvincesSummary');
        String statesCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'States');
        String factoriesCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Factories');
        String artisansCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Artisans');
        String nullCsv = EconomyAnalysisController.exportCsv(null, 'Summary');
        String invalidScopeCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'InvalidScope');
        Test.stopTest();

        System.assert(summaryCsv.contains('Analysis ID,Save File Name'), 'Summary CSV should contain headers');
        System.assert(summaryCsv.contains('prussia_1848.v2'), 'Summary CSV should contain save file name');

        System.assert(goodsCsv.contains('Good,Price'), 'Goods CSV should contain headers');
        System.assert(goodsCsv.contains('small_arms'), 'Goods CSV should contain small_arms');

        System.assert(countriesGoldenCsv.contains('Rank,ID,Name,Population,Colony_Population,Total_Population,FGDP,PGDP,AGDP,GDP,GDPperCapita'), 'Countries CSV should contain golden headers');
        System.assert(countriesGoldenCsv.contains('PRU'), 'Countries CSV should contain country tag PRU');

        System.assert(countriesLegacyCsv.contains('Tag,Official Name'), 'Legacy Countries CSV should contain legacy headers');
        System.assert(countriesLegacyCsv.contains('PRU'), 'Legacy Countries CSV should contain country tag PRU');

        System.assert(productsCsv.contains('Product Code,Product Name'), 'Products CSV should contain headers');
        System.assert(productsCsv.contains('small_arms'), 'Products CSV should contain product code');

        System.assert(cpCsv.contains('Country Tag,Product Code'), 'CountryProducts CSV should contain headers');

        System.assert(provincesGoldenCsv.contains('ID,Provid,Name,Owner,Country,State,Colony,Pop,Goods_type,RGO_Production'), 'Provinces CSV should contain golden headers');

        System.assert(provincesLegacyCsv.contains('Province ID,Country Tag,Population,RGO Production'), 'Legacy Provinces CSV should contain legacy headers');

        System.assert(statesCsv.contains('Rank,Name,Country,Population,GDP,GDP_PerCapita,RGO_Income,PGDP,AGDP,FGDP'), 'States CSV should contain golden headers');

        System.assert(factoriesCsv.contains('Rank,State,Tag,Country,Building,Level,Employees,Produces'), 'Factories CSV should contain golden headers');

        System.assert(artisansCsv.contains('ID,Provid,Name,Country,State,artisan_type,last_spending'), 'Artisans CSV should contain golden headers');

        System.assertEquals('', nullCsv, 'Null analysis ID should return empty CSV string');
        System.assertEquals('', invalidScopeCsv, 'Invalid scope should return empty CSV string');
    }
}
