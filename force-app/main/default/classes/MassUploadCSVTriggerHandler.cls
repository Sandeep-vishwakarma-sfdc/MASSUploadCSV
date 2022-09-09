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
       Id MassUploadSplitRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;
        
       for(SObject item : newItems.values())
       {    
           Mass_Upload_CSV__c massupload =(Mass_Upload_CSV__c) item.clone();
           System.debug('Mass Upload is'+massupload);
           System.debug('REcordtype Trigger is'+massupload.RecordType.Name);
           if((massupload.Status__c=='Inprogress')&& massupload.recordTypeId == MassUploadSplitRecordTypeId)
           {
               AsyncApexJob[] jobs = [SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset, CronTriggerId FROM AsyncApexJob where ApexClass.Name = 'ReadAndSplitAttachment' and Status='Processing'];
               if(jobs.size()>0){
              	   item.addError('Job is already in a Queue');
               }else{
                   ID jobID = System.enqueueJob(new ReadAndSplitAttachment(newItems));
               }
              
           }
       }
   
   }

   public void afterDelete(Map<Id,SObject> oldItems,Map<Id,Sobject> newItems) {}

   public void afterUndelete(Map<Id, SObject> oldItems) {}
}