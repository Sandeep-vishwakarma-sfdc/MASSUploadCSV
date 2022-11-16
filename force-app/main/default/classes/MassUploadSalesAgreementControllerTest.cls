@isTest 
public class MassUploadSalesAgreementControllerTest {
	@testSetup
    static void allDataForThisClass(){
         
        Sales_Org__c salesOrg= new Sales_Org__c();
        salesorg.Name='Brazil';
        salesorg.Description__c='Brazil';
        salesorg.Sales_Org_Code__c='5191';
        insert salesorg;
         
		Sales_Forecast_Setting__c sfsObj= new Sales_Forecast_Setting__c();
        sfsObj.Active_Forecast_Month__c='May';
        sfsObj.Start_Day_Of_Approval__c=7;
        sfsObj.End_Day_Of_Approval__c=14;
        sfsObj.Start_Day_of_Submission__c=2;
        sfsObj.End_Day_of_Submission__c=5;
        //sfsObj.Sales_Org__c=salesorg.Id;
        insert sfsObj;
        
        
    }
    static testMethod void method(){
        
        MassUploadSalesAgreementController.getsalesforecastsetting();
        
        String body ='Update Id;Planned Quantity\r\n';
        body+='0YC1m0000004OmoGAE;1\r\n';
        body+='0YC1m0000004OmnGAE;2\r\n';
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'SalesAgreementSchedule',
            PathOnClient = 'SalesAgreementSchedule.csv',
            VersionData = Blob.valueOf(body),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        
        BusinessDashboard__c bdObj2 = new BusinessDashboard__c();
        bdObj2.RecordTypeId = Schema.SObjectType.BusinessDashboard__c.getRecordTypeInfosByName().get('Split File').getRecordTypeId();
       	bdObj2.EmailSubject__c = 'test_liquidation3.txt';
        bdObj2.FromAddress__c = 'azhar.shaikh@skinternational.com' ;
        bdObj2.Status__c = 'Draft';
        bdObj2.As_of_now__c = System.now();
        bdObj2.Rows__c = 5;
        bdObj2.Header__c = 'Update Id,Planned Quantity';
        insert bdObj2;
        System.debug('bdObj2 :----'+bdObj2);
        
        Attachment attachment2 = new Attachment();
        attachment2.ParentId = bdObj2.Id;
        attachment2.Name = 'SalesAgreementSchedule.csv';
        attachment2.Body = Blob.valueof('0YC0k0000002v6JGAQ,1\r\n');
        insert attachment2;
        System.debug('attachment2 :----'+attachment2);
        
        Schema_Definition__c sdObj3 = new Schema_Definition__c();
        sdObj3.Name = 'SalesAgreementProductSchedule';
        sdObj3.Mapping_Definition__c = '[{"position":0,"label":"","fieldType":"","column":"Update Id","api":"Id"},{"position":1,"label":"","fieldType":"DOUBLE","column":"Planned Quantity","api":"PlannedQuantity"}]';
        insert sdObj3;
        System.debug('sdObj3 :----'+sdObj3);
        
        SchemaObjectMapping__c smObj2 = new SchemaObjectMapping__c();
        smObj2.Name = 'SalesAgreementProductSchedule';
        smObj2.Filename__c='SalesAgreementSchedule.csv';
        smObj2.Object__c = 'SalesAgreementProductSchedule';
        insert smObj2;
        
        MassUploadSalesAgreementController.readCSVFile(contentVersionSelect.ContentDocumentId);
    }
    
}