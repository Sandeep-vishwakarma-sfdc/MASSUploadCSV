public with sharing class BatchGetCSVContent implements Database.Batchable<String>{
    String  folderName = 'folder1';
    public BatchGetCSVContent(String folderName){
        folderName = folderName;
    }

    public Iterable<String> start(Database.BatchableContext bc){
        List<String> fileNames = new List<String>();
        fileNames = ConnectToSharePoint.readFilesName(folderName);
        return fileNames;
    }
  
    public void execute(Database.BatchableContext bc, List<String> fileNames){
        String filname = fileNames[0]; 
        String csvBody = csvContent(this.folderName,filname);
        Blob content = Blob.valueOf(csvBody);
        Mass_Upload_CSV__c massupload = createMassUpload('SalesDeduction'); //TODO: Dyanamic Type from fileName
        createFiles(massupload,content);

    }
  
    public void finish(Database.BatchableContext bc){
    }

    public String csvContent(String folderName,String fileName){
        String accessToken = ConnectToSharePoint.authentication();
        SharePointDetails__c sharepointDetail = ConnectToSharePoint.getSharePointdetails();
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        String authorizationHeader = 'Bearer '+accessToken;
        String appendFolder = sharepointDetail.Get_CSV_File_URL__c + folderName+'/'+fileName+'\')'+'/$value';
        request.setendPoint(appendFolder);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json;odata=verbose');
        request.setHeader('Authorization',authorizationHeader);
        httpResponse response = https.send(request);
        System.debug('Body Files'+response.getbody());
        // String csvbody = response.getbody(); TODO: Reponse from API
        String csvbody = 'Profit Center,Sales Org,Dc,Div,SKU Code,UOM ,Sales Deduction LC,Sales Deduction USD,Start Date, End Date \nLA0005,5100,20,10,000000000000856010,KG,11,0.58,30042022,31032023\nLA0005,5100,20,10,000000000000856083,KG,12,0.68,30042022,31032023\nLA0005,5100,20,10,000000000000854052,KG,13,1,30042022,31032023\nLA0005,5100,20,60,000000000000854053,KG,14,1,30042022,31032023\nLA0005,5100,20,60,000000000000720502,KG,15,12,30042022,31032023';
        return csvbody;
    }

    public void linkFilesToMassUpload(){

    }
    public  Mass_Upload_CSV__c createMassUpload(String type){
        MassUploadExternalIdRecords__c massUploadExternalIdRecords = [select Id,Name,DataType__c,ExternalId__c,ObjectName__c,FieldUseInCombinationKey__c,isRecordType__c,Type__c,CSVFields__c,TypeApiName__c from MassUploadExternalIdRecords__c where Type__c =:type limit 1];   
        Id MassUploadSplitRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;

        Mass_Upload_CSV__c massupload = new Mass_Upload_CSV__c();
        massupload.Name = type;
        massupload.CSV_fields__c = massUploadExternalIdRecords.CSVFields__c;
        massupload.File_Name__c = type;
        massupload.File_Type__c = type;
        massupload.Mode__c = 'Auto';
        massupload.Object_Name__c = massUploadExternalIdRecords.ObjectName__c;
        massupload.Status__c = 'Draft';
        massupload.RecordTypeId = MassUploadSplitRecordTypeId;
        insert massupload;
        return massupload;
    }
    public  void createFiles(Mass_Upload_CSV__c massupload,Blob content){    
        ContentVersion contentV = new ContentVersion();
        contentV.VersionData=content;
        contentV.Title=massupload.File_Name__c;
        contentV.PathOnClient=massupload.File_Name__c +'.'+'csv';
        contentV.IsMajorVersion=true;
        insert contentV;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentV.Id].ContentDocumentId;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = massupload.Id;
        cdl.ContentDocumentId = conDocId;
        Insert cdl;
    }

}
