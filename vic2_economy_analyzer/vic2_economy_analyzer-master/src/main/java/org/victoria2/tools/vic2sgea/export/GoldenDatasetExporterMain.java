package org.victoria2.tools.vic2sgea.export;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.victoria2.tools.vic2sgea.entities.Country;
import org.victoria2.tools.vic2sgea.entities.Product;
import org.victoria2.tools.vic2sgea.entities.ProductStorage;
import org.victoria2.tools.vic2sgea.main.Report;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

public class GoldenDatasetExporterMain {

    public static void main(String[] args) {
        if (args.length < 4) {
            System.err.println("Usage: GoldenDatasetExporterMain <savePath> <gamePath> <modPath> <outputDir>");
            System.exit(1);
        }

        String savePath = args[0];
        String gamePath = args[1];
        String modPath = args[2];
        String outputDir = args[3];

        System.out.println("Loading report for Golden Dataset export...");
        // Pass filter = true so GenericObjectConsumer loads provinces, countries, and worldmarket
        Report report = new Report(savePath, gamePath, modPath, true);

        try {
            Path outPath = Paths.get(outputDir);
            Files.createDirectories(outPath);

            exportJson(report, outPath.resolve("golden-dataset.json"));
            exportCsv(report, outPath.resolve("golden-dataset.csv"));
            exportMarkdown(report, outPath.resolve("golden-dataset.md"));

            System.out.println("Golden dataset exported successfully to: " + outputDir);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(2);
        }
    }

    private static double sanitize(double val) {
        if (Double.isNaN(val) || Double.isInfinite(val)) {
            return 0.0;
        }
        return val;
    }

    private static float sanitize(float val) {
        if (Float.isNaN(val) || Float.isInfinite(val)) {
            return 0.0f;
        }
        return val;
    }

