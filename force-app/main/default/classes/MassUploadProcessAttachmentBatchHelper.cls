public class MassUploadProcessAttachmentBatchHelper {
    
    public static Void createRecords(List<String> rows,Mass_Upload_CSV__c massupload)
    {   
        try{
       
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
       System.debug('massUploadExternalIdRecords size '+massUploadExternalIdRecords.size());
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
               System.debug('mapMassUploadExt Key'+tempMassExternal.ObjectName__c+tempMassExternal.Type__c);
            }else{
                mapMassUploadExt.put(tempMassExternal.ObjectName__c+'',tempMassExternal);  
               System.debug('mapMassUploadExt Key'+tempMassExternal.ObjectName__c+'');
            }
            
           System.debug('tempMassExternal.CSVFields__c '+tempMassExternal.CSVFields__c);
            if(!String.isEmpty(tempMassExternal.CSVFields__c)){
               System.debug('IN IF tempMassExternal.CSVFields__c '+tempMassExternal.CSVFields__c);
            	csvFieldsMap.put(tempMassExternal.Type__c,tempMassExternal.CSVFields__c.split(';'));
            }
        }
        String sObjectTypeApi = massupload.Object_Name__c;
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectTypeApi);
        Map<String, SObjectField> fieldsMap = t.getDescribe().fields.getMap();
        List<String> csvFields = csvFieldsMap.get(massupload.File_Type__c);
       System.debug('csvFields size'+csvFields.size());
        System.debug('csvFields '+csvFields);
        
        String ObjectcombinationKeyValue = '';
        String ObjectcombinationExternalId = '';
        SObjectField ObjectcombinationExternalIdField = null;
        List<String> ObjectcombinationKeyFields = new List<String>();
            //if(mapMassUploadExt.get(sObjectTypeApi)!=null){
               System.debug('Key :'+sObjectTypeApi+massupload.File_Type__c);
                if(!String.isEmpty(massupload.File_Type__c)){
                    ObjectcombinationKeyFields = mapMassUploadExt.get(sObjectTypeApi+massupload.File_Type__c).FieldUseInCombinationKey__c.split(';');
                	ObjectcombinationExternalId  = mapMassUploadExt.get(sObjectTypeApi+massupload.File_Type__c).ExternalId__c;
                }else{
                     ObjectcombinationKeyFields = mapMassUploadExt.get(sObjectTypeApi).FieldUseInCombinationKey__c.split(';');
                	ObjectcombinationExternalId  = mapMassUploadExt.get(sObjectTypeApi).ExternalId__c;
                }
                ObjectcombinationExternalIdField = fieldsMap.get(ObjectcombinationExternalId);
            //}
        
        SObject obj;
        List<String> record;
        String value='';
        String tempRecord='';
        for(String lineItem: rows){
            obj= t.newSObject();
            ObjectcombinationKeyValue = '';
            record = lineItem.split(massupload.Seperator__c); 
            if(record.size()>1)
            {
             System.debug('reocrd is'+record +'recordsize'+record.size()); 
                for(Integer j=0;j<=csvFields.size()-1;j++){
                System.debug('For loop j is'+csvFields[j]);  
                System.debug('For loop i is'+record[j]);  

                if(ObjectcombinationKeyFields.contains(csvFields[j])){
                    value = record[j];
                    if(mapLeftpad.get(csvFields[j]) != null)
                    {
                        ObjectcombinationKeyValue = ObjectcombinationKeyValue+value.leftpad(mapLeftpad.get(csvFields[j]), '0');
                    }else{
                        ObjectcombinationKeyValue = ObjectcombinationKeyValue+value;
                    }
                    System.debug('Combination Key value '+ObjectcombinationKeyValue);
                }

                    if(csvFields[j].contains('__r')){
                        //System.debug('Error attempt'+mapObjectName.get(csvFields[j]).ObjectName__c);
                        String sObjectTypeLookup = mapObjectName.get(csvFields[j]).ObjectName__c;
                        Schema.SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectTypeLookup);
                        SObject lookupObj = schemaType.newSObject();
                        String key='';
                       // System.debug('mapcombination is');
                        List<String> filedMapping = mapCombinationFields.get(csvFields[j]);
                        System.debug('csvFields[j] '+csvFields[j]);
                       System.debug('fieldMapping'+mapCombinationFields);
                       
                        if(filedMapping.size()>=1){
                            System.debug('for loop for filed mapping');
                            for(String tempFields:filedMapping){
                                System.debug('For loop for tempfields'+tempFields);
                                if(!String.isEmpty(tempFields)){
                                   System.debug('temp field is--'+tempFields);
                                    tempRecord=record[csvFields.indexOf(tempFields)];
                                   System.debug('temprecord'+tempRecord);
									if(mapLeftpad.get(tempFields) != null){
									 tempRecord=record[csvFields.indexOf(tempFields)].leftPad(mapLeftpad.get(tempFields), '0');
									System.debug('temprecord1'+tempRecord);
									  
                                       System.debug('key1'+key);
                                    }
                                    key = key+tempRecord;
                                    
                                }
                            }
                        
                        }else{
                            key = record[j];
                        }
                        lookupObj.put(mapExternalIdField.get(csvFields[j]),key);
                        System.debug('lookupObj Obj'+lookupObj);
                        obj.putSObject(csvFields[j],lookupObj);
                        System.debug('Obj putSObject'+obj);
                    }
                    else{
                        
                       System.debug('For DATA TYPE '+record[j]);
                        if(mapObjectName.get(csvFields[j]) !=null )
                        {
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
                          //  System.debug('Date '+Date1+'Length '+Date1.length());
                            //System.debug('Year '+Integer.valueOf(record[j].subString(4,8))+' Month '+Integer.valueOf(record[j].subString(2,4))+' Day '+Integer.valueOf(record[j].subString(0,2)));
							Date d = Date.newInstance(Integer.valueOf(record[j].subString(4,8)),Integer.valueOf(record[j].subString(2,4)), Integer.valueOf(record[j].subString(0,2)));                           
                        	//System.debug('The date is'+d);
                            obj.put(csvFields[j], d);    
                        }
                        }
                        
                    }
                    
                }
               System.debug('------------------------------END OF COLUMNS-----------------------------------');
            }
            System.debug('------------------------------END OF RECORD-----------------------------------');
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
           System.debug('obj '+obj);
            System.debug('obj Key'+String.valueOf(obj.get('Combination_Key__c')).length());
            sObjects.add(obj);
        }
       System.debug('object '+sObjects.size());
        Database.UpsertResult [] cr =  Database.upsert(sObjects,ObjectcombinationExternalIdField,false);
        System.debug('CR '+cr);
        
        
        updateLogs(cr,massupload);
        }
        catch(Exception e)
        {   
           System.debug('Inside Exception log'+e);
           System.debug('Inside Exception log'+e.getMessage());
            massupload.Comments__c=e.getMessage();
            massupload.Status__c='Rejected';
            // update massupload;
            
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
            if(!cr[i].isSuccess())
            {
				 errorCount++;
                 massupload.Error_records__c= errorCount;
                 Database.Error[] errors=cr[i].getErrors();   
                // system.debug('The error is==>'+errors);
                
            }
             else
                 {
                     successCount++;
   					 massupload.Success_records__c=successCount;
                     
                    // system.debug('The Success id is==>'+cr[i].getId());
                 }                 
           }
        for( integer i=0;i<cr.size();i++)
        {
           errList.add(cr[i].getErrors()+' ');  
           successList.add(cr[i].getId()+' ');
        }
  
        	errorCSV =String.join(errList, massupload.Seperator__c+'\n');
			successCSV = String.join(successList, massupload.Seperator__c+'\n');
			Blob errBlob = Blob.valueof(errorCSV);
            Blob succesBlob = Blob.valueof(successCSV);
          
			ContentVersion errorcontent = new ContentVersion();
			errorcontent.VersionData = errBlob;
			errorcontent.Title='ErrorCsv';
			errorcontent.PathOnClient='ErrorCsv'+'.'+'csv';
			errorcontent.IsMajorVersion=true;
			insert errorcontent;
			
            ContentVersion successcontent = new ContentVersion();
			successcontent.VersionData = succesBlob;
			successcontent.Title='SuccessCsv';
			successcontent.PathOnClient='SuccessCsv'+'.'+'csv';
			successcontent.IsMajorVersion=true;
			insert successcontent;
      
            Id errorConDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:errorcontent.Id].ContentDocumentId;
            Id successConDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:successcontent.Id].ContentDocumentId;
          
             ContentDocumentLink cdl = New ContentDocumentLink();
             cdl.LinkedEntityId = massupload.id;
             cdl.ContentDocumentId = errorConDocId;
             Insert cdl;
             
             ContentDocumentLink cdl1 = New ContentDocumentLink();
             cdl1.LinkedEntityId = massupload.id;
             cdl1.ContentDocumentId = successConDocId;
             Insert cdl1;
             
        // System.debug('massupload'+massupload);       
         massupload.Status__c='Completed';
        //  update massupload;
        
    }
   
    
}