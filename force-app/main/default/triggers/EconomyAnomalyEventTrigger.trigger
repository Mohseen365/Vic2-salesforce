/**
 * @description Platform Event trigger for Economy_Anomaly_Event__e handling real-time economic and political anomalies.
 */
trigger EconomyAnomalyEventTrigger on Economy_Anomaly_Event__e (after insert) {
    for (Economy_Anomaly_Event__e evt : Trigger.new) {
        System.debug(LoggingLevel.INFO, 'Economy Anomaly Event received: ' + evt.Anomaly_Type__c + ' for ' + evt.Country_Tag__c);
    }
}
