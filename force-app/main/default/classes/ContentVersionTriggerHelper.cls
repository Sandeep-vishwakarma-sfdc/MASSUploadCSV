/**
* @description       : Trigger Helper Method For Checkbox True
* @author            : Amol Patil
* @group             : SKI
* @last modified onC  : 08-10-2022
* @last modified by  : amol.patil@skinternational.com
**/
public with sharing class ContentVersionTriggerHelper {
    
    public Static boolean IsAttachmentupdated = false;
    public static boolean massUploadTriggerExecuted = false;
    public static Id MassUploadRecordTypeId;
    public static List<contentversion> contentvarid=null;
    public static Integer count=1;
    public static List<ContentDocumentLink> contentDocumentsLink=null;
    public static List<contentdocument> contentdocuments = null;// Added by Sandeep 11-18-2022
    public static List<AggregateResult> c = null; // Added by Sandeep Vishwakarama 11-18-2022
    public static List<contentversion> contentversions=null; // Added by Sandeep Vishwakarama
    public ContentVersionTriggerHelper() {
        
    }
    
    /**
     * updateMassUploadCSV method use to update status of mass upload record to IN-progress and isAttachment to true
     * @param newItems The first parameter Map<Id, SObject>.
     * @return void
    */
    public static void updateMassUploadCSV(Map<Id, SObject> newItems){
        
        
        Set<String> itemIds=new Set<String>();
        for(SObject item:newItems.values()){
            itemIds.add(item.id);
            System.debug('itemids'+itemIds);
        }
        if(contentvarid==null || contentvarid.size()==0) {
        contentvarid =[SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id In:itemIds];
        System.debug('ContentDocumentId==>'+contentvarid);
        }
        List<String> contdocIds = new List<String>();
        
        for(ContentVersion contvar:contentvarid){
            
            contdocIds.add(contvar.ContentDocumentId);
           
        }
        system.debug('contdocIds==>'+contdocIds);
        if(count<=2)
        {
           count++;
        contentDocumentsLink=[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where ContentDocumentId IN:contdocIds];
        
        System.debug('ContentDocumentLink'+contentDocumentsLink);
        }
        List<String> MassUploadIds=new List<String>();
        
        for(ContentDocumentLink linkId :contentDocumentsLink)
        {
            MassUploadIds.add(linkId.LinkedEntityId);
        }
        System.debug('MassUploadIds is ==>' +MassUploadIds);
        if(MassUploadRecordTypeId==null){
        	MassUploadRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;
            }
          System.debug('Record type id'+MassUploadRecordTypeId);
        List<Mass_Upload_CSV__c> massUploadCSVs = [SELECT Id,isAttachment__c,Status__c,recordTypeId FROM Mass_Upload_CSV__c WHERE Id IN : MassUploadIds and recordTypeId=:MassUploadRecordTypeId];
        
        if(massuploadCSVs.size() > 0){
            System.debug('Is Checkbox True?==>'+massUploadCSVs[0].isAttachment__c);
            massUploadCSVs[0].isAttachment__c = true;
            massUploadCSVs[0].Status__c='Inprogress';
            IsAttachmentupdated=true;
            System.debug('Checkbox True==>'+massUploadCSVs[0].isAttachment__c);
            update massUploadCSVs;
        }

    }
    
}