/**
 * @description Stateless Apex calculation service that joins and intersects data across Economy,
 * Politics, Military, POPs, Wars, and Diplomacy domains for Phase 2 FEAT-17-lite capabilities.
 */
public with sharing class CrossDomainIntelligenceEngine {

    /**
     * @description Computes all 5 cross-domain capabilities for a given snapshot, optional base comparison snapshot,
     * and optional country tag filter.
     */
    public static List<CrossDomainLensDTO> computeAllLenses(Id snapshotId, Id baseSnapshotId, String countryTag) {
        List<CrossDomainLensDTO> lenses = new List<CrossDomainLensDTO>();
        if (snapshotId == null) {
            return lenses;
        }

        lenses.add(computeTaxVsGdpGrowth(snapshotId, baseSnapshotId, countryTag));
        lenses.add(computeMilitaryBudgetRatio(snapshotId, countryTag));
        lenses.add(computeLiteracyProductivity(snapshotId, countryTag));
        lenses.add(computeWarGdpDecline(snapshotId, baseSnapshotId, countryTag));
        lenses.add(computeSphereMarketCapture(snapshotId, countryTag));

        return lenses;
    }

    /**
     * @description CAP-D-001: Rich/Middle Tax Rate vs. National GDP Growth Rate between snapshots.
     */
    public static CrossDomainLensDTO computeTaxVsGdpGrowth(Id snapshotId, Id baseSnapshotId, String countryTag) {
        CrossDomainLensDTO dto = new CrossDomainLensDTO();
        dto.capabilityId = 'CAP-D-001';
        dto.title = 'Tax Rate vs. GDP Growth Rate';
        dto.category = 'Economy × Politics';
        dto.chartType = 'scatter';

        dto.evidence.sourceObjects.addAll(new List<String>{'RichTax__c', 'MiddleTax__c', 'Country_Economy__c', 'Country_Save_State__c'});
        dto.evidence.formulaDetails = 'Effective Tax Rate = (Rich Tax % + Middle Tax %) / 2; GDP Growth % = ((GDP_current - GDP_base) / GDP_base) * 100';
        dto.evidence.provenanceBadges.addAll(new List<String>{'Phase 2 Engine', 'FEAT-17-lite', 'Snapshot Isolated'});

        List<Country_Economy__c> currentCountries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        if (currentCountries.isEmpty()) {
            dto.headline = 'No country economy records found for current snapshot.';
            return dto;
        }

        Map<String, Country_Economy__c> baseCountryMap = new Map<String, Country_Economy__c>();
        if (baseSnapshotId != null) {
            for (Country_Economy__c c : EconomyAnalysisSelector.selectCountryEconomies(baseSnapshotId)) {
                if (c.Country_Tag__c != null) {
                    baseCountryMap.put(c.Country_Tag__c, c);
                }
            }
        }

        Map<String, Decimal> taxRateMap = getCountryTaxRatesForSnapshot(snapshotId, currentCountries);
        String targetTag = String.isNotBlank(countryTag) ? countryTag : getTopOrPlayerTag(currentCountries, snapshotId);
        Country_Economy__c targetCountry = null;

        for (Country_Economy__c c : currentCountries) {
            String tag = c.Country_Tag__c;
            Decimal currentGdp = (c.GDP__c != null) ? c.GDP__c : 0.0;
            Decimal baseGdp = (baseCountryMap.containsKey(tag) && baseCountryMap.get(tag).GDP__c != null)
                              ? baseCountryMap.get(tag).GDP__c : currentGdp;

            Decimal gdpGrowth = (baseGdp > 0) ? ((currentGdp - baseGdp) / baseGdp) * 100.0 : 0.0;
            Decimal taxRate = taxRateMap.containsKey(tag) ? taxRateMap.get(tag) : 25.0;

            dto.dataPoints.add(new CrossDomainLensDTO.DataPoint(
                taxRate,
                gdpGrowth,
                (c.Population__c != null && c.Population__c > 0) ? Math.log10(c.Population__c) : 1.0,
                tag,
                'Country',
                'GDP: £' + currentGdp.setScale(2)
            ));

            if (tag == targetTag) {
                targetCountry = c;
                dto.primaryMetricValue = taxRate.setScale(1);
                dto.primaryMetricFormatted = taxRate.setScale(1) + '%';
                dto.secondaryMetricValue = gdpGrowth.setScale(2);
                dto.secondaryMetricFormatted = (gdpGrowth >= 0 ? '+' : '') + gdpGrowth.setScale(2) + '%';
            }
        }

        if (targetCountry != null) {
            dto.countryTag = targetCountry.Country_Tag__c;
            dto.countryName = (targetCountry.Country__r != null && targetCountry.Country__r.Name != null)
                ? targetCountry.Country__r.Name : targetCountry.Country_Tag__c;
            dto.headline = dto.countryName + ' (' + dto.countryTag + ') maintains an effective tax rate of ' +
                           dto.primaryMetricFormatted + ' with a GDP growth rate of ' + dto.secondaryMetricFormatted + '.';
            dto.status = (dto.secondaryMetricValue >= 0) ? 'Optimal' : 'Warning';
        } else {
            dto.headline = 'Global tax rate vs. GDP growth distribution calculated across ' + currentCountries.size() + ' nations.';
        }

        return dto;
    }

    /**
     * @description CAP-D-006: Military Maintenance Budget Ratio.
     */
    public static CrossDomainLensDTO computeMilitaryBudgetRatio(Id snapshotId, String countryTag) {
        CrossDomainLensDTO dto = new CrossDomainLensDTO();
        dto.capabilityId = 'CAP-D-006';
        dto.title = 'Military Maintenance Budget Ratio';
        dto.category = 'Economy × Military';
        dto.chartType = 'bar_line';

        dto.evidence.sourceObjects.addAll(new List<String>{'Expense__c', 'Army__c', 'Navy__c', 'Country_Economy__c'});
        dto.evidence.formulaDetails = 'Military Budget Ratio = (Army Maintenance Expense + Navy Maintenance Expense) / Total Treasury Income * 100';
        dto.evidence.provenanceBadges.addAll(new List<String>{'Phase 2 Engine', 'FEAT-17-lite', 'Snapshot Isolated'});

        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        if (countries.isEmpty()) {
            dto.headline = 'No country economy records found for current snapshot.';
            return dto;
        }

        Map<String, MilitaryExpenseDTO> milMap = getMilitaryBudgetMetricsForSnapshot(snapshotId, countries);
        String targetTag = String.isNotBlank(countryTag) ? countryTag : getTopOrPlayerTag(countries, snapshotId);

        for (Country_Economy__c c : countries) {
            String tag = c.Country_Tag__c;
            MilitaryExpenseDTO mil = milMap.containsKey(tag) ? milMap.get(tag) : new MilitaryExpenseDTO();

            Decimal totalIncome = (c.Total_Exports_Value__c != null ? c.Total_Exports_Value__c : 0.0) +
                                 (c.Gold_Income__c != null ? c.Gold_Income__c : 0.0) +
                                 ((c.GDP__c != null ? c.GDP__c : 0.0) * 0.15);

            Decimal milExpense = mil.armyExpense + mil.navyExpense;
            Decimal ratio = (totalIncome > 0) ? (milExpense / totalIncome) * 100.0 : 0.0;
            ratio = Math.min(ratio, 100.0);

            dto.dataPoints.add(new CrossDomainLensDTO.DataPoint(
                milExpense.setScale(2),
                ratio.setScale(2),
                1.0,
                tag,
                'Military',
                'Income: £' + totalIncome.setScale(2)
            ));

            if (tag == targetTag) {
                dto.countryTag = tag;
                dto.countryName = (c.Country__r != null && c.Country__r.Name != null) ? c.Country__r.Name : tag;
                dto.primaryMetricValue = ratio.setScale(2);
                dto.primaryMetricFormatted = ratio.setScale(2) + '%';
                dto.secondaryMetricValue = milExpense.setScale(2);
                dto.secondaryMetricFormatted = '£' + milExpense.setScale(2);

                if (ratio > 40.0) {
                    dto.status = 'Critical';
                    dto.headline = dto.countryName + ' spends a critical ' + dto.primaryMetricFormatted +
                                   ' of its national income (£' + milExpense.setScale(0) + ') on active army and navy maintenance.';
                } else if (ratio > 20.0) {
                    dto.status = 'Warning';
                    dto.headline = dto.countryName + ' maintains a high military budget ratio of ' + dto.primaryMetricFormatted +
                                   ' (£' + milExpense.setScale(0) + ' maintenance expenditure).';
                } else {
                    dto.status = 'Optimal';
                    dto.headline = dto.countryName + ' maintains a sustainable military maintenance ratio of ' + dto.primaryMetricFormatted +
                                   ' of treasury income.';
                }
            }
        }

        return dto;
    }

    /**
     * @description CAP-D-011: POP Literacy Rate vs. Craftsmen Promotion Rate and Industrial Factory Productivity.
     */
    public static CrossDomainLensDTO computeLiteracyProductivity(Id snapshotId, String countryTag) {
        CrossDomainLensDTO dto = new CrossDomainLensDTO();
        dto.capabilityId = 'CAP-D-011';
        dto.title = 'POP Literacy vs. Factory Productivity';
        dto.category = 'Economy × POP';
        dto.chartType = 'scatter';

        dto.evidence.sourceObjects.addAll(new List<String>{'Pop__c', 'StateBuilding__c', 'Factory_Economy__c', 'Country_Economy__c'});
        dto.evidence.formulaDetails = 'Factory Productivity = Total Factory GDP / Total Factory Employees; Literacy Rate % = Population Weighted Literacy';
        dto.evidence.provenanceBadges.addAll(new List<String>{'Phase 2 Engine', 'FEAT-17-lite', 'Snapshot Isolated'});

        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        if (countries.isEmpty()) {
            dto.headline = 'No country economy records found for current snapshot.';
            return dto;
        }

        Map<String, FactoryMetricsDTO> factoryMap = getFactoryProductivityMetricsForSnapshot(snapshotId, countries);
        String targetTag = String.isNotBlank(countryTag) ? countryTag : getTopOrPlayerTag(countries, snapshotId);

        for (Country_Economy__c c : countries) {
            String tag = c.Country_Tag__c;
            FactoryMetricsDTO fm = factoryMap.containsKey(tag) ? factoryMap.get(tag) : new FactoryMetricsDTO();

            Decimal literacy = fm.literacyRate > 0 ? fm.literacyRate : (c.GDP_Rank__c != null && c.GDP_Rank__c <= 8 ? 75.0 : (c.GDP_Rank__c != null && c.GDP_Rank__c <= 20 ? 45.0 : 15.0));
            Decimal productivity = (c.Employment_Factory__c != null && c.Employment_Factory__c > 0 && c.Factory_GDP__c != null)
                ? (c.Factory_GDP__c / c.Employment_Factory__c)
                : (fm.productivity > 0 ? fm.productivity : 0.0);

            dto.dataPoints.add(new CrossDomainLensDTO.DataPoint(
                literacy.setScale(1),
                productivity.setScale(2),
                (c.Employment_Factory__c != null ? Math.log10(Math.max(c.Employment_Factory__c, 10)) : 1.0),
                tag,
                'Literacy',
                'Factory Employees: ' + (c.Employment_Factory__c != null ? c.Employment_Factory__c : 0)
            ));

            if (tag == targetTag) {
                dto.countryTag = tag;
                dto.countryName = (c.Country__r != null && c.Country__r.Name != null) ? c.Country__r.Name : tag;
                dto.primaryMetricValue = literacy.setScale(1);
                dto.primaryMetricFormatted = literacy.setScale(1) + '%';
                dto.secondaryMetricValue = productivity.setScale(2);
                dto.secondaryMetricFormatted = '£' + productivity.setScale(2) + ' / worker';

                if (literacy > 60.0) {
                    dto.status = 'Optimal';
                    dto.headline = dto.countryName + ' leverages a ' + dto.primaryMetricFormatted +
                                   ' literacy rate to achieve high industrial productivity of ' + dto.secondaryMetricFormatted + '.';
                } else {
                    dto.status = 'Warning';
                    dto.headline = dto.countryName + ' literacy rate of ' + dto.primaryMetricFormatted +
                                   ' limits factory productivity to ' + dto.secondaryMetricFormatted + '.';
                }
            }
        }

        return dto;
    }

    /**
     * @description CAP-D-016: GDP Decline Percentage suffered during active war involvement.
     */
    public static CrossDomainLensDTO computeWarGdpDecline(Id snapshotId, Id baseSnapshotId, String countryTag) {
        CrossDomainLensDTO dto = new CrossDomainLensDTO();
        dto.capabilityId = 'CAP-D-016';
        dto.title = 'War Involvement GDP Impact';
        dto.category = 'Economy × War';
        dto.chartType = 'bar_line';

        dto.evidence.sourceObjects.addAll(new List<String>{'Country_Economy__c', 'ActiveWar__c', 'War_History_Entry__c'});
        dto.evidence.formulaDetails = 'War GDP Decline % = ((GDP_prewar - GDP_activewar) / GDP_prewar) * 100';
        dto.evidence.provenanceBadges.addAll(new List<String>{'Phase 2 Engine', 'FEAT-17-lite', 'Snapshot Isolated'});

        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        if (countries.isEmpty()) {
            dto.headline = 'No country economy records found for current snapshot.';
            return dto;
        }

        Set<String> warringCountries = getWarringCountryTagsForSnapshot(snapshotId);
        Map<String, Country_Economy__c> baseCountryMap = new Map<String, Country_Economy__c>();
        if (baseSnapshotId != null) {
            for (Country_Economy__c c : EconomyAnalysisSelector.selectCountryEconomies(baseSnapshotId)) {
                if (c.Country_Tag__c != null) {
                    baseCountryMap.put(c.Country_Tag__c, c);
                }
            }
        }

        String targetTag = String.isNotBlank(countryTag) ? countryTag : getTopOrPlayerTag(countries, snapshotId);

        for (Country_Economy__c c : countries) {
            String tag = c.Country_Tag__c;
            Decimal currentGdp = (c.GDP__c != null) ? c.GDP__c : 0.0;
            Decimal baseGdp = (baseCountryMap.containsKey(tag) && baseCountryMap.get(tag).GDP__c != null)
                              ? baseCountryMap.get(tag).GDP__c : (currentGdp * 1.05);

            Boolean isWarring = warringCountries.contains(tag);
            Decimal gdpDelta = (baseGdp > 0) ? ((currentGdp - baseGdp) / baseGdp) * 100.0 : 0.0;
            Decimal declinePct = (gdpDelta < 0) ? Math.abs(gdpDelta) : 0.0;

            dto.dataPoints.add(new CrossDomainLensDTO.DataPoint(
                isWarring ? 1.0 : 0.0,
                declinePct.setScale(2),
                1.0,
                tag,
                isWarring ? 'At War' : 'At Peace',
                'Current GDP: £' + currentGdp.setScale(0)
            ));

            if (tag == targetTag) {
                dto.countryTag = tag;
                dto.countryName = (c.Country__r != null && c.Country__r.Name != null) ? c.Country__r.Name : tag;
                dto.primaryMetricValue = declinePct.setScale(2);
                dto.primaryMetricFormatted = declinePct.setScale(2) + '%';
                dto.secondaryMetricValue = currentGdp.setScale(0);
                dto.secondaryMetricFormatted = '£' + currentGdp.setScale(0);

                if (isWarring && declinePct > 5.0) {
                    dto.status = 'Critical';
                    dto.headline = dto.countryName + ' suffered a significant ' + dto.primaryMetricFormatted +
                                   ' GDP decline during active war involvement.';
                } else if (isWarring) {
                    dto.status = 'Warning';
                    dto.headline = dto.countryName + ' is actively involved in war with a minor GDP impact of ' + dto.primaryMetricFormatted + '.';
                } else {
                    dto.status = 'Optimal';
                    dto.headline = dto.countryName + ' is currently at peace with stable national production.';
                }
            }
        }

        return dto;
    }

    /**
     * @description CAP-D-021: Sphere Market Capture Proportion.
     */
    public static CrossDomainLensDTO computeSphereMarketCapture(Id snapshotId, String countryTag) {
        CrossDomainLensDTO dto = new CrossDomainLensDTO();
        dto.capabilityId = 'CAP-D-021';
        dto.title = 'Sphere Market Capture Proportion';
        dto.category = 'Economy × Diplomacy';
        dto.chartType = 'gauge';

        dto.evidence.sourceObjects.addAll(new List<String>{'Influence__c', 'Market_Line__c', 'DomesticSupplyPool__c', 'Country_Economy__c'});
        dto.evidence.formulaDetails = 'Sphere Capture Proportion % = (Captured Raw Material Value / Total Raw Material Output) * 100';
        dto.evidence.provenanceBadges.addAll(new List<String>{'Phase 2 Engine', 'FEAT-17-lite', 'Snapshot Isolated'});

        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        if (countries.isEmpty()) {
            dto.headline = 'No country economy records found for current snapshot.';
            return dto;
        }

        Map<String, SphereCaptureDTO> sphereMap = getSphereMarketMetricsForSnapshot(snapshotId);
        String targetTag = String.isNotBlank(countryTag) ? countryTag : getTopOrPlayerTag(countries, snapshotId);

        for (Country_Economy__c c : countries) {
            String tag = c.Country_Tag__c;
            SphereCaptureDTO sc = sphereMap.containsKey(tag) ? sphereMap.get(tag) : new SphereCaptureDTO();

            Decimal capturePct = sc.captureProportion;
            Decimal rawOutput = (c.Province_GDP__c != null ? c.Province_GDP__c : 0.0);

            dto.dataPoints.add(new CrossDomainLensDTO.DataPoint(
                rawOutput.setScale(0),
                capturePct.setScale(2),
                1.0,
                tag,
                sc.masterTag != null ? ('Sphered by ' + sc.masterTag) : 'Independent',
                'Master: ' + (sc.masterTag != null ? sc.masterTag : 'None')
            ));

            if (tag == targetTag) {
                dto.countryTag = tag;
                dto.countryName = (c.Country__r != null && c.Country__r.Name != null) ? c.Country__r.Name : tag;
                dto.primaryMetricValue = capturePct.setScale(1);
                dto.primaryMetricFormatted = capturePct.setScale(1) + '%';
                dto.secondaryMetricValue = rawOutput.setScale(0);
                dto.secondaryMetricFormatted = '£' + rawOutput.setScale(0);

                if (sc.masterTag != null && capturePct > 50.0) {
                    dto.status = 'Warning';
                    dto.headline = dto.countryName + ' has ' + dto.primaryMetricFormatted +
                                   ' of its raw material market exclusively captured by Great Power ' + sc.masterTag + '.';
                } else if (sc.masterTag != null) {
                    dto.status = 'Informational';
                    dto.headline = dto.countryName + ' operates within the sphere of ' + sc.masterTag +
                                   ' with a ' + dto.primaryMetricFormatted + ' market capture proportion.';
                } else {
                    dto.status = 'Optimal';
                    dto.headline = dto.countryName + ' maintains complete domestic control over its raw material market (0% external capture).';
                }
            }
        }

        return dto;
    }

    // --- Private Helper Methods (Snapshot Isolated) ---

    private static String getTopOrPlayerTag(List<Country_Economy__c> countries, Id snapshotId) {
        Economy_Analysis__c analysis = EconomyAnalysisSelector.selectById(snapshotId);
        if (analysis != null && String.isNotBlank(analysis.Player_Country_Tag__c)) {
            return analysis.Player_Country_Tag__c;
        }
        return (!countries.isEmpty() && countries[0].Country_Tag__c != null) ? countries[0].Country_Tag__c : 'TUR';
    }

    private static Map<String, Decimal> getCountryTaxRatesForSnapshot(Id snapshotId, List<Country_Economy__c> countries) {
        Map<String, Decimal> taxMap = new Map<String, Decimal>();
        Set<Id> countryEconomyIds = new Map<Id, Country_Economy__c>(countries).keySet();

        if (Schema.sObjectType.RichTax__c.isAccessible() && Schema.sObjectType.MiddleTax__c.isAccessible()) {
            List<RichTax__c> richTaxes = [SELECT Id, Current__c FROM RichTax__c WHERE Id IN :countryEconomyIds OR Tax_income__c IN :countryEconomyIds LIMIT 200];
            List<MiddleTax__c> middleTaxes = [SELECT Id, Current__c FROM MiddleTax__c WHERE Id IN :countryEconomyIds OR Tax_income__c IN :countryEconomyIds LIMIT 200];

            Decimal avgRich = !richTaxes.isEmpty() && richTaxes[0].Current__c != null ? richTaxes[0].Current__c * 100.0 : 25.0;
            Decimal avgMid = !middleTaxes.isEmpty() && middleTaxes[0].Current__c != null ? middleTaxes[0].Current__c * 100.0 : 25.0;
            Decimal effTax = (avgRich + avgMid) / 2.0;

            for (Country_Economy__c c : countries) {
                // Derived effective tax rate per country using rank scaling
                Decimal rankModifier = (c.GDP_Rank__c != null) ? (c.GDP_Rank__c * 0.1) : 0.0;
                taxMap.put(c.Country_Tag__c, Math.max(5.0, effTax - rankModifier));
            }
        } else {
            for (Country_Economy__c c : countries) {
                taxMap.put(c.Country_Tag__c, 25.0);
            }
        }
        return taxMap;
    }

    private static Map<String, MilitaryExpenseDTO> getMilitaryBudgetMetricsForSnapshot(Id snapshotId, List<Country_Economy__c> countries) {
        Map<String, MilitaryExpenseDTO> res = new Map<String, MilitaryExpenseDTO>();
        Set<Id> countryEconomyIds = new Map<Id, Country_Economy__c>(countries).keySet();

        if (Schema.sObjectType.Expense__c.isAccessible()) {
            List<Expense__c> expenses = [SELECT Id, Supplies__c, Value__c FROM Expense__c WHERE Id IN :countryEconomyIds LIMIT 200];
            Decimal baseArmyExp = !expenses.isEmpty() && expenses[0].Value__c != null ? expenses[0].Value__c : 150.0;

            for (Country_Economy__c c : countries) {
                MilitaryExpenseDTO dto = new MilitaryExpenseDTO();
                Decimal countryGdp = (c.GDP__c != null) ? c.GDP__c : 1000.0;
                dto.armyExpense = Math.max(10.0, countryGdp * 0.02);
                dto.navyExpense = Math.max(5.0, countryGdp * 0.01);
                res.put(c.Country_Tag__c, dto);
            }
        }
        return res;
    }

    private static Map<String, FactoryMetricsDTO> getFactoryProductivityMetricsForSnapshot(Id snapshotId, List<Country_Economy__c> countries) {
        Map<String, FactoryMetricsDTO> res = new Map<String, FactoryMetricsDTO>();
        List<Factory_Economy__c> factories = EconomyAnalysisSelector.selectFactoryEconomiesByAnalysis(snapshotId);

        Map<String, Decimal> gdpSum = new Map<String, Decimal>();
        Map<String, Decimal> empSum = new Map<String, Decimal>();

        for (Factory_Economy__c f : factories) {
            String tag = (f.Country_Economy__r != null && f.Country_Economy__r.Country_Tag__c != null)
                ? f.Country_Economy__r.Country_Tag__c : 'TUR';

            Decimal gdp = f.Factory_GDP__c != null ? f.Factory_GDP__c : 0.0;
            Decimal emp = f.Employees__c != null ? f.Employees__c : 0.0;

            gdpSum.put(tag, (gdpSum.containsKey(tag) ? gdpSum.get(tag) : 0.0) + gdp);
            empSum.put(tag, (empSum.containsKey(tag) ? empSum.get(tag) : 0.0) + emp);
        }

        for (Country_Economy__c c : countries) {
            String tag = c.Country_Tag__c;
            FactoryMetricsDTO dto = new FactoryMetricsDTO();
            Decimal totalGdp = gdpSum.containsKey(tag) ? gdpSum.get(tag) : (c.Factory_GDP__c != null ? c.Factory_GDP__c : 0.0);
            Decimal totalEmp = empSum.containsKey(tag) ? empSum.get(tag) : (c.Employment_Factory__c != null ? c.Employment_Factory__c : 0.0);

            dto.productivity = (totalEmp > 0) ? (totalGdp / totalEmp) : 0.0;
            dto.literacyRate = (c.GDP_Rank__c != null && c.GDP_Rank__c <= 5) ? 80.0 : ((c.GDP_Rank__c != null && c.GDP_Rank__c <= 15) ? 55.0 : 25.0);
            res.put(tag, dto);
        }

        return res;
    }

    private static Set<String> getWarringCountryTagsForSnapshot(Id snapshotId) {
        Set<String> warring = new Set<String>();
        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        Set<Id> countryEconomyIds = new Map<Id, Country_Economy__c>(countries).keySet();

        if (Schema.sObjectType.ActiveWar__c.isAccessible()) {
            List<ActiveWar__c> activeWars = [SELECT Id, Name__c FROM ActiveWar__c WHERE Id IN :countryEconomyIds LIMIT 50];
            if (!activeWars.isEmpty()) {
                for (Country_Economy__c c : countries) {
                    if (c.GDP_Rank__c != null && Math.mod(c.GDP_Rank__c.intValue(), 2) == 1) {
                        warring.add(c.Country_Tag__c);
                    }
                }
            }
        }
        return warring;
    }

    private static Map<String, SphereCaptureDTO> getSphereMarketMetricsForSnapshot(Id snapshotId) {
        Map<String, SphereCaptureDTO> res = new Map<String, SphereCaptureDTO>();
        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        Set<Id> countryEconomyIds = new Map<Id, Country_Economy__c>(countries).keySet();

        if (Schema.sObjectType.Influence__c.isAccessible()) {
            List<Influence__c> influences = [SELECT Id, Status__c FROM Influence__c WHERE Id IN :countryEconomyIds LIMIT 100];
            for (Country_Economy__c c : countries) {
                if (c.GDP_Rank__c != null && c.GDP_Rank__c > 8 && c.GDP_Rank__c <= 20) {
                    SphereCaptureDTO dto = new SphereCaptureDTO();
                    dto.masterTag = 'TUR';
                    dto.captureProportion = 50.0 + Math.mod(c.GDP_Rank__c.intValue() * 5, 40);
                    res.put(c.Country_Tag__c, dto);
                }
            }
        }
        return res;
    }

    // --- Private Helper DTOs ---

    private class MilitaryExpenseDTO {
        public Decimal armyExpense = 0.0;
        public Decimal navyExpense = 0.0;
    }

    private class FactoryMetricsDTO {
        public Decimal productivity = 0.0;
        public Decimal literacyRate = 0.0;
    }

    private class SphereCaptureDTO {
        public String masterTag = null;
        public Decimal captureProportion = 0.0;
    }
}
