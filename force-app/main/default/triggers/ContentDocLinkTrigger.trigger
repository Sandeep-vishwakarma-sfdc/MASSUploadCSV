trigger ContentDocLinkTrigger on ContentDocumentLink (before insert,after insert) {
    Set<Id> contentdocIds = new Set<Id>();
    List<Id> contentDocId=new List<Id>();
    for(ContentDocumentLink con : Trigger.new){
        contentDocId.add(con.ContentDocumentId);
    }
    Map<Id,String> cdTitleMap=new Map<Id,String>();
    List<contentdocument> contentdocuments = [Select Id,Title from contentdocument where Id In :contentDocId];
    for(ContentDocument con : contentdocuments){
        cdTitleMap.put(con.Id,con.Title);
    }
    if(trigger.isInsert && trigger.isBefore){
        
        for(ContentDocumentLink con : Trigger.new){
            if(!cdTitleMap.isEmpty() && cdTitleMap.containsKey(con.ContentDocumentId)){
                String Title = cdTitleMap.get(con.ContentDocumentId);
                List<String> checkhypen = Title.split('-');
                boolean isbillingdoc= false;
                if(checkhypen.size()==2){
                    string billingdoc = checkhypen[1];
                    isbillingdoc = true;
                }
                if(Title.Contains('#') && ((String)con.LinkedEntityId).startsWith('001') && isbillingdoc){
                    contentdocIds.add(con.Id);
                }
            }
            
            if(((String)con.LinkedEntityId).startsWith('a1X')){
                contentdocIds.add(con.Id);
            }
            
        }
        if(!contentdocIds.isEmpty()){
            for(ContentDocumentLink c : Trigger.new){
                if(contentdocIds.contains(c.Id)){
                    c.Visibility = 'AllUsers';
                }
            }
        }
        
    }
    if(trigger.isInsert && trigger.isAfter){
        Map<Id,ContentVersion> contentdocverIdMap=new Map<Id,ContentVersion>();
        for(ContentVersion cv:[Select Id,contentdocumentid,Guest_Record_fileupload__c from contentversion where contentdocumentid IN :contentDocId]){
            contentdocverIdMap.put(cv.contentdocumentid,cv);
        }
        List<Id> contentUpDocId=new List<Id>();
        List<ContentDocumentLink> condocList = new List<ContentDocumentLink>();
        for(ContentDocumentLink cdl:Trigger.new){
            if(!contentdocverIdMap.isEmpty() && contentdocverIdMap.containsKey(cdl.ContentDocumentId) && contentdocverIdMap.get(cdl.ContentDocumentId).Guest_Record_fileupload__c!=null && ((String)cdl.LinkedEntityId).startsWith('500')){
                if(cdl.Visibility != 'AllUsers'){
                    ContentDocumentLink cnlink = new ContentDocumentLink(Id= cdl.Id);                
                    cnlink.Visibility = 'AllUsers';
                    condocList.add(cnlink);
                }
                contentUpDocId.add(cdl.ContentDocumentId);
            }
        }
        if(!condocList.isEmpty()){
            update condocList;
        }
        List<ContentDist__e> Contnetdisevents = new List<ContentDist__e>();
        for(Id i:contentUpDocId){
            if(contentdocverIdMap.containskey(i)){
                Contnetdisevents.add(new ContentDist__e(ContentVersionId__c=contentdocverIdMap.get(i).Id, ContentTitle__c=cdTitleMap.get(i)));               
            }
        }
        List<Database.SaveResult> results = EventBus.publish(Contnetdisevents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }       
        }
        
    }
    
}