public class MassUploadProcessAttachmentBatch implements Database.Batchable<sObject>, Database.Stateful {
	public List<String> contentVersionIds;
	public Mass_Upload_CSV__c massupload;

	public MassUploadProcessAttachmentBatch(List<String> contentVersionIds) {
		this.contentVersionIds = contentVersionIds;
	}

	public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('Inside Start Method==>'+this.contentVersionIds);
        List<String> cvtemp = this.contentVersionIds;
        return Database.getQueryLocator('SELECT Id, VersionData,ContentDocumentId,Title FROM ContentVersion WHERE Id IN:cvtemp');
        
    }

	public void execute(Database.BatchableContext bc, List<ContentVersion> contentVersionData){
        System.debug('Execute List==>'+contentVersionData.size());
        try {
            if(contentVersionData.size()>0){
                String contentVersionId=contentVersionData[0].id;
                ContentVersion contentvar=[SELECT Id,ContentDocumentId,Title,VersionData FROM ContentVersion WHERE Id =:contentVersionId];
                List<ContentDocumentLink> conDocLink = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =:contentvar.ContentDocumentId];
                List<String> linkentityID= new List<String> ();
                for(ContentDocumentLink linkEId:conDocLink){
                    linkentityID.add(linkEId.LinkedEntityId);
                }
                massupload=[select Id,name,Comments__c,CSV_fields__c,Error_records__c,File_Name__c,File_Type__c,isAttachment__c,Mode__c,Object_Name__c,	Operation__c,Parent__c,Status__c,Success_records__c,Total_records__c,Upload_Date_Time__c,Upsert_Key__c,Seperator__c from Mass_Upload_CSV__c where Id IN:linkentityID limit 1];
                
                SplitString splitObj = new SplitString();
                String fileTypeName=massupload.File_Type__c.deleteWhitespace();
                if(contentvar.Title.contains(fileTypeName)){
                //    list<String> csvFileds=massupload.CSV_fields__c.split(';');
                   List<String> csvbody=splitObj.safeSplit(contentvar.VersionData.toString(), '\n');
                   MassUploadProcessAttachmentBatchHelper.createRecords(csvbody,massupload,bc);
               }
            }
        } catch (Exception e) {
            massupload.Comments__c=e.getMessage()+' '+e.getLineNumber();
            massupload.Status__c='Completed';
	        update massupload;
            // System.abortJob(bc.getJobId());
        }
    }

	public void finish(Database.BatchableContext bc){
        System.debug('Inside Finish Method');  
        Mass_Upload_CSV__c splitmassUploadCsv  = [select Id,Name,Parent__c,Error_records__c,Success_records__c,Total_records__c,Status__c,Comments__c from Mass_Upload_CSV__c where Id=:massupload.Id];
        String parentId = splitmassUploadCsv.Parent__c;
        Mass_Upload_CSV__c   parentMassUpload= [select ID,Name, Error_records__c,Success_records__c,Total_records__c,Status__c,Comments__c from Mass_Upload_CSV__c where id=:parentId];
        Integer totalSuccessCount = 0;
        Integer totalErrorCount = 0;
        Integer totalRecordsCount=0;
        Decimal successCount=0;
        Decimal errorCount=0;
        Decimal totalCount=0;
        DateTime d = Date.Today() ;
        String dateString =  d.format('dd/MM/yyyy') ;
        List<Mass_Upload_CSV__c> allSplitMassupload=[select ID,Name, Error_records__c,Success_records__c,Parent__c,Total_records__c,Status__c,Comments__c from Mass_Upload_CSV__c where Parent__c=:ParentId];
        for(Mass_Upload_CSV__c split:allSplitMassupload){
            totalCount= !String.isEmpty(String.valueof(split.Total_records__c))  ? split.Total_records__c :0;            
            successCount= !String.isEmpty(String.valueof(split.Success_records__c))  ? split.Success_records__c :0;
            errorCount= !String.isEmpty(String.valueof(split.Error_records__c))  ? split.Error_records__c :0 ;
            parentMassUpload.Total_records__c = totalRecordsCount +totalCount +(!String.isEmpty(String.valueof(parentMassUpload.Total_records__c))  ? parentMassUpload.Total_records__c :0) ;  
            parentMassUpload.Success_records__c = totalSuccessCount +successCount+(!String.isEmpty(String.valueof(parentMassUpload.Success_records__c))  ? parentMassUpload.Success_records__c :0) ;      
            parentMassUpload.Error_records__c  = totalErrorCount +errorCount+(!String.isEmpty(String.valueof(parentMassUpload.Error_records__c))  ? parentMassUpload.Error_records__c :0) ;
            parentMassUpload.Status__c=split.Status__c;
            parentMassUpload.Comments__c=split.Comments__c; 
            }
        //parentMassUpload.Status__c='Completed';
            
                    
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                   
             mail.setUseSignature(false);
             mail.setToAddresses(new String[] { Mass_upload_Emails__c.getValues('MarginBlockEmails').email__c });
             mail.setSubject(massupload.File_Type__c+'Successfully process');
             mail.setHtmlBody('Dear User,<br /><br />Your Records are Successfully processd<br /><br />Date: '+dateString+'<br /><br />No. of Total records: '+ parentMassUpload.Total_records__c+'<br /><br />No. of Success records: '+ parentMassUpload.Success_records__c+'<br /><br />No. of Error records: '+ parentMassUpload.Error_records__c+'<br /><br />Regards,<br/>UPL Salesforce Administrator<br />');
           //mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach1 }); 
           if(errorCount==0){
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
             update parentMassUpload; 

         
       List<Integration_Files__c> integrationFiles = [select id,Name,Folder_Name__c,Status__c from Integration_Files__c where Mass_Upload_CSV__c=:parentMassUpload.Id limit 1];
        if(integrationFiles.size() >0 )
        {
         Integration_Files__c integrationFile=integrationFiles[0];
         System.debug('integrationFile is'+integrationFile);   
        integrationFile.Status__c = 'Completed';
         update integrationFile;
         String folderName = integrationFile.Folder_Name__c;
         BatchGetCSVContent batch = new BatchGetCSVContent(folderName);
         Database.executeBatch(batch,1);
        }
        else
        {
            System.debug('integrationFile is1'+integrationFiles);   
         System.debug('Dont Update status');   
        }
    }

}