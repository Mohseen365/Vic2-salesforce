@isTest
private class EconomyCalculationEngineTest {

    @isTest
    static void testResultDtoInstantiation() {
        Test.startTest();
        EconomyCalculationResult result = new EconomyCalculationResult();
        EconomyCalculationResult.JunctionResult jr = new EconomyCalculationResult.JunctionResult();
        EconomyCalculationResult.CountryResult cr = new EconomyCalculationResult.CountryResult();
        EconomyCalculationResult.AnalysisResult ar = new EconomyCalculationResult.AnalysisResult();

        jr.junctionId = null;
        jr.soldUnits = 10.0;
        jr.totalSupplyPounds = 100.0;
        jr.actualSupplyPounds = 100.0;
        jr.actualDemandPounds = 50.0;
        jr.importValue = 0.0;
        jr.exportValue = 50.0;
        jr.domesticSalesValue = 50.0;
        jr.gdpContribution = 100.0;

        cr.countryEconomyId = null;
        cr.countryTag = 'ENG';
        cr.gdp = 1000.0;
        cr.gdpRank = 1;
        cr.totalImportsValue = 200.0;
        cr.totalExportsValue = 500.0;

        ar.analysisId = null;
        ar.totalWorldImports = 1000.0;
        ar.totalWorldExports = 1000.0;

        result.analysisResult = ar;
        result.countryResultsById.put(null, cr);
        result.junctionResultsById.put(null, jr);
        Test.stopTest();

        System.assertEquals(100.0, jr.gdpContribution, 'Junction GDP contribution should match');
        System.assertEquals('ENG', cr.countryTag, 'Country tag should match');
        System.assertEquals(1000.0, ar.totalWorldImports, 'Analysis imports should match');
    }

    @isTest
    static void testSafeDivide() {
        Test.startTest();
        Decimal res1 = EconomyCalculationEngine.safeDivide(100.0, 50.0, 0.0);
        Decimal res2 = EconomyCalculationEngine.safeDivide(100.0, 0.0, 0.0);
        Decimal res3 = EconomyCalculationEngine.safeDivide(100.0, null, 0.0);
        Decimal res4 = EconomyCalculationEngine.safeDivide(null, 50.0, 0.0);
        Test.stopTest();

        System.assertEquals(2.0, res1, '100 / 50 should equal 2');
        System.assertEquals(0.0, res2, 'Division by zero should return fallback 0');
        System.assertEquals(0.0, res3, 'Division by null denominator should return fallback 0');
        System.assertEquals(0.0, res4, 'Division with null numerator should return fallback 0');
    }

