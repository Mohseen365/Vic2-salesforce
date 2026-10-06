/**
 * @description Provides structured grounding prompt templates for the Agentforce Campaign Advisor AI.
 */
public with sharing class CampaignAdvisorPromptTemplate {

    /**
     * @description Formats a grounded prompt instructing the LLM to answer strictly from action outputs,
     * format numbers as read-only chips [chip: NUMBER], and structure output into [FACTS] and [INTERPRETATION] blocks.
     */
    public static String buildGroundedPrompt(String userQuery, Map<String, Object> groundTruthData, String countryTag, String snapshotDate) {
        String prompt = 'You are the Victoria 2 Enterprise Campaign Advisor AI.\n';
        prompt += 'Context: Country ' + countryTag + ' | Snapshot Date: ' + snapshotDate + '\n\n';
        prompt += 'STRICT ANTI-HALLUCINATION RULES:\n';
        prompt += '1. Answer ONLY using numbers and facts provided in the GROUNDED DATA below.\n';
        prompt += '2. Do NOT invent, estimate, extrapolate, or modify any numbers.\n';
        prompt += '3. Enclose all numeric values inside read-only chips like [chip: VALUE].\n';
        prompt += '4. Separate your response into two distinct sections:\n';
        prompt += '   [FACTS]\n';
        prompt += '   - Factual point 1 with [chip: VALUE]\n';
        prompt += '   [INTERPRETATION]\n';
        prompt += '   Strategic analysis and advice referencing the facts above.\n\n';
        prompt += 'GROUNDED DATA:\n';
        prompt += JSON.serializePretty(groundTruthData) + '\n\n';
        prompt += 'USER QUESTION:\n' + userQuery;

        return prompt;
    }
}
