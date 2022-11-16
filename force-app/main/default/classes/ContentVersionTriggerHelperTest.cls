@isTest(SeeAllData=false)
public class ContentVersionTriggerHelperTest {
    @isTest
    public static void testContentVersionTriggerHelper(){
        
        Id MassUploadRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;
        system.debug('MassUploadRecordTypeId==>'+MassUploadRecordTypeId);
        
        insert new Trigger_Settings__c(Name ='MassUploadCSVTrigger' , IsActive__c = true , ObjectName__c = 'Mass_Upload_CSV__c');   
        
        String str = 'Profit Center;Sales Org;Dc;Div;SKU Code;UOM;Sales Deduction_LC;Sales Deduction USD;Start Date;End Date\nLA0005;5100;20;10;000000000000856010;KG;11;0.58;30042022;31032023';
        ContentVersion content=new Contentversion(); 
        content.title='SalesDeduction';
        content.PathOnClient ='test';
        // user  id= UserInfo.getUserId();
        Blob b=Blob.valueOf(str); 
        content.versiondata=b; 
        insert content;
        system.debug('content==>'+content);
        
        List<ContentVersion> contentId=[Select ContentDocumentId from ContentVersion where ID=:content.Id];
        System.debug('contentId Test==>'+contentId);
        
        
        List<String> contdocIds = new List<String>();
        for(ContentVersion contvar:contentId)
        {
            
            contdocIds.add(contvar.ContentDocumentId);
        }
        System.debug('contdocIds Test==>'+contdocIds);
        
        List<ContentDocumentLink> contentDocumentsLink=[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where ContentDocumentId IN:contdocIds];
        System.debug('ContentDocumentLink Test==>'+contentDocumentsLink);
        
        List<String> MassUploadIds=new List<String>();
        for(ContentDocumentLink linkId :contentDocumentsLink)
        {
            MassUploadIds.add(linkId.LinkedEntityId);
        }
        System.debug('contentLink Test id is' +MassUploadIds);
        
        List<Mass_Upload_CSV__c> massUploadCSVs = [SELECT Id,isAttachment__c,Status__c FROM Mass_Upload_CSV__c WHERE Id In:MassUploadIds];
        system.debug('massUploadCSVs==>'+massUploadCSVs);
        Map<Id,SObject> massuploadmap = new Map<Id,SObject>();
        for(Mass_Upload_CSV__c masscsv:massUploadCSVs)
        {
            massuploadmap.put(masscsv.Id,masscsv);
        }
        
        Test.startTest();
        ContentVersionTriggerHelper cvs = new ContentVersionTriggerHelper();
        ContentVersionTriggerHelper.updateMassUploadCSV(massuploadmap);
        Grz_TestDataFactory.createContentDocument(true);
        
        Test.stopTest();
        
    } 
  
}