@IsTest
private class EconomyPlatformEventTest {

    @IsTest
    static void testPublishImportEvents() {
        // Create an analysis record
        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Name = 'Platform Event Test Analysis',
            Save_File_Name__c = 'PE_Test_Save',
            Unique_Snapshot_Key__c = 'PE_Test_Save',
            Import_Status__c = 'RECEIVED'
        );
        insert analysis;

        Test.startTest();

        // 1. Publish RECEIVED status
        EconomyImportService.publishImportEvent(analysis.Id, 'RECEIVED', 'Import queued', 10);

        // 2. Publish PROCESSING status
        EconomyImportService.publishImportEvent(analysis.Id, 'PROCESSING', 'Processing records', 50);

        // 3. Publish CALCULATING status
        EconomyImportService.publishImportEvent(analysis.Id, 'CALCULATING', 'Calculating GDP', 50);

        // 4. Publish COMPLETED status
        EconomyImportService.publishImportEvent(analysis.Id, 'COMPLETED', null, 50);

        // 5. Publish FAILED status
        EconomyImportService.publishImportEvent(analysis.Id, 'FAILED', 'Diagnostic error message', 0);

        // Edge case: null analysisId or status
        EconomyImportService.publishImportEvent(null, 'COMPLETED', null, 0);
        EconomyImportService.publishImportEvent(analysis.Id, null, null, 0);

        Test.stopTest();

        // Verify analysis record remains intact
        Economy_Analysis__c reloaded = [SELECT Id, Import_Status__c FROM Economy_Analysis__c WHERE Id = :analysis.Id];
        System.assertEquals('RECEIVED', reloaded.Import_Status__c, 'Direct call to publishImportEvent should not mutate SObject record status directly');
    }
}
