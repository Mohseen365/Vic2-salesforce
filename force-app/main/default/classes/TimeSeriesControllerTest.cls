@isTest
private class TimeSeriesControllerTest {

    @testSetup
    static void setupData() {
        // Create Economy_Analysis__c records
        List<Economy_Analysis__c> analyses = new List<Economy_Analysis__c>();
        for (Integer i = 1; i <= 15; i++) {
            analyses.add(new Economy_Analysis__c(
                Save_File_Name__c = 'snapshot_war_reform_' + i + '.v2',
                Ingame_Date__c = Date.newInstance(1836 + i, 1, 1),
                Total_World_GDP__c = 100000.0 * i,
                Total_World_Population__c = 5000000 * i,
                Total_World_Imports__c = 20000.0 * i,
                Total_World_Exports__c = 25000.0 * i,
                Import_Status__c = 'COMPLETED'
            ));
        }
        insert analyses;

        // Create Country__c
        Country__c country = new Country__c(
            Name = 'Egypt',
            Country_Tag__c = 'EGY'
        );
        insert country;

        // Create Country_Economy__c
        List<Country_Economy__c> countryEcons = new List<Country_Economy__c>();
        for (Economy_Analysis__c ea : analyses) {
            countryEcons.add(new Country_Economy__c(
                Economy_Analysis__c = ea.Id,
                Country__c = country.Id,
                Country_Tag__c = 'EGY',
                GDP__c = 5000.0 * ea.Total_World_GDP__c / 100000.0,
                Total_Imports_Value__c = 1000.0,
                Total_Exports_Value__c = 1500.0,
                GDP_Rank__c = 5
            ));
        }
        insert countryEcons;

        // Create Product__c
        Product__c prod = new Product__c(
            Code__c = 'grain',
            Name = 'grain',
            Base_Price__c = 2.0
        );
        insert prod;

        // Create Product_Economy__c
        List<Product_Economy__c> prodEcons = new List<Product_Economy__c>();
        for (Economy_Analysis__c ea : analyses) {
            prodEcons.add(new Product_Economy__c(
                Economy_Analysis__c = ea.Id,
                Product__c = prod.Id,
                Product_Code__c = 'grain',
                Price__c = 2.5,
                Real_Demand__c = 1000.0,
                Total_World_Supply__c = 1200.0,
                Unique_Snapshot_Key__c = ea.Id + '_grain'
            ));
        }
        insert prodEcons;
    }

    @isTest
    static void testGetNarrowTimeSeriesWorld() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        List<Id> ids = new List<Id>();
        for (Economy_Analysis__c ea : analyses) {
            ids.add(ea.Id);
        }

        Test.startTest();
        List<NarrowMetricDTO> worldGdp = TimeSeriesController.getNarrowTimeSeries(ids, 'WORLD_GDP', null);
        List<NarrowMetricDTO> worldPop = TimeSeriesController.getNarrowTimeSeries(ids, 'WORLD_POPULATION', null);
        List<NarrowMetricDTO> worldImp = TimeSeriesController.getNarrowTimeSeries(ids, 'WORLD_IMPORTS', null);
        List<NarrowMetricDTO> worldExp = TimeSeriesController.getNarrowTimeSeries(ids, 'WORLD_EXPORTS', null);
        Test.stopTest();

        // 12-snapshot cap enforcement check
        System.assertEquals(12, worldGdp.size(), 'Should enforce 12-snapshot hard cap');
        System.assertEquals(12, worldPop.size());
        System.assertEquals(12, worldImp.size());
        System.assertEquals(12, worldExp.size());
        System.assertEquals('WORLD_GDP', worldGdp[0].metricKey);
    }

    @isTest
    static void testGetNarrowTimeSeriesCountryAndProduct() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC LIMIT 5];
        List<Id> ids = new List<Id>();
        for (Economy_Analysis__c ea : analyses) {
            ids.add(ea.Id);
        }

        Test.startTest();
        List<NarrowMetricDTO> countryGdp = TimeSeriesController.getNarrowTimeSeries(ids, 'COUNTRY_GDP', 'EGY');
        List<NarrowMetricDTO> countryImp = TimeSeriesController.getNarrowTimeSeries(ids, 'COUNTRY_IMPORT', 'EGY');
        List<NarrowMetricDTO> countryExp = TimeSeriesController.getNarrowTimeSeries(ids, 'COUNTRY_EXPORT', 'EGY');
        List<NarrowMetricDTO> countryRank = TimeSeriesController.getNarrowTimeSeries(ids, 'COUNTRY_RANK', 'EGY');

        List<NarrowMetricDTO> prodPrice = TimeSeriesController.getNarrowTimeSeries(ids, 'PRODUCT_PRICE', 'grain');
        List<NarrowMetricDTO> prodDemand = TimeSeriesController.getNarrowTimeSeries(ids, 'PRODUCT_DEMAND', 'grain');
        List<NarrowMetricDTO> prodSupply = TimeSeriesController.getNarrowTimeSeries(ids, 'PRODUCT_SUPPLY', 'grain');
        Test.stopTest();

        System.assertEquals(5, countryGdp.size());
        System.assertEquals(5, countryImp.size());
        System.assertEquals(5, countryExp.size());
        System.assertEquals(5, countryRank.size());
        System.assertEquals(5, prodPrice.size());
        System.assertEquals(5, prodDemand.size());
        System.assertEquals(5, prodSupply.size());
    }

    @isTest
    static void testGetEventTicksAndHeadToHead() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC LIMIT 2];
        List<Id> ids = new List<Id>{ analyses[0].Id, analyses[1].Id };

        Test.startTest();
        List<NarrowMetricDTO.EventTickDTO> ticks = TimeSeriesController.getEventTicks(ids);
        Map<String, Object> h2h = TimeSeriesController.getHeadToHeadComparison(analyses[0].Id, analyses[1].Id);
        Test.stopTest();

        System.assertNotEquals(0, ticks.size(), 'Event ticks should be retrieved');
        System.assertEquals(analyses[0].Id, (Id) h2h.get('baseId'));
        System.assertEquals(analyses[1].Id, (Id) h2h.get('compareId'));
    }

    @isTest
    static void testNullAndEmptyInputs() {
        Test.startTest();
        List<NarrowMetricDTO> emptyList = TimeSeriesController.getNarrowTimeSeries(null, null, null);
        List<NarrowMetricDTO.EventTickDTO> emptyTicks = TimeSeriesController.getEventTicks(null);
        Map<String, Object> emptyH2h = TimeSeriesController.getHeadToHeadComparison(null, null);
        Test.stopTest();

        System.assertEquals(0, emptyList.size());
        System.assertEquals(0, emptyTicks.size());
        System.assertEquals(0, emptyH2h.size());
    }
}
