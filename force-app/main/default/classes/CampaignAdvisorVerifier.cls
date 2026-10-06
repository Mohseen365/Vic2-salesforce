/**
 * @description Post-verification handler validating LLM narrative outputs against deterministic Apex action payloads (RSK-25).
 */
public with sharing class CampaignAdvisorVerifier {

    public class VerificationResult {
        @AuraEnabled public Boolean isVerified;
        @AuraEnabled public List<Decimal> extractedNumbers;
        @AuraEnabled public List<Decimal> hallucinatedNumbers;
        @AuraEnabled public String rejectionReason;
        @AuraEnabled public String cleansedOutput;

        public VerificationResult() {
            this.isVerified = true;
            this.extractedNumbers = new List<Decimal>();
            this.hallucinatedNumbers = new List<Decimal>();
            this.rejectionReason = '';
            this.cleansedOutput = '';
        }
    }

    /**
     * @description Extracts numbers from LLM narrative response, compares against allowed grounding numbers,
     * and rejects or regenerates response if ungrounded/hallucinated numbers are detected.
     */
    public static VerificationResult verifyNumericPayload(String llmOutput, Map<String, Object> groundTruthData) {
        VerificationResult result = new VerificationResult();
        if (String.isBlank(llmOutput)) {
            result.cleansedOutput = llmOutput;
            return result;
        }

        Set<Decimal> allowedNumbers = extractAllowedNumbers(groundTruthData);
        List<Decimal> extractedNumbers = extractNumbersFromText(llmOutput);
        result.extractedNumbers = extractedNumbers;

        for (Decimal num : extractedNumbers) {
            Boolean matchFound = false;
            for (Decimal allowed : allowedNumbers) {
                if (Math.abs(num - allowed) <= 0.051) {
                    matchFound = true;
                    break;
                }
            }
            if (!matchFound) {
                result.hallucinatedNumbers.add(num);
            }
        }

        if (!result.hallucinatedNumbers.isEmpty()) {
            result.isVerified = false;
            result.rejectionReason = 'Numeric hallucination detected (RSK-25): Unverifiable numbers ' +
                JSON.serialize(result.hallucinatedNumbers) + ' in model response.';

            // Regenerate clean, verified output from ground truth
            result.cleansedOutput = generateVerifiedFallbackOutput(groundTruthData);
        } else {
            result.isVerified = true;
            result.cleansedOutput = llmOutput;
        }

        return result;
    }

    /**
     * @description Recursively extracts all Decimal numeric values from ground truth payload map/objects.
     */
    public static Set<Decimal> extractAllowedNumbers(Map<String, Object> groundTruthData) {
        Set<Decimal> allowed = new Set<Decimal>();
        if (groundTruthData == null) {
            return allowed;
        }

        for (String key : groundTruthData.keySet()) {
            Object val = groundTruthData.get(key);
            addValueToAllowedSet(val, allowed);
        }

        // Add default date/year numbers if present (e.g. 1836, 1864)
        if (groundTruthData.containsKey('snapshotDate')) {
            String dateStr = String.valueOf(groundTruthData.get('snapshotDate'));
            List<Decimal> dateNums = extractNumbersFromText(dateStr);
            allowed.addAll(dateNums);
        }

        return allowed;
    }

    private static void addValueToAllowedSet(Object val, Set<Decimal> allowed) {
        if (val == null) return;

        if (val instanceof Decimal) {
            allowed.add(((Decimal) val).setScale(2, System.RoundingMode.HALF_UP));
            allowed.add(((Decimal) val).setScale(0, System.RoundingMode.HALF_UP));
            allowed.add(((Decimal) val).setScale(1, System.RoundingMode.HALF_UP));
        } else if (val instanceof Integer) {
            allowed.add(Decimal.valueOf((Integer) val));
        } else if (val instanceof Double) {
            Decimal d = Decimal.valueOf((Double) val);
            allowed.add(d.setScale(2, System.RoundingMode.HALF_UP));
            allowed.add(d.setScale(0, System.RoundingMode.HALF_UP));
            allowed.add(d.setScale(1, System.RoundingMode.HALF_UP));
        } else if (val instanceof Long) {
            allowed.add(Decimal.valueOf((Long) val));
        } else if (val instanceof String) {
            List<Decimal> nums = extractNumbersFromText((String) val);
            allowed.addAll(nums);
        } else if (val instanceof Map<String, Object>) {
            Map<String, Object> subMap = (Map<String, Object>) val;
            for (Object subVal : subMap.values()) {
                addValueToAllowedSet(subVal, allowed);
            }
        } else if (val instanceof List<Object>) {
            List<Object> listVals = (List<Object>) val;
            for (Object item : listVals) {
                addValueToAllowedSet(item, allowed);
            }
        }
    }

    /**
     * @description Uses regex pattern matching to extract all numbers from plain text.
     */
    public static List<Decimal> extractNumbersFromText(String text) {
        List<Decimal> nums = new List<Decimal>();
        if (String.isBlank(text)) return nums;

        // Pattern matches integers and decimals (e.g. 100, 12.34, 0.5)
        Pattern numPattern = Pattern.compile('(?<![A-Za-z_])\\d+(\\.\\d+)?(?![A-Za-z_])');
        Matcher matcher = numPattern.matcher(text);

        while (matcher.find()) {
            try {
                Decimal num = Decimal.valueOf(matcher.group());
                nums.add(num.setScale(2, System.RoundingMode.HALF_UP));
            } catch (Exception e) {
                // Skip non-parsable tokens
            }
        }
        return nums;
    }

    /**
     * @description Generates a strictly grounded fallback output if an LLM hallucination is rejected.
     */
    private static String generateVerifiedFallbackOutput(Map<String, Object> groundTruthData) {
        String countryTag = groundTruthData.containsKey('countryTag') ? String.valueOf(groundTruthData.get('countryTag')) : 'TUR';
        String date = groundTruthData.containsKey('snapshotDate') ? String.valueOf(groundTruthData.get('snapshotDate')) : '1836-01-01';

        String fallback = '[FACTS]\n';
        for (String key : groundTruthData.keySet()) {
            Object val = groundTruthData.get(key);
            if (val != null && !(val instanceof List<Object>) && !(val instanceof Map<String, Object>)) {
                fallback += '• ' + key + ': [chip: ' + String.valueOf(val) + ']\n';
            }
        }

        fallback += '\n[INTERPRETATION]\n';
        fallback += 'The model response was rejected by the anti-hallucination post-processor (RSK-25) due to unverified numbers. Above are the verified factual numbers for ' + countryTag + ' as of ' + date + '.';

        return fallback;
    }
}
