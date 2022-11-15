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
        
        insert new Trigger_Settings__c(Name ='MassUploadCSVTrigger', IsActive__c = true , ObjectName__c = 'Mass_Upload_CSV__c');
    }

    @isTest static void testCallout() {
        ConnectToSharePoint.AccessTokenResponse token = new ConnectToSharePoint.AccessTokenResponse();
        token.access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvdXBsbGltaXRlZC5zaGFyZXBvaW50LmNvbUA4YmM5N2Y5YS1lYTg2LTQ3MmUtOGFiNy0xOWRiNThjNGM4YWYiLCJpc3MiOiIwMDAwMDAwMS0wMDAwLTAwMDAtYzAwMC0wMDAwMDAwMDAwMDBAOGJjOTdmOWEtZWE4Ni00NzJlLThhYjctMTlkYjU4YzRjOGFmIiwiaWF0IjoxNjY0MTkyNTcxLCJuYmYiOjE2NjQxOTI1NzEsImV4cCI6MTY2NDI3OTI3MSwiaWRlbnRpdHlwcm92aWRlciI6IjAwMDAwMDAxLTAwMDAtMDAwMC1jMDAwLTAwMDAwMDAwMDAwMEA4YmM5N2Y5YS1lYTg2LTQ3MmUtOGFiNy0xOWRiNThjNGM4YWYiLCJuYW1laWQiOiJiMGJiY2VkZi1lZDQ1LTRhYTktYTllMy0xYmM1NmQzMWExYjRAOGJjOTdmOWEtZWE4Ni00NzJlLThhYjctMTlkYjU4YzRjOGFmIiwib2lkIjoiYmU5M2EyNDEtMDRlOS00MzY2LTk4ZWUtMjQ2Nzk0MjYwNGUwIiwic3ViIjoiYmU5M2EyNDEtMDRlOS00MzY2LTk4ZWUtMjQ2Nzk0MjYwNGUwIiwidHJ1c3RlZGZvcmRlbGVnYXRpb24iOiJmYWxzZSJ9.EUaTDMdn8-3TiRS44R2hirSSPA88ILQ64bzWiFQfG0drDtQrf7TL4ky3U2kyqgYC1EopL0UFuQN4dGJNdQj-8nrxeGf9107TxPC-SOp-mysvdOd-cHJHS8u3TBKxCrhuKNsTsupX1j4ja4J8mtz852NHp8ChmI5XRpBiAucre0MB5uutFrOz4gtCV1rehpaYLCjmZoBDx9QL3Jx8JaCmcXME4shGMKUhSE8Omlln2BdujfhRpdOVmMreKGCX_v2n9baGvZWmczVjderc9FQn2a-jqb7c5mS7BEAl6n25WN2rh1iuVlre5_VslrfqCIErH_ZvfsFKJCnZk36OyTmEHg';
        Test.setMock(HttpCalloutMock.class, new MockHttpSharepoint(200,'OK',JSON.serialize(token),new Map<String,String>()));
        SharepointSchedular sch = new SharepointSchedular('folder1');
        sch.execute(null);
    }
}