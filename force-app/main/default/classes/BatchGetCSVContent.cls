/*******************************************************************************************
* @Name         BatchGetCSVContent
* @Author       Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
* @Group        SKI
* @Description  This class takes foldername from SharePointSchedular and Create  Mass upload Records (Record type: Original) and assign Files to mass upload records you can see it in related list files.
*******************************************************************************************/
public with sharing class BatchGetCSVContent implements Database.Batchable<Integration_Files__c>,Database.AllowsCallouts{
    String  folderName = 'folder1';//Default folder Name 
	Boolean isFileCreated = false;
    /**
     * This is a constructor which take folder name as a input.
     * @param folderName The first String.
     * @return No return
    */
    public BatchGetCSVContent(String folderName,Boolean isFileCreated){
        this.folderName = folderName;
        this.isFileCreated = isFileCreated;
    }

    /**
     * This is a Start method of batchable class. It bring the Integration Files which are in Draft stage.
     * @param bc The first paramter of type Database.BatchableContext.
     * @return It returns Iterable<Integration_Files__c>.
    */
    public Iterable<Integration_Files__c> start(Database.BatchableContext bc){
        System.debug('Folder '+this.folderName);
        List<String> fileNames = new List<String>();
        if(!this.isFileCreated){
            fileNames = ConnectToSharePoint.readFilesName(this.folderName);
            SharepointSchedular sch = new SharepointSchedular(this.folderName);
            sch.createIntegrationFile(fileNames,this.folderName);// check for Duplicate
            SharepointSchedular.fileCreated = true;
        }
        
        List<Integration_Files__c> integrationFiles = [select Id,Name,Status__c,File_Name__c from Integration_Files__c where Folder_Name__c=:this.folderName and Status__c='Draft' limit 1];
        System.debug('integrationFiles Files '+integrationFiles);
        return integrationFiles;
    }
  
    /**
     * This is a execute method of batchable class. It process the list of Integration files coming from start method.
     * It is used to create mass upload record of record type original by calling method createMassUpload.
     * @param bc The first paramter of type Database.BatchableContext.
     * @param integrationFiles The second paramter of type List<Integration_Files__c>.
     * @return It returns Iterable<Integration_Files__c>.
    */
    public void execute(Database.BatchableContext bc, List<Integration_Files__c> integrationFiles){
        String filname = integrationFiles[0].File_Name__c; 
        String csvBody = csvContent(this.folderName,filname);
        filname = filname.removeEnd('.csv');
        Blob content = Blob.valueOf(csvBody);
        Mass_Upload_CSV__c massupload = createMassUpload(filname,integrationFiles[0]); //TODO: Dyanamic Type from fileName
        createFiles(massupload,content);

    }
  
    /**
     * This is a finish method It will run once all the mass upload record (i.e of type original) and their repective file content is created 
     * @param bc The first paramter of type Database.BatchableContext.
     * @return void
    */  
    public void finish(Database.BatchableContext bc){
        System.debug('Batch Complete');
    }

    /**
     * This is csvContent method used to bring content of fileName provided as input from folderName provided as input which is stored on Microsoft sharepoint.
     * @param folderName The first paramter String.
     * @param fileName The Second paramter String .
     * @return It returns csv file content in string type. 
    */
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
        String csvbody = response.getbody();
        return csvbody;
    }

    /**
     * createMassUpload method used to create mass upload record (Mass_Upload_CSV__c) of record type Original and status will be Draft.
     * @param type The first paramter String.
     * @param integrationFiles The Second paramter Integration_Files__c .
     * @return It returns created mass upload record (Mass_Upload_CSV__c )
    */
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
        massupload.Seperator__c = Mass_upload_Emails__c.getValues('MarginBlockEmails').separator__c;
        insert massupload;

        integrationFiles.Mass_Upload_CSV__c =massupload.Id;
        update integrationFiles;
        return massupload;
    }
    /**
     * createFiles method is use to Create File for provided mass upload record with the provided content
     * @param massupload The first paramter Mass_Upload_CSV__c.
     * @param content The Second paramter Blob.
     * @return void
    */
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

    /**
     * getTypeFromFileName method used to get Type of file (i.e SalesDeduction,E2ECost etc)
     * @param fileName The first paramter String.
     * @return It returns type of file
    */
    public String getTypeFromFileName(String fileName){
        List<String> words = fileName.split('_');
        System.debug('Words '+words);
        words.remove(words.size() - 1);
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
        mapFileTypes.put('PLN_CustomerSKU','PLNCustomer');
        mapFileTypes.put('Exchange_Rate','USDExchangeRate');

        return mapFileTypes.get(fileName);// return type of record
    }

}