@isTest
private class EconomyImportIdempotencyTest {

    private static EconomyImportRequestDTO buildSamplePayload(String saveFileName, String ingameDate) {
        EconomyImportRequestDTO req = new EconomyImportRequestDTO();

        req.analysis = new EconomyImportRequestDTO.AnalysisDTO();
        req.analysis.saveFileName = saveFileName;
        req.analysis.ingameDate = ingameDate;
        req.analysis.sourceFileName = saveFileName + '.v2';
        req.analysis.playerCountryTag = 'TUR';
        req.analysis.contractVersion = '1.0.0';

        EconomyImportRequestDTO.CountryDTO tur = new EconomyImportRequestDTO.CountryDTO();
        tur.tag = 'TUR';
        tur.name = 'Ottoman Empire';
        tur.population = 47481816;
        tur.corePopulation = 13252500;
        tur.colonyPopulation = 34229316;
        tur.workforce = 11870454;
        tur.employment = 11870454;
        tur.gdp = 7010392.13;
        tur.factoryGdp = 280400.13;
        tur.provinceGdp = 6726168.00;
        tur.artisanGdp = 3824.00;
        tur.goldIncome = 0.00;
        tur.totalImports = 1250340.50;
        tur.totalExports = 1890210.75;
        req.countries.add(tur);

        EconomyImportRequestDTO.CountryDTO egy = new EconomyImportRequestDTO.CountryDTO();
        egy.tag = 'EGY';
        egy.name = 'Egypt';
        egy.population = 2400000;
        egy.corePopulation = 2400000;
        egy.colonyPopulation = 0;
        egy.workforce = 600000;
        egy.employment = 600000;
        egy.gdp = 124500.00;
        egy.factoryGdp = 0.00;
        egy.provinceGdp = 120000.00;
        egy.artisanGdp = 4500.00;
        egy.goldIncome = 0.00;
        egy.totalImports = 15000.00;
        egy.totalExports = 32000.00;
        req.countries.add(egy);

        EconomyImportRequestDTO.ProductDTO ammo = new EconomyImportRequestDTO.ProductDTO();
        ammo.code = 'ammunition';
        ammo.name = 'Ammunition';
        ammo.basePrice = 18.8313;
        ammo.price = 18.8313;
        ammo.totalWorldSupply = 25.5;
        ammo.realDemand = 30.0;
        ammo.maxDemand = 50.0;
        req.products.add(ammo);

        EconomyImportRequestDTO.CountryProductDTO cp1 = new EconomyImportRequestDTO.CountryProductDTO();
        cp1.countryTag = 'TUR';
        cp1.productCode = 'ammunition';
        cp1.soldDomestic = 15.0;
        cp1.boughtQuantity = 15.0;
        cp1.thrownToMarket = 10.5;
        cp1.actualSoldWorld = 10.5;
        cp1.worldmarketPool = 0.0;
        cp1.intermediateConsumption = 5.0;
        cp1.totalSupplyPounds = 480.20;
        cp1.actualSupplyPounds = 480.20;
        cp1.actualDemandPounds = 564.94;
        req.countryProducts.add(cp1);

        EconomyImportRequestDTO.StateDTO stTur = new EconomyImportRequestDTO.StateDTO();
        stTur.stateCode = 'TUR_blank';
        stTur.stateName = 'blank';
        stTur.countryTag = 'TUR';
        stTur.population = 47481816;
        stTur.gdp = 6729992.30;
        stTur.gdpRank = 1;
        stTur.rgoIncome = 18427.86;
        stTur.pgdp = 6726167.83;
        stTur.agdp = 3824.48;
        stTur.fgdp = 0.00;
        stTur.factoryEmployees = 0;
        stTur.factoryRevenue = 0.00;
        stTur.factoryProfit = 0.00;
        req.states.add(stTur);

        EconomyImportRequestDTO.ProvinceDTO p674 = new EconomyImportRequestDTO.ProvinceDTO();
        p674.externalProvinceId = '674';
        p674.countryTag = 'TUR';
        p674.stateCode = 'TUR_blank';
        p674.population = 43319;
        p674.rgoProduction = 7.43;
        p674.colony = false;
        p674.rgoIncome = 16.35;
        p674.rgoGdp = 5966.50;
        p674.artisanSpending = 4.47;
        p674.artisanIncome = 6.60;
        p674.artisanGdp = 2.14;
        req.provinces.add(p674);

        EconomyImportRequestDTO.FactoryDTO f1 = new EconomyImportRequestDTO.FactoryDTO();
        f1.stateCode = 'TUR_blank';
        f1.countryTag = 'TUR';
        f1.productCode = 'ammunition';
        f1.buildingType = 'ammunition_factory';
        f1.occurrenceIndex = 1;
        f1.level = 1;
        f1.employees = 7379;
        f1.outputQuantity = 2.00;
        f1.unsoldQuantity = 0.56;
        f1.capitalReserves = 1.00;
        f1.revenue = 207.99;
        f1.inputCost = 98.87;
        f1.wagesPaid = 81.84;
        f1.injectedMoney = 0.00;
        f1.factoryGdp = 39830.97;
        f1.profitRank = 35;
        req.factories.add(f1);

        EconomyImportRequestDTO.ArtisanDTO a1 = new EconomyImportRequestDTO.ArtisanDTO();
        a1.externalProvinceId = '674';
        a1.countryTag = 'TUR';
        a1.stateCode = 'TUR_blank';
        a1.productCode = 'ammunition';
        a1.artisanType = 'ammunition';
        a1.spending = 1.17;
        a1.income = 1.96;
        a1.agdp = 0.79;
        a1.productionQuantity = 0.02;
        req.artisans.add(a1);

        return req;
    }

