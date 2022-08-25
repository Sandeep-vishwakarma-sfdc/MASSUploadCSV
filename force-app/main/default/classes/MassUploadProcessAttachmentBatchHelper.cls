public class MassUploadProcessAttachmentBatchHelper {
    
    public static Void createRecords(List<String> rows,Mass_Upload_CSV__c massupload)
    {   
        List<SObject> sObjects=new List<SObject>();
        rows.remove(0);
        System.debug('data from class==>'+rows.size());
        String SalesOrgCode=rows[0].split(',')[1];
        
        String sObjectTypeApi = massupload.Object_Name__c;
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectTypeApi);
		Map<String,Schema.SObjectType> describe=  Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> objectField=  describe.get(sObjectTypeApi).getDescribe().fields.getMap();  
        List<String> csvFields = massupload.CSV_fields__c.split(';');
        SObject obj= t.newSObject();
        for(String lineItem: rows){
            List<String> record = lineItem.split(','); 
            for(Integer i=0;i<=record.size();i++){
                for(String fields:csvFields){
                    obj.put(objectField.get(fields), record[i]);    
                }
            }
        }
        System.debug('obj '+obj);
                               
    }

}