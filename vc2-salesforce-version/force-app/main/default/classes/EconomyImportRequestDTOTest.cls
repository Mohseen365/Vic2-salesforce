/**
 * @description Unit test suite for EconomyImportRequestDTO JSON deserialization, round-trip, null safety, and contract version.
 */
@isTest
private class EconomyImportRequestDTOTest {

    private static String getSamplePayload() {
        return '{' +
            '"analysis": {' +
                '"saveFileName": "sample_egypt_turkey_1836.v2",' +
                '"ingameDate": "1836-01-01",' +
                '"sourceFileName": "sample_egypt_turkey_1836.v2",' +
                '"playerCountryTag": "EGY",' +
                '"contractVersion": "1.0.0"' +
            '},' +
            '"countries": [' +
                '{' +
                    '"tag": "TUR",' +
                    '"name": "Ottoman Empire",' +
                    '"flagUrl": "https://example.org/flags/TUR.png",' +
                    '"corePopulation": 13252500,' +
                    '"colonyPopulation": 34229316,' +
                    '"population": 47481816,' +
                    '"workforce": 11870454,' +
                    '"employment": 11870454,' +
                    '"gdp": 7010392.13,' +
                    '"factoryGdp": 280400.13,' +
                    '"provinceGdp": 6726168.00,' +
                    '"artisanGdp": 3824.00,' +
                    '"goldIncome": 0.00,' +
                    '"totalImports": 1250340.50,' +
                    '"totalExports": 1890210.75' +
                '}' +
            '],' +
            '"products": [' +
                '{' +
                    '"code": "ammunition",' +
                    '"name": "Ammunition",' +
                    '"basePrice": 18.8313,' +
                    '"price": 18.8313,' +
                    '"totalWorldSupply": 25.5,' +
                    '"realDemand": 30.0,' +
                    '"maxDemand": 50.0' +
                '}' +
            '],' +
            '"countryProducts": [' +
                '{' +
                    '"countryTag": "TUR",' +
                    '"productCode": "ammunition",' +
                    '"soldDomestic": 15.0,' +
                    '"boughtQuantity": 15.0,' +
                    '"thrownToMarket": 10.5,' +
                    '"actualSoldWorld": 10.5,' +
                    '"worldmarketPool": 0.0,' +
                    '"intermediateConsumption": 5.0,' +
                    '"totalSupplyPounds": 480.20,' +
                    '"actualSupplyPounds": 480.20,' +
                    '"actualDemandPounds": 564.94' +
                '}' +
            '],' +
            '"provinces": [' +
                '{' +
                    '"externalProvinceId": "674",' +
                    '"countryTag": "TUR",' +
                    '"stateCode": "TUR_blank",' +
                    '"population": 43319,' +
                    '"rgoProduction": 7.43,' +
                    '"colony": false,' +
                    '"rgoIncome": 16.35,' +
                    '"rgoGdp": 5966.50,' +
                    '"artisanSpending": 4.47,' +
                    '"artisanIncome": 6.60,' +
                    '"artisanGdp": 2.14' +
                '}' +
            '],' +
            '"states": [' +
                '{' +
                    '"stateCode": "TUR_blank",' +
                    '"stateName": "blank",' +
                    '"countryTag": "TUR",' +
                    '"population": 47481816,' +
                    '"gdp": 6729992.30,' +
                    '"gdpRank": 1,' +
                    '"rgoIncome": 18427.86,' +
                    '"pgdp": 6726167.83,' +
                    '"agdp": 3824.48,' +
                    '"fgdp": 0.00,' +
                    '"factoryEmployees": 0,' +
                    '"factoryRevenue": 0.00,' +
                    '"factoryProfit": 0.00' +
                '}' +
            '],' +
            '"factories": [' +
                '{' +
                    '"stateCode": "TUR_876",' +
                    '"countryTag": "TUR",' +
                    '"productCode": "luxury_clothes",' +
                    '"buildingType": "luxury_clothes_factory",' +
                    '"occurrenceIndex": 1,' +
                    '"level": 1,' +
                    '"employees": 7379,' +
                    '"outputQuantity": 2.00,' +
                    '"unsoldQuantity": 0.56,' +
                    '"capitalReserves": 1.00,' +
                    '"revenue": 207.99,' +
                    '"inputCost": 98.87,' +
                    '"wagesPaid": 81.84,' +
                    '"injectedMoney": 0.00,' +
                    '"factoryGdp": 39830.97,' +
                    '"profitRank": 35' +
                '}' +
            '],' +
            '"artisans": [' +
                '{' +
                    '"externalProvinceId": "674",' +
                    '"countryTag": "TUR",' +
                    '"stateCode": "TUR_blank",' +
                    '"productCode": "paper",' +
                    '"artisanType": "paper",' +
                    '"spending": 3.07,' +
                    '"income": 4.39,' +
                    '"agdp": 1.32,' +
                    '"productionQuantity": 1.28' +
                '}' +
            ']' +
        '}';
    }