    @isTest
    static void testScenario1_RepeatIdenticalImportSmallFixture() {
        EconomyImportRequestDTO req = buildSamplePayload('sample_egypt_turkey_1836.v2', '1836-01-01');

        Test.startTest();
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req);
        System.assertEquals(true, res1.success);

        // Snapshot counts after run 1
        Integer cCount1 = [SELECT COUNT() FROM Country__c];
        Integer pCount1 = [SELECT COUNT() FROM Product__c];
        Integer stCount1 = [SELECT COUNT() FROM State__c];
        Integer provCount1 = [SELECT COUNT() FROM Province__c];
        Integer ceCount1 = [SELECT COUNT() FROM Country_Economy__c];
        Integer peCount1 = [SELECT COUNT() FROM Product_Economy__c];
        Integer steCount1 = [SELECT COUNT() FROM State_Economy__c];
        Integer proveCount1 = [SELECT COUNT() FROM Province_Economy__c];
        Integer cpeCount1 = [SELECT COUNT() FROM Country_Product_Economy__c];
        Integer feCount1 = [SELECT COUNT() FROM Factory_Economy__c];
        Integer aeCount1 = [SELECT COUNT() FROM Artisan_Economy__c];

        // Re-import identical payload
        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(true, res2.success);
        System.assertEquals(res1.analysisId, res2.analysisId, 'Header ID must remain identical');

