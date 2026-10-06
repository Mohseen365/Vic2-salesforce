@isTest
private class EconomyImportIntegrationTest {

    @isTest
    static void testFullImportPipelineIntegration() {
        EconomyImportRequestDTO req = new EconomyImportRequestDTO();

        req.analysis = new EconomyImportRequestDTO.AnalysisDTO();
        req.analysis.saveFileName = 'egypt.v2';
        req.analysis.ingameDate = '1836-01-01';
        req.analysis.sourceFileName = 'egypt.v2';
        req.analysis.playerCountryTag = 'EGY';
        req.analysis.contractVersion = '1.0.0';

        // 5 Countries
        EconomyImportRequestDTO.CountryDTO tur = new EconomyImportRequestDTO.CountryDTO();
        tur.tag = 'TUR'; tur.name = 'TUR'; tur.population = 47481816; tur.corePopulation = 13252500; tur.colonyPopulation = 34229316; tur.goldIncome = 1299.0;
        req.countries.add(tur);

        EconomyImportRequestDTO.CountryDTO eng = new EconomyImportRequestDTO.CountryDTO();
        eng.tag = 'ENG'; eng.name = 'ENG'; eng.population = 40000000; eng.corePopulation = 15000000; eng.colonyPopulation = 25000000; eng.goldIncome = 553.0;
        req.countries.add(eng);

        EconomyImportRequestDTO.CountryDTO chi = new EconomyImportRequestDTO.CountryDTO();
        chi.tag = 'CHI'; chi.name = 'CHI'; chi.population = 30000000; chi.corePopulation = 30000000; chi.colonyPopulation = 0; chi.goldIncome = 1363.0;
        req.countries.add(chi);

        EconomyImportRequestDTO.CountryDTO fra = new EconomyImportRequestDTO.CountryDTO();
        fra.tag = 'FRA'; fra.name = 'FRA'; fra.population = 17000000; fra.corePopulation = 12000000; fra.colonyPopulation = 5000000; fra.goldIncome = 459.0;
        req.countries.add(fra);

        EconomyImportRequestDTO.CountryDTO egy = new EconomyImportRequestDTO.CountryDTO();
        egy.tag = 'EGY'; egy.name = 'EGY'; egy.population = 2500000; egy.corePopulation = 2500000; egy.colonyPopulation = 0; egy.goldIncome = 0.0;
        req.countries.add(egy);

        // Products
        EconomyImportRequestDTO.ProductDTO grain = new EconomyImportRequestDTO.ProductDTO();
        grain.code = 'grain'; grain.name = 'Grain'; grain.price = 3.20; grain.basePrice = 3.20;
        req.products.add(grain);

        EconomyImportRequestDTO.ProductDTO gold = new EconomyImportRequestDTO.ProductDTO();
        gold.code = 'precious_metal'; gold.name = 'Precious Metal'; gold.price = 20.0; gold.basePrice = 20.0;
        req.products.add(gold);

        // Country Products
        EconomyImportRequestDTO.CountryProductDTO cpTurGold = new EconomyImportRequestDTO.CountryProductDTO();
        cpTurGold.countryTag = 'TUR'; cpTurGold.productCode = 'precious_metal'; cpTurGold.soldDomestic = 100.0; cpTurGold.boughtQuantity = 0.0; cpTurGold.thrownToMarket = 50.0; cpTurGold.actualSoldWorld = 0.0; cpTurGold.worldmarketPool = 0.0; cpTurGold.intermediateConsumption = 0.0;
        req.countryProducts.add(cpTurGold);

        EconomyImportRequestDTO.CountryProductDTO cpEngGrain = new EconomyImportRequestDTO.CountryProductDTO();
        cpEngGrain.countryTag = 'ENG'; cpEngGrain.productCode = 'grain'; cpEngGrain.soldDomestic = 200.0; cpEngGrain.boughtQuantity = 300.0; cpEngGrain.thrownToMarket = 0.0; cpEngGrain.actualSoldWorld = 0.0; cpEngGrain.worldmarketPool = 0.0; cpEngGrain.intermediateConsumption = 50.0;
        req.countryProducts.add(cpEngGrain);

        // State
        EconomyImportRequestDTO.StateDTO stThrace = new EconomyImportRequestDTO.StateDTO();
        stThrace.stateCode = 'TUR_Thrace'; stThrace.stateName = 'Thrace'; stThrace.countryTag = 'TUR'; stThrace.population = 1200000; stThrace.gdp = 150000.0;
        req.states.add(stThrace);

        // Province
        EconomyImportRequestDTO.ProvinceDTO pr1720 = new EconomyImportRequestDTO.ProvinceDTO();
        pr1720.provinceId = '1720'; pr1720.countryTag = 'TUR'; pr1720.stateCode = 'TUR_Thrace'; pr1720.population = 125000; pr1720.rgoProduction = 45.2; pr1720.colony = false; pr1720.rgoIncome = 12.50;
        req.provinces.add(pr1720);

        // Factory
        EconomyImportRequestDTO.FactoryDTO fGlass = new EconomyImportRequestDTO.FactoryDTO();
        fGlass.stateCode = 'TUR_Thrace'; fGlass.countryTag = 'TUR'; fGlass.productCode = 'glass'; fGlass.buildingType = 'glass_factory'; fGlass.occurrenceIndex = 1; fGlass.level = 1; fGlass.employees = 4200; fGlass.revenue = 45.10; fGlass.inputCost = 22.30; fGlass.wagesPaid = 12.00;
        req.factories.add(fGlass);

        // Artisan
        EconomyImportRequestDTO.ArtisanDTO aFabric = new EconomyImportRequestDTO.ArtisanDTO();
        aFabric.externalProvinceId = '1720'; aFabric.countryTag = 'TUR'; aFabric.stateCode = 'TUR_Thrace'; aFabric.productCode = 'grain'; aFabric.artisanType = 'fabric'; aFabric.spending = 1.10; aFabric.income = 3.50; aFabric.agdp = 2.40; aFabric.productionQuantity = 1.0;
        req.artisans.add(aFabric);

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(true, res.success);
        System.assertEquals('COMPLETED', res.importStatus);

        // Verify Master Data created
        List<Country__c> mastersC = [SELECT Id, Tag__c FROM Country__c];
        System.assertEquals(5, mastersC.size());

        List<State__c> mastersS = [SELECT Id, State_Code__c FROM State__c];
        System.assertEquals(1, mastersS.size());

        List<Province__c> mastersP = [SELECT Id, External_Province_Id__c FROM Province__c];
        System.assertEquals(1, mastersP.size());

        // Verify Snapshots created and calculated
        List<Country_Economy__c> countrySnapshots = [SELECT Id, Country_Tag__c, GDP__c, GDP_Rank__c FROM Country_Economy__c WHERE Economy_Analysis__c = :res.analysisId];
        System.assertEquals(5, countrySnapshots.size());
        for (Country_Economy__c ce : countrySnapshots) {
            System.assertNotEquals(null, ce.GDP__c);
            System.assertNotEquals(null, ce.GDP_Rank__c);
        }

        List<Factory_Economy__c> factorySnapshots = [SELECT Id, Unique_Snapshot_Key__c FROM Factory_Economy__c WHERE Economy_Analysis__c = :res.analysisId];
        System.assertEquals(1, factorySnapshots.size());
        System.assertEquals('egypt.v2_TUR_Thrace_glass_factory_1', factorySnapshots[0].Unique_Snapshot_Key__c);

        List<Artisan_Economy__c> artisanSnapshots = [SELECT Id, Unique_Snapshot_Key__c FROM Artisan_Economy__c WHERE Economy_Analysis__c = :res.analysisId];
        System.assertEquals(1, artisanSnapshots.size());
        System.assertEquals('egypt.v2_1720_grain', artisanSnapshots[0].Unique_Snapshot_Key__c);

        // Verify Import_Run__c tracking and checksum reconciliation
        List<Import_Run__c> runs = [
            SELECT Id, Status__c, Checksum_Status__c, Calculated_Pop_Checksum__c, Rollup_Schema_Version__c, Economy_Analysis__c
            FROM Import_Run__c
            WHERE Economy_Analysis__c = :res.analysisId
        ];
        System.assertEquals(1, runs.size(), 'Import_Run__c record should be created.');
        System.assertEquals('PUBLISHED', runs[0].Status__c, 'Import_Run__c status should be PUBLISHED.');
        System.assertEquals('MATCHED', runs[0].Checksum_Status__c, 'Checksum status should be MATCHED.');
        System.assertEquals('1.0.0', runs[0].Rollup_Schema_Version__c, 'Rollup schema version should be 1.0.0.');
        System.assertEquals(136981816L, runs[0].Calculated_Pop_Checksum__c, 'Total population checksum should match sum of country populations.');
    }

