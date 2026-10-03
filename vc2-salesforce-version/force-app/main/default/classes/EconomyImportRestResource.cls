/**
 * @description REST API Resource exposing POST /services/apexrest/economy/import
 * Ingests normalized JSON DTO payloads from external save-game parser (EUG parser microservice).
 */
@RestResource(urlMapping='/economy/import')
global with sharing class EconomyImportRestResource {

    @HttpPost
    global static EconomyImportResponseDTO doPost() {
        EconomyImportResponseDTO response = new EconomyImportResponseDTO();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        // FLS / CRUD Authorization Check
        if (!Schema.sObjectType.Economy_Analysis__c.isCreateable()) {
            res.statusCode = 403;
            response.success = false;
            response.importStatus = 'FAILED';
            response.errorMessage = 'User does not have permission to create Economy_Analysis__c records.';
            return response;
        }

        if (req == null || req.requestBody == null) {
            res.statusCode = 400;
            response.success = false;
            response.importStatus = 'FAILED';
            response.errorMessage = 'Empty or missing request body.';
            return response;
        }

        try {
            String jsonString = req.requestBody.toString();
            if (String.isBlank(jsonString)) {
                res.statusCode = 400;
                response.success = false;
                response.importStatus = 'FAILED';
                response.errorMessage = 'Empty request body content.';
                return response;
            }

            EconomyImportRequestDTO requestDTO = (EconomyImportRequestDTO) JSON.deserialize(
                jsonString,
                EconomyImportRequestDTO.class
            );

            response = EconomyImportService.processImport(requestDTO);

            if (response != null && response.success) {
                res.statusCode = 200;
            } else {
                res.statusCode = 400;
            }

            return response;

        } catch (Exception ex) {
            res.statusCode = 500;
            response.success = false;
            response.importStatus = 'FAILED';
            response.errorMessage = 'Error processing import payload: ' + ex.getMessage();
            return response;
        }
    }
}