    @isTest
    static void testCalculateProductStorageContributions_NormalAndTrade() {
        Id fakeProdId = '01t000000000001AAA';
        Product_Economy__c grainProd = new Product_Economy__c(
            Id = fakeProdId,
            Product_Code__c = 'grain',
            Price__c = 10.0,
            Base_Price__c = 10.0
        );

        Map<Id, Product_Economy__c> prodMap = new Map<Id, Product_Economy__c>{ fakeProdId => grainProd };

        // Junction 1: Exports scenario (sold > bought)
        // Sold_Domestic = 5, Thrown = 10, Actual_Sold_World = 8, Worldmarket_Pool = 10
        // soldUnits = 5 + (10 * 8 / 10) = 13.
        // Intermediate_Consumption = 3.
        // unclamped GDP units = 13 - 3 = 10. GDP contribution = 10 * 10 = 100.0
        // Total_Supply = (5 + 10) * 10 = 150.0
        // Actual_Supply = 13 * 10 = 130.0
        // Actual_Demand = 2 * 10 = 20.0 (bought = 2)
        // Domestic_Sales_Value = 5 * 10 = 50.0
        // Import_Value = max(2 - 13, 0) * 10 = 0.0
        // Export_Value = max(13 - 2, 0) * 10 = 110.0
        Country_Product_Economy__c j1 = new Country_Product_Economy__c(
            Product_Economy__c = fakeProdId,
            Product_Code__c = 'grain',
            Sold_Domestic__c = 5.0,
            Bought_Quantity__c = 2.0,
            Thrown_To_Market__c = 10.0,
            Actual_Sold_World__c = 8.0,
            Worldmarket_Pool__c = 10.0,
            Intermediate_Consumption__c = 3.0
        );

        // Junction 2: Imports scenario (bought > sold)
        // Sold_Domestic = 2, Thrown = 0, Worldmarket_Pool = 0
        // soldUnits = 2.
        // Bought = 10.
        // Import_Value = max(10 - 2, 0) * 10 = 80.0
        // Export_Value = max(2 - 10, 0) * 10 = 0.0
        Country_Product_Economy__c j2 = new Country_Product_Economy__c(
            Product_Economy__c = fakeProdId,
            Product_Code__c = 'grain',
            Sold_Domestic__c = 2.0,
            Bought_Quantity__c = 10.0,
            Thrown_To_Market__c = 0.0,
            Actual_Sold_World__c = 0.0,
            Worldmarket_Pool__c = 0.0,
            Intermediate_Consumption__c = 0.0
        );

        List<Country_Product_Economy__c> junctions = new List<Country_Product_Economy__c>{ j1, j2 };

        Test.startTest();
        EconomyCalculationEngine.calculateProductStorageContributions(junctions, prodMap);
        Test.stopTest();

        System.assertEquals(150.0, j1.Total_Supply_Pounds__c, 'Total supply pounds should be 150');
        System.assertEquals(130.0, j1.Actual_Supply_Pounds__c, 'Actual supply pounds should be 130');
        System.assertEquals(20.0, j1.Actual_Demand_Pounds__c, 'Actual demand pounds should be 20');
        System.assertEquals(50.0, j1.Domestic_Sales_Value__c, 'Domestic sales value should be 50');
        System.assertEquals(0.0, j1.Import_Value__c, 'Import value should be 0');
        System.assertEquals(110.0, j1.Export_Value__c, 'Export value should be 110');
        System.assertEquals(100.0, j1.GDP_Contribution__c, 'GDP contribution should be 100');

        System.assertEquals(80.0, j2.Import_Value__c, 'Import value should be 80');
        System.assertEquals(0.0, j2.Export_Value__c, 'Export value should be 0');
        System.assertEquals(20.0, j2.GDP_Contribution__c, 'GDP contribution should be 20');
    }

    @isTest
    static void testCalculateProductStorageContributions_PreciousMetalsAndZeroPool() {
        Id fakeGoldId = '01t000000000002AAA';
        Id fakeIronId = '01t000000000003AAA';

        Product_Economy__c goldProd = new Product_Economy__c(
            Id = fakeGoldId,
            Product_Code__c = 'precious_metal',
            Price__c = 20.0
        );

        Product_Economy__c ironProd = new Product_Economy__c(
            Id = fakeIronId,
            Product_Code__c = 'iron',
            Price__c = 5.0
        );

        Map<Id, Product_Economy__c> prodMap = new Map<Id, Product_Economy__c>{
            fakeGoldId => goldProd,
            fakeIronId => ironProd
        };

        Country_Product_Economy__c goldJunction = new Country_Product_Economy__c(
            Product_Economy__c = fakeGoldId,
            Product_Code__c = 'precious_metal',
            Sold_Domestic__c = 10.0,
            Bought_Quantity__c = 0.0,
            Thrown_To_Market__c = 5.0,
            Actual_Sold_World__c = 0.0,
            Worldmarket_Pool__c = 0.0,
            Intermediate_Consumption__c = 0.0
        );

        Country_Product_Economy__c zeroPoolJunction = new Country_Product_Economy__c(
            Product_Economy__c = fakeIronId,
            Product_Code__c = 'iron',
            Sold_Domestic__c = 4.0,
            Bought_Quantity__c = 1.0,
            Thrown_To_Market__c = 6.0,
            Actual_Sold_World__c = 0.0,
            Worldmarket_Pool__c = 0.0,
            Intermediate_Consumption__c = 0.0
        );

        List<Country_Product_Economy__c> junctions = new List<Country_Product_Economy__c>{ goldJunction, zeroPoolJunction };

        Test.startTest();
        EconomyCalculationEngine.calculateProductStorageContributions(junctions, prodMap);
        Test.stopTest();

        System.assertEquals(0.0, goldJunction.Export_Value__c, 'Precious metals must have 0 export value (bypasses world market exports)');
        System.assertEquals(300.0, goldJunction.GDP_Contribution__c, 'Gold junction GDP contribution should be (10+5)*20=300');
        System.assertEquals(0.0, zeroPoolJunction.Import_Value__c, 'Import value should be 0 when sold >= bought');
        System.assertEquals(15.0, zeroPoolJunction.Export_Value__c, 'Export value should be (4-1)*5=15');
    }

