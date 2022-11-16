@isTest
public class ReadAndSplitAttachmentTest {
   /* public Map<Id,Mass_Upload_CSV__c> newItems = new Map<Id,Mass_Upload_CSV__c>(); 
    static testMethod void getReadAndSplitAttachment()
    {
        Id MassUploadSplitRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;  
        
        insert new Trigger_Settings__c(Name ='setttingName' , IsActive__c = true , ObjectName__c = 'Mass_Upload_CSV__c');
     
        String str = 'Profit Center;Sales Org;Dc;Div;SKU Code;UOM;Sales Deduction_LC;Sales Deduction USD;Start Date;End Date\nLA0005;5100;20;10;000000000000856010;KG;11;0.58;30042022;31032023';
        ContentVersion content=new Contentversion(); 
        content.title='SalesDeduction';
        content.PathOnClient ='test'+'.'+'csv'; 
        Blob b=Blob.valueOf(str); 
        content.versiondata=b; 
        content.IsMajorVersion=true;
        insert content;
        
        List<ContentVersion> contentId=[SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:content.Id limit 1];
        System.debug('contentId Test==>'+contentId);
        
        List<String> contdocIds = new List<String>();
        for(ContentVersion contvar:contentId){
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

        List<Mass_Upload_CSV__c> massUploadCSVs = [SELECT Id,isAttachment__c,Status__c FROM Mass_Upload_CSV__c WHERE Id =:MassUploadIds];
        system.debug('massUploadCSVs==>'+massUploadCSVs);
        Map<Id,SObject> massuploadmap = new Map<Id,SObject>();
        for(Mass_Upload_CSV__c masscsv:massUploadCSVs){
            massuploadmap.put(masscsv.Id,masscsv);
        }
         
        List<String> parentIds=new List<String>();
            for(SObject item:massuploadmap.values()){
                parentIds.add(item.id);
            }
        system.debug('parentIds in test==>'+parentIds);
        
        Map<String,ContentVersion> contMap = new Map<String,ContentVersion>();
        for(ContentVersion cont:contentId){
            contMap.put(cont.Id, cont);
        }
        
        Mass_Upload_CSV__c mucsv = [select Id from Mass_Upload_CSV__c where Parent__c In: parentIds];
        system.debug('mucsv parent-->'+mucsv);
        
        Mass_Upload_CSV__c mass=new Mass_Upload_CSV__c();
        mass.Comments__c='test';
        mass.CSV_fields__c='Profit_Center__r; Sales_Org__r; Dc; Div; SKU_Code__r; UOM__c; Sales_Deduction_LC__c; Sales_Deduction_USD__c; Start_Date__c; End_Date__c';
        mass.Error_records__c=50;
        mass.File_Name__c='SalesDeduction';
        mass.File_Type__c='SalesDeduction';
        mass.isAttachment__c=true;
        mass.Mode__c='Auto';
        mass.Object_Name__c='Price_Block_Margin_Matrix__c';
        mass.Operation__c='Insert';
        mass.Parent__r=mucsv;
        mass.Seperator__c=',';
        mass.Status__c='Completed';
        mass.Success_records__c=100;
        mass.Total_records__c=50;
        mass.Upload_Date_Time__c=datetime.newInstance(2022, 9, 15, 12, 30, 0);
        mass.Upsert_Key__c='abcs1234';
        mass.RecordTypeId=MassUploadSplitRecordTypeId;
        insert mass;
        system.debug('mass==>'+mass);
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id].ContentDocumentId;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = mass.Id;
        cdl.ContentDocumentId = conDocId;
        Insert cdl;    
        
        Test.startTest();
		ReadAndSplitAttachment rs = new ReadAndSplitAttachment(massuploadmap);        
        rs.divideCSV(massuploadmap,contMap);
        Test.stopTest();

    }
*/
}