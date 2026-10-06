/**
 * @description Platform Event trigger for Economy_Import_Event__e handling real-time import status events.
 */
trigger EconomyImportEventTrigger on Economy_Import_Event__e (after insert) {
    for (Economy_Import_Event__e evt : Trigger.new) {
        System.debug(LoggingLevel.INFO, 'Economy Import Event received: ' + evt.Status__c + ' for analysis ' + evt.Analysis_Id__c);
    }
}
