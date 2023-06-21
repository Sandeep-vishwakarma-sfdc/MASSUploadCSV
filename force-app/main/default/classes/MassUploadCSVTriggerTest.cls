@isTest(SeeAllData=false) 
public class MassUploadCSVTriggerTest {
    @isTest 
    public static void testSetupmassCSV(){
        
        Mass_upload_Emails__c emails = new Mass_upload_Emails__c();
        emails.Name = 'MarginBlockEmails';
        emails.email__c = 'sandeep.vishwakarma@skinternational.com';
        emails.separator__c = ';';
        insert emails;
        /* Start Creating Sales Area Config */
        
        Sales_Org__c sorg =new Sales_Org__c();
        sorg.Name='Mexico';
        sorg.Description__c='Mexico';
        sorg.Sales_Org_Code__c='5100';
        insert sorg;

RecordType Supplier_RecTypeId = [SELECT Id FROM RecordType WHERE name = 'Depot' and isActive = true LIMIT 1];
        Depot__c dp =new Depot__c ();
        dp.Name='UPL Mexico';
        dp.recordtypeId=Supplier_RecTypeId.id;
        dp.Country__c='Mexico';
        dp.Depot_Code__c='MX00';
        dp.SalesOrg__c = sorg.ID;
        insert dp;
		
		Distribution_Channel__c disbj = new Distribution_Channel__c();
        disbj.Name = '20';                      
        disbj.Distribution_Channel_Code__c = '20';  
        disbj.Description__c='test';
        insert disbj;
        
        Division__c Divbj2 = new Division__c();
        Divbj2.Name = '10';         
        Divbj2.Description__c = null;    
        Divbj2.Division_Code__c = '10'; 
        insert Divbj2;
		
		Sales_Area_Configuration__c salesAreaConfig = new Sales_Area_Configuration__c();
        salesAreaConfig.Depot__c = dp.Id;
        salesAreaConfig.Distribution_Channel__c = disbj.Id;
        salesAreaConfig.Division__c = Divbj2.Id;
        salesAreaConfig.Sales_Org__c = sorg.Id;
		salesAreaConfig.Combination_Key__c = '51002010MX00';
		insert salesAreaConfig;
        
        
        
        /* End Creating Sales Area Config */
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
        
        MassUploadExternalIdRecords__c extB = new MassUploadExternalIdRecords__c();
        extB.Name='Price_Block_Margin_Matrix__c(MBEW)';
        extB.Type__c='E2ECostMBEW';
        extB.FieldUseInCombinationKey__c='Sales_Org__r;Dc;Div;SKU_Code__r;Depot_Code__r;UOM__c;Type__c';
        extB.DataType__c='';
        extB.TypeApiName__c='Type__c';
        extB.ExternalId__c='Combination_Key__c';
        extB.ObjectName__c='Price_Block_Margin_Matrix__c';
        extB.CSVFields__c='Sales_Org__r;Dc;Div;Depot_Code__r;SKU_Code__r;UOM__c;E2E_Cost_MBEW_LC__c;E2E_Cost_MBEW_USD__c;Start_Date__c;End_Date__c';
		extB.csvFieldDepot__c = 'Depot__r;SKU_Code__r;Depot_Code__r;UOM__c;E2E_Cost_MBEW_LC__c;E2E_Cost_MBEW_USD__c;Start_Date__c;End_Date__c';
        extB.Length__c=null;
        insert extB;
              
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
        
        MassUploadExternalIdRecords__c extDepot = new MassUploadExternalIdRecords__c();
        extDepot.Name='Depot_Code__r';
        extDepot.Type__c='';
        extDepot.FieldUseInCombinationKey__c='Depot_Code__r';
        extDepot.DataType__c='Lookup';
        extDepot.TypeApiName__c='';
        extDepot.ExternalId__c='Depot_Code__c';
        extDepot.ObjectName__c='Depot__c';
        extDepot.CSVFields__c='';
        extDepot.Length__c=null;

        insert extDepot;
        
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
        
        String str = 'Profit Center;Sales Org;Dc;Div;SKU Code;UOM;Sales Deduction_LC;Sales Deduction USD\nLA0005;5100;20;10;856010;KG;11;0.58\nLA0005;5100;20;60;856010;KG;11;0.58';
        ContentVersion content=new Contentversion();
        Blob b=Blob.valueOf(str); 
        content.title='SalesDeduction';
        content.PathOnClient ='test'; 
        content.versiondata=b; 
        content.IsMajorVersion=true;
        insert content;
        
        String str1 = 'Depot Code;SKU Code;UOM;E2E Cost MBEW(LC);E2E Cost MBEW(USD)\nMX00;856083;L;25;25\nMX00;856083;L;25;25';
        ContentVersion content1=new Contentversion();
        Blob b1=Blob.valueOf(str1); 
        content1.title='E2ECostMBEW';
        content1.PathOnClient ='test'; 
        content1.versiondata=b1; 
        content1.IsMajorVersion=true;
        insert content1;
        
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
        //mass1.Parent__c=mass1.Id;
        mass1.Seperator__c=';';
        mass1.Status__c='Inprogress';
        mass1.Success_records__c=100;
        mass1.Total_records__c=5000;
        mass1.Upload_Date_Time__c=datetime.newInstance(2022, 9, 15, 12, 30, 0);
       // mass1.Upsert_Key__c='abcs1234';
        mass1.RecordTypeId=MassUploadRecordTypeId;
        insert mass1;
        
        
         Mass_Upload_CSV__c mass2=new Mass_Upload_CSV__c();
        mass2.Comments__c='test';
        //mass2.CSV_fields__c='Depot Code;SKU Code;UOM;E2E Cost MBEW(LC);E2E Cost MBEW(USD)';
        mass2.Error_records__c=50;
        mass2.File_Name__c='E2ECostMBEW';
        mass2.File_Type__c='E2ECostMBEW';
        mass2.isAttachment__c=true;
        mass2.Mode__c='Auto';
        mass2.Object_Name__c='Price_Block_Margin_Matrix__c';
        mass2.Operation__c='Insert';
        //mass1.Parent__c=mass1.Id;
        mass2.Seperator__c=';';
        mass2.Status__c='Inprogress';
        mass2.Success_records__c=100;
        mass2.Total_records__c=5000;
        mass2.Upload_Date_Time__c=datetime.newInstance(2022, 9, 15, 12, 30, 0);
       // mass1.Upsert_Key__c='abcs1234';
        mass2.RecordTypeId=MassUploadRecordTypeId;
        insert mass2;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id].ContentDocumentId;
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content1.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = mass1.Id;
        cdl.ContentDocumentId = conDocId;   
        cdl.Visibility='AllUsers';
        cdl.ShareType = 'I';
        Insert cdl;   
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = mass2.Id;
        cdl1.ContentDocumentId = conDocId1;   
        cdl1.Visibility='AllUsers';
        cdl1.ShareType = 'I';
        Insert cdl1;  
        
        Integration_Files__c file=new Integration_Files__c();
        file.Status__c='Draft';
        file.Folder_Name__c = 'folder1';
        file.Mass_Upload_CSV__c=mass1.id;
        insert file;
        
        Integration_Files__c file1=new Integration_Files__c();
        file1.Status__c='Draft';
        file1.Folder_Name__c = 'folder1';
        file1.Mass_Upload_CSV__c=mass2.id;
        insert file1;
        
        Test.startTest();
        update mass1;
        update mass2;
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