        // Assert record counts unchanged
        System.assertEquals(cCount1, [SELECT COUNT() FROM Country__c]);
        System.assertEquals(pCount1, [SELECT COUNT() FROM Product__c]);
        System.assertEquals(stCount1, [SELECT COUNT() FROM State__c]);
        System.assertEquals(provCount1, [SELECT COUNT() FROM Province__c]);
        System.assertEquals(ceCount1, [SELECT COUNT() FROM Country_Economy__c]);
        System.assertEquals(peCount1, [SELECT COUNT() FROM Product_Economy__c]);
        System.assertEquals(steCount1, [SELECT COUNT() FROM State_Economy__c]);
        System.assertEquals(proveCount1, [SELECT COUNT() FROM Province_Economy__c]);
        System.assertEquals(cpeCount1, [SELECT COUNT() FROM Country_Product_Economy__c]);
        System.assertEquals(feCount1, [SELECT COUNT() FROM Factory_Economy__c]);
        System.assertEquals(aeCount1, [SELECT COUNT() FROM Artisan_Economy__c]);
    }

    @isTest
    static void testScenario2_RepeatIdenticalImportAsyncBatchLDV() {
        EconomyImportRequestDTO req = buildSamplePayload('ldv_sample_1836.v2', '1836-01-01');

        Test.startTest();
        // Force batch execution to test async path idempotency
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req, true);
        System.assertEquals('PROCESSING', res1.importStatus);

        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req, true);
        Test.stopTest();

        System.assertEquals(res1.analysisId, res2.analysisId);
        System.assertEquals(1, [SELECT COUNT() FROM Economy_Analysis__c WHERE Id = :res1.analysisId]);
    }

    @isTest
    static void testScenario3_ModifiedReImport() {
        EconomyImportRequestDTO req1 = buildSamplePayload('modified_sample_1836.v2', '1836-01-01');

        Test.startTest();
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req1);
        System.assertEquals(true, res1.success);

        // Fetch initial value
        Country_Product_Economy__c cpBefore = [
            SELECT Id, Sold_Domestic__c
            FROM Country_Product_Economy__c
            WHERE Unique_Snapshot_Key__c = 'modified_sample_1836.v2_TUR_ammunition'
        ];
        System.assertEquals(15.0, cpBefore.Sold_Domestic__c);

        // Modify RAW value in payload and re-import
        EconomyImportRequestDTO req2 = buildSamplePayload('modified_sample_1836.v2', '1836-01-01');
        req2.countryProducts[0].soldDomestic = 45.0;

        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req2);
        Test.stopTest();

        System.assertEquals(true, res2.success);
        System.assertEquals(res1.analysisId, res2.analysisId);

        // Assert record count unchanged and updated in place
        System.assertEquals(1, [SELECT COUNT() FROM Country_Product_Economy__c WHERE Unique_Snapshot_Key__c = 'modified_sample_1836.v2_TUR_ammunition']);
        Country_Product_Economy__c cpAfter = [
            SELECT Id, Sold_Domestic__c
            FROM Country_Product_Economy__c
            WHERE Unique_Snapshot_Key__c = 'modified_sample_1836.v2_TUR_ammunition'
        ];
        System.assertEquals(45.0, cpAfter.Sold_Domestic__c);
        System.assertEquals(cpBefore.Id, cpAfter.Id, 'Record ID must match (upserted in place)');
    }

    @isTest
    static void testScenario4_SameSaveFileNameDifferentIngameDate() {
        EconomyImportRequestDTO req1 = buildSamplePayload('multi_date_save.v2', '1836-01-01');

        Test.startTest();
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req1);
        System.assertEquals(true, res1.success);

        // Re-import with same saveFileName but updated ingameDate
        EconomyImportRequestDTO req2 = buildSamplePayload('multi_date_save.v2', '1840-01-01');
        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req2);
        Test.stopTest();

        // Save_File_Name__c is external ID on Economy_Analysis__c so it upserts the same analysis header
        System.assertEquals(res1.analysisId, res2.analysisId);
        Economy_Analysis__c header = [SELECT Id, Ingame_Date__c FROM Economy_Analysis__c WHERE Id = :res1.analysisId];
        System.assertEquals(Date.newInstance(1840, 1, 1), header.Ingame_Date__c);
    }

    @isTest
    static void testScenario5_ConcurrentImports() {
        EconomyImportRequestDTO req = buildSamplePayload('concurrency_sample.v2', '1836-01-01');

        Test.startTest();
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req);
        // Simulate immediate second import in same context/transaction
        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(true, res1.success);
        System.assertEquals(true, res2.success);
        System.assertEquals(res1.analysisId, res2.analysisId);
        System.assertEquals(1, [SELECT COUNT() FROM Economy_Analysis__c]);
    }

    @isTest
    static void testScenario6_PartialFailureRecovery() {
        EconomyImportRequestDTO reqMalformed = buildSamplePayload('failure_recovery_sample.v2', '1836-01-01');
        // Malform contract version to force pipeline failure
        reqMalformed.analysis.contractVersion = '9.9.9';

        Test.startTest();
        EconomyImportResponseDTO resFailed = EconomyImportService.processImport(reqMalformed);
        System.assertEquals(false, resFailed.success);
        System.assertEquals('FAILED', resFailed.importStatus);

        // Fix contract version and re-import
        EconomyImportRequestDTO reqFixed = buildSamplePayload('failure_recovery_sample.v2', '1836-01-01');
        reqFixed.analysis.contractVersion = '1.0.0';
        EconomyImportResponseDTO resSuccess = EconomyImportService.processImport(reqFixed);
        Test.stopTest();

        System.assertEquals(true, resSuccess.success);
        System.assertEquals('COMPLETED', resSuccess.importStatus);
        System.assertEquals(1, [SELECT COUNT() FROM Economy_Analysis__c WHERE Save_File_Name__c = 'failure_recovery_sample.v2']);
    }

    @isTest
    static void testScenario7_MasterAutoProvisioningIdempotency() {
        EconomyImportRequestDTO req = buildSamplePayload('auto_provision_sample.v2', '1836-01-01');

        // Add unknown country tag and unknown product code
        EconomyImportRequestDTO.CountryDTO unkC = new EconomyImportRequestDTO.CountryDTO();
        unkC.tag = 'XYZ';
        unkC.name = 'Unknown Tag XYZ';
        req.countries.add(unkC);

        EconomyImportRequestDTO.ProductDTO unkP = new EconomyImportRequestDTO.ProductDTO();
        unkP.code = 'modded_silk';
        unkP.name = 'Modded Silk';
        unkP.basePrice = 0.0;
        req.products.add(unkP);

        Test.startTest();
        EconomyImportResponseDTO res1 = EconomyImportService.processImport(req);
        EconomyImportResponseDTO res2 = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(true, res1.success);
        System.assertEquals(true, res2.success);

        System.assertEquals(1, [SELECT COUNT() FROM Country__c WHERE Tag__c = 'XYZ']);
        System.assertEquals(1, [SELECT COUNT() FROM Product__c WHERE Code__c = 'modded_silk']);
    }

    @isTest
    static void testSnapshotIntegrity_KeyFormats() {
        EconomyImportRequestDTO req = buildSamplePayload('key_format_sample.v2', '1836-01-01');

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(true, res.success);

        // Assert literal key formats matching Phase 1 frozen contract
        Country_Economy__c ce = [SELECT Unique_Snapshot_Key__c FROM Country_Economy__c WHERE Country_Tag__c = 'TUR' LIMIT 1];
        System.assertEquals('key_format_sample.v2_TUR', ce.Unique_Snapshot_Key__c);

        Product_Economy__c pe = [SELECT Unique_Snapshot_Key__c FROM Product_Economy__c WHERE Product_Code__c = 'ammunition' LIMIT 1];
        System.assertEquals('key_format_sample.v2_ammunition', pe.Unique_Snapshot_Key__c);

        State_Economy__c se = [SELECT Unique_Snapshot_Key__c FROM State_Economy__c WHERE Unique_Snapshot_Key__c LIKE '%TUR_blank' LIMIT 1];
        System.assertEquals('key_format_sample.v2_TUR_blank', se.Unique_Snapshot_Key__c);

        Province_Economy__c prove = [SELECT Unique_Snapshot_Key__c FROM Province_Economy__c WHERE Unique_Snapshot_Key__c LIKE '%674' LIMIT 1];
        System.assertEquals('key_format_sample.v2_674', prove.Unique_Snapshot_Key__c);

        Factory_Economy__c fe = [SELECT Unique_Snapshot_Key__c FROM Factory_Economy__c WHERE Unique_Snapshot_Key__c LIKE '%ammunition_factory%' LIMIT 1];
        System.assertEquals('key_format_sample.v2_TUR_blank_ammunition_factory_1', fe.Unique_Snapshot_Key__c);

        Artisan_Economy__c ae = [SELECT Unique_Snapshot_Key__c FROM Artisan_Economy__c WHERE Unique_Snapshot_Key__c LIKE '%674_ammunition' LIMIT 1];
        System.assertEquals('key_format_sample.v2_674_ammunition', ae.Unique_Snapshot_Key__c);
    }

    @isTest
    static void testSnapshotIntegrity_UniquenessAndReferential() {
        EconomyImportRequestDTO req = buildSamplePayload('integrity_sample.v2', '1836-01-01');

        Test.startTest();
        EconomyImportResponseDTO res = EconomyImportService.processImport(req);
        Test.stopTest();

        System.assertEquals(true, res.success);

        // Uniqueness check via AggregateResult GROUP BY Unique_Snapshot_Key__c
        List<AggregateResult> dupCE = [
            SELECT Unique_Snapshot_Key__c, COUNT(Id) cnt
            FROM Country_Economy__c
            GROUP BY Unique_Snapshot_Key__c
            HAVING COUNT(Id) > 1
        ];
        System.assertEquals(0, dupCE.size(), 'Zero duplicates allowed for Country_Economy__c');

        List<AggregateResult> dupFE = [
            SELECT Unique_Snapshot_Key__c, COUNT(Id) cnt
            FROM Factory_Economy__c
            GROUP BY Unique_Snapshot_Key__c
            HAVING COUNT(Id) > 1
        ];
        System.assertEquals(0, dupFE.size(), 'Zero duplicates allowed for Factory_Economy__c');

        List<AggregateResult> dupAE = [
            SELECT Unique_Snapshot_Key__c, COUNT(Id) cnt
            FROM Artisan_Economy__c
            GROUP BY Unique_Snapshot_Key__c
            HAVING COUNT(Id) > 1
        ];
        System.assertEquals(0, dupAE.size(), 'Zero duplicates allowed for Artisan_Economy__c');

        // Referential integrity check: all snapshot children belong to the target analysis header
        List<Factory_Economy__c> factories = [SELECT Id, Economy_Analysis__c FROM Factory_Economy__c];
        for (Factory_Economy__c f : factories) {
            System.assertEquals(res.analysisId, f.Economy_Analysis__c, 'Factory must belong to imported analysis header');
        }

        List<Artisan_Economy__c> artisans = [SELECT Id, Economy_Analysis__c FROM Artisan_Economy__c];
        for (Artisan_Economy__c a : artisans) {
            System.assertEquals(res.analysisId, a.Economy_Analysis__c, 'Artisan must belong to imported analysis header');
        }
    }
}
