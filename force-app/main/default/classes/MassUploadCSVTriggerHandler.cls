public with sharing class MassUploadCSVTriggerHandler implements ITriggerHandler{
    public Trigger_Settings__c triggerMetaData = new Trigger_Settings__c();

    public MassUploadCSVTriggerHandler(){}
   public MassUploadCSVTriggerHandler(String setttingName){
    triggerMetaData = [select id,Name,ObjectName__c,IsActive__c from Trigger_Settings__c where Name=:setttingName];
   }

   public Boolean isDisabled(){
       return !triggerMetaData.IsActive__c;
   }

   public void beforeInsert(List<Sobject> newItems){}

   public void beforeUpdate(Map<Id,SObject> oldItems,Map<Id,Sobject> newItems){}
   public void beforeDelete(Map<Id, SObject> oldItems) {}
 
   public void afterInsert(Map<Id, SObject> newItems) {}

   public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems) {
    ID jobID = System.enqueueJob(new ReadAndSplitAttachment(newItems));
   }

   public void afterDelete(Map<Id,SObject> oldItems,Map<Id,Sobject> newItems) {}

   public void afterUndelete(Map<Id, SObject> oldItems) {}
}