    private static void exportJson(Report report, Path targetFile) throws IOException {
        Map<String, Object> root = new LinkedHashMap<>();

        Map<String, Object> header = new LinkedHashMap<>();
        header.put("currentDate", report.getCurrentDate());
        header.put("startDate", report.getStartDate());
        header.put("playerCountry", report.getPlayerCountry() != null ? report.getPlayerCountry().getTag() : "NONE");
        header.put("popCountInProvinces", report.popCount);
        root.put("header", header);

        List<Map<String, Object>> countriesJson = new ArrayList<>();
        for (Country country : report.getCountryList()) {
            Map<String, Object> cMap = new LinkedHashMap<>();
            cMap.put("tag", country.getTag());
            cMap.put("officialName", country.getOfficialName());
            cMap.put("population", country.getPopulation());
            cMap.put("workforceRGO", country.getWorkforceRgo());
            cMap.put("employmentRGO", country.getEmploymentRGO());
            cMap.put("unemploymentRateRGO", sanitize(country.getUnemploymentRateRgo()));
            cMap.put("workforceFactory", country.getWorkforceFactory());
            cMap.put("employmentFactory", country.getEmploymentFactory());
            cMap.put("unemploymentRateFactory", sanitize(country.getUnemploymentRateFactory()));
            cMap.put("wagesRGO", sanitize(country.wagesRgo));
            cMap.put("wagesFactory", sanitize(country.wagesFactory));
            cMap.put("goldIncome", country.getGoldIncome());
            cMap.put("totalSupplyPounds", sanitize(country.getTotalSupply()));
            cMap.put("actualSupplyPounds", sanitize(country.getSold()));
            cMap.put("actualDemandPounds", sanitize(country.getBought()));
            cMap.put("importedPounds", sanitize(country.getImported()));
            cMap.put("exportedPounds", sanitize(country.getExported()));
            cMap.put("gdpPounds", sanitize(country.getGdp()));
            cMap.put("gdpPerCapita", sanitize(country.getGdpPerCapita()));
            cMap.put("gdpSharePercent", sanitize(country.getGDPPart()));
            cMap.put("gdpRank", country.getGDPPlace());

            List<Map<String, Object>> storageJson = new ArrayList<>();
            for (ProductStorage storage : country.getStorage().values()) {
                Map<String, Object> sMap = new LinkedHashMap<>();
                sMap.put("productName", storage.product.getName());
                sMap.put("price", sanitize(storage.getPrice()));
                sMap.put("soldDomestic", sanitize(storage.getSoldDomestic()));
                sMap.put("totalSupplyPounds", sanitize(storage.getTotalSupplyPounds()));
                sMap.put("actualDemandPounds", sanitize(storage.getActualDemandPounds()));
                sMap.put("actualSupplyPounds", sanitize(storage.getActualSupplyPounds()));
                sMap.put("importedPounds", sanitize(storage.getImportedPounds()));
                sMap.put("exportedPounds", sanitize(storage.getExportedPounds()));
                sMap.put("gdpPounds", sanitize(storage.getGdpPounds()));
                storageJson.add(sMap);
            }
            cMap.put("productStorages", storageJson);
            countriesJson.add(cMap);
        }
        root.put("countries", countriesJson);

        List<Map<String, Object>> productsJson = new ArrayList<>();
        for (Product product : report.getProductList()) {
            Map<String, Object> pMap = new LinkedHashMap<>();
            pMap.put("name", product.getName());
            pMap.put("basePrice", sanitize(product.getBasePrice()));
            pMap.put("minPrice", sanitize(product.getMinPrice()));
            pMap.put("maxPrice", sanitize(product.getMaxPrice()));
            pMap.put("price", sanitize(product.getPrice()));
            pMap.put("trend", product.getTrend());
            pMap.put("inflationPercent", sanitize(product.getInflation()));
            pMap.put("supplyPool", sanitize(product.getSupply()));
            pMap.put("actualSupply", sanitize(product.getActualSupply()));
            pMap.put("realDemand", sanitize(product.getDemand()));
            pMap.put("maxDemand", sanitize(product.getMaxDemand()));
            pMap.put("consumption", sanitize(product.getConsumption()));
            pMap.put("overproducedPercent", sanitize(product.getOverproduced()));
            productsJson.add(pMap);
        }
        root.put("products", productsJson);

        Gson gson = new GsonBuilder()
                .serializeSpecialFloatingPointValues()
                .setPrettyPrinting()
                .create();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(targetFile.toFile()))) {
            gson.toJson(root, writer);
        }
    }

    private static void exportCsv(Report report, Path targetFile) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(targetFile.toFile()))) {
            writer.write("RECORD_TYPE,TAG_OR_PRODUCT,NAME,POPULATION,GDP_POUNDS,GDP_PER_CAPITA,GDP_SHARE_PCT,UNEMP_RGO_PCT,UNEMP_FACTORY_PCT,GOLD_INCOME,PRICE,BASE_PRICE,WORLD_SUPPLY,REAL_DEMAND,OVERPRODUCED_PCT\n");

            for (Country country : report.getCountryList()) {
                writer.write(String.format(Locale.US,
                        "COUNTRY,%s,\"%s\",%d,%.4f,%.4f,%.4f,%.4f,%.4f,%d,,,,,\n",
                        country.getTag(),
                        country.getOfficialName(),
                        country.getPopulation(),
                        sanitize(country.getGdp()),
                        sanitize(country.getGdpPerCapita()),
                        sanitize(country.getGDPPart()),
                        sanitize(country.getUnemploymentRateRgo()),
                        sanitize(country.getUnemploymentRateFactory()),
                        country.getGoldIncome()
                ));
            }

            for (Product product : report.getProductList()) {
                writer.write(String.format(Locale.US,
                        "PRODUCT,%s,\"%s\",,,,,,,,,%.4f,%.4f,%.4f,%.4f,%.4f\n",
                        product.getName(),
                        product.getName(),
                        sanitize(product.getPrice()),
                        sanitize(product.getBasePrice()),
                        sanitize(product.getSupply()),
                        sanitize(product.getDemand()),
                        sanitize(product.getOverproduced())
                ));
            }
        }
    }

    private static void exportMarkdown(Report report, Path targetFile) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(targetFile.toFile()))) {
            writer.write("# Victoria 2 Economy Analyzer — Golden Dataset Reference\n\n");
            writer.write(String.format("- **Analysis Date:** %s\n", report.getCurrentDate()));
            writer.write(String.format("- **Start Date:** %s\n", report.getStartDate()));
            writer.write(String.format("- **Player Country:** %s\n\n", report.getPlayerCountry() != null ? report.getPlayerCountry().getTag() : "N/A"));

            writer.write("## 1. Country Economic Overview\n\n");
            writer.write("| Tag | Name | Population | GDP (£) | GDP/Capita (£/100k) | GDP Share (%) | Unemployment RGO (%) | Unemployment Factory (%) | Gold Income (£) |\n");
            writer.write("| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n");

            for (Country c : report.getCountryList()) {
                writer.write(String.format(Locale.US,
                        "| %s | %s | %d | %.2f | %.2f | %.2f%% | %.2f%% | %.2f%% | %d |\n",
                        c.getTag(), c.getOfficialName(), c.getPopulation(), sanitize(c.getGdp()),
                        sanitize(c.getGdpPerCapita()), sanitize(c.getGDPPart()), sanitize(c.getUnemploymentRateRgo()),
                        sanitize(c.getUnemploymentRateFactory()), c.getGoldIncome()
                ));
            }

            writer.write("\n## 2. World Commodity Market Overview\n\n");
            writer.write("| Commodity | Base Price (£) | World Price (£) | Inflation (%) | World Supply Pool | World Real Demand | Overproduced (%) |\n");
            writer.write("| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n");

            for (Product p : report.getProductList()) {
                writer.write(String.format(Locale.US,
                        "| %s | %.2f | %.2f | %.2f%% | %.2f | %.2f | %.2f%% |\n",
                        p.getName(), sanitize(p.getBasePrice()), sanitize(p.getPrice()), sanitize(p.getInflation()),
                        sanitize(p.getSupply()), sanitize(p.getDemand()), sanitize(p.getOverproduced())
                ));
            }

            writer.write("\n## 3. Country Product Storage Breakdowns\n\n");
            for (Country c : report.getCountryList()) {
                writer.write(String.format("### Country: %s (%s)\n\n", c.getTag(), c.getOfficialName()));
                writer.write("| Product | Price (£) | Domestic Demand (Pool) | Sold Domestic | Actual Supply (£) | Actual Demand (£) | Imported (£) | Exported (£) | GDP (£) |\n");
                writer.write("| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n");

                for (ProductStorage ps : c.getStorage().values()) {
                    writer.write(String.format(Locale.US,
                            "| %s | %.2f | %.2f | %.2f | %.2f | %.2f | %.2f | %.2f | %.2f |\n",
                            ps.product.getName(), sanitize(ps.getPrice()), sanitize(ps.getSoldDomestic()), sanitize(ps.getSoldDomestic()),
                            sanitize(ps.getActualSupplyPounds()), sanitize(ps.getActualDemandPounds()), sanitize(ps.getImportedPounds()),
                            sanitize(ps.getExportedPounds()), sanitize(ps.getGdpPounds())
                    ));
                }
                writer.write("\n");
            }
        }
    }
}
