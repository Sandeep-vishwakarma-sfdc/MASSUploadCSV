public class MassUploadProcessAttachmentBatchHelper {
    
    public static Void createRecords(List<String> rows,Mass_Upload_CSV__c massupload)
    {   
        List<SObject> sObjects=new List<SObject>();
        String header = rows.remove(0);
        List<String> headers = header.split(',');
        System.debug('data from class==>'+rows.size());
        // Key:ObjectName,Value:externalIdField
        Map<String,String> mapExternalIdField = new Map<String,String>();
        Map<String,List<String>> mapCombinationFields = new Map<String,List<String>>();
        List<MassUploadExternalIdRecords__c> massUploadExternalIdRecords = [select Id,Name,DataType__c,ExternalId__c,ObjectName__c,FieldUseInCombinationKey__c,isRecordType__c,Type__c,CSVFields__c,TypeApiName__c from MassUploadExternalIdRecords__c];
        Map<String,MassUploadExternalIdRecords__c> mapObjectName = new Map<String,MassUploadExternalIdRecords__c>();
        Map<String,MassUploadExternalIdRecords__c> mapMassUploadExt = new Map<String,MassUploadExternalIdRecords__c>();
        Map<String,List<String>> csvFieldsMap = new Map<String,List<String>>();
        System.debug('massUploadExternalIdRecords size '+massUploadExternalIdRecords.size());
        for(MassUploadExternalIdRecords__c tempMassExternal:massUploadExternalIdRecords){
            mapExternalIdField.put(tempMassExternal.Name,tempMassExternal.ExternalId__c);
            if(!String.isEmpty(tempMassExternal.FieldUseInCombinationKey__c)){
                mapCombinationFields.put(tempMassExternal.Name,tempMassExternal.FieldUseInCombinationKey__c.split(';'));
            }
            mapObjectName.put(tempMassExternal.Name,tempMassExternal);
            mapMassUploadExt.put(tempMassExternal.ObjectName__c,tempMassExternal);
            System.debug('tempMassExternal.CSVFields__c '+tempMassExternal.CSVFields__c);
            if(!String.isEmpty(tempMassExternal.CSVFields__c)){
                System.debug('IN IF tempMassExternal.CSVFields__c '+tempMassExternal.CSVFields__c);
            	csvFieldsMap.put(tempMassExternal.Type__c,tempMassExternal.CSVFields__c.split(';'));
            }
        }
        String sObjectTypeApi = massupload.Object_Name__c;
		Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectTypeApi);
        List<String> csvFields = csvFieldsMap.get(massupload.File_Type__c);
        System.debug('csvFields size'+csvFields.size());
        System.debug('csvFields '+csvFields);
        
        String ObjectcombinationKeyValue = '';
        String ObjectcombinationExternalId = '';
        List<String> ObjectcombinationKeyFields = new List<String>();
            if(mapMassUploadExt.get(sObjectTypeApi)!=null){
                ObjectcombinationKeyFields = mapMassUploadExt.get(sObjectTypeApi).FieldUseInCombinationKey__c.split(';');
                ObjectcombinationExternalId  = mapMassUploadExt.get(sObjectTypeApi).ExternalId__c;
            }
        for(String lineItem: rows){
            SObject obj= t.newSObject();
            ObjectcombinationKeyValue = '';
            List<String> record = lineItem.split(','); 
            if(record.size()>1)
            {
              System.debug('reocrd is'+record +'recordsize'+record.size());  
            for(Integer j=0;j<=csvFields.size()-1;j++){
            for(Integer i=0;i<=record.size()-1;i++){
                if(i==j && !String.isBlank(record[i])){
                    System.debug('record '+record[i]);
                    if(csvFields[j].contains('__r')){
                        String sObjectTypeLookup = mapObjectName.get(csvFields[j]).ObjectName__c;
                        Schema.SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectTypeLookup);
                        SObject lookupObj = schemaType.newSObject();
                        String key='';
                        List<String> filedMapping = mapCombinationFields.get(csvFields[j]);
                        if(filedMapping.size()>1){
                            System.debug('for loop for filed mapping');
                            for(String tempFields:filedMapping){
                                if(!String.isEmpty(tempFields)){
                                    System.debug('temp field is--'+tempFields);
                                    key = key+record[headers.indexOf(tempFields)];
                                }
                            }
                        
                        }else{
                            key = record[i];
                        }
                        lookupObj.put(mapExternalIdField.get(csvFields[j]),key);
                        System.debug('lookupObj Obj'+lookupObj);
                        obj.putSObject(csvFields[j],lookupObj);
                        System.debug('Obj putSObject'+obj);
                    }
                    else{
                        
                        System.debug('For DATA TYPE '+csvFields[j]);
                        if(mapObjectName.get(csvFields[j]) !=null )
                        {
                        String fieldDataType = mapObjectName.get(csvFields[j]).DataType__c;
                        
                        if(fieldDataType=='Number'){
                            Decimal value = Decimal.valueOf(record[i]);
                        	obj.put(csvFields[j], value);    
                        }
                        if(fieldDataType=='Text'){
                        	obj.put(csvFields[j], record[i]);    
                        }
                        if(fieldDataType=='Date'){
							String Date1 = record[i];
                            System.debug('Date '+Date1+'Length '+Date1.length());
                            System.debug('Year '+Integer.valueOf(record[i].subString(4,8))+' Month '+Integer.valueOf(record[i].subString(2,4))+' Day '+Integer.valueOf(record[i].subString(0,2)));
							Date d = Date.newInstance(Integer.valueOf(record[i].subString(4,8)),Integer.valueOf(record[i].subString(2,4)), Integer.valueOf(record[i].subString(0,2)));                           
                        	System.debug('The date is'+d);
                            obj.put(csvFields[j], d);    
                        }
                        }
                        
                        
                    }
                    String value = '';
                    for(String objectKeyFields:ObjectcombinationKeyFields){
                        System.debug('objectKeyFields '+objectKeyFields);
                        System.debug('objectKeyFields headers'+headers);
                        System.debug('objectKeyFields headers '+headers.indexOf(objectKeyFields));
                        if(headers.indexOf(objectKeyFields)!=-1){
                            value = record[headers.indexOf(objectKeyFields)];
                        }else{
                            value = '';
                        }
                        
                       if(!String.isEmpty(objectKeyFields) && value==record[j]){
                            
                           System.debug('Combination Key Field Name --'+objectKeyFields);
                           System.debug('Combination Key index'+headers.indexOf(objectKeyFields));   
                           System.debug('Combination Key record '+value);
                           System.debug('Combination Key J Index '+record[j]);
                           System.debug('Combination Key ObjectcombinationKeyValue '+ObjectcombinationKeyValue.length());
                           System.debug('Combination Key value Length '+value.length());
                            ObjectcombinationKeyValue = ObjectcombinationKeyValue+value;
                           System.debug('Combination Key value '+ObjectcombinationKeyValue);
                       }
                    
                    }
                }
                System.debug('------------------------------END OF COLUMNS-----------------------------------');
            }
            }
            System.debug('------------------------------END OF RECORD-----------------------------------');
            obj.put(mapMassUploadExt.get(massupload.Object_Name__c).TypeApiName__c,mapMassUploadExt.get(massupload.Object_Name__c).Type__c);
            ObjectcombinationKeyValue = ObjectcombinationKeyValue+mapMassUploadExt.get(massupload.Object_Name__c).Type__c;
            obj.put(ObjectcombinationExternalId, ObjectcombinationKeyValue);
            System.debug('obj '+obj);
            System.debug('obj Key'+String.valueOf(obj.get('Combination_Key__c')).length());
            sObjects.add(obj);
            }
           
        }
        System.debug('object '+sObjects.size());
        Database.UpsertResult [] cr =  Database.upsert(sObjects,Price_Block_Margin_Matrix__c.Combination_Key__c,false);
        System.debug('CR '+cr);
                               
    }

}