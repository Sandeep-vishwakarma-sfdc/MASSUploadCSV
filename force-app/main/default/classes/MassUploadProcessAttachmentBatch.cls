global class MassUploadProcessAttachmentBatch implements Database.Batchable<sObject>,Database.Stateful{ 
    public List<String> contentVersionIds;
    public Mass_Upload_CSV__c massupload;
   public MassUploadProcessAttachmentBatch(List<String> contentVersionIds){
        this.contentVersionIds = contentVersionIds;
    }  
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Inside Start Method==>'+this.contentVersionIds);
        List<String> cvtemp = this.contentVersionIds;
        return Database.getQueryLocator('SELECT Id, VersionData,ContentDocumentId,Title FROM ContentVersion WHERE Id IN:cvtemp');
    }
    
    global void execute(Database.BatchableContext bc, List<ContentVersion> contentVersionData){
        System.debug('Execute List==>'+contentVersionData);
        if(contentVersionData.size()>0){
            String contentVersionId=contentVersionData[0].id;
      		System.debug('Inside Execute Method==>'+contentVersionData[0].VersionData.toString());
            
            ContentVersion contentvar=[SELECT Id,ContentDocumentId,Title,VersionData FROM ContentVersion WHERE Id =:contentVersionId];
             System.debug('ContentDocumentId==>'+contentvar);
            
            
            List<ContentDocumentLink> conDocLink = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =:contentvar.ContentDocumentId];
         	 System.debug('LinkedEntityId is==>'+conDocLink);
            
            List<String> LinkentityID= new List<String> ();
            for(ContentDocumentLink linkEId:conDocLink)
            {
                LinkentityID.add(linkEId.LinkedEntityId);
                System.debug('LinkEntityid==>'+LinkentityID);
            }
            massupload=[select Id,name,Comments__c,CSV_fields__c,Error_records__c,File_Name__c,File_Type__c,
                                                   isAttachment__c,Mode__c,Object_Name__c,	Operation__c,Parent__c,Status__c,
                                                   Success_records__c,Total_records__c,Upload_Date_Time__c,Upsert_Key__c,Seperator__c from Mass_Upload_CSV__c 
                                                   where Id IN:LinkentityID limit 1];
           
            
            SplitString splitObj = new SplitString();
            String fileTypeName=massupload.File_Type__c.deleteWhitespace();
            System.debug('filetype==>'+fileTypeName.deleteWhitespace());
            //today
            System.debug('title'+contentvar.Title);
            if(contentvar.Title.contains(fileTypeName)){
               list<String> csvFileds=massupload.CSV_fields__c.split(';');
               System.debug('csvFileds is==>'+csvFileds);
               List<String> csvbody=splitObj.safeSplit(contentvar.VersionData.toString(), '\n');
               /*list<String> CsvHeader=csvbody[0].replaceAll('\u0009','').trim().split(',');
               List<String> csvAttachment = new List<String>();
              
               Integer Count=0;
               for(Integer i=0; i<CsvHeader.size();i++)
               {
        
                   if(csvFileds.contains(CsvHeader[i].deleteWhitespace()))
                   {
                       Count++;
                       
                   }
               }
               if(Count==CsvHeader.size())
               {
                   System.debug('Success');
                   MassUploadProcessAttachmentBatchHelper.createRecords(csvbody,massupload);
               }
               else
               {
                   System.debug('Error');
               }
               */
            	MassUploadProcessAttachmentBatchHelper.createRecords(csvbody,massupload);

           }
        }
             
        
    }    
    
    global void finish(Database.BatchableContext BC){
        System.debug('Inside Finish Method');  
        Mass_Upload_CSV__c splitmassUploadCsv  = [select Id,Name,Parent__c,Error_records__c,Success_records__c,Total_records__c,Status__c,Comments__c from Mass_Upload_CSV__c where Id=:massupload.Id];
        System.debug(' MassUpload Records==>'+splitmassUploadCsv.Id);  
        System.debug(' Split Records==>'+splitmassUploadCsv);  
                
        String ParentId = splitmassUploadCsv.Parent__c;
       
        System.debug(' ParentId Records==>'+ParentId);  
        Mass_Upload_CSV__c   parentMassUpload= [select ID,Name, Error_records__c,Success_records__c,Total_records__c,Status__c,Comments__c from Mass_Upload_CSV__c where id=:ParentId];
        System.debug('SplitmassUploadCsv Records==>'+splitmassUploadCsv);
        Integer totalSuccessCount = 0;
        Integer totalErrorCount = 0;
        Integer totalRecordsCount=0;
        Decimal successCount=0;
        Decimal errorCount=0;
        Decimal totalCount=0;
        
        List<Mass_Upload_CSV__c> allSplitMassupload=[select ID,Name, Error_records__c,Success_records__c,Parent__c,Total_records__c,Status__c,Comments__c from Mass_Upload_CSV__c where Parent__c=:ParentId];
        system.debug(' allSplitMassupload'+ allSplitMassupload);
        for(Mass_Upload_CSV__c split:allSplitMassupload){
            totalCount= !String.isEmpty(String.valueof(split.Total_records__c))  ? split.Total_records__c :0;            
            successCount= !String.isEmpty(String.valueof(split.Success_records__c))  ? split.Success_records__c :0;
            errorCount= !String.isEmpty(String.valueof(split.Error_records__c))  ? split.Error_records__c :0 ;
            
           System.debug('Error record'+errorCount + 'split Error record'+split.Error_records__c);
            parentMassUpload.Total_records__c = totalRecordsCount +totalCount +(!String.isEmpty(String.valueof(parentMassUpload.Total_records__c))  ? parentMassUpload.Total_records__c :0) ;  
            parentMassUpload.Success_records__c = totalSuccessCount +successCount+(!String.isEmpty(String.valueof(parentMassUpload.Success_records__c))  ? parentMassUpload.Success_records__c :0) ;      
            parentMassUpload.Error_records__c  = totalErrorCount +errorCount+(!String.isEmpty(String.valueof(parentMassUpload.Error_records__c))  ? parentMassUpload.Error_records__c :0) ;
            parentMassUpload.Status__c=split.Status__c;
            parentMassUpload.Comments__c=split.Comments__c; 
            }
        //parentMassUpload.Status__c='Completed';
        update parentMassUpload; 
    }
          
  }