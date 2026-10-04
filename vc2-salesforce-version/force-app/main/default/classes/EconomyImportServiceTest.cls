@isTest
private class EconomyImportServiceTest {

    @testSetup
    static void setupMasterData() {
        Country__c cPrussia = new Country__c(Tag__c = 'PRU', Name = 'Prussia');
        insert cPrussia;

        Product__c pGrain = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert pGrain;

        Province__c prov1 = new Province__c(External_Province_Id__c = '42', Country__c = cPrussia.Id);
        insert prov1;

        State__c st1 = new State__c(State_Code__c = 'PRU_Silesia', Name = 'Silesia', Country__c = cPrussia.Id);
        insert st1;
    }

    private static EconomyImportRequestDTO buildSamplePayload() {
        EconomyImportRequestDTO req = new EconomyImportRequestDTO();

        req.analysis = new EconomyImportRequestDTO.AnalysisDTO();
        req.analysis.saveFileName = 'Prussia_1848_03_12';
        req.analysis.ingameDate = '1848-03-12';
        req.analysis.sourceFileName = 'Prussia_1848_03_12.v2';
        req.analysis.playerCountryTag = 'PRU';
        req.analysis.contractVersion = '1.0.0';

        EconomyImportRequestDTO.CountryDTO pru = new EconomyImportRequestDTO.CountryDTO();
        pru.tag = 'PRU';
        pru.name = 'Prussia';
        pru.population = 14820000;
        pru.corePopulation = 14000000;
        pru.colonyPopulation = 820000;
        pru.workforce = 3705000;
        pru.employment = 3550000;
        pru.goldIncome = 12000;
        pru.factoryGdp = 500000.0;
        pru.provinceGdp = 1200000.0;
        pru.artisanGdp = 3000.0;
        req.countries.add(pru);

        EconomyImportRequestDTO.ProductDTO grain = new EconomyImportRequestDTO.ProductDTO();
        grain.code = 'grain';
        grain.name = 'Grain';
        grain.price = 2.10;
        grain.basePrice = 2.00;
        grain.totalWorldSupply = 45000.0;
        grain.realDemand = 42000.0;
        grain.maxDemand = 48000.0;
        req.products.add(grain);

        EconomyImportRequestDTO.StateDTO st = new EconomyImportRequestDTO.StateDTO();
        st.stateCode = 'PRU_Silesia';
        st.stateName = 'Silesia';
        st.countryTag = 'PRU';
        st.population = 1500000;
        st.gdp = 200000.0;
        st.gdpRank = 1;
        req.states.add(st);

        EconomyImportRequestDTO.ProvinceDTO p1 = new EconomyImportRequestDTO.ProvinceDTO();
        p1.provinceId = 42;
        p1.countryTag = 'PRU';
        p1.stateCode = 'PRU_Silesia';
        p1.population = 85000;
        p1.rgoProduction = 120.0;
        p1.colony = false;
        p1.rgoIncome = 50.0;
        p1.rgoGdp = 18250.0;
        req.provinces.add(p1);

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

        EconomyImportRequestDTO.FactoryDTO f1 = new EconomyImportRequestDTO.FactoryDTO();
        f1.stateCode = 'PRU_Silesia';
        f1.countryTag = 'PRU';
        f1.buildingType = 'glass_factory';
        f1.occurrenceIndex = 1;
        f1.level = 1;
        f1.employees = 1000;
        f1.revenue = 500.0;
        f1.inputCost = 200.0;
        f1.wagesPaid = 100.0;
        req.factories.add(f1);

        EconomyImportRequestDTO.ArtisanDTO a1 = new EconomyImportRequestDTO.ArtisanDTO();
        a1.externalProvinceId = '42';
        a1.countryTag = 'PRU';
        a1.stateCode = 'PRU_Silesia';
        a1.productCode = 'grain';
        a1.artisanType = 'fabric';
        a1.spending = 10.0;
        a1.income = 25.0;
        a1.agdp = 15.0;
        a1.productionQuantity = 2.976;
        req.artisans.add(a1);

        return req;
    }

    @isTest
    static void testSuccessfulImportSynchronous() {
        EconomyImportRequestDTO req = buildSamplePayload();

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(true, res.success);
        System.assertEquals('COMPLETED', res.importStatus);
        System.assertNotEquals(null, res.analysisId);
        System.assertEquals(1, res.recordCounts.get('countries'));
        System.assertEquals(1, res.recordCounts.get('products'));
        System.assertEquals(1, res.recordCounts.get('states'));
        System.assertEquals(1, res.recordCounts.get('provinces'));
        System.assertEquals(1, res.recordCounts.get('factories'));
        System.assertEquals(1, res.recordCounts.get('artisans'));

        Economy_Analysis__c header = [SELECT Id, Import_Status__c FROM Economy_Analysis__c WHERE Id = :res.analysisId];
        System.assertEquals('COMPLETED', header.Import_Status__c);
    }

    @isTest
    static void testContractVersionMismatch() {
        EconomyImportRequestDTO req = buildSamplePayload();
        req.analysis.contractVersion = '2.0.0';

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(false, res.success);
        System.assertEquals('FAILED', res.importStatus);
        System.assert(res.errorMessage.contains('Contract version mismatch'));
    }

    @isTest
    static void testImportIdempotency() {
        EconomyImportRequestDTO req = buildSamplePayload();

        Test.startTest();
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req);
        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(res1.analysisId, res2.analysisId);
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c];
        System.assertEquals(1, analyses.size());
    }

    @isTest
    static void testGate1UnmappedArtisanTypeWarning() {
        EconomyImportRequestDTO req = buildSamplePayload();
        EconomyImportRequestDTO.ArtisanDTO unmappedA = new EconomyImportRequestDTO.ArtisanDTO();
        unmappedA.externalProvinceId = '42';
        unmappedA.countryTag = 'PRU';
        unmappedA.productCode = 'unknown_modded_commodity_xyz';
        unmappedA.artisanType = 'unknown_modded_commodity_xyz';
        req.artisans.add(unmappedA);

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(true, res.success);
        System.assertNotEquals(0, res.warnings.size());
        System.assert(res.warnings[0].contains('GATE-1 Warning'));
    }

    @isTest
    static void testForceBatchProcessing() {
        EconomyImportRequestDTO req = buildSamplePayload();

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req, true);
        Test.stopTest();

        System.assertEquals(true, res.success);
        System.assertEquals('PROCESSING', res.importStatus);
    }
}
