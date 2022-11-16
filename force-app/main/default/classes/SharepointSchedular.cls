public with sharing class SharepointSchedular implements Schedulable {
    String folderName = '';
    public SharepointSchedular(String folderName){
        this.folderName = folderName;
    }
    
    public void execute(SchedulableContext sc) {
        List<String> fileNames = new List<String>();
        if(Test.isRunningTest()){
            fileNames = new List<String>{'Sales_Deduction_1'};
                createIntegrationFile(fileNames,folderName);
        }else{
            fileNames = ConnectToSharePoint.readFilesName(folderName);
            createIntegrationFile(fileNames,folderName);// check for Duplicate
            BatchGetCSVContent batch = new BatchGetCSVContent(this.folderName);
            Database.executeBatch(batch,1);
        }
        
    }

    public void createIntegrationFile(List<String> fileNames,String folderName){
        List<Integration_Files__c> integrationFiles = new List<Integration_Files__c>();
        
        for(String fileName :fileNames){
            Integration_Files__c integrationFile = new Integration_Files__c();
            integrationFile.File_Name__c = fileName;
            integrationFile.Folder_Name__c = folderName;
            integrationFile.Status__c = 'Draft';
            integrationFiles.add(integrationFile);
        }
        insert integrationFiles;
 
    }
}