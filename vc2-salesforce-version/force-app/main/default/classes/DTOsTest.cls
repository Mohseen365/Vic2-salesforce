@isTest
private class DTOsTest {

    @isTest
    static void testCountrySummaryDto() {
        CountrySummaryDTO dto1 = new CountrySummaryDTO();
        System.assertEquals(0.0, dto1.gdp, 'Default GDP should be 0.0');

        Country_Economy__c ce = new Country_Economy__c(
            Country_Tag__c = 'ENG',
            Population__c = 1000000,
            Workforce__c = 400000,
            Employment__c = 380000,
            GDP__c = 15000.0,
            Gold_Income__c = 500.0
        );

        CountrySummaryDTO dto2 = new CountrySummaryDTO(ce);
        System.assertEquals('ENG', dto2.countryTag, 'Tag should match');

        String jsonStr = JSON.serialize(dto2);
        CountrySummaryDTO deserialized = (CountrySummaryDTO) JSON.deserialize(jsonStr, CountrySummaryDTO.class);
        System.assertEquals('ENG', deserialized.countryTag, 'Deserialized tag should match');
    }

    @isTest
    static void testProductSummaryDto() {
        ProductSummaryDTO dto1 = new ProductSummaryDTO();
        System.assertEquals(0.0, dto1.price, 'Default price should be 0.0');

        Product_Economy__c pe = new Product_Economy__c(
            Product_Code__c = 'grain',
            Price__c = 2.5,
            Base_Price__c = 2.0,
            Total_World_Supply__c = 1000.0,
            Real_Demand__c = 900.0,
            Max_Demand__c = 1200.0
        );

        ProductSummaryDTO dto2 = new ProductSummaryDTO(pe);
        System.assertEquals('grain', dto2.productCode, 'Product code should match');

        String jsonStr = JSON.serialize(dto2);
        ProductSummaryDTO deserialized = (ProductSummaryDTO) JSON.deserialize(jsonStr, ProductSummaryDTO.class);
        System.assertEquals('grain', deserialized.productCode, 'Deserialized product code should match');
    }

    @isTest
    static void testCountryProductSummaryDto() {
        CountryProductSummaryDTO dto1 = new CountryProductSummaryDTO();
        System.assertEquals(0.0, dto1.soldDomestic, 'Default sold domestic should be 0.0');

        Country_Product_Economy__c cpe = new Country_Product_Economy__c(
            Product_Code__c = 'iron',
            Sold_Domestic__c = 10.0,
            Bought_Quantity__c = 5.0,
            Thrown_To_Market__c = 15.0,
            Actual_Sold_World__c = 12.0,
            Worldmarket_Pool__c = 20.0,
            Intermediate_Consumption__c = 2.0,
            Total_Supply_Pounds__c = 250.0,
            Actual_Supply_Pounds__c = 220.0,
            Actual_Demand_Pounds__c = 50.0,
            Domestic_Sales_Value__c = 100.0,
            Import_Value__c = 0.0,
            Export_Value__c = 120.0,
            GDP_Contribution__c = 200.0
        );

        CountryProductSummaryDTO dto2 = new CountryProductSummaryDTO(cpe);
        System.assertEquals('iron', dto2.productCode, 'Product code should match');

        String jsonStr = JSON.serialize(dto2);
        CountryProductSummaryDTO deserialized = (CountryProductSummaryDTO) JSON.deserialize(jsonStr, CountryProductSummaryDTO.class);
        System.assertEquals('iron', deserialized.productCode, 'Deserialized product code should match');
    }

    @isTest
    static void testProvinceSummaryDto() {
        ProvinceSummaryDTO dto1 = new ProvinceSummaryDTO();
        System.assertEquals(0, dto1.population, 'Default population should be 0');

        Province_Economy__c pe = new Province_Economy__c(
            Population__c = 50000,
            RGO_Production__c = 120.5
        );

        ProvinceSummaryDTO dto2 = new ProvinceSummaryDTO(pe);
        System.assertEquals(50000, dto2.population, 'Population should match');

        String jsonStr = JSON.serialize(dto2);
        ProvinceSummaryDTO deserialized = (ProvinceSummaryDTO) JSON.deserialize(jsonStr, ProvinceSummaryDTO.class);
        System.assertEquals(50000, deserialized.population, 'Deserialized population should match');
    }