    @isTest
    static void testCalculateProductStorageContributions_MissingLookupOrPrice() {
        Id fakeProdId = '01t000000000005AAA';
        // Junction referencing missing product ID in map
        Country_Product_Economy__c jMissing = new Country_Product_Economy__c(
            Product_Economy__c = fakeProdId,
            Product_Code__c = 'unmapped_good',
            Sold_Domestic__c = 10.0
        );

        // Product with null price
        Id fakeNullPriceProdId = '01t000000000006AAA';
        Product_Economy__c nullPriceProd = new Product_Economy__c(
            Id = fakeNullPriceProdId,
            Product_Code__c = 'null_price_good',
            Price__c = null
        );

        Country_Product_Economy__c jNullPrice = new Country_Product_Economy__c(
            Product_Economy__c = fakeNullPriceProdId,
            Product_Code__c = 'null_price_good',
            Sold_Domestic__c = 10.0
        );

        Map<Id, Product_Economy__c> prodMap = new Map<Id, Product_Economy__c>{ fakeNullPriceProdId => nullPriceProd };
        List<Country_Product_Economy__c> junctions = new List<Country_Product_Economy__c>{ jMissing, jNullPrice };

        Test.startTest();
        EconomyCalculationEngine.calculateProductStorageContributions(junctions, prodMap);
        Test.stopTest();

        System.assertEquals(0.0, jMissing.Total_Supply_Pounds__c, 'Missing lookup should produce 0 supply pounds');
        System.assertEquals(0.0, jNullPrice.Total_Supply_Pounds__c, 'Null price should produce 0 supply pounds');
    }

    @isTest
    static void testNegativeIntermediateConsumptionClamping() {
        Id fakeProdId = '01t000000000004AAA';
        Product_Economy__c timberProd = new Product_Economy__c(
            Id = fakeProdId,
            Product_Code__c = 'timber',
            Price__c = 5.0
        );

        Map<Id, Product_Economy__c> prodMap = new Map<Id, Product_Economy__c>{ fakeProdId => timberProd };

        Country_Product_Economy__c j = new Country_Product_Economy__c(
            Product_Economy__c = fakeProdId,
            Product_Code__c = 'timber',
            Sold_Domestic__c = 2.0,
            Bought_Quantity__c = 0.0,
            Thrown_To_Market__c = 0.0,
            Intermediate_Consumption__c = 10.0
        );

        List<Country_Product_Economy__c> junctions = new List<Country_Product_Economy__c>{ j };

        Test.startTest();
        EconomyCalculationEngine.calculateProductStorageContributions(junctions, prodMap);
        Test.stopTest();

        System.assertEquals(0.0, j.GDP_Contribution__c, 'Negative unclamped GDP should be clamped to 0.0');
    }