    @isTest
    static void testPopChecksumMismatchValidation() {
        EconomyImportRequestDTO req = new EconomyImportRequestDTO();
        req.analysis = new EconomyImportRequestDTO.AnalysisDTO();
        req.analysis.saveFileName = 'checksum_test.v2';
        req.analysis.ingameDate = '1836-01-01';
        req.analysis.expectedPopChecksum = 999999999L; // Intentionally wrong expected total

        EconomyImportRequestDTO.CountryDTO egy = new EconomyImportRequestDTO.CountryDTO();
        egy.tag = 'EGY'; egy.name = 'Egypt'; egy.population = 2500000;
        req.countries.add(egy);

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(false, res.success);
        System.assertEquals('FAILED', res.importStatus);
        System.assertEquals('MISMATCHED', res.checksumStatus);

        List<Import_Run__c> runs = [
            SELECT Id, Status__c, Checksum_Status__c, Calculated_Pop_Checksum__c, Total_Pop_Checksum__c
            FROM Import_Run__c
            WHERE Save_Identifier__c = 'checksum_test.v2_run_1'
        ];
        System.assertEquals(1, runs.size());
        System.assertEquals('FAILED', runs[0].Status__c);
        System.assertEquals('MISMATCHED', runs[0].Checksum_Status__c);
        System.assertEquals(2500000L, runs[0].Calculated_Pop_Checksum__c);
        System.assertEquals(999999999L, runs[0].Total_Pop_Checksum__c);
    }

