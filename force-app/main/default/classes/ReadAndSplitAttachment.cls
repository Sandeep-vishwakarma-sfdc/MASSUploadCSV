public with sharing class ReadAndSplitAttachment implements Queueable{
    
    // private Map<String,ContentVersion> mapContentversion=new Map<String,ContentVersion>();
    private Map<Id,SObject> newItems = new Map<Id,SObject>();
    private Integer count = 0;
    private static Id MassUploadSplitRecordTypeId;
   
    /**
     * ReadAndSplitAttachment is a constructor which takes Map<Id,SObject> as input and brings  Mass_Upload_CSV__c records of record type original and is Attachement is true.
     * @param newItems The first parameter Map<Id,SObject>.
     * @return void
    */
    public ReadAndSplitAttachment(Map<Id,SObject> newItems){
        Map<Id,SObject> mapitems= new Map<Id,SObject>(); 
        if(MassUploadSplitRecordTypeId==null){
            MassUploadSplitRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;
        }
        for(SObject n:newItems.values()){ 
			Mass_Upload_CSV__c massupload=(Mass_Upload_CSV__c) n;
            System.debug('Record Type '+massupload.RecordTypeId +' ' +MassUploadSplitRecordTypeId+ ' isAttach '+massupload.isAttachment__c);
            if(massupload.isAttachment__c==true && massupload.recordTypeId == MassUploadSplitRecordTypeId && (massupload.Status__c=='Inprogress'))
			{
                System.debug('Mass Upload Id '+massupload.id);
				mapitems.put(massupload.id,n);
			} 
        }
         System.debug('New Items'+mapitems.values().size());
        if(mapitems.values().size()>0){ 
        	this.newItems = mapitems;
        }else{
            System.debug('STOP');
            return; 
        }
    }
   
    /**
     * execute method split the original file and call MassUploadProcessAttachmentBatch batch to process the records
     * @param context The first parameter QueueableContext.
     * @return void
    */
    public void execute(QueueableContext context) {
        
        if(newItems.values().size()>0){
        	Map<String,ContentVersion> mapContentversion = mapMassUploadToContentVersionData(newItems);
        	divideCSV(this.newItems,mapContentversion);
            
            List<String> parentIds=new List<String>();
            for(SObject item:newItems.values()){
                parentIds.add(item.id);
            }
           List<Mass_Upload_CSV__c> splitMassupload =[select id  from Mass_Upload_CSV__c where Parent__c IN:parentIds];
           List<String> contentVersionIds = getContentVersionIds(splitMassupload); 
           MassUploadProcessAttachmentBatch batchobj= new MassUploadProcessAttachmentBatch(contentVersionIds);
           Database.executeBatch(batchobj,1); 

        }
        
    }    

    /**
     * mapMassUploadToContentVersionData used to map csv chunk body to respective spli mass upload record
     * @param context The first parameter QueueableContext.
     * @return void
    */
    private Map<String,ContentVersion> mapMassUploadToContentVersionData(Map<Id,SObject> newItems){
        Map<String,ContentVersion> mapContentversion=new Map<String,ContentVersion>();
        System.debug('Item updated '+newItems);
        List<String> itemIds=new List<String>();
        for(SObject item:newItems.values()){
            itemIds.add(item.id);
            System.debug('itemids'+itemIds);
        }

        List<ContentDocumentLink> contentDocumentsLink=[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:itemIds];
        System.debug('ContentDocumentLink'+contentDocumentsLink);
        List<String> contentDocumentsIds=new List<String>();
        Map<String,String> mapContentDocumentLink = new Map<String,String>();
        for(ContentDocumentLink linkId :contentDocumentsLink){
            contentDocumentsIds.add(linkId.ContentDocumentId);
            mapContentDocumentLink.put(linkId.ContentDocumentId,linkId.LinkedEntityId);
        }
        System.debug('The content Link id is'+contentDocumentsIds);
        if(contentDocumentsIds.size()>0) {
            List<ContentVersion> contentVersions = [SELECT Id, VersionData,ContentDocumentId,Title FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentsIds];
            for(ContentVersion versionData  :contentVersions){
                // Mapping Mass Upload CSV Object and Content version Data
                mapContentversion.put(mapContentDocumentLink.get(versionData.ContentDocumentId),versionData);
            }
        }
        return mapContentversion;
    }

    /**
     * divideCSV method use to divide the original csv file based on its size and call createSplitFile method to Create a chunk of files.
     * @param newItems The first parameter QueueableContext.
     * @param mapContentversion The seciond paramter Map<String,ContentVersion>
     * @return void
    */
	 @TestVisible
     private void divideCSV(Map<Id,SObject> newItems,Map<String,ContentVersion> mapContentversion){
        SplitString splitObj = new SplitString();
        Integer csvBodysize = 0;
        for(SObject item:newItems.values()){
            ContentVersion contentVersionObj=mapContentversion.get(item.id);
            List<String> csvbody=splitObj.safeSplit(contentVersionObj.VersionData.toString(), '\n');
            System.debug('csvbody size'+csvbody.size());
            Integer divideCsv = 0;
            csvBodysize = csvbody.size();
            System.debug('csvBodysize'+csvBodysize);
            if(csvBodysize<=1000){
                divideCsv = csvBodysize;
                System.debug('Divinding File into 1 parts');
            }else{
                Double noOfFiles = csvBodysize/3000;//Noted///
                if(Math.Floor(noOfFiles)==0){
                    noOfFiles = csvBodysize/csvBodysize;
                }
                divideCsv = csvBodysize/Integer.valueOf(Math.Floor(noOfFiles));
            }
            
            String idStr=UserInfo.getUserId();
            List<String> csvAttachment = new List<String>();
            String csv = '';
            String header = csvbody[0].replaceAll('\u0009','').trim();
            System.debug('Header is'+header);
            Integer countCSVSplitSize = 1;
            Integer n=1;
            for(Integer j=1; j < csvbody.size(); j++){
                csvAttachment.add(csvbody[j].replaceAll('\u0009','').trim());
                System.debug('Count '+j+' Divide CSV '+divideCsv);
                countCSVSplitSize ++;
                    
                if(j==divideCsv*n){
                    System.debug('Creating File part 1');
                    csv = String.join(csvAttachment, '\r\n');
                    csv+='\r';
                    createSplitFile(item,csv,header,countCSVSplitSize);
                    csvAttachment.clear();
                    countCSVSplitSize =1;
                    n++;
                }
                else if(j==csvbody.size()-1)
                {
                    csv = String.join(csvAttachment, '\r\n');
                    csv+='\r';
                    createSplitFile(item,csv,header,countCSVSplitSize);
                    csvAttachment.clear();
                    countCSVSplitSize =1;   
                }
                
            }
        }
    }
    
    /**
     * createSplitFile use to create split files
     * @param item The first parameter SObject (i.e Record).
     * @param csv The second paramter String
     * @param header The Third paramter String
     * @param csvAttachment The Fourth paramter Integer (i.e No. of total records in each split)
     * @return void
    */
    private void createSplitFile(SObject item,String csv,String header,Integer csvAttachment ){
        //System.debug('Create split count'+ this.count++);
        this.count++;
        System.debug('item data is'+ item.id);
        System.debug('divide csv  data is'+ csvAttachment);
        Mass_Upload_CSV__c massupload =(Mass_Upload_CSV__c) item.clone();
        massupload.RecordTypeId = Schema.SObjectType.Mass_Upload_CSV__c.getRecordTypeInfosByName().get('Split').getRecordTypeId();
        massupload.Status__c='Inprogress';
        massupload.Parent__c=item.id;
        massupload.Name=massupload.Name+'-Split'+this.count;
        massupload.Total_records__c=csvAttachment-1;
        insert massupload;
       
        
        List<ContentVersion> con=new List<ContentVersion>();                    
        ContentVersion content = new ContentVersion();
        content.VersionData=Blob.valueOf(header+'\n'+csv);
        content.Title=massupload.File_Name__c+'-Split'+this.count;
        content.PathOnClient=massupload.File_Name__c+'-Split'+this.count +'.'+'csv';
        content.IsMajorVersion=true;
        con.add(content);
        insert con;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id].ContentDocumentId;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = massupload.Id;
        cdl.ContentDocumentId = conDocId;
        Insert cdl;
    }

    /**
     * getContentVersionIds method use bring content version Id form split mass upload record
     * @param splitMassuploads The first parameter List<Mass_Upload_CSV__c>.
     * @return List<String> i.e Id's of content versions
    */
    public List<String> getContentVersionIds(List<Mass_Upload_CSV__c> splitMassuploads){
       
        System.debug('splitMassupload '+splitMassuploads); 
        List<String>  splitMassuploadIds = new List<String>();
        for(Mass_Upload_CSV__c splitMassUpload:splitMassuploads){
            splitMassuploadIds.add(splitMassUpload.Id);
        }
        List<ContentDocumentLink> contentDocumentsLink = new List<ContentDocumentLink>();
        if(splitMassuploadIds.size()>0){
        contentDocumentsLink =[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:splitMassuploadIds];
        }
            
        List<String> ContentdocId= new List<String>(); 
            
        for(ContentDocumentLink condoclink  :contentDocumentsLink)
        {
            ContentdocId.add(condoclink.ContentDocumentId);
        }
            
        List<ContentVersion> contentVersions = [SELECT Id, VersionData,ContentDocumentId,Title FROM ContentVersion WHERE ContentDocumentId IN:ContentdocId];
        System.debug('Content Version id is'+contentVersions);
        List<String> contentVersionIds= new List<String>();
        for(ContentVersion versiondata:contentVersions)
        {
            contentVersionIds.add(versiondata.Id);
        }
        return contentVersionIds;
	}  
  
}