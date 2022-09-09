/**
* @description       : Trigger Helper Method For Checkbox True
* @author            : Amol Patil
* @group             : SKI
* @last modified onC  : 08-10-2022
* @last modified by  : amol.patil@skinternational.com
**/
public with sharing class ContentVersionTriggerHelper {
    
    public Static boolean IsAttachmentupdated = true;
    public static boolean triggerExecuted = false;
    public ContentVersionTriggerHelper() {
        
    }
    
    public static void updateMassUploadCSV(Map<Id, SObject> newItems){
        
        
        Set<String> itemIds=new Set<String>();
        for(SObject item:newItems.values()){
            itemIds.add(item.id);
            System.debug('itemids'+itemIds);
        }
        
        List<ContentVersion> contentvarid =[SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id In:itemIds];
        System.debug('ContentDocumentId==>'+contentvarid);
        
        List<String> contdocIds = new List<String>();
        
        for(ContentVersion contvar:contentvarid){
            
            contdocIds.add(contvar.ContentDocumentId);
        }
        List<ContentDocumentLink> contentDocumentsLink=[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where ContentDocumentId IN:contdocIds];
        
        System.debug('ContentDocumentLink'+contentDocumentsLink);
        
        List<String> MassUploadIds=new List<String>();
        
        for(ContentDocumentLink linkId :contentDocumentsLink)
        {
            MassUploadIds.add(linkId.LinkedEntityId);
        }
        System.debug('content Link id is' +MassUploadIds);
        
        List<Mass_Upload_CSV__c> massUploadCSVs = [SELECT Id,isAttachment__c,Status__c FROM Mass_Upload_CSV__c WHERE Id IN : MassUploadIds];
        
        if(massuploadCSVs.size() > 0){
            System.debug('Is Checkbox True?==>'+massUploadCSVs[0].isAttachment__c);
            
            massUploadCSVs[0].isAttachment__c = true;
            massUploadCSVs[0].Status__c='Inprogress';
            IsAttachmentupdated=false;
            System.debug('Checkbox True==>'+massUploadCSVs[0].isAttachment__c);
        }
        
        update massUploadCSVs;
        
    }
    
}