    @isTest
    static void testChunkedIngestionParams() {
        EconomyImportRequestDTO req = new EconomyImportRequestDTO();
        req.analysis = new EconomyImportRequestDTO.AnalysisDTO();
        req.analysis.saveFileName = 'chunked_save.v2';
        req.analysis.chunkSeq = 1;
        req.analysis.totalChunks = 3;
        req.analysis.entityType = 'COUNTRIES';
        req.analysis.expectedPopChecksum = 5000000L;

        EconomyImportRequestDTO.CountryDTO egy = new EconomyImportRequestDTO.CountryDTO();
        egy.tag = 'EGY'; egy.name = 'Egypt'; egy.population = 5000000;
        req.countries.add(egy);

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(true, res.success);
        System.assertEquals(1, res.chunkSeq);
        System.assertEquals(3, res.totalChunks);
        System.assertEquals(5000000L, res.calculatedPopChecksum);
        System.assertEquals('MATCHED', res.checksumStatus);

        Import_Run__c runRec = [
            SELECT Entity_Type__c, Chunk_Sequence__c, Total_Chunks__c
            FROM Import_Run__c
            WHERE Id = :res.importRunId
        ];
        System.assertEquals('COUNTRIES', runRec.Entity_Type__c);
        System.assertEquals(1, runRec.Chunk_Sequence__c);
        System.assertEquals(3, runRec.Total_Chunks__c);
    }
}
