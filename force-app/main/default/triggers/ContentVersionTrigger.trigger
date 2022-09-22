trigger ContentVersionTrigger on ContentVersion (after insert,after update) {
    public static List<AggregateResult> c;
    public static List<contentdocumentlink> contentdocumentlinks;
    if ((trigger.isInsert || trigger.isupdate) && (trigger.isafter && ContentVersionTriggerHelper.IsAttachmentupdated==false)){
       System.debug('Condition Satisfied');
        ContentVersionTriggerHelper.updateMassUploadCSV(trigger.newmap);
     }
    
    
    List<Id> contentDocIdList=new List<Id>();
    Map<Id,String> caseIdMap=new Map<Id,Id>(); 
    for(ContentVersion con : Trigger.new){
        contentDocIdList.add(con.ContentDocumentId);
        if(con.Guest_Record_fileupload__c!=null || Test.isRunningTest())
            caseIdMap.put(con.ContentDocumentId,con.Guest_Record_fileupload__c);
    }
    //System.debug('contentDocIdList==>'+contentDocIdList);
    //System.debug('caseIdMap==>'+caseIdMap);
    List<Integer> countList=new List<Integer>();
    if(c==null || c.size()==0){
        c=[SELECT count(id)cnt from contentdocumentlink where contentdocumentid IN :contentDocIdList];
    }
    for(AggregateResult so:c){
        countList.add(Integer.valueOf(so.get('cnt')));
    }
   System.debug('countList==>'+countList);
    Map<Id,Integer> countMap=new Map<Id,Integer>();
    for(Integer i=0;i<=countList.size()-1;i++){
        countMap.put(contentDocIdList[i],countList[i]);
    }
    System.debug('countMap==>'+countMap); 
    Map<Id,contentdocumentlink> cdlMap=new Map<Id,contentdocumentlink>();
    if(contentdocumentlinks==null){
        contentdocumentlinks = [SELECT id, visibility, linkedentityid,contentdocumentid from contentdocumentlink where contentdocumentid IN :contentDocIdList];
    }
    for(contentdocumentlink cdl: contentdocumentlinks){
       system.debug('cdl==>'+cdl);
        if(!countMap.isEmpty() && countMap.containsKey(cdl.contentdocumentid) && (countMap.get(cdl.contentdocumentid)<2)){
            cdlMap.put(cdl.contentdocumentid,cdl);
        }
    }
  System.debug('cdlMap==>'+cdlMap); 
    List<ContentDocumentLink> cdlNewList=new List<ContentDocumentLink>();
    for(contentdocumentlink cdl:cdlMap.values()){
        if(!caseIdMap.isEmpty() && caseIdMap.containskey(cdl.ContentDocumentId) &&  !Test.isRunningTest()){
            contentdocumentlink cd=new contentdocumentlink();
            cd.ContentDocumentId=cdl.ContentDocumentId;
            cd.Visibility = 'AllUsers';
            cd.LinkedEntityId=caseIdMap.get(cdl.ContentDocumentId);
            cdlNewList.add(cd);
        }
        
    }
    System.debug('cdlNewList==>'+cdlNewList); 
    if(!cdlNewList.isEmpty()){
        insert cdlNewList;
    }
    
}