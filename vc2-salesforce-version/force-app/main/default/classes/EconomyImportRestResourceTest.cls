@isTest
private class EconomyImportRestResourceTest {

    private static String getValidJsonBody() {
        return '{' +
            '"analysis": {' +
                '"saveGameName": "Prussia_1848_03_12",' +
                '"ingameDate": "1848-03-12",' +
                '"sourceFileName": "Prussia_1848_03_12.v2",' +
                '"playerCountryTag": "PRU"' +
            '},' +
            '"countries": [' +
                '{ "tag": "PRU", "name": "Prussia", "population": 14820000, "workforce": 3705000, "employment": 3550000, "goldIncome": 12000 }' +
            '],' +
            '"products": [' +
                '{ "code": "grain", "name": "Grain", "price": 2.10, "basePrice": 2.00, "totalWorldSupply": 45000.0, "realDemand": 42000.0, "maxDemand": 48000.0 }' +
            '],' +
            '"countryProducts": [' +
                '{ "countryTag": "PRU", "productCode": "grain", "soldDomestic": 1400.0, "boughtQuantity": 60.0, "thrownToMarket": 80.0, "actualSoldWorld": 70.0, "worldmarketPool": 4000.0, "intermediateConsumption": 0.0, "totalSupplyPounds": 1450.0, "actualSupplyPounds": 1440.0, "actualDemandPounds": 1500.0 }' +
            '],' +
            '"provinces": [' +
                '{ "provinceId": 42, "countryTag": "PRU", "population": 85000, "rgoProduction": 120.0 }' +
            ']' +
        '}';
    }

    @isTest
    static void testDoPostSuccess() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/economy/import';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(getValidJsonBody());

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        EconomyImportResponseDTO response = EconomyImportRestResource.doPost();
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null.');
        System.assertEquals(true, response.success, 'Import should be successful.');
        System.assertEquals(200, res.statusCode, 'Status code should be 200.');
        System.assertNotEquals(null, response.analysisId);
        System.assertEquals('COMPLETED', response.importStatus);
    }

    @isTest
    static void testDoPostEmptyBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/economy/import';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        EconomyImportResponseDTO response = EconomyImportRestResource.doPost();
        Test.stopTest();

        System.assertEquals(false, response.success);
        System.assertEquals(400, res.statusCode);
        System.assertEquals('FAILED', response.importStatus);
    }

    @isTest
    static void testDoPostMalformedJson() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/economy/import';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{ "analysis": { invalid json } }');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        EconomyImportResponseDTO response = EconomyImportRestResource.doPost();
        Test.stopTest();

        System.assertEquals(false, response.success);
        System.assertEquals(500, res.statusCode);
        System.assertEquals('FAILED', response.importStatus);
    }
}
