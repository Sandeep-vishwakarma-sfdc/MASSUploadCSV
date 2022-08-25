trigger MassUploadCSVTrigger on Mass_Upload_CSV__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new MassUploadCSVTriggerHandler('MassUploadCSVTrigger'));
}