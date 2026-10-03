/**
 * @description Request DTO for inbound economy import payload from external EUG save-game parser.
 * Aligns with Section 2.2 JSON data contract.
 */
public with sharing class EconomyImportRequestDTO {
    public AnalysisDTO analysis;
    public List<CountryDTO> countries;
    public List<ProductDTO> products;
    public List<CountryProductDTO> countryProducts;
    public List<ProvinceDTO> provinces;

    public EconomyImportRequestDTO() {
        this.countries = new List<CountryDTO>();
        this.products = new List<ProductDTO>();
        this.countryProducts = new List<CountryProductDTO>();
        this.provinces = new List<ProvinceDTO>();
    }

    public class AnalysisDTO {
        public String saveGameName;
        public String ingameDate;
        public String sourceFileName;
        public String playerCountryTag;
    }

    public class CountryDTO {
        public String tag;
        public String name;
        public Decimal population;
        public Decimal workforce;
        public Decimal employment;
        public Decimal goldIncome;
    }

    public class ProductDTO {
        public String code;
        public String name;
        public Decimal price;
        public Decimal basePrice;
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
        public String countryTag;
        public Decimal population;
        public Decimal rgoProduction;

        public String getProvinceIdAsString() {
            return provinceId != null ? String.valueOf(provinceId) : null;
        }
    }
}
