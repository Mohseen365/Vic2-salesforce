/**
 * @description Comprehensive unit tests for CampaignAdvisorVerifier and anti-hallucination verification logic (RSK-25).
 */
@isTest
private class CampaignAdvisorVerifierTest {

    @isTest
    static void testVerificationSuccessWithGroundedNumbers() {
        Map<String, Object> groundTruthData = new Map<String, Object>{
            'countryTag' => 'TUR',
            'snapshotDate' => '1836-01-01',
            'gdp' => 25000.0,
            'gdpRank' => 6,
            'rebellionRiskIndex' => 45.5
        };

        String llmOutput = '[FACTS]\n• National GDP: [chip: 25000.00]\n• Global Rank: [chip: 6]\n\n[INTERPRETATION]\nAs of 1836, TUR has rebellion risk of 45.5.';

        Test.startTest();
        CampaignAdvisorVerifier.VerificationResult vr = CampaignAdvisorVerifier.verifyNumericPayload(llmOutput, groundTruthData);
        Test.stopTest();

        System.assert(vr.isVerified, 'Output containing only grounded numbers should pass verification');
        System.assertEquals(0, vr.hallucinatedNumbers.size(), 'No hallucinated numbers should be detected');
        System.assertEquals(llmOutput, vr.cleansedOutput, 'Cleansed output should match original when verified');
    }

    @isTest
    static void testVerificationFailureWithHallucinatedNumbers() {
        Map<String, Object> groundTruthData = new Map<String, Object>{
            'countryTag' => 'TUR',
            'snapshotDate' => '1836-01-01',
            'gdp' => 25000.0,
            'gdpRank' => 6
        };

        // Output contains ungrounded/hallucinated number 99999.99
        String llmOutput = '[FACTS]\n• National GDP: [chip: 25000.00]\n• Fake Reserve: [chip: 99999.99]\n\n[INTERPRETATION]\nFake advice.';

        Test.startTest();
        CampaignAdvisorVerifier.VerificationResult vr = CampaignAdvisorVerifier.verifyNumericPayload(llmOutput, groundTruthData);
        Test.stopTest();

        System.assert(!vr.isVerified, 'Output with ungrounded numbers must fail verification (RSK-25)');
        System.assert(vr.hallucinatedNumbers.size() > 0, 'Hallucinated numbers must be detected');
        System.assert(vr.rejectionReason.contains('RSK-25'), 'Rejection reason should reference RSK-25');
        System.assert(vr.cleansedOutput.contains('[FACTS]'), 'Cleansed fallback output should be generated');
    }

    @isTest
    static void testExtractNumbersFromText() {
        String sampleText = 'In year 1864, Egypt produced 123.45 units with 62 rebellion risk.';

        Test.startTest();
        List<Decimal> numbers = CampaignAdvisorVerifier.extractNumbersFromText(sampleText);
        Test.stopTest();

        System.assertEquals(3, numbers.size(), 'Should extract 3 numeric tokens');
        System.assertEquals(1864.00, numbers[0]);
        System.assertEquals(123.45, numbers[1]);
        System.assertEquals(62.00, numbers[2]);
    }
}