    @isTest
    static void testCalculateCountryTotalsAndRanking() {
        Country_Economy__c c1 = new Country_Economy__c(
            Country_Tag__c = 'USA',
            Gold_Income__c = 50.0
        );
        Country_Economy__c c2 = new Country_Economy__c(
            Country_Tag__c = 'ENG',
            Gold_Income__c = 100.0
        );
        Country_Economy__c c3 = new Country_Economy__c(
            Country_Tag__c = 'FRA',
            Gold_Income__c = 50.0
        );
        Country_Economy__c c4 = new Country_Economy__c(
            Country_Tag__c = 'ZUL',
            Gold_Income__c = 0.0
        );

        List<Country_Economy__c> countries = new List<Country_Economy__c>{ c1, c2, c3, c4 };

        Country_Product_Economy__c j1 = new Country_Product_Economy__c(Product_Code__c = 'grain', GDP_Contribution__c = 200.0);
        Country_Product_Economy__c j2 = new Country_Product_Economy__c(Product_Code__c = 'grain', GDP_Contribution__c = 300.0);
        Country_Product_Economy__c j3 = new Country_Product_Economy__c(Product_Code__c = 'grain', GDP_Contribution__c = 200.0);

        Id fakeId1 = '001000000000001AAA';
        Id fakeId2 = '001000000000002AAA';
        Id fakeId3 = '001000000000003AAA';
        Id fakeId4 = '001000000000004AAA';
        c1.Id = fakeId1;
        c2.Id = fakeId2;
        c3.Id = fakeId3;
        c4.Id = fakeId4;

        Map<Id, List<Country_Product_Economy__c>> junctionsByCountryId = new Map<Id, List<Country_Product_Economy__c>>{
            fakeId1 => new List<Country_Product_Economy__c>{ j1 },
            fakeId2 => new List<Country_Product_Economy__c>{ j2 },
            fakeId3 => new List<Country_Product_Economy__c>{ j3 }
        };

        Test.startTest();
        EconomyCalculationEngine.calculateCountryTotals(countries, junctionsByCountryId);
        EconomyCalculationEngine.assignGdpRanks(countries);
        Test.stopTest();

        System.assertEquals(250.0, c1.GDP__c, 'USA GDP should be 200 + 50 (gold income added because precious_metal junction absent)');
        System.assertEquals(400.0, c2.GDP__c, 'ENG GDP should be 300 + 100');
        System.assertEquals(250.0, c3.GDP__c, 'FRA GDP should be 200 + 50');
        System.assertEquals(0.0, c4.GDP__c, 'ZUL GDP should be 0');

        System.assertEquals(1, c2.GDP_Rank__c, 'ENG should be Rank 1');
        System.assertEquals(2, c3.GDP_Rank__c, 'FRA should be Rank 2 due to alphabetical tie-break over USA');
        System.assertEquals(3, c1.GDP_Rank__c, 'USA should be Rank 3');
        System.assertEquals(4, c4.GDP_Rank__c, 'ZUL should be Rank 4');
    }

    @isTest
    static void testCalculateAnalysisTotals() {
        Economy_Analysis__c analysis = new Economy_Analysis__c();
        Country_Economy__c c1 = new Country_Economy__c(Total_Imports_Value__c = 150.0, Total_Exports_Value__c = 300.0);
        Country_Economy__c c2 = new Country_Economy__c(Total_Imports_Value__c = 250.0, Total_Exports_Value__c = 100.0);

        List<Country_Economy__c> countries = new List<Country_Economy__c>{ c1, c2 };

        Test.startTest();
        EconomyCalculationEngine.calculateAnalysisTotals(analysis, countries);
        Test.stopTest();

        System.assertEquals(400.0, analysis.Total_World_Imports__c, 'Total World Imports should sum country imports');
        System.assertEquals(400.0, analysis.Total_World_Exports__c, 'Total World Exports should sum country exports');
    }

    @isTest
    static void testEdgeCases_EmptyAndNullInputs() {
        Test.startTest();
        EconomyCalculationEngine.calculateProductStorageContributions(null, null);
        EconomyCalculationEngine.calculateProductStorageContributions(new List<Country_Product_Economy__c>(), null);

        EconomyCalculationEngine.calculateCountryTotals(null, null);
        EconomyCalculationEngine.calculateCountryTotals(new List<Country_Economy__c>(), null);

        EconomyCalculationEngine.assignGdpRanks(null);
        EconomyCalculationEngine.assignGdpRanks(new List<Country_Economy__c>());

        EconomyCalculationEngine.calculateAnalysisTotals(null, null);
        EconomyCalculationEngine.calculateAnalysisTotals(new Economy_Analysis__c(), new List<Country_Economy__c>());
        Test.stopTest();

        System.assert(true, 'Null and empty list handlers executed without throwing exceptions');
    }

