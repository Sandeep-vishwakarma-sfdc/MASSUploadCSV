/*******************************************************************************************
* @Name         BatchGetCSVContent
* @Author       Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
* @Group        SKI
* @Description  This class takes foldername from SharePointSchedular and Create  Mass upload Records (Record type: Original) and assign Files to mass upload records
*******************************************************************************************/
public with sharing class BatchGetCSVContent implements Database.Batchable<Integration_Files__c>,Database.AllowsCallouts{
    String  folderName = 'folder1';//Default folder Name
    public BatchGetCSVContent(String folderName){
        folderName = folderName;
    }

    public Iterable<Integration_Files__c> start(Database.BatchableContext bc){
        List<Integration_Files__c> integrationFiles = [select Id,Name,Status__c,File_Name__c from Integration_Files__c where Folder_Name__c=:this.folderName and Status__c='Draft' limit 1];
        return integrationFiles;
    }
  
    public void execute(Database.BatchableContext bc, List<Integration_Files__c> integrationFiles){
        String filname = integrationFiles[0].File_Name__c; 
        String csvBody = csvContent(this.folderName,filname);
        filname = filname.removeEnd('.csv');
        Blob content = Blob.valueOf(csvBody);
        Mass_Upload_CSV__c massupload = createMassUpload(filname,integrationFiles[0]); //TODO: Dyanamic Type from fileName
        createFiles(massupload,content);

    }
  
    public void finish(Database.BatchableContext bc){
        System.debug('Batch Complete');
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
        String csvbody = response.getbody(); //TODO: Reponse from API
        //String csvbody = 'Profit Center,Sales Org,Dc,Div,SKU Code,UOM ,Sales Deduction LC,Sales Deduction USD,Start Date, End Date \nLA0005,5100,20,10,000000000000856010,KG,11,0.58,30042022,31032023\nLA0005,5100,20,10,000000000000856083,KG,12,0.68,30042022,31032023\nLA0005,5100,20,10,000000000000854052,KG,13,1,30042022,31032023\nLA0005,5100,20,60,000000000000854053,KG,14,1,30042022,31032023\nLA0005,5100,20,60,000000000000720502,KG,15,12,30042022,31032023';
        return csvbody;
    }

    public  Mass_Upload_CSV__c createMassUpload(String type,Integration_Files__c integrationFiles){
        type = getTypeFromFileName(type);
        System.debug('Type '+type);
        MassUploadExternalIdRecords__c massUploadExternalIdRecords = [select Id,Name,DataType__c,ExternalId__c,ObjectName__c,FieldUseInCombinationKey__c,isRecordType__c,Type__c,CSVFields__c,TypeApiName__c from MassUploadExternalIdRecords__c where Type__c =:type limit 1];   
        Id MassUploadSplitRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;

        Mass_Upload_CSV__c massupload = new Mass_Upload_CSV__c();
        massupload.Name = type;
        // massupload.CSV_fields__c = massUploadExternalIdRecords.CSVFields__c;
        massupload.File_Name__c = type;
        massupload.File_Type__c = type;
        massupload.Mode__c = 'Auto';
        massupload.Object_Name__c = massUploadExternalIdRecords.ObjectName__c;
        massupload.Status__c = 'Draft';
        massupload.RecordTypeId = MassUploadSplitRecordTypeId;
        massupload.Seperator__c = ';';
        insert massupload;

        integrationFiles.Mass_Upload_CSV__c =massupload.Id;
        update integrationFiles;
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

    public String getTypeFromFileName(String fileName){
        /* List<String> fileNames = fileName.split('_');
        if(fileNames.size()>0){// Logic to covert FileName to type i.e (SalesDeduction_1 to SalesDeduction)
            fileNames.remove(fileNames.size()-1);
            String type = String.join(fileNames,'');
            return type;
        }else{
            return fileName;
        } */

        // Logic to convert Additional_Discount_1_20230227081442 to Additional_Discount
        // String fileName = 'Additional_Discount_1_20230227081442';
        List<String> words = fileName.split('_');
        System.debug('Words '+words);
        words.remove(words.size() - 1);
        words.remove(words.size() - 1);
        fileName = String.join(words,'_');
        System.debug('fileName '+fileName);
        Map<String,String> mapFileTypes = new Map<String,String>();
       
        mapFileTypes.put('Sales_Deduction','SalesDeduction');
        mapFileTypes.put('E2E_Cost','E2ECost');
        mapFileTypes.put('E2E_UPC9','E2ECostUPC9');
        mapFileTypes.put('E2E_MBEW','E2ECostMBEW');
        mapFileTypes.put('Rebate','Rebate');
        mapFileTypes.put('Rebate_Customer','RebateCustomer');
        mapFileTypes.put('Discount','Discount');
        mapFileTypes.put('Additional_Discount','AdditionalDiscount');
        mapFileTypes.put('PLN','PLN');
        mapFileTypes.put('PLN_Customer','PLNCustomer');

        return mapFileTypes.get(fileName);// return type of record
    }

}



// Sales_Deduction
// E2E_Cost
// E2E_UPC9
// E2E_MBEW
// Rebate
// Rebate_Customer
// Discount
// Additional_Discount
// PLN
// PLN_Customer
// Exchange_Rate

// Additional_Discount_1_20230227081442
// PLN_1_20230227081518
// Additional_Discount
// PLN