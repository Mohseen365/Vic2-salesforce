/**
 * @description Master Ingestion DTO for inbound save-game economy import payload from external parser.
 * Serves as the authoritative data contract between external parsers and Salesforce REST ingestion.
 */
public class EconomyImportRequestDTO {
    public AnalysisDTO analysis;
    public List<CountryDTO> countries;
    public List<ProductDTO> products;
    public List<CountryProductDTO> countryProducts;
    public List<ProvinceDTO> provinces;
    public List<StateDTO> states;
    public List<FactoryDTO> factories;
    public List<ArtisanDTO> artisans;

    public EconomyImportRequestDTO() {
        this.countries = new List<CountryDTO>();
        this.products = new List<ProductDTO>();
        this.countryProducts = new List<CountryProductDTO>();
        this.provinces = new List<ProvinceDTO>();
        this.states = new List<StateDTO>();
        this.factories = new List<FactoryDTO>();
        this.artisans = new List<ArtisanDTO>();
    }

    public class AnalysisDTO {
        public String saveFileName;
        public String ingameDate;
        public String sourceFileName;
        public String playerCountryTag;
        public String contractVersion;

        public AnalysisDTO() {
            this.contractVersion = '1.0.0';
        }
    }

    public class CountryDTO {
        public String tag;
        public String name;
        public String flagUrl;
        public Integer corePopulation;
        public Integer colonyPopulation;
        public Integer population;
        public Integer workforce;
        public Integer employment;
        public Decimal gdp;
        public Decimal factoryGdp;
        public Decimal provinceGdp;
        public Decimal artisanGdp;
        public Decimal goldIncome;
        public Decimal totalImports;
        public Decimal totalExports;
    }

    public class ProductDTO {
        public String code;
        public String name;
        public Decimal basePrice;
        public Decimal price;
        public Decimal totalWorldSupply;
        public Decimal realDemand;
        public Decimal maxDemand;
    }

    public class CountryProductDTO {
        public String countryTag;
        public String productCode;
        public Decimal soldDomestic;
        public Decimal boughtQuantity;
        public Decimal thrownToMarket;
        public Decimal actualSoldWorld;
        public Decimal worldmarketPool;
        public Decimal intermediateConsumption;
        public Decimal totalSupplyPounds;
        public Decimal actualSupplyPounds;
        public Decimal actualDemandPounds;
    }

    public class ProvinceDTO {
        public Object provinceId;
        public String externalProvinceId;
        public String countryTag;
        public String stateCode;
        public Integer population;
        public Decimal rgoProduction;
        public Boolean colony;
        public Decimal rgoIncome;
        public Decimal rgoGdp;
        public Decimal artisanSpending;
        public Decimal artisanIncome;
        public Decimal artisanGdp;

        public String getProvinceIdAsString() {
            if (externalProvinceId != null) {
                return externalProvinceId;
            }
            return provinceId != null ? String.valueOf(provinceId) : null;
        }
    }

    public class StateDTO {
        public String stateCode;
        public String stateName;
        public String countryTag;
        public Integer population;
        public Decimal gdp;
        public Integer gdpRank;
        public Decimal rgoIncome;
        public Decimal pgdp;
        public Decimal agdp;
        public Decimal fgdp;
        public Integer factoryEmployees;
        public Decimal factoryRevenue;
        public Decimal factoryProfit;
    }

    public class FactoryDTO {
        public String stateCode;
        public String countryTag;
        public String productCode;
        public String buildingType;
        public Integer occurrenceIndex;
        public Integer level;
        public Integer employees;
        public Decimal outputQuantity;
        public Decimal unsoldQuantity;
        public Decimal capitalReserves;
        public Decimal revenue;
        public Decimal inputCost;
        public Decimal wagesPaid;
        public Decimal injectedMoney;
        public Decimal factoryGdp;
        public Integer profitRank;
    }

    public class ArtisanDTO {
        public String externalProvinceId;
        public String countryTag;
        public String stateCode;
        public String productCode;
        public String artisanType;
        public Decimal spending;
        public Decimal income;
        public Decimal agdp;
        public Decimal productionQuantity;
    }
}
