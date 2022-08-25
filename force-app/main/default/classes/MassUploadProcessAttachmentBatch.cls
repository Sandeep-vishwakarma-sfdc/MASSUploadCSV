global class MassUploadProcessAttachmentBatch implements Database.Batchable<sObject>,Database.Stateful{ 
    public List<String> contentVersionIds;
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
            Mass_Upload_CSV__c massupload=[select Id,name,Comments__c,CSV_fields__c,Error_records__c,File_Name__c,File_Type__c,
                                                   isAttachment__c,Mode__c,Object_Name__c,	Operation__c,Parent__c,Status__c,
                                                   Success_records__c,Total_records__c,Upload_Date_Time__c,Upsert_Key__c from Mass_Upload_CSV__c 
                                                   where Id IN:LinkentityID limit 1];
            
            
            SplitString splitObj = new SplitString();
            String fileTypeName=massupload.File_Type__c.deleteWhitespace();
            System.debug('filetype==>'+fileTypeName.deleteWhitespace());
            if(fileTypeName.equals(contentvar.Title)){
               list<String> csvFileds=massupload.CSV_fields__c.split(';');
               System.debug('csvFileds is==>'+csvFileds);
               List<String> csvbody=splitObj.safeSplit(contentvar.VersionData.toString(), '\n');
               list<String> CsvHeader=csvbody[0].replaceAll('\u0009','').trim().split(',');
               List<String> csvAttachment = new List<String>();
              
               Integer Count=0;
               for(Integer i=0; i<CsvHeader.size();i++)
               {
        
                   if(csvFileds[i].deleteWhitespace().equals(CsvHeader[i].deleteWhitespace()))
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
               
            
           }
        }
             
        
    }    

    global void finish(Database.BatchableContext BC){
      System.debug('Inside Finish Method');  
    }
    
}