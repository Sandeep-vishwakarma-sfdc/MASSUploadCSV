public class MassUploadProcessAttachmentBatchHelper {

	public static Void createRecords(List<String> rows,Mass_Upload_CSV__c massupload,Database.BatchableContext bc){   
        try{
            System.debug('row Size is'+rows.size());
	        List<SObject> sObjects=new List<SObject>();
	        String header = rows.remove(0);
	        List<String> headers = header.split(massupload.Seperator__c);
	        Map<String,String> mapExternalIdField = new Map<String,String>();
	        Map<String,List<String>> mapCombinationFields = new Map<String,List<String>>();
	        List<MassUploadExternalIdRecords__c> massUploadExternalIdRecords = [select Id,Name,DataType__c,ExternalId__c,ObjectName__c,FieldUseInCombinationKey__c,isRecordType__c,Type__c,CSVFields__c,TypeApiName__c,Length__c from MassUploadExternalIdRecords__c];
	        Map<String,MassUploadExternalIdRecords__c> mapObjectName = new Map<String,MassUploadExternalIdRecords__c>();
	        Map<String,MassUploadExternalIdRecords__c> mapMassUploadExt = new Map<String,MassUploadExternalIdRecords__c>();
	        Map<String,List<String>> csvFieldsMap = new Map<String,List<String>>();
	        Map<String,Integer> mapLeftpad = new Map<String,Integer>();
	        for(MassUploadExternalIdRecords__c tempMassExternal:massUploadExternalIdRecords){
	            mapExternalIdField.put(tempMassExternal.Name,tempMassExternal.ExternalId__c);
	            if(!String.isEmpty(tempMassExternal.FieldUseInCombinationKey__c)){
	                mapCombinationFields.put(tempMassExternal.Name,tempMassExternal.FieldUseInCombinationKey__c.split(';'));
					if(!String.isEmpty(String.valueof(tempMassExternal.Length__c))){
						mapLeftpad.put(tempMassExternal.Name,Integer.valueof(tempMassExternal.Length__c));
					}
				}
	            mapObjectName.put(tempMassExternal.Name,tempMassExternal);
	            if(!String.isEmpty(tempMassExternal.Type__c)){
	            	mapMassUploadExt.put(tempMassExternal.ObjectName__c+tempMassExternal.Type__c,tempMassExternal);  
	            }else{
	                mapMassUploadExt.put(tempMassExternal.ObjectName__c+'',tempMassExternal);
	            }
	            if(!String.isEmpty(tempMassExternal.CSVFields__c)){
	            	csvFieldsMap.put(tempMassExternal.Type__c,tempMassExternal.CSVFields__c.split(';'));
	            }
	        }
	        String sObjectTypeApi = massupload.Object_Name__c;
			Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectTypeApi);
	        Map<String, SObjectField> fieldsMap = t.getDescribe().fields.getMap();
	        List<String> csvFields = csvFieldsMap.get(massupload.File_Type__c);
	        
	        String ObjectcombinationKeyValue = '';
	        String ObjectcombinationExternalId = '';
	        SObjectField ObjectcombinationExternalIdField = null;
	        List<String> ObjectcombinationKeyFields = new List<String>();
	        System.debug('Key :'+sObjectTypeApi+massupload.File_Type__c);
	        if(!String.isEmpty(massupload.File_Type__c)){
	        	ObjectcombinationKeyFields = mapMassUploadExt.get(sObjectTypeApi+massupload.File_Type__c).FieldUseInCombinationKey__c.split(';');
	            ObjectcombinationExternalId  = mapMassUploadExt.get(sObjectTypeApi+massupload.File_Type__c).ExternalId__c;
	        }else{
	        	ObjectcombinationKeyFields = mapMassUploadExt.get(sObjectTypeApi).FieldUseInCombinationKey__c.split(';');
	            ObjectcombinationExternalId  = mapMassUploadExt.get(sObjectTypeApi).ExternalId__c;
	        }
	        ObjectcombinationExternalIdField = fieldsMap.get(ObjectcombinationExternalId);
	        
	        SObject obj;
	        List<String> record;
	        String value='';
	        String tempRecord='';
			Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

			

	        for(String lineItem: rows){ // LA0005	5100	Dc	Div	SKU Code	KG	11	0.58	30042022	31032023
	            obj= t.newSObject(); // Creating Mass upload Object
	            ObjectcombinationKeyValue = '';
	            record = lineItem.split(massupload.Seperator__c); 
                System.debug('recordsize is'+record.size());
	            if(record.size()>1){
                    System.debug('recordsize is'+record.size());
	                for(Integer j=0;j<=csvFields.size()-1;j++){ // loop on Columns
	                if(ObjectcombinationKeyFields.contains(csvFields[j])){
	                    value = record[j];
	                    if(mapLeftpad.get(csvFields[j]) != null){
	                        ObjectcombinationKeyValue = ObjectcombinationKeyValue+value.leftpad(mapLeftpad.get(csvFields[j]), '0');
	                    }else{
	                        ObjectcombinationKeyValue = ObjectcombinationKeyValue+value;
	                    }
	                }
	                if(csvFields[j].contains('__r')){
	                	String sObjectTypeLookup = mapObjectName.get(csvFields[j]).ObjectName__c; // SKU__C
	                    Schema.SObjectType schemaType = globalDescribe.get(sObjectTypeLookup); 
	                    SObject lookupObj = schemaType.newSObject(); // Object of SKU
	                    String key='';
	                    List<String> filedMapping = mapCombinationFields.get(csvFields[j]);
	                    if(filedMapping.size()>=1){
	                    	for(String tempFields:filedMapping){
	                    		if(!String.isEmpty(tempFields)){
	                            tempRecord=record[csvFields.indexOf(tempFields)];
								if(mapLeftpad.get(tempFields) != null){
									tempRecord=record[csvFields.indexOf(tempFields)].leftPad(mapLeftpad.get(tempFields), '0');
								}
								key = key+tempRecord;// SKU Combination Key
								}
	                    	}
	                    }else{
	                    	key = record[j];
	                    }
	                    lookupObj.put(mapExternalIdField.get(csvFields[j]),key);
	                    obj.putSObject(csvFields[j],lookupObj);
	                }
	                else{
	                	if(mapObjectName.get(csvFields[j]) !=null ){
	                        String fieldDataType = mapObjectName.get(csvFields[j]).DataType__c;
	                        if(fieldDataType=='Number'){
	                            try{
	                                Decimal value1 = Decimal.valueOf(record[j].deleteWhiteSpace());
	                                obj.put(csvFields[j], value1);    
	                            }catch(Exception e){
	                                System.debug('Decimal Exception '+e);
	                            }
	                        }
	                        if(fieldDataType=='Text'){
	                        	obj.put(csvFields[j], record[j]);    
	                        }
	                        if(fieldDataType=='Date'){
								String Date1 = record[j];
								Date d = Date.newInstance(Integer.valueOf(record[j].subString(4,8)),Integer.valueOf(record[j].subString(2,4)), Integer.valueOf(record[j].subString(0,2)));
	                            obj.put(csvFields[j], d);    
	                        }
	                    }  
	                    }
	                }
	            }
	            if(!String.isEmpty(massupload.File_Type__c)){
	            	if(mapMassUploadExt.get(massupload.Object_Name__c+massupload.File_Type__c).TypeApiName__c!=null){
	            		obj.put(mapMassUploadExt.get(massupload.Object_Name__c+massupload.File_Type__c).TypeApiName__c,massupload.File_Type__c);
	                    ObjectcombinationKeyValue = ObjectcombinationKeyValue+massupload.File_Type__c;
	                }
	            }else{
	            	if(mapMassUploadExt.get(massupload.Object_Name__c).TypeApiName__c!=null){
	            		obj.put(mapMassUploadExt.get(massupload.Object_Name__c).TypeApiName__c,massupload.File_Type__c);
	                    ObjectcombinationKeyValue = ObjectcombinationKeyValue+massupload.File_Type__c;
	                }
	            }
	            obj.put(ObjectcombinationExternalId, ObjectcombinationKeyValue);
	            sObjects.add(obj);
	        }
	        Database.UpsertResult [] cr =  Database.upsert(sObjects,ObjectcombinationExternalIdField,false);
	        System.debug('CR '+cr);
	        updateLogs(cr,massupload);
	        }
	        catch(Exception e){
				System.debug('Inside Exception log'+e);
	            System.debug('Inside Exception log'+e.getMessage());
                DateTime d = Date.Today() ;
                String dateString =  d.format('dd/MM/yyyy') ;
	            massupload.Comments__c=e.getMessage();
	            massupload.Status__c='Rejected';
	            update massupload;
                
                Mass_Upload_CSV__c splitmassUploadCsv  = [select Id,Name,Status__c,Comments__c,Parent__c from Mass_Upload_CSV__c where Id=:massupload.Id];
                String parentId = splitmassUploadCsv.Parent__c;
                Mass_Upload_CSV__c   parentMassUpload= [select ID,Name,Status__c,Comments__c from Mass_Upload_CSV__c where id=:parentId];
                parentMassUpload.Status__c='Rejected';
                parentMassUpload.Comments__c=e.getMessage();
                update parentMassUpload;
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                   
                mail.setUseSignature(false);
                mail.setToAddresses(new String[] { 'prashant.kumbhar@skinternational.com' });
                mail.setSubject(massupload.File_Type__c+' ' +'Could Not  process');
                mail.setHtmlBody('Dear User,<br /><br />There was an error while uploading your records.<br /><br />Date: '+dateString+'<br /><br />Reason: '+ e.getMessage()+'<br /><br />Regards,<br/>UPL Salesforce Administrator<br />'); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
				System.abortJob(bc.getJobId());
	        }
    }

	public static void updateLogs(Database.UpsertResult [] cr,Mass_upload_csv__c massupload){
        String saperator = ';';
        String successCSV = '';
        String errorCSV = '';
        Integer errorCount=0;
        Integer successCount=0;
		List<String> errList = new List<String>();
        List<String> successList = new List<String>();
        
        for( integer i=0;i<cr.size();i++)
        { 
            if(!cr[i].isSuccess()){
				 errorCount++;
                 massupload.Error_records__c= errorCount;
                 Database.Error[] errors=cr[i].getErrors(); 
                 errList.add(cr[i].getErrors()+' ');
            }
            else{
            	successCount++;
   				massupload.Success_records__c=successCount;
                successList.add(cr[i].getId()+' ');
            }                 
        }
        
        errorCSV =String.join(errList, massupload.Seperator__c+'\n');
		successCSV = String.join(successList, massupload.Seperator__c+'\n');
		Blob errBlob = Blob.valueof(errorCSV);
        Blob succesBlob = Blob.valueof(successCSV);
        
        ContentVersion errorcontent = new ContentVersion();
		if(errBlob.size() !=0 )
        {
        System.debug('errorBlob in if'+errBlob.size());
        errorcontent.VersionData = errBlob;   
        }
        else
        {
         errorcontent.VersionData =Blob.valueOf('No Error');
         System.debug('errorBlob in else'+errBlob.size());
        
        }
        errorcontent.Title='ErrorCsv';
		errorcontent.PathOnClient='ErrorCsv'+'.'+'csv';
		errorcontent.IsMajorVersion=true;
		insert errorcontent;
        Id errorConDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:errorcontent.Id].ContentDocumentId;
         
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = massupload.id;
        cdl.ContentDocumentId = errorConDocId;
        Insert cdl;
        
        
        ContentVersion successcontent = new ContentVersion();
		if(succesBlob.size() !=0 )
        {
       		 successcontent.VersionData = succesBlob;
        }
        else
        {
            successcontent.VersionData=Blob.valueOf('No Success');
        }
		successcontent.Title='SuccessCsv';
		successcontent.PathOnClient='SuccessCsv'+'.'+'csv';
		successcontent.IsMajorVersion=true;
		insert successcontent;
      
        Id successConDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:successcontent.Id].ContentDocumentId;
          
       
             
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = massupload.id;
        cdl1.ContentDocumentId = successConDocId;
        Insert cdl1;
        massupload.Status__c='Completed';
        update massupload;
    }
}