@isTest
public with sharing class SharepointSchedularTest {

    @TestSetup
    static void makeData(){
        SharePointDetails__c details = new SharePointDetails__c();
        details.Name ='MarginBlockCLI';
        details.AuthorizationURL__c = 'https://accounts.accesscontrol.windows.net/8bc97f9a-ea86-472e-8ab7-19db58c4c8af/tokens/OAuth/2';
        details.Client_Id__c = 'b0bbcedf-ed45-4aa9-a9e3-1bc56d31a1b4@8bc97f9a-ea86-472e-8ab7-19db58c4c8af';
        details.Client_Secret__c = 'Mj4mCQnwGE%2fgWgOF0Ct090AdWBjXU%2fCLYfiD%2B656y8Q%3D';
        details.Get_CSV_File_URL__c = '';
        details.Get_Files_URL__c = 'https://upllimited.sharepoint.com/sites/spdevelopment/_api/web/GetFolderByServerRelativeUrl(\'/sites/spdevelopment/PLNMarginData/';
        details.Grant_Type__c = 'client_credentials';
        details.Resource__c = '00000003-0000-0ff1-ce00-000000000000/upllimited.sharepoint.com@8bc97f9a-ea86-472e-8ab7-19db58c4c8af';

        insert details;
        
      
        
        Trigger_Settings__c triggerSetting = new Trigger_Settings__c(
            Name ='MassUploadCSVTrigger', 
            IsActive__c = true , 
            ObjectName__c = 'Mass_Upload_CSV__c'
        );
        insert triggerSetting;
        
        
        /*Adding Custom Setting records */
        Mass_upload_Emails__c emails = new Mass_upload_Emails__c();
        emails.Name = 'MarginBlockEmails';
        emails.email__c = 'sandeep.vishwakarma@skinternational.com';
        emails.separator__c = ';';
        insert emails;
        
        Id MassUploadRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;
        
        insert new Trigger_Settings__c(Name ='MassUploadCSVTrigger', IsActive__c = true , ObjectName__c = 'Mass_Upload_CSV__c');
        
        
        
        
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
        file.File_Name__c = 'SalesDeduction_1_123.csv';
        file.Mass_Upload_CSV__c=mass1.id;
        insert file;
        
        Integration_Files__c file1=new Integration_Files__c();
        file1.Status__c='Draft';
        file1.Folder_Name__c = 'folder1';
        file.File_Name__c = 'E2ECostMBEW_1_123.CSV';
        file1.Mass_Upload_CSV__c=mass2.id;
        insert file1;
        
        /* End */
        
     /*   Test.startTest(); 
        update mass1;
        update mass2;
        mucsv.beforeDelete(oldItems);
        mucsv.afterUndelete(oldItems);
        mucsv.afterDelete(oldItems, newItems);
        rns.divideCSV(newItems, mapContentversion);
        System.enqueueJob(rns);
       
        Test.stopTest(); */
            
    }

    @isTest 
    static void testCallout() {
        ConnectToSharePoint.AccessTokenResponse token = new ConnectToSharePoint.AccessTokenResponse();
        token.access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvdXBsbGltaXRlZC5zaGFyZXBvaW50LmNvbUA4YmM5N2Y5YS1lYTg2LTQ3MmUtOGFiNy0xOWRiNThjNGM4YWYiLCJpc3MiOiIwMDAwMDAwMS0wMDAwLTAwMDAtYzAwMC0wMDAwMDAwMDAwMDBAOGJjOTdmOWEtZWE4Ni00NzJlLThhYjctMTlkYjU4YzRjOGFmIiwiaWF0IjoxNjY0MTkyNTcxLCJuYmYiOjE2NjQxOTI1NzEsImV4cCI6MTY2NDI3OTI3MSwiaWRlbnRpdHlwcm92aWRlciI6IjAwMDAwMDAxLTAwMDAtMDAwMC1jMDAwLTAwMDAwMDAwMDAwMEA4YmM5N2Y5YS1lYTg2LTQ3MmUtOGFiNy0xOWRiNThjNGM4YWYiLCJuYW1laWQiOiJiMGJiY2VkZi1lZDQ1LTRhYTktYTllMy0xYmM1NmQzMWExYjRAOGJjOTdmOWEtZWE4Ni00NzJlLThhYjctMTlkYjU4YzRjOGFmIiwib2lkIjoiYmU5M2EyNDEtMDRlOS00MzY2LTk4ZWUtMjQ2Nzk0MjYwNGUwIiwic3ViIjoiYmU5M2EyNDEtMDRlOS00MzY2LTk4ZWUtMjQ2Nzk0MjYwNGUwIiwidHJ1c3RlZGZvcmRlbGVnYXRpb24iOiJmYWxzZSJ9.EUaTDMdn8-3TiRS44R2hirSSPA88ILQ64bzWiFQfG0drDtQrf7TL4ky3U2kyqgYC1EopL0UFuQN4dGJNdQj-8nrxeGf9107TxPC-SOp-mysvdOd-cHJHS8u3TBKxCrhuKNsTsupX1j4ja4J8mtz852NHp8ChmI5XRpBiAucre0MB5uutFrOz4gtCV1rehpaYLCjmZoBDx9QL3Jx8JaCmcXME4shGMKUhSE8Omlln2BdujfhRpdOVmMreKGCX_v2n9baGvZWmczVjderc9FQn2a-jqb7c5mS7BEAl6n25WN2rh1iuVlre5_VslrfqCIErH_ZvfsFKJCnZk36OyTmEHg';
        Test.setMock(HttpCalloutMock.class, new MockHttpSharepoint(200,'OK',JSON.serialize(token),new Map<String,String>()));
        //SharepointSchedular sch = new SharepointSchedular('folder1');
        //sch.execute(null);
        MassCSVReprocessLWC.reprocess('folder1','','');
    }
    
    @isTest 
    static void testCallout1() {
        GetSharePointFilesResponse res = GetSharePointFilesResponse.parse('{"d":{"results":[{"__metadata":{"id":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')","uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')","type":"SP.File"},"Author":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/Author"}},"CheckedOutByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/CheckedOutByUser"}},"EffectiveInformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/EffectiveInformationRightsManagementSettings"}},"InformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/InformationRightsManagementSettings"}},"ListItemAllFields":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/ListItemAllFields"}},"LockedByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/LockedByUser"}},"ModifiedBy":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/ModifiedBy"}},"Properties":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/Properties"}},"VersionEvents":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/VersionEvents"}},"Versions":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv\')/Versions"}},"CheckInComment":"","CheckOutType":2,"ContentTag":"{6DFB201B-9ECA-48F7-879D-7996828AD958},1,1","CustomizedPageStatus":0,"ETag":"\\"{6DFB201B-9ECA-48F7-879D-7996828AD958},1\\"","Exists":true,"IrmEnabled":false,"Length":"5311257","Level":1,"LinkingUri":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv?d=w6dfb201b9eca48f7879d7996828ad958","LinkingUrl":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv?d=w6dfb201b9eca48f7879d7996828ad958","MajorVersion":1,"MinorVersion":0,"Name":"Discount_1__123.csv","ServerRelativeUrl":"/sites/SPDevelopment/PLNMarginData/folder1/Discount.csv","TimeCreated":"2022-09-23T11:57:22Z","TimeLastModified":"2022-09-23T11:57:22Z","Title":null,"UIVersion":512,"UIVersionLabel":"1.0","UniqueId":"6dfb201b-9eca-48f7-879d-7996828ad958"},{"__metadata":{"id":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')","uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')","type":"SP.File"},"Author":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/Author"}},"CheckedOutByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/CheckedOutByUser"}},"EffectiveInformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/EffectiveInformationRightsManagementSettings"}},"InformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/InformationRightsManagementSettings"}},"ListItemAllFields":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/ListItemAllFields"}},"LockedByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/LockedByUser"}},"ModifiedBy":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/ModifiedBy"}},"Properties":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/Properties"}},"VersionEvents":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/VersionEvents"}},"Versions":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv\')/Versions"}},"CheckInComment":"","CheckOutType":2,"ContentTag":"{BCEA2C34-14CC-4311-BE05-AEAF30166E17},1,1","CustomizedPageStatus":0,"ETag":"\\"{BCEA2C34-14CC-4311-BE05-AEAF30166E17},1\\"","Exists":true,"IrmEnabled":false,"Length":"5105807","Level":1,"LinkingUri":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv?d=wbcea2c3414cc4311be05aeaf30166e17","LinkingUrl":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv?d=wbcea2c3414cc4311be05aeaf30166e17","MajorVersion":1,"MinorVersion":0,"Name":"Rebate_1__123.csv","ServerRelativeUrl":"/sites/SPDevelopment/PLNMarginData/folder1/Rebate.csv","TimeCreated":"2022-09-23T11:57:19Z","TimeLastModified":"2022-09-23T11:57:19Z","Title":null,"UIVersion":512,"UIVersionLabel":"1.0","UniqueId":"bcea2c34-14cc-4311-be05-aeaf30166e17"},{"__metadata":{"id":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')","uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')","type":"SP.File"},"Author":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/Author"}},"CheckedOutByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/CheckedOutByUser"}},"EffectiveInformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/EffectiveInformationRightsManagementSettings"}},"InformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/InformationRightsManagementSettings"}},"ListItemAllFields":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/ListItemAllFields"}},"LockedByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/LockedByUser"}},"ModifiedBy":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/ModifiedBy"}},"Properties":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/Properties"}},"VersionEvents":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/VersionEvents"}},"Versions":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv\')/Versions"}},"CheckInComment":"","CheckOutType":2,"ContentTag":"{80E535DD-7B26-4136-A6F7-BC9C567AC436},1,1","CustomizedPageStatus":0,"ETag":"\\"{80E535DD-7B26-4136-A6F7-BC9C567AC436},1\\"","Exists":true,"IrmEnabled":false,"Length":"4315847","Level":1,"LinkingUri":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv?d=w80e535dd7b264136a6f7bc9c567ac436","LinkingUrl":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv?d=w80e535dd7b264136a6f7bc9c567ac436","MajorVersion":1,"MinorVersion":0,"Name":"AdditionalDiscount_1__123.csv","ServerRelativeUrl":"/sites/SPDevelopment/PLNMarginData/folder1/AdditionalDiscount.csv","TimeCreated":"2022-09-23T11:57:21Z","TimeLastModified":"2022-09-23T11:57:21Z","Title":null,"UIVersion":512,"UIVersionLabel":"1.0","UniqueId":"80e535dd-7b26-4136-a6f7-bc9c567ac436"},{"__metadata":{"id":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')","uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')","type":"SP.File"},"Author":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/Author"}},"CheckedOutByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/CheckedOutByUser"}},"EffectiveInformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/EffectiveInformationRightsManagementSettings"}},"InformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/InformationRightsManagementSettings"}},"ListItemAllFields":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/ListItemAllFields"}},"LockedByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/LockedByUser"}},"ModifiedBy":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/ModifiedBy"}},"Properties":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/Properties"}},"VersionEvents":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/VersionEvents"}},"Versions":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv\')/Versions"}},"CheckInComment":"","CheckOutType":2,"ContentTag":"{A47933D0-5F4E-42A1-AE5A-BD2E3E8FA3F1},1,1","CustomizedPageStatus":0,"ETag":"\\"{A47933D0-5F4E-42A1-AE5A-BD2E3E8FA3F1},1\\"","Exists":true,"IrmEnabled":false,"Length":"3361585","Level":1,"LinkingUri":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv?d=wa47933d05f4e42a1ae5abd2e3e8fa3f1","LinkingUrl":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv?d=wa47933d05f4e42a1ae5abd2e3e8fa3f1","MajorVersion":1,"MinorVersion":0,"Name":"PLN_1__123.csv","ServerRelativeUrl":"/sites/SPDevelopment/PLNMarginData/folder1/PLN.csv","TimeCreated":"2022-09-23T11:57:16Z","TimeLastModified":"2022-09-23T11:57:16Z","Title":null,"UIVersion":512,"UIVersionLabel":"1.0","UniqueId":"a47933d0-5f4e-42a1-ae5a-bd2e3e8fa3f1"},{"__metadata":{"id":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')","uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')","type":"SP.File"},"Author":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/Author"}},"CheckedOutByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/CheckedOutByUser"}},"EffectiveInformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/EffectiveInformationRightsManagementSettings"}},"InformationRightsManagementSettings":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/InformationRightsManagementSettings"}},"ListItemAllFields":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/ListItemAllFields"}},"LockedByUser":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/LockedByUser"}},"ModifiedBy":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/ModifiedBy"}},"Properties":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/Properties"}},"VersionEvents":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/VersionEvents"}},"Versions":{"__deferred":{"uri":"https://upllimited.sharepoint.com/sites/SPDevelopment/_api/Web/GetFileByServerRelativePath(decodedurl=\'/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv\')/Versions"}},"CheckInComment":"","CheckOutType":2,"ContentTag":"{AC9D7880-B925-486E-B8B9-C66668019AF0},1,1","CustomizedPageStatus":0,"ETag":"\\"{AC9D7880-B925-486E-B8B9-C66668019AF0},1\\"","Exists":true,"IrmEnabled":false,"Length":"4272105","Level":1,"LinkingUri":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv?d=wac9d7880b925486eb8b9c66668019af0","LinkingUrl":"https://upllimited.sharepoint.com/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv?d=wac9d7880b925486eb8b9c66668019af0","MajorVersion":1,"MinorVersion":0,"Name":"SalesDeduction_1__123.csv","ServerRelativeUrl":"/sites/SPDevelopment/PLNMarginData/folder1/SalesDeduction.csv","TimeCreated":"2022-09-23T11:57:18Z","TimeLastModified":"2022-09-23T11:57:18Z","Title":null,"UIVersion":512,"UIVersionLabel":"1.0","UniqueId":"ac9d7880-b925-486e-b8b9-c66668019af0"}]}}');
        //response.d.results = ['Sales_Deduction_1'];
        Test.setMock(HttpCalloutMock.class, new MockHttpSharepoint(200,'OK',JSON.serialize(res),new Map<String,String>()));
        Test.startTest();
        ConnectToSharePoint.readFilesName('folder1');
        Test.stopTest();
    }
                                                                          
    @isTest 
    static void testCallout2() {
		ConnectToSharePoint.AccessTokenResponse token = new ConnectToSharePoint.AccessTokenResponse();
        token.access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvdXBsbGltaXRlZC5zaGFyZXBvaW50LmNvbUA4YmM5N2Y5YS1lYTg2LTQ3MmUtOGFiNy0xOWRiNThjNGM4YWYiLCJpc3MiOiIwMDAwMDAwMS0wMDAwLTAwMDAtYzAwMC0wMDAwMDAwMDAwMDBAOGJjOTdmOWEtZWE4Ni00NzJlLThhYjctMTlkYjU4YzRjOGFmIiwiaWF0IjoxNjY0MTkyNTcxLCJuYmYiOjE2NjQxOTI1NzEsImV4cCI6MTY2NDI3OTI3MSwiaWRlbnRpdHlwcm92aWRlciI6IjAwMDAwMDAxLTAwMDAtMDAwMC1jMDAwLTAwMDAwMDAwMDAwMEA4YmM5N2Y5YS1lYTg2LTQ3MmUtOGFiNy0xOWRiNThjNGM4YWYiLCJuYW1laWQiOiJiMGJiY2VkZi1lZDQ1LTRhYTktYTllMy0xYmM1NmQzMWExYjRAOGJjOTdmOWEtZWE4Ni00NzJlLThhYjctMTlkYjU4YzRjOGFmIiwib2lkIjoiYmU5M2EyNDEtMDRlOS00MzY2LTk4ZWUtMjQ2Nzk0MjYwNGUwIiwic3ViIjoiYmU5M2EyNDEtMDRlOS00MzY2LTk4ZWUtMjQ2Nzk0MjYwNGUwIiwidHJ1c3RlZGZvcmRlbGVnYXRpb24iOiJmYWxzZSJ9.EUaTDMdn8-3TiRS44R2hirSSPA88ILQ64bzWiFQfG0drDtQrf7TL4ky3U2kyqgYC1EopL0UFuQN4dGJNdQj-8nrxeGf9107TxPC-SOp-mysvdOd-cHJHS8u3TBKxCrhuKNsTsupX1j4ja4J8mtz852NHp8ChmI5XRpBiAucre0MB5uutFrOz4gtCV1rehpaYLCjmZoBDx9QL3Jx8JaCmcXME4shGMKUhSE8Omlln2BdujfhRpdOVmMreKGCX_v2n9baGvZWmczVjderc9FQn2a-jqb7c5mS7BEAl6n25WN2rh1iuVlre5_VslrfqCIErH_ZvfsFKJCnZk36OyTmEHg';
        Test.setMock(HttpCalloutMock.class, new MockHttpSharepoint(200,'OK',JSON.serialize(token),new Map<String,String>()));        
        
        Test.startTest();
        ConnectToSharePoint.authentication();
        Test.stopTest();
    }
                                                                          
	@isTest 
    static void testCallout3() {
    Test.startTest(); 
        Mass_Upload_CSV__c mass1 = [select Id,Name from Mass_Upload_CSV__c where File_Name__c='SalesDeduction'];
        Mass_Upload_CSV__c mass2 = [select Id,Name from Mass_Upload_CSV__c where File_Name__c='E2ECostMBEW'];
        
        MassUploadCSVTriggerHandler mucsv = new  MassUploadCSVTriggerHandler();
        Map<Id, SObject> oldItems = new Map<Id, SObject>();
        Map<Id,Sobject> newItems = new Map<Id,Sobject>();
        newItems.put(mass1.Id,mass1);
        Map<String,ContentVersion> mapContentversion=new Map<String,ContentVersion>();
       // ReadAndSplitAttachment rns = new ReadAndSplitAttachment(newItems);
        
        update mass1;
        update mass2;
       /* mucsv.beforeDelete(oldItems);
        mucsv.afterUndelete(oldItems);
        mucsv.afterDelete(oldItems, newItems);
        rns.divideCSV(newItems, mapContentversion);
        System.enqueueJob(rns); */
       
        Test.stopTest();
    }                                            
}