    @isTest
    static void testGoldenDatasetParity_SampleCountries() {
        Country_Economy__c tur = new Country_Economy__c(Country_Tag__c = 'TUR', Gold_Income__c = 1299.0);
        Country_Economy__c eng = new Country_Economy__c(Country_Tag__c = 'ENG', Gold_Income__c = 553.0);
        Country_Economy__c chi = new Country_Economy__c(Country_Tag__c = 'CHI', Gold_Income__c = 1363.0);
        Country_Economy__c fra = new Country_Economy__c(Country_Tag__c = 'FRA', Gold_Income__c = 459.0);
        Country_Economy__c rus = new Country_Economy__c(Country_Tag__c = 'RUS', Gold_Income__c = 0.0);
        Country_Economy__c peu = new Country_Economy__c(Country_Tag__c = 'PEU', Gold_Income__c = 180.0);
        Country_Economy__c frm = new Country_Economy__c(Country_Tag__c = 'FRM', Gold_Income__c = 0.0);
        Country_Economy__c nzl = new Country_Economy__c(Country_Tag__c = 'NZL', Gold_Income__c = 0.0);

        Id idTur = '001000000000001000';
        Id idEng = '001000000000002000';
        Id idChi = '001000000000003000';
        Id idFra = '001000000000004000';
        Id idRus = '001000000000005000';
        Id idPeu = '001000000000006000';
        Id idFrm = '001000000000007000';
        Id idNzl = '001000000000008000';

        tur.Id = idTur;
        eng.Id = idEng;
        chi.Id = idChi;
        fra.Id = idFra;
        rus.Id = idRus;
        peu.Id = idPeu;
        frm.Id = idFrm;
        nzl.Id = idNzl;

        Map<Id, List<Country_Product_Economy__c>> jMap = new Map<Id, List<Country_Product_Economy__c>>{
            idTur => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'precious_metal', GDP_Contribution__c = 22681.332) },
            idEng => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'precious_metal', GDP_Contribution__c = 15961.109) },
            idChi => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'precious_metal', GDP_Contribution__c = 12691.274) },
            idFra => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'precious_metal', GDP_Contribution__c = 11182.592) },
            idRus => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'grain', GDP_Contribution__c = 10215.959) },
            idPeu => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'precious_metal', GDP_Contribution__c = 185.45108) },
            idFrm => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'ammunition', GDP_Contribution__c = 24.594963) },
            idNzl => new List<Country_Product_Economy__c>{ new Country_Product_Economy__c(Product_Code__c = 'luxury_furniture', GDP_Contribution__c = 17.379854) }
        };

        List<Country_Economy__c> countryList = new List<Country_Economy__c>{ tur, eng, chi, fra, rus, peu, frm, nzl };

        Test.startTest();
        EconomyCalculationEngine.calculateCountryTotals(countryList, jMap);
        EconomyCalculationEngine.assignGdpRanks(countryList);
        Test.stopTest();

        System.assertEquals(22681.332, tur.GDP__c.setScale(3), 'TUR GDP parity check');
        System.assertEquals(15961.109, eng.GDP__c.setScale(3), 'ENG GDP parity check');
        System.assertEquals(12691.274, chi.GDP__c.setScale(3), 'CHI GDP parity check');
        System.assertEquals(11182.592, fra.GDP__c.setScale(3), 'FRA GDP parity check');
        System.assertEquals(10215.959, rus.GDP__c.setScale(3), 'RUS GDP parity check');
        System.assertEquals(185.451, peu.GDP__c.setScale(3), 'PEU GDP parity check');

        System.assertEquals(1, tur.GDP_Rank__c, 'TUR rank in sample subset should be 1');
        System.assertEquals(2, eng.GDP_Rank__c, 'ENG rank in sample subset should be 2');
        System.assertEquals(3, chi.GDP_Rank__c, 'CHI rank in sample subset should be 3');
        System.assertEquals(4, fra.GDP_Rank__c, 'FRA rank in sample subset should be 4');
        System.assertEquals(5, rus.GDP_Rank__c, 'RUS rank in sample subset should be 5');
        System.assertEquals(6, peu.GDP_Rank__c, 'PEU rank in sample subset should be 6');
        System.assertEquals(7, frm.GDP_Rank__c, 'FRM rank in sample subset should be 7');
        System.assertEquals(8, nzl.GDP_Rank__c, 'NZL rank in sample subset should be 8');
    }
}
