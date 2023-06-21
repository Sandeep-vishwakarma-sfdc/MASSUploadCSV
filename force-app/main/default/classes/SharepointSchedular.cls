public with sharing class SharepointSchedular implements Schedulable {
    String folderName = '';
	public static boolean fileCreated = false;
    
    /**
     * SharepointSchedular is a constructor takes folder name of sharepoint
     * @param folderName The first parameter folderName.
     * @return No returns
    */
    public SharepointSchedular(String folderName){
        this.folderName = folderName;
        if(String.isBlank(folderName)){
            DateTime now = DateTime.now();
            String formattedDate = now.format('MMM_yy');
            System.debug('formattedDate '+formattedDate);
            this.folderName = formattedDate;
        }
    }
    
    /**
     * execute method calls runs method of this class to create Integration Files of each file present in the provided folder in sharepoint
     * @param sc The first parameter SchedulableContext.
     * @return void
    */
    public void execute(SchedulableContext sc) {
        run();
    }

    /**
     * run method brings names of the file present in the specified folder and call createIntegrationFile method of this class
     * @return void
    */
    public void run(){
        List<String> fileNames = new List<String>();
        if(Test.isRunningTest()){
            fileNames = new List<String>{'Sales_Deduction_1'};
                createIntegrationFile(fileNames,folderName);
        }else{
            
            BatchGetCSVContent batch = new BatchGetCSVContent(this.folderName,false);
          Database.executeBatch(batch,1);
        }
    }

    /**
     * createIntegrationFile method creates Integrtion files for each file present in provided folder
     * @return void
    */
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

    // String jobName = 'MyCronJob';
    // String cronExpression = '0 30 14 5 * ?'; // Runs at 2:30 PM on the 5th day of every month
    // System.schedule(jobName, cronExpression, new MyCronJobClass());
}