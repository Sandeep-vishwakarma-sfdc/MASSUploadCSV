@isTest(SeeAllData=false)
public class MassUploadCSVTriggerTest {
    @isTest
    public static void testSetupmassCSV(){
        
        Id MassUploadRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;
        
        insert new Trigger_Settings__c(Name ='MassUploadCSVTrigger', IsActive__c = true , ObjectName__c = 'Mass_Upload_CSV__c');
        
        MassUploadCSVTriggerHandler mucsv = new  MassUploadCSVTriggerHandler();
        Map<Id, SObject> oldItems = new Map<Id, SObject>();
        Map<Id,Sobject> newItems = new Map<Id,Sobject>();
        Map<String,ContentVersion> mapContentversion=new Map<String,ContentVersion>();
        ReadAndSplitAttachment rns = new ReadAndSplitAttachment(newItems);
        List <Mass_Upload_CSV__c> massCSV = new List<Mass_Upload_CSV__c>();
        
        MassUploadExternalIdRecords__c ext = new MassUploadExternalIdRecords__c();
        ext.Name='Price_Block_Margin_Matrix__c(SalesDed)';
        ext.Type__c='SalesDeduction';
        ext.FieldUseInCombinationKey__c='Profit_Center__r;Sales_Org__r;Dc;Div;SKU_Code__r;UOM__c;Type__c';
        ext.DataType__c='';
        ext.TypeApiName__c='Type__c';
        ext.ExternalId__c='Combination_Key__c';
        ext.ObjectName__c='Price_Block_Margin_Matrix__c';
        ext.CSVFields__c='Profit_Center__r;Sales_Org__r;Dc;Div;SKU_Code__r;UOM__c;Sales_Deduction_LC__c;Sales_Deduction_USD__c;Start_Date__c;End_Date__c';
        ext.Length__c=null;
        insert ext;
              
        MassUploadExternalIdRecords__c ext1 = new MassUploadExternalIdRecords__c();
        ext1.Name='SKU_Code__r';
        ext1.FieldUseInCombinationKey__c='Sales_Org__r;Dc;Div;SKU_Code__r';
        ext1.DataType__c='Lookup';
        ext1.TypeApiName__c='';
        ext1.ExternalId__c='Combination_Key__c';
        ext1.ObjectName__c='SKU__c';
        ext1.CSVFields__c='';
        ext1.Length__c=18;
        insert ext1;
        
        MassUploadExternalIdRecords__c ext2 = new MassUploadExternalIdRecords__c();
        ext2.Name='Profit_Center__r';
        ext2.Type__c='';
        ext2.FieldUseInCombinationKey__c='Sales_Org__r;Profit_Center__r';
        ext2.DataType__c='Lookup';
        ext2.TypeApiName__c='';
        ext2.ExternalId__c='Combination_Key__c';
        ext2.ObjectName__c='Profit_Center__c';
        ext2.CSVFields__c='';
        ext2.Length__c=null;
        insert ext2;
        
        MassUploadExternalIdRecords__c ext7 = new MassUploadExternalIdRecords__c();
        ext7.Name='Sales_Org__r';
        ext7.Type__c='';
        ext7.FieldUseInCombinationKey__c='Sales_Org__r';
        ext7.DataType__c='Lookup';
        ext7.TypeApiName__c='';
        ext7.ExternalId__c='Sales_Org_Code__c';
        ext7.ObjectName__c='Sales_Org__c';
        ext7.CSVFields__c='';
        ext7.Length__c=null;
        insert ext7;
        
        MassUploadExternalIdRecords__c ext3 = new MassUploadExternalIdRecords__c();
        ext3.Name='Sales_Deduction_LC__c';
        ext3.DataType__c='Number';
        insert ext3;
        
        MassUploadExternalIdRecords__c ext4 = new MassUploadExternalIdRecords__c();
        ext4.Name='Sales_Deduction_USD__c';
        ext4.DataType__c='Number';
        insert ext4;
        
        MassUploadExternalIdRecords__c ext5 = new MassUploadExternalIdRecords__c();
        ext5.Name='UOM__c';
        ext5.DataType__c='Text';
        insert ext5;
        
        MassUploadExternalIdRecords__c ext6 = new MassUploadExternalIdRecords__c();
        ext6.Name='End_Date__c';
        ext6.DataType__c='Date';
        insert ext6;
        
        MassUploadExternalIdRecords__c ext8 = new MassUploadExternalIdRecords__c();
        ext8.Name='End_Date__c';
        ext8.DataType__c='Date';
        insert ext8;
        
        String str = 'Profit Center;Sales Org;Dc;Div;SKU Code;UOM;Sales Deduction_LC;Sales Deduction USD;Start Date;End Date\nLA0005;5100;20;10;856010;KG;11;0.58;30042022;31032023\nLA0005;5100;20;60;856010;KG;11;0.58;30042022;31032023';
        ContentVersion content=new Contentversion();
        Blob b=Blob.valueOf(str); 
        content.title='SalesDeduction';
        content.PathOnClient ='test'; 
        content.versiondata=b; 
        content.IsMajorVersion=true;
        insert content;
        
        Mass_Upload_CSV__c mass1=new Mass_Upload_CSV__c();
        mass1.Comments__c='test';
        mass1.CSV_fields__c='Profit_Center__r; Sales_Org__r; Dc; Div; SKU_Code__r; UOM__c; Sales_Deduction_LC__c; Sales_Deduction_USD__c; Start_Date__c; End_Date__c';
        mass1.Error_records__c=50;
        mass1.File_Name__c='SalesDeduction';
        mass1.File_Type__c='SalesDeduction';
        mass1.isAttachment__c=true;
        mass1.Mode__c='Auto';
        mass1.Object_Name__c='Price_Block_Margin_Matrix__c';
        mass1.Operation__c='Insert';
        mass1.Parent__c=mass1.Id;
        mass1.Seperator__c=';';
        mass1.Status__c='Inprogress';
        mass1.Success_records__c=100;
        mass1.Total_records__c=5000;
        mass1.Upload_Date_Time__c=datetime.newInstance(2022, 9, 15, 12, 30, 0);
       // mass1.Upsert_Key__c='abcs1234';
        mass1.RecordTypeId=MassUploadRecordTypeId;
        insert mass1;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = mass1.Id;
        cdl.ContentDocumentId = conDocId;   
        cdl.Visibility='AllUsers';
        cdl.ShareType = 'I';
        Insert cdl;   
        
        Integration_Files__c file=new Integration_Files__c();
        file.Status__c='Completed';
        file.Mass_Upload_CSV__c=mass1.id;
        insert file;
        
        Test.startTest();
        mucsv.beforeDelete(oldItems);
        mucsv.afterUndelete(oldItems);
        mucsv.afterDelete(oldItems, newItems);
        rns.divideCSV(newItems, mapContentversion);
        System.enqueueJob(rns);
       
        Test.stopTest();

    }
    
     @isTest
    public static void testSetupmassCSV2(){
    
    }
 
}