    @isTest
    static void testDeserializeSamplePayload() {
        String jsonPayload = getSamplePayload();
        Test.startTest();
        EconomyImportRequestDTO dto = (EconomyImportRequestDTO) JSON.deserialize(jsonPayload, EconomyImportRequestDTO.class);
        Test.stopTest();

        Assert.areNotEqual(null, dto, 'DTO should not be null');
        Assert.areNotEqual(null, dto.analysis, 'Analysis should not be null');
        Assert.assertEquals('sample_egypt_turkey_1836.v2', dto.analysis.saveFileName, 'Save file name match');
        Assert.assertEquals('1.0.0', dto.analysis.contractVersion, 'Contract version match');

        Assert.assertEquals(1, dto.countries.size(), 'Country count match');
        Assert.assertEquals('TUR', dto.countries[0].tag, 'Country tag match');
        Assert.assertEquals(13252500, dto.countries[0].corePopulation, 'Core population match');

        Assert.assertEquals(1, dto.products.size(), 'Product count match');
        Assert.assertEquals('ammunition', dto.products[0].code, 'Product code match');

        Assert.assertEquals(1, dto.countryProducts.size(), 'CountryProduct count match');
        Assert.assertEquals('TUR', dto.countryProducts[0].countryTag, 'Country tag match');

        Assert.assertEquals(1, dto.provinces.size(), 'Province count match');
        Assert.assertEquals('674', dto.provinces[0].getProvinceIdAsString(), 'Province ID match');

        Assert.assertEquals(1, dto.states.size(), 'State count match');
        Assert.assertEquals('TUR_blank', dto.states[0].stateCode, 'State code match');

        Assert.assertEquals(1, dto.factories.size(), 'Factory count match');
        Assert.assertEquals('luxury_clothes_factory', dto.factories[0].buildingType, 'Factory building type match');

        Assert.assertEquals(1, dto.artisans.size(), 'Artisan count match');
        Assert.assertEquals('paper', dto.artisans[0].artisanType, 'Artisan type match');
    }

    @isTest
    static void testRoundTripSerialization() {
        String jsonPayload = getSamplePayload();
        EconomyImportRequestDTO dtoOriginal = (EconomyImportRequestDTO) JSON.deserialize(jsonPayload, EconomyImportRequestDTO.class);

        Test.startTest();
        String serialized = JSON.serialize(dtoOriginal);
        EconomyImportRequestDTO dtoRoundTrip = (EconomyImportRequestDTO) JSON.deserialize(serialized, EconomyImportRequestDTO.class);
        Test.stopTest();

        Assert.assertEquals(dtoOriginal.analysis.saveFileName, dtoRoundTrip.analysis.saveFileName, 'Save file name roundtrip');
        Assert.assertEquals(dtoOriginal.analysis.contractVersion, dtoRoundTrip.analysis.contractVersion, 'Contract version roundtrip');
        Assert.assertEquals(dtoOriginal.countries.size(), dtoRoundTrip.countries.size(), 'Countries size roundtrip');
        Assert.assertEquals(dtoOriginal.products.size(), dtoRoundTrip.products.size(), 'Products size roundtrip');
        Assert.assertEquals(dtoOriginal.states.size(), dtoRoundTrip.states.size(), 'States size roundtrip');
        Assert.assertEquals(dtoOriginal.factories.size(), dtoRoundTrip.factories.size(), 'Factories size roundtrip');
        Assert.assertEquals(dtoOriginal.artisans.size(), dtoRoundTrip.artisans.size(), 'Artisans size roundtrip');
    }

    @isTest
    static void testNullAndEmptySafety() {
        String emptyJson = '{}';
        Test.startTest();
        EconomyImportRequestDTO dto = (EconomyImportRequestDTO) JSON.deserialize(emptyJson, EconomyImportRequestDTO.class);
        Test.stopTest();

        Assert.areNotEqual(null, dto, 'DTO should deserialize empty object safely');
        Assert.assertEquals(null, dto.analysis, 'Analysis is null');

        EconomyImportRequestDTO defaultDto = new EconomyImportRequestDTO();
        Assert.areNotEqual(null, defaultDto.countries, 'Default countries list initialized');
        Assert.areNotEqual(null, defaultDto.products, 'Default products list initialized');
        Assert.areNotEqual(null, defaultDto.countryProducts, 'Default countryProducts list initialized');
        Assert.areNotEqual(null, defaultDto.provinces, 'Default provinces list initialized');
        Assert.areNotEqual(null, defaultDto.states, 'Default states list initialized');
        Assert.areNotEqual(null, defaultDto.factories, 'Default factories list initialized');
        Assert.areNotEqual(null, defaultDto.artisans, 'Default artisans list initialized');

        EconomyImportRequestDTO.AnalysisDTO analysis = new EconomyImportRequestDTO.AnalysisDTO();
        Assert.assertEquals('1.0.0', analysis.contractVersion, 'Default contract version initialized');

        EconomyImportRequestDTO.ProvinceDTO prov = new EconomyImportRequestDTO.ProvinceDTO();
        prov.provinceId = 1234;
        Assert.assertEquals('1234', prov.getProvinceIdAsString(), 'Province ID integer conversion');
        prov.externalProvinceId = '5678';
        Assert.assertEquals('5678', prov.getProvinceIdAsString(), 'External province ID string priority');
    }
}
