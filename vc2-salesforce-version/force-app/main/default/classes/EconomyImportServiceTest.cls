@isTest
private class EconomyImportServiceTest {

    @testSetup
    static void setupMasterData() {
        // Pre-create master country and product
        Country__c cPrussia = new Country__c(Tag__c = 'PRU', Name = 'Prussia');
        insert cPrussia;

        Product__c pGrain = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert pGrain;

        Province__c prov1 = new Province__c(External_Province_Id__c = '42', Country__c = cPrussia.Id);
        insert prov1;
    }

    private static EconomyImportRequestDTO buildSamplePayload() {
        EconomyImportRequestDTO req = new EconomyImportRequestDTO();

        req.analysis = new EconomyImportRequestDTO.AnalysisDTO();
        req.analysis.saveGameName = 'Prussia_1848_03_12';
        req.analysis.ingameDate = '1848-03-12';
        req.analysis.sourceFileName = 'Prussia_1848_03_12.v2';
        req.analysis.playerCountryTag = 'PRU';

        // Known tag PRU + Unknown tag ENG (tests master-data dynamic creation)
        EconomyImportRequestDTO.CountryDTO pru = new EconomyImportRequestDTO.CountryDTO();
        pru.tag = 'PRU';
        pru.name = 'Prussia';
        pru.population = 14820000;
        pru.workforce = 3705000;
        pru.employment = 3550000;
        pru.goldIncome = 12000;
        req.countries.add(pru);

        EconomyImportRequestDTO.CountryDTO eng = new EconomyImportRequestDTO.CountryDTO();
        eng.tag = 'ENG';
        eng.name = 'United Kingdom';
        eng.population = 25000000;
        eng.workforce = 6000000;
        eng.employment = 5800000;
        eng.goldIncome = 5000;
        req.countries.add(eng);

        // Known code grain + Unknown code iron (tests master-data dynamic creation)
        EconomyImportRequestDTO.ProductDTO grain = new EconomyImportRequestDTO.ProductDTO();
        grain.code = 'grain';
        grain.name = 'Grain';
        grain.price = 2.10;
        grain.basePrice = 2.00;
        grain.totalWorldSupply = 45000.0;
        grain.realDemand = 42000.0;
        grain.maxDemand = 48000.0;
        req.products.add(grain);

        EconomyImportRequestDTO.ProductDTO iron = new EconomyImportRequestDTO.ProductDTO();
        iron.code = 'iron';
        iron.name = 'Iron';
        iron.price = 5.00;
        iron.basePrice = 4.50;
        iron.totalWorldSupply = 10000.0;
        iron.realDemand = 9500.0;
        iron.maxDemand = 11000.0;
        req.products.add(iron);

        // Country Products
        EconomyImportRequestDTO.CountryProductDTO cp1 = new EconomyImportRequestDTO.CountryProductDTO();
        cp1.countryTag = 'PRU';
        cp1.productCode = 'grain';
        cp1.soldDomestic = 1400.0;
        cp1.boughtQuantity = 60.0;
        cp1.thrownToMarket = 80.0;
        cp1.actualSoldWorld = 70.0;
        cp1.worldmarketPool = 4000.0;
        cp1.intermediateConsumption = 0.0;
        req.countryProducts.add(cp1);

        EconomyImportRequestDTO.CountryProductDTO cp2 = new EconomyImportRequestDTO.CountryProductDTO();
        cp2.countryTag = 'ENG';
        cp2.productCode = 'iron';
        cp2.soldDomestic = 500.0;
        cp2.boughtQuantity = 20.0;
        cp2.thrownToMarket = 100.0;
        cp2.actualSoldWorld = 90.0;
        cp2.worldmarketPool = 2000.0;
        cp2.intermediateConsumption = 10.0;
        req.countryProducts.add(cp2);

        // Provinces (known 42 + unknown 99)
        EconomyImportRequestDTO.ProvinceDTO p1 = new EconomyImportRequestDTO.ProvinceDTO();
        p1.provinceId = 42;
        p1.countryTag = 'PRU';
        p1.population = 85000;
        p1.rgoProduction = 120.0;
        req.provinces.add(p1);

        EconomyImportRequestDTO.ProvinceDTO p2 = new EconomyImportRequestDTO.ProvinceDTO();
        p2.provinceId = '99';
        p2.countryTag = 'ENG';
        p2.population = 150000;
        p2.rgoProduction = 300.0;
        req.provinces.add(p2);

        return req;
    }

    @isTest
    static void testSuccessfulImportSynchronous() {
        EconomyImportRequestDTO req = buildSamplePayload();

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertNotEquals(null, res, 'Response should not be null.');
        System.assertEquals(true, res.success, 'Import should succeed.');
        System.assertEquals('COMPLETED', res.importStatus, 'Final status should be COMPLETED.');
        System.assertNotEquals(null, res.analysisId, 'Analysis ID should be set.');
        System.assertEquals(2, res.recordCounts.get('countries'), 'Should have 2 countries.');
        System.assertEquals(2, res.recordCounts.get('products'), 'Should have 2 products.');
        System.assertEquals(2, res.recordCounts.get('countryProducts'), 'Should have 2 countryProducts.');
        System.assertEquals(2, res.recordCounts.get('provinces'), 'Should have 2 provinces.');

        // Verify dynamic master data resolution
        List<Country__c> allCountries = [SELECT Id, Tag__c FROM Country__c];
        System.assertEquals(2, allCountries.size(), 'Unknown country ENG should be dynamically created.');

        List<Product__c> allProducts = [SELECT Id, Code__c FROM Product__c];
        System.assertEquals(2, allProducts.size(), 'Unknown product iron should be dynamically created.');

        List<Province__c> allProvinces = [SELECT Id, External_Province_Id__c FROM Province__c];
        System.assertEquals(2, allProvinces.size(), 'Unknown province 99 should be dynamically created.');

        // Verify Analysis Header and recalculated values
        Economy_Analysis__c header = [SELECT Id, Import_Status__c, Total_World_Imports__c FROM Economy_Analysis__c WHERE Id = :res.analysisId];
        System.assertEquals('COMPLETED', header.Import_Status__c);
    }

    @isTest
    static void testImportIdempotency() {
        EconomyImportRequestDTO req = buildSamplePayload();

        Test.startTest();
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req);
        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(res1.analysisId, res2.analysisId, 'Re-importing same save should update existing header.');

        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c];
        System.assertEquals(1, analyses.size(), 'Should not duplicate Economy_Analysis__c.');

        List<Country_Economy__c> countryEcons = [SELECT Id FROM Country_Economy__c WHERE Economy_Analysis__c = :res1.analysisId];
        System.assertEquals(2, countryEcons.size(), 'Should not duplicate Country_Economy__c.');
    }

    @isTest
    static void testInvalidPayload() {
        EconomyImportRequestDTO req = new EconomyImportRequestDTO();
        // Missing analysis header

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(false, res.success, 'Import should fail for missing analysis header.');
        System.assertEquals('FAILED', res.importStatus);
        System.assertNotEquals(null, res.errorMessage);
    }

    @isTest
    static void testForceBatchProcessing() {
        EconomyImportRequestDTO req = buildSamplePayload();

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req, true);
        Test.stopTest();

        System.assertEquals(true, res.success);
        System.assertEquals('PROCESSING', res.importStatus, 'Status should be PROCESSING when batch is enqueued.');
    }
}
