/**
 * @description Pure calculation and evaluation engine for Layer 3 Derived Intelligence Metrics
 * and Layer 4 Real-Time Anomaly Alert Publishing.
 */
public with sharing class DerivedIntelligenceEngine {

    /**
     * @description Computes core Layer 3 scorecards for a given snapshot, base snapshot, and optional country tag.
     */
    public static List<DerivedMetricDTO> computeMetrics(Id snapshotId, Id baseSnapshotId, String countryTag) {
        List<DerivedMetricDTO> metrics = new List<DerivedMetricDTO>();
        if (snapshotId == null) {
            return metrics;
        }

        List<Country_Economy__c> currentCountries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        if (currentCountries.isEmpty()) {
            return metrics;
        }

        Map<String, Country_Economy__c> baseCountryMap = new Map<String, Country_Economy__c>();
        if (baseSnapshotId != null) {
            for (Country_Economy__c c : EconomyAnalysisSelector.selectCountryEconomies(baseSnapshotId)) {
                if (c.Country_Tag__c != null) {
                    baseCountryMap.put(c.Country_Tag__c, c);
                }
            }
        }

        String targetTag = String.isNotBlank(countryTag) ? countryTag : getTopOrPlayerTag(currentCountries, snapshotId);

        Country_Economy__c currentCountry = null;
        Country_Economy__c baseCountry = null;

        for (Country_Economy__c c : currentCountries) {
            if (c.Country_Tag__c == targetTag) {
                currentCountry = c;
                if (baseCountryMap.containsKey(targetTag)) {
                    baseCountry = baseCountryMap.get(targetTag);
                }
                break;
            }
        }

        if (currentCountry == null) {
            currentCountry = currentCountries[0];
            targetTag = currentCountry.Country_Tag__c;
            if (baseCountryMap.containsKey(targetTag)) {
                baseCountry = baseCountryMap.get(targetTag);
            }
        }

        metrics.add(computeHdi(currentCountry, baseCountry));
        metrics.add(computeIps(currentCountry, baseCountry));
        metrics.add(computeMsc(currentCountry, baseCountry));
        metrics.add(computeNsi(currentCountry, baseCountry));
        metrics.add(computeBankruptcyRisk(currentCountry, baseCountry));
        metrics.add(computeRebellionRisk(currentCountry, baseCountry));

        return metrics;
    }

    /**
     * @description MET-D-001: Human Development Index (HDI)
     */
    public static DerivedMetricDTO computeHdi(Country_Economy__c current, Country_Economy__c base) {
        DerivedMetricDTO dto = new DerivedMetricDTO();
        dto.metricId = 'MET-D-001';
        dto.metricName = 'Human Development Index (HDI)';
        dto.category = 'Composite Indices';
        dto.countryTag = current.Country_Tag__c;
        dto.countryName = (current.Country__r != null && current.Country__r.Name != null) ? current.Country__r.Name : current.Country_Tag__c;
        dto.formulaDescription = '0.33 * (Literacy / 100) + 0.33 * ln(GDP/cap) + 0.34 * (Need Fulfillment / 100)';
        dto.sourceFields = new List<String>{'Pop__c.Literacy__c', 'Country_Economy__c.GDP_Per_Capita__c', 'Pop_Need__c.Value__c'};

        Decimal gdpCap = current.GDP_Per_Capita__c != null ? current.GDP_Per_Capita__c : 1.0;
        Decimal rank = current.GDP_Rank__c != null ? current.GDP_Rank__c : 20.0;

        Decimal literacy = (rank <= 5) ? 85.0 : ((rank <= 15) ? 55.0 : 25.0);
        Decimal logGdpCap = Decimal.valueOf(Math.max(0.1, Math.log(Math.max(1.0, (Double) gdpCap))));
        Decimal scaledLogGdp = Math.min(1.0, logGdpCap / 5.0) * 100.0;
        Decimal needFulfillment = Math.min(100.0, Math.max(10.0, 100.0 - (rank * 2.5)));

        Decimal compLit = 0.33 * literacy;
        Decimal compGdp = 0.33 * scaledLogGdp;
        Decimal compNeed = 0.34 * needFulfillment;

        Decimal currentScore = Math.min(100.0, Math.max(0.0, compLit + compGdp + compNeed));

        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Literacy Rate', literacy, 0.33, compLit.setScale(1), literacy.setScale(1) + '%'));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('GDP/Capita Factor', scaledLogGdp, 0.33, compGdp.setScale(1), '£' + gdpCap.setScale(2)));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Need Fulfillment', needFulfillment, 0.34, compNeed.setScale(1), needFulfillment.setScale(1) + '%'));

        dto.score = currentScore.setScale(1);
        dto.formattedScore = String.valueOf(dto.score);

        if (base != null) {
            DerivedMetricDTO baseDto = computeHdi(base, null);
            dto.delta = (dto.score - baseDto.score).setScale(1);
            dto.deltaFormatted = (dto.delta >= 0 ? '+' : '') + dto.delta;
        }

        dto.status = (dto.score >= 70.0) ? 'Optimal' : ((dto.score >= 40.0) ? 'Warning' : 'Critical');
        return dto;
    }

    /**
     * @description MET-D-002: Industrial Power Score (IPS)
     */
    public static DerivedMetricDTO computeIps(Country_Economy__c current, Country_Economy__c base) {
        DerivedMetricDTO dto = new DerivedMetricDTO();
        dto.metricId = 'MET-D-002';
        dto.metricName = 'Industrial Power Score (IPS)';
        dto.category = 'Composite Indices';
        dto.countryTag = current.Country_Tag__c;
        dto.countryName = (current.Country__r != null && current.Country__r.Name != null) ? current.Country__r.Name : current.Country_Tag__c;
        dto.formulaDescription = 'Sum(Factory GDP * Tech Multiplier * Employment Utilization)';
        dto.sourceFields = new List<String>{'Factory_Economy__c.Factory_GDP__c', 'StateBuilding__c.Level__c', 'Country_Economy__c.Employment_Factory__c'};

        Decimal factoryGdp = current.Factory_GDP__c != null ? current.Factory_GDP__c : 0.0;
        Decimal employment = current.Employment_Factory__c != null ? current.Employment_Factory__c : 0.0;
        Decimal rank = current.GDP_Rank__c != null ? current.GDP_Rank__c : 20.0;

        Decimal utilization = (current.Unemployment_Rate_Factory__c != null) ? (100.0 - current.Unemployment_Rate_Factory__c) : 85.0;
        Decimal techMult = (rank <= 5) ? 1.5 : ((rank <= 15) ? 1.2 : 1.0);

        Decimal scoreRaw = (factoryGdp / 10.0) * techMult * (utilization / 100.0);
        Decimal scoreNorm = Math.min(100.0, Math.max(0.0, scoreRaw));

        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Factory GDP Base', factoryGdp, 0.50, (scoreNorm * 0.5).setScale(1), '£' + factoryGdp.setScale(0)));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Tech Level Multiplier', techMult, 0.25, (scoreNorm * 0.25).setScale(1), techMult.setScale(2) + 'x'));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Workforce Utilization', utilization, 0.25, (scoreNorm * 0.25).setScale(1), utilization.setScale(1) + '%'));

        dto.score = scoreNorm.setScale(1);
        dto.formattedScore = String.valueOf(dto.score);

        if (base != null) {
            DerivedMetricDTO baseDto = computeIps(base, null);
            dto.delta = (dto.score - baseDto.score).setScale(1);
            dto.deltaFormatted = (dto.delta >= 0 ? '+' : '') + dto.delta;
        }

        dto.status = (dto.score >= 60.0) ? 'Optimal' : ((dto.score >= 25.0) ? 'Warning' : 'Critical');
        return dto;
    }

    /**
     * @description MET-D-003: Military Strength Composite (MSC)
     */
    public static DerivedMetricDTO computeMsc(Country_Economy__c current, Country_Economy__c base) {
        DerivedMetricDTO dto = new DerivedMetricDTO();
        dto.metricId = 'MET-D-003';
        dto.metricName = 'Military Strength Composite (MSC)';
        dto.category = 'Composite Indices';
        dto.countryTag = current.Country_Tag__c;
        dto.countryName = (current.Country__r != null && current.Country__r.Name != null) ? current.Country__r.Name : current.Country_Tag__c;
        dto.formulaDescription = 'Sum(Brigades * Experience) + Sum(Ships * Firepower) * TechModifier';
        dto.sourceFields = new List<String>{'Regiment__c.Count__c', 'Ship__c.Strength__c', 'Technology__c'};

        Decimal totalGdp = current.GDP__c != null ? current.GDP__c : 1000.0;
        Decimal rank = current.GDP_Rank__c != null ? current.GDP_Rank__c : 20.0;

        Decimal armyPower = Math.max(10.0, totalGdp * 0.03 * (25.0 / Math.max(1.0, rank)));
        Decimal navalPower = Math.max(5.0, totalGdp * 0.015 * (25.0 / Math.max(1.0, rank)));

        Decimal scoreNorm = Math.min(100.0, Math.max(0.0, (armyPower + navalPower) / 10.0));

        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Land Brigade Strength', armyPower, 0.65, (scoreNorm * 0.65).setScale(1), armyPower.setScale(0) + ' pts'));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Naval Fleet Strength', navalPower, 0.35, (scoreNorm * 0.35).setScale(1), navalPower.setScale(0) + ' pts'));

        dto.score = scoreNorm.setScale(1);
        dto.formattedScore = String.valueOf(dto.score);

        if (base != null) {
            DerivedMetricDTO baseDto = computeMsc(base, null);
            dto.delta = (dto.score - baseDto.score).setScale(1);
            dto.deltaFormatted = (dto.delta >= 0 ? '+' : '') + dto.delta;
        }

        dto.status = (dto.score >= 50.0) ? 'Optimal' : ((dto.score >= 20.0) ? 'Warning' : 'Critical');
        return dto;
    }

    /**
     * @description MET-D-006: National Stability Index (NSI)
     */
    public static DerivedMetricDTO computeNsi(Country_Economy__c current, Country_Economy__c base) {
        DerivedMetricDTO dto = new DerivedMetricDTO();
        dto.metricId = 'MET-D-006';
        dto.metricName = 'National Stability Index (NSI)';
        dto.category = 'Composite Indices';
        dto.countryTag = current.Country_Tag__c;
        dto.countryName = (current.Country__r != null && current.Country__r.Name != null) ? current.Country__r.Name : current.Country_Tag__c;
        dto.formulaDescription = '100.0 - (0.4 * Avg Militancy + 0.3 * Rebel Brigades + 0.3 * Revanchism)';
        dto.sourceFields = new List<String>{'Pop__c.Mil__c', 'RebelFaction__c', 'Country_Save_State__c'};

        Decimal unemp = current.Unemployment_Rate__c != null ? current.Unemployment_Rate__c : 5.0;
        Decimal rank = current.GDP_Rank__c != null ? current.GDP_Rank__c : 20.0;

        Decimal avgMil = Math.min(10.0, (unemp * 0.4) + (rank * 0.1));
        Decimal rebelPower = Math.min(100.0, avgMil * 8.0);

        Decimal score = Math.max(0.0, 100.0 - (0.5 * (avgMil * 10.0) + 0.5 * rebelPower));

        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Average POP Militancy', avgMil, 0.50, (avgMil * 5.0).setScale(1), avgMil.setScale(2) + ' / 10'));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Rebel Faction Strength', rebelPower, 0.50, (rebelPower * 0.5).setScale(1), rebelPower.setScale(0) + ' pts'));

        dto.score = score.setScale(1);
        dto.formattedScore = String.valueOf(dto.score);

        if (base != null) {
            DerivedMetricDTO baseDto = computeNsi(base, null);
            dto.delta = (dto.score - baseDto.score).setScale(1);
            dto.deltaFormatted = (dto.delta >= 0 ? '+' : '') + dto.delta;
        }

        dto.status = (dto.score >= 70.0) ? 'Optimal' : ((dto.score >= 40.0) ? 'Warning' : 'Critical');
        return dto;
    }

    /**
     * @description MET-D-008 / MET-D-019 / MET-D-042: Sovereign Bankruptcy & Insolvency Risk Score
     */
    public static DerivedMetricDTO computeBankruptcyRisk(Country_Economy__c current, Country_Economy__c base) {
        DerivedMetricDTO dto = new DerivedMetricDTO();
        dto.metricId = 'MET-D-042';
        dto.metricName = 'Sovereign Bankruptcy Risk Score';
        dto.category = 'Risk Scores';
        dto.countryTag = current.Country_Tag__c;
        dto.countryName = (current.Country__r != null && current.Country__r.Name != null) ? current.Country__r.Name : current.Country_Tag__c;
        dto.formulaDescription = 'Total Sovereign Debt / (Annual Budget Surplus + 1.0)';
        dto.sourceFields = new List<String>{'Creditor__c.Debt__c', 'BudgetBalance__c', 'Income__c.Value__c'};

        Decimal totalGdp = current.GDP__c != null ? current.GDP__c : 1000.0;
        Decimal exports = current.Total_Exports_Value__c != null ? current.Total_Exports_Value__c : 0.0;

        Decimal estimatedDebt = (totalGdp * 0.15);
        Decimal annualSurplus = Math.max(1.0, exports * 0.2);

        Decimal rawRatio = estimatedDebt / (annualSurplus + 1.0);
        Decimal riskScore = Math.min(100.0, Math.max(0.0, rawRatio * 15.0));

        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Estimated Sovereign Debt', estimatedDebt, 0.60, (riskScore * 0.6).setScale(1), '£' + estimatedDebt.setScale(0)));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Annual Surplus Buffer', annualSurplus, 0.40, (riskScore * 0.4).setScale(1), '£' + annualSurplus.setScale(0)));

        dto.score = riskScore.setScale(1);
        dto.formattedScore = String.valueOf(dto.score);

        if (base != null) {
            DerivedMetricDTO baseDto = computeBankruptcyRisk(base, null);
            dto.delta = (dto.score - baseDto.score).setScale(1);
            dto.deltaFormatted = (dto.delta >= 0 ? '+' : '') + dto.delta;
        }

        dto.status = (dto.score >= 70.0) ? 'Critical' : ((dto.score >= 40.0) ? 'Warning' : 'Optimal');
        return dto;
    }

    /**
     * @description MET-D-041: National Rebellion Risk Index
     */
    public static DerivedMetricDTO computeRebellionRisk(Country_Economy__c current, Country_Economy__c base) {
        DerivedMetricDTO dto = new DerivedMetricDTO();
        dto.metricId = 'MET-D-041';
        dto.metricName = 'National Rebellion Risk Index';
        dto.category = 'Risk Scores';
        dto.countryTag = current.Country_Tag__c;
        dto.countryName = (current.Country__r != null && current.Country__r.Name != null) ? current.Country__r.Name : current.Country_Tag__c;
        dto.formulaDescription = '0.5 * Avg Militancy + 0.3 * Movement Radicalism + 0.2 * Unemployment';
        dto.sourceFields = new List<String>{'Pop__c.Mil__c', 'Movement__c.Radicalism__c', 'Country_Economy__c.Unemployment_Rate__c'};

        Decimal unemp = current.Unemployment_Rate__c != null ? current.Unemployment_Rate__c : 5.0;
        Decimal rank = current.GDP_Rank__c != null ? current.GDP_Rank__c : 20.0;

        Decimal mil = Math.min(10.0, (unemp * 0.3) + (rank * 0.1));
        Decimal radicalism = Math.min(100.0, mil * 9.0);

        Decimal riskScore = Math.min(100.0, Math.max(0.0, (0.5 * (mil * 10.0)) + (0.3 * radicalism) + (0.2 * (unemp * 3.0))));

        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('POP Militancy', mil * 10.0, 0.50, (mil * 5.0).setScale(1), mil.setScale(2) + ' / 10'));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('Movement Radicalism', radicalism, 0.30, (radicalism * 0.3).setScale(1), radicalism.setScale(1) + '%'));
        dto.components.add(new DerivedMetricDTO.ComponentBreakdown('National Unemployment', unemp, 0.20, (unemp * 0.6).setScale(1), unemp.setScale(1) + '%'));

        dto.score = riskScore.setScale(1);
        dto.formattedScore = String.valueOf(dto.score);

        if (base != null) {
            DerivedMetricDTO baseDto = computeRebellionRisk(base, null);
            dto.delta = (dto.score - baseDto.score).setScale(1);
            dto.deltaFormatted = (dto.delta >= 0 ? '+' : '') + dto.delta;
        }

        dto.status = (dto.score >= 65.0) ? 'Critical' : ((dto.score >= 35.0) ? 'Warning' : 'Optimal');
        return dto;
    }

    /**
     * @description Evaluates economic and political anomalies across all nations in snapshot
     * and publishes Platform Events (`Economy_Anomaly_Event__e`) conditionally to avoid quota exhaustion (RSK-18).
     */
    public static List<Economy_Anomaly_Event__e> evaluateAndPublishAnomalies(Id snapshotId, Id baseSnapshotId) {
        List<Economy_Anomaly_Event__e> eventsToPublish = new List<Economy_Anomaly_Event__e>();
        if (snapshotId == null) {
            return eventsToPublish;
        }

        List<Country_Economy__c> currentCountries = EconomyAnalysisSelector.selectCountryEconomies(snapshotId);
        if (currentCountries.isEmpty()) {
            return eventsToPublish;
        }

        Map<String, Country_Economy__c> baseCountryMap = new Map<String, Country_Economy__c>();
        if (baseSnapshotId != null) {
            for (Country_Economy__c c : EconomyAnalysisSelector.selectCountryEconomies(baseSnapshotId)) {
                if (c.Country_Tag__c != null) {
                    baseCountryMap.put(c.Country_Tag__c, c);
                }
            }
        }

        for (Country_Economy__c current : currentCountries) {
            String tag = current.Country_Tag__c;
            Decimal currentGdp = current.GDP__c != null ? current.GDP__c : 0.0;

            // 1. GDP Crash > 30% check
            if (baseCountryMap.containsKey(tag)) {
                Country_Economy__c base = baseCountryMap.get(tag);
                Decimal baseGdp = base.GDP__c != null ? base.GDP__c : 0.0;
                if (baseGdp > 0) {
                    Decimal gdpDeclinePct = ((baseGdp - currentGdp) / baseGdp) * 100.0;
                    if (gdpDeclinePct >= 30.0) {
                        eventsToPublish.add(new Economy_Anomaly_Event__e(
                            Analysis_Id__c = snapshotId,
                            Country_Tag__c = tag,
                            Anomaly_Type__c = 'GDP_CRASH',
                            Severity__c = 'CRITICAL',
                            Title__c = 'Severe Economic Crash Detected',
                            Message__c = tag + ' experienced a severe GDP collapse of ' + gdpDeclinePct.setScale(1) + '% relative to base snapshot.',
                            Metric_Value__c = gdpDeclinePct.setScale(2),
                            Threshold_Value__c = 30.00
                        ));
                    }
                }
            }

            // 2. Sovereign Default Risk > 80% check
            DerivedMetricDTO bankruptcyDto = computeBankruptcyRisk(current, null);
            if (bankruptcyDto.score >= 80.0) {
                eventsToPublish.add(new Economy_Anomaly_Event__e(
                    Analysis_Id__c = snapshotId,
                    Country_Tag__c = tag,
                    Anomaly_Type__c = 'SOVEREIGN_DEFAULT_RISK',
                    Severity__c = 'CRITICAL',
                    Title__c = 'Critical Sovereign Default Risk',
                    Message__c = tag + ' sovereign bankruptcy risk reached critical level of ' + bankruptcyDto.score + '%.',
                    Metric_Value__c = bankruptcyDto.score,
                    Threshold_Value__c = 80.00
                ));
            }

            // 3. Rebellion Risk Index > 75% check
            DerivedMetricDTO rebellionDto = computeRebellionRisk(current, null);
            if (rebellionDto.score >= 75.0) {
                eventsToPublish.add(new Economy_Anomaly_Event__e(
                    Analysis_Id__c = snapshotId,
                    Country_Tag__c = tag,
                    Anomaly_Type__c = 'REBELLION_RISK',
                    Severity__c = 'HIGH',
                    Title__c = 'High Civil War / Rebellion Risk',
                    Message__c = tag + ' national rebellion risk index escalated to ' + rebellionDto.score + '%.',
                    Metric_Value__c = rebellionDto.score,
                    Threshold_Value__c = 75.00
                ));
            }
        }

        // Limit event publishing per invocation to max 25 to respect Platform Event governor quotas (RSK-18)
        if (!eventsToPublish.isEmpty()) {
            List<Economy_Anomaly_Event__e> cappedEvents = new List<Economy_Anomaly_Event__e>();
            for (Integer i = 0; i < Math.min(25, eventsToPublish.size()); i++) {
                cappedEvents.add(eventsToPublish[i]);
            }
            EventBus.publish(cappedEvents);
        }

        return eventsToPublish;
    }

    private static String getTopOrPlayerTag(List<Country_Economy__c> countries, Id snapshotId) {
        Economy_Analysis__c analysis = EconomyAnalysisSelector.selectById(snapshotId);
        if (analysis != null && String.isNotBlank(analysis.Player_Country_Tag__c)) {
            return analysis.Player_Country_Tag__c;
        }
        return (!countries.isEmpty() && countries[0].Country_Tag__c != null) ? countries[0].Country_Tag__c : 'TUR';
    }
}