    @isTest
    static void testAnalysisSummaryDto() {
        AnalysisSummaryDTO dto1 = new AnalysisSummaryDTO();
        System.assertEquals(0.0, dto1.totalWorldGdp, 'Default world GDP should be 0.0');

        Economy_Analysis__c ea = new Economy_Analysis__c(
            Save_File_Name__c = 'egypt.v2',
            Source_Save_File_Name__c = 'egypt.v2',
            Ingame_Date__c = Date.newInstance(1848, 3, 12),
            Analysis_Timestamp__c = System.now(),
            Player_Country_Tag__c = 'EGY',
            Total_World_Exports__c = 50000.0,
            Total_World_Imports__c = 50000.0,
            Import_Status__c = 'COMPLETED'
        );

        AnalysisSummaryDTO dto2 = new AnalysisSummaryDTO(ea);
        System.assertEquals('egypt.v2', dto2.saveFileName, 'Save file name should match');

        String jsonStr = JSON.serialize(dto2);
        AnalysisSummaryDTO deserialized = (AnalysisSummaryDTO) JSON.deserialize(jsonStr, AnalysisSummaryDTO.class);
        System.assertEquals('egypt.v2', deserialized.saveFileName, 'Deserialized save file name should match');
    }

    @isTest
    static void testStateSummaryDto() {
        StateSummaryDTO dto1 = new StateSummaryDTO();
        System.assertEquals(0, dto1.population, 'Default population should be 0');

        State_Economy__c se = new State_Economy__c(
            Population__c = 1500000,
            GDP__c = 200000.0,
            GDP_Rank__c = 1
        );

        StateSummaryDTO dto2 = new StateSummaryDTO(se);
        System.assertEquals(1500000, dto2.population, 'Population should match');

        String jsonStr = JSON.serialize(dto2);
        StateSummaryDTO deserialized = (StateSummaryDTO) JSON.deserialize(jsonStr, StateSummaryDTO.class);
        System.assertEquals(1500000, deserialized.population, 'Deserialized population should match');
    }

    @isTest
    static void testFactorySummaryDto() {
        FactorySummaryDTO dto1 = new FactorySummaryDTO();
        System.assertEquals(0, dto1.employees, 'Default employees should be 0');

        Factory_Economy__c fe = new Factory_Economy__c(
            Building_Type__c = 'steel_factory',
            Employees__c = 1200,
            Revenue__c = 500.0,
            Input_Cost__c = 200.0,
            Wages_Paid__c = 100.0
        );

        FactorySummaryDTO dto2 = new FactorySummaryDTO(fe);
        System.assertEquals('steel_factory', dto2.buildingType, 'Building type should match');

        String jsonStr = JSON.serialize(dto2);
        FactorySummaryDTO deserialized = (FactorySummaryDTO) JSON.deserialize(jsonStr, FactorySummaryDTO.class);
        System.assertEquals('steel_factory', deserialized.buildingType, 'Deserialized building type should match');
    }

    @isTest
    static void testArtisanSummaryDto() {
        ArtisanSummaryDTO dto1 = new ArtisanSummaryDTO();
        System.assertEquals(0.0, dto1.spending, 'Default spending should be 0.0');

        Artisan_Economy__c ae = new Artisan_Economy__c(
            Artisan_Type__c = 'fabric',
            Spending__c = 10.0,
            Income__c = 25.0,
            AGDP__c = 15.0
        );

        ArtisanSummaryDTO dto2 = new ArtisanSummaryDTO(ae);
        System.assertEquals('fabric', dto2.artisanType, 'Artisan type should match');

        String jsonStr = JSON.serialize(dto2);
        ArtisanSummaryDTO deserialized = (ArtisanSummaryDTO) JSON.deserialize(jsonStr, ArtisanSummaryDTO.class);
        System.assertEquals('fabric', deserialized.artisanType, 'Deserialized artisan type should match');
    }

    @isTest
    static void testAnalysisComparisonDto() {
        AnalysisComparisonDTO dto = new AnalysisComparisonDTO();
        dto.baseGdp = 100000.0;
        dto.compareGdp = 120000.0;
        dto.gdpGrowthPercent = 20.0;

        AnalysisComparisonDTO.CountryDelta cd = new AnalysisComparisonDTO.CountryDelta();
        cd.countryTag = 'USA';
        cd.baseGdp = 1000.0;
        cd.compareGdp = 1500.0;
        cd.gdpDelta = 500.0;
        cd.gdpGrowthPercent = 50.0;
        dto.countryDeltas.add(cd);

        AnalysisComparisonDTO.ProductDelta pd = new AnalysisComparisonDTO.ProductDelta();
        pd.productCode = 'grain';
        pd.basePrice = 10.0;
        pd.comparePrice = 12.0;
        pd.priceDelta = 2.0;
        pd.priceGrowthPercent = 20.0;
        dto.productDeltas.add(pd);

        String jsonStr = JSON.serialize(dto);
        AnalysisComparisonDTO deserialized = (AnalysisComparisonDTO) JSON.deserialize(jsonStr, AnalysisComparisonDTO.class);
        System.assertEquals(120000.0, deserialized.compareGdp, 'Deserialized compare GDP should match');
        System.assertEquals(1, deserialized.countryDeltas.size(), 'Country deltas count should match');
        System.assertEquals(1, deserialized.productDeltas.size(), 'Product deltas count should match');
    }
}
