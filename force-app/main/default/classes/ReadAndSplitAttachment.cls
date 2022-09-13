public with sharing class ReadAndSplitAttachment implements Queueable{
    
    // private Map<String,ContentVersion> mapContentversion=new Map<String,ContentVersion>();
    private Map<Id,SObject> newItems = new Map<Id,SObject>();
    private Integer count = 0;
   
    public ReadAndSplitAttachment(Map<Id,SObject> newItems){
        Map<Id,SObject> mapitems= new Map<Id,SObject>(); 
        Id MassUploadSplitRecordTypeId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType where SobjectType='Mass_Upload_CSV__c' and Name='Original' limit 1].Id;
        for(SObject n:newItems.values())
        { 
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
            if(csvBodysize<=5000){
                divideCsv = csvBodysize;
                System.debug('Divinding File into 1 parts');
            }
            else if(csvBodysize<=10000){
                divideCsv = csvBodysize/2;
                System.debug('Divinding File into 2 parts');
            }
            else if(csvBodysize<=15000){
                divideCsv = csvBodysize/3;
                System.debug('Divinding File into 3 parts');
            }
            else if(csvBodysize<=20000){
                divideCsv = csvBodysize/4;
                System.debug('Divinding File into 4 parts');
            }
            else{
                Double noOfFiles = csvBodysize/5000;
                divideCsv = csvBodysize/Integer.valueOf(Math.Floor(noOfFiles));
                System.debug('Divinding File into 4 parts');
            }
            
            String idStr=UserInfo.getUserId();
            List<String> csvAttachment = new List<String>();
            String csv = '';
            String header = csvbody[0].replaceAll('\u0009','').trim();
            System.debug('Header is'+header);
            Integer countCSVSplitSize = 1;
            for(Integer j=1; j < csvbody.size(); j++){
                csvAttachment.add(csvbody[j].replaceAll('\u0009','').trim());
                System.debug('Count '+j+' Divide CSV '+divideCsv);
                countCSVSplitSize ++;
                if(j==divideCsv){
                    System.debug('Creating File part 1');
                    csv = String.join(csvAttachment, '\r\n');
                    csv+='\r\n';
                    createSplitFile(item,csv,header,countCSVSplitSize);
                    csvAttachment.clear();
                    countCSVSplitSize =1;
                }

                else if(j==divideCsv*2){
                    System.debug('Creating File part 2');
                    csv = String.join(csvAttachment, '\r\n');
                    csv+='\r\n';
                    createSplitFile(item,csv,header,countCSVSplitSize);
                    csvAttachment.clear();
                    countCSVSplitSize = 1;
                }
                else if(j==divideCsv*3){
                    System.debug('Creating File part 3');
                    csv = String.join(csvAttachment, '\r\n');
                    csv+='\r\n';
                    createSplitFile(item,csv,header,countCSVSplitSize);
                    csvAttachment.clear();
                    countCSVSplitSize = 1;
                }
                else if(j==divideCsv*4){
                    System.debug('Creating File part 3');
                    csv = String.join(csvAttachment, '\r\n');
                    csv+='\r\n';
                    createSplitFile(item,csv,header,countCSVSplitSize);
                    csvAttachment.clear();
                    countCSVSplitSize = 1;
                }
                else if(j==csvbody.size()-1){
                    System.debug('Creating File part 4');
                    csv = String.join(csvAttachment, '\r\n');
                    csv+='\r\n';
                    createSplitFile(item,csv,header,countCSVSplitSize);
                    csvAttachment.clear();
                    countCSVSplitSize = 1;
                }
                
            }
        }
    }
        
    private void createSplitFile(SObject item,String csv,String header,Integer csvAttachment ){
        //System.debug('Create split count'+ this.count++);
        this.count++;
        //System.debug('item data is'+ item);
       // System.debug('divide csv  data is'+ csvAttachment);
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
    
    public List<String> getContentVersionIds(List<Mass_Upload_CSV__c> splitMassuploads){
       
        System.debug('splitMassupload '+splitMassuploads); 
        List<String>  splitMassuploadIds = new List<String>();
        for(Mass_Upload_CSV__c splitMassUpload:splitMassuploads){
            splitMassuploadIds.add(splitMassUpload.Id);
        }
        List<ContentDocumentLink> contentDocumentsLink=[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:splitMassuploadIds];
            
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