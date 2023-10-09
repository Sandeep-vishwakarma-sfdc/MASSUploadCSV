public class MassUploadProcessAttachmentBatchHelper {
	public static List<String>  errList = new List<String>();
	
	/**
     * createRecords method use to create mass upload record (of record type Split) from the provided data
     * @param rows The first parameter List<String>.
     * @param massupload The Second parameter Mass_Upload_CSV__c.
	 * @param bc The Third parameter Database.BatchableContext.
     * @return void
    */
	public static Void createRecords(List<String> rows,Mass_Upload_CSV__c massupload,Database.BatchableContext bc){   
        try{
			System.debug('massupload :'+massupload);
            System.debug('row Size is'+rows.size());
			
			String todayString = String.valueOf(Date.today().day()).leftPad(2, '0') + 
                     String.valueOf(Date.today().month()).leftPad(2, '0') + 
                     String.valueOf(Date.today().year());// Current day in String format

			String next30thDayString = getNext30thDayString();
					 
	        List<SObject> sObjects=new List<SObject>();
	        String header = rows.remove(0);
	        List<String> headers = header.split(massupload.Seperator__c);
			Map<String,String> mapCustomerType = new Map<String,String>();
			mapCustomerType.put('PLNCustomer','PLN');
			mapCustomerType.put('RebateCustomer','Rebate');
			List<String> alreadyDateIncluded = new List<String>();
			alreadyDateIncluded.add('Rebate');
			alreadyDateIncluded.add('Discount');
			alreadyDateIncluded.add('AdditionalDiscount');
	        Map<String,String> mapExternalIdField = new Map<String,String>();
	        Map<String,List<String>> mapCombinationFields = new Map<String,List<String>>();
	        List<MassUploadExternalIdRecords__c> massUploadExternalIdRecords = [select Id,Name,DataType__c,ExternalId__c,ObjectName__c,FieldUseInCombinationKey__c,isRecordType__c,Type__c,CSVFields__c,TypeApiName__c,Length__c,csvFieldDepot__c from MassUploadExternalIdRecords__c];
	        Map<String,MassUploadExternalIdRecords__c> mapObjectName = new Map<String,MassUploadExternalIdRecords__c>();
	        Map<String,MassUploadExternalIdRecords__c> mapMassUploadExt = new Map<String,MassUploadExternalIdRecords__c>();
	        Map<String,List<String>> csvFieldsMap = new Map<String,List<String>>();
			Map<String,List<String>> csvFieldsMapDepot = new Map<String,List<String>>();
	        Map<String,Integer> mapLeftpad = new Map<String,Integer>();
	        for(MassUploadExternalIdRecords__c tempMassExternal:massUploadExternalIdRecords){
	            mapExternalIdField.put(tempMassExternal.Name,tempMassExternal.ExternalId__c);// {Name:Depot_Code__r,ExternalId:Depot_Code__c},{Name:Sales_Org__r,ExternalId:Sales_Org_Code__c}
	            if(!String.isEmpty(tempMassExternal.FieldUseInCombinationKey__c)){
	                mapCombinationFields.put(tempMassExternal.Name,tempMassExternal.FieldUseInCombinationKey__c.split(';')); // {Name:'Price_Block_Margin_Matrix__c(SalesDed)',FieldUseInCombinationKey:'Profit_Center__r;Sales_Org__r;Dc;Div;SKU_Code__r;UOM__c;Type__c'},{Name:'SKU_Code__r',FieldUseInCombinationKey:'Sales_Org__r;Dc;Div;SKU_Code__r'}

					if(!String.isEmpty(String.valueof(tempMassExternal.Length__c))){
						mapLeftpad.put(tempMassExternal.Name,Integer.valueof(tempMassExternal.Length__c)); //{Name:SKU_Code__r,Length__c:18}
					}
				}
	            mapObjectName.put(tempMassExternal.Name,tempMassExternal); // {Name:'Sales_Org__r',MassUploadExternalIdRecords__c:{Name:'Sales_Org__r',ObjectName__c:'Sales_Org__c',DataType__c:'Lookup'}}
	            if(!String.isEmpty(tempMassExternal.Type__c) && tempMassExternal.ObjectName__c=='Price_Block_Margin_Matrix__c'){
	            	mapMassUploadExt.put(tempMassExternal.ObjectName__c+tempMassExternal.Type__c,tempMassExternal);  // {ObjectName__c:'Price_Block_Margin_Matrix__c'+'SalesDeduction',tempMassExternal:{FieldUseInCombinationKey__c:'Profit_Center__r;Sales_Org__r;Dc;Div;SKU_Code__r;UOM__c;Type__c',ExternalId__c:'Combination_Key__c',TypeApiName__c:'Type__c'}}
	            }else{
	                mapMassUploadExt.put(tempMassExternal.ObjectName__c+'',tempMassExternal);// {ObjectName__c:'Price_Block_Margin_Matrix__c'+'SalesDeduction',tempMassExternal:{FieldUseInCombinationKey__c:'Profit_Center__r;Sales_Org__r;Dc;Div;SKU_Code__r;UOM__c;Type__c',ExternalId__c:'Combination_Key__c',TypeApiName__c:'Type__c'}}
	            }
	            if(!String.isEmpty(tempMassExternal.CSVFields__c)){
	            	csvFieldsMap.put(tempMassExternal.Type__c,tempMassExternal.CSVFields__c.split(';')); //{Type__c:SalesDeduction,CSVFields__c:'Profit_Center__r;Sales_Org__r;Dc;Div;SKU_Code__r;UOM__c;Sales_Deduction_LC__c;Sales_Deduction_USD__c;Start_Date__c;End_Date__c'}
					csvFieldsMapDepot.put(tempMassExternal.Type__c,tempMassExternal.csvFieldDepot__c?.split(';'));
	            }
	        }

			List<Sales_Area_Configuration__c> salesAreaConfigs = [select id,Depot__c,Depot__r.Depot_code__c,Distribution_Channel__c,Distribution_Channel__r.Distribution_Channel_Code__c,Division__c,Division__r.Division_Code__c,Sales_Org__c,Sales_Org__r.Sales_org_code__c,Combination_Key__c from Sales_Area_Configuration__c];
			Map<String,List<Sales_Area_Configuration__c>> mapSalesAreaConfigs = new Map<String,List<Sales_Area_Configuration__c>>();
			for(Sales_Area_Configuration__c salesAreaConfig :salesAreaConfigs){
				List<Sales_Area_Configuration__c> tempSalesAreaConfigs = new List<Sales_Area_Configuration__c>();
				System.debug('salesAreaConfig.Depot__r.Depot_code__c '+salesAreaConfig.Depot__r.Depot_code__c);
				if(mapSalesAreaConfigs.containsKey(salesAreaConfig.Depot__r.Depot_code__c)){
					tempSalesAreaConfigs = mapSalesAreaConfigs.get(salesAreaConfig.Depot__r.Depot_code__c);
					tempSalesAreaConfigs.add(salesAreaConfig);
					mapSalesAreaConfigs.put(salesAreaConfig.Depot__r.Depot_code__c,tempSalesAreaConfigs);
				}else{
					tempSalesAreaConfigs.add(salesAreaConfig);
					mapSalesAreaConfigs.put(salesAreaConfig.Depot__r.Depot_code__c,tempSalesAreaConfigs);
				}
			}

	        String sObjectTypeApi = massupload.Object_Name__c; // Price_Block_Margin_Matrix__c
			Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectTypeApi); 
	        Map<String, SObjectField> fieldsMap = t.getDescribe().fields.getMap(); // Map of All Fields of Price_Block_Margin_Matrix__c
	        List<String> csvFields = csvFieldsMap.get(massupload.File_Type__c); // Getting All Fields from csvFieldsMap Which is required to set in Price_Block_Margin_Matrix__c of given record Type
	        
	        String ObjectcombinationKeyValue = '';
	        String ObjectcombinationExternalId = '';
	        SObjectField ObjectcombinationExternalIdField = null;
	        List<String> ObjectcombinationKeyFields = new List<String>();
	        System.debug('Key :'+sObjectTypeApi+massupload.File_Type__c);
	        if(!String.isEmpty(massupload.File_Type__c) && sObjectTypeApi=='Price_Block_Margin_Matrix__c'){ // For Price Blocks Margin Matrix required record types
	        	ObjectcombinationKeyFields = mapMassUploadExt.get(sObjectTypeApi+massupload.File_Type__c).FieldUseInCombinationKey__c.split(';');
	            ObjectcombinationExternalId  = mapMassUploadExt.get(sObjectTypeApi+massupload.File_Type__c).ExternalId__c;
	        }else{ // For Object Which does not require record types (Configuration in Mass Upload Object -> File_Type__c)
	        	ObjectcombinationKeyFields = mapMassUploadExt.get(sObjectTypeApi).FieldUseInCombinationKey__c.split(';');
	            ObjectcombinationExternalId  = mapMassUploadExt.get(sObjectTypeApi).ExternalId__c;
	        }
	        ObjectcombinationExternalIdField = fieldsMap.get(ObjectcombinationExternalId); // Access All Field od Price_Block_Margin_Matrix__c
	        
	        SObject obj;
	        List<String> record;
	        String value='';
	        String tempRecord='';
			Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

			//DepotCombination 
			//loop on combination and loop on row prepare row for Each combination add SalesOrg,DC,DIV
			List<String> rowsWithSalesAreaConfig =  new List<String>();
			List<String> skuCodes = new List<String>();
			if(massupload.File_Type__c!='AdditionalDiscount' && massupload.File_Type__c!= 'Discount' && massupload.File_Type__c!= 'Rebate' && massupload.File_Type__c!= 'RebateCustomer' && massupload.File_Type__c!= 'PLN' && massupload.File_Type__c!= 'PLNCustomer' && massupload.File_Type__c!= 'SalesDeduction' && massupload.File_Type__c!= 'E2ECost' && massupload.File_Type__c!= 'USDExchangeRate'){
			for(String lineItem:rows){
				record = lineItem.split(massupload.Seperator__c);
				/*String tempSetting = 'Depot__r;SKU_Code__r;Depot_Code__r;UOM__c;E2E_Cost_UPC9_LC__c;E2E_Cost_UPC9_USD__c;Start_Date__c;End_Date__c';
				List<String> settings = tempSetting.split(';');*/ //Hard coded Csv Header Fields
				List<String> settings = csvFieldsMapDepot.get(massupload.File_Type__c);
				String depotCode = record[settings.indexOf('Depot__r')];
				System.debug('depotCode :'+depotCode);
				List<Sales_Area_Configuration__c> salesAreasConfigs = mapSalesAreaConfigs.get(depotCode);
				String depotCombination = '';
				List<String> columns = lineItem.split(massupload.Seperator__c,3);
				System.debug('Columns '+columns);
				String skucode = null;
				System.debug('salesAreasConfigs '+salesAreasConfigs);
				if(salesAreasConfigs != null){
				for(Sales_Area_Configuration__c config:salesAreasConfigs){
					depotCombination = config.Sales_Org__r.Sales_Org_Code__c+massupload.Seperator__c+ config.Distribution_Channel__r.Distribution_Channel_Code__c+massupload.Seperator__c+ config.Division__r.Division_Code__c+massupload.Seperator__c;
					skucode = depotCombination.remove(massupload.Seperator__c) + record[settings.indexOf('SKU_Code__r')].trim().leftPad(18,'0');
					System.debug('skucode 1 '+skucode);
					skuCodes.add(skucode);
				}
				}else{
					System.debug('Sales_Area_Configuration__c Mapping Not Present');
					errList.add(columns+ 'Sales_Area_Configuration__c Mapping Not Present');
				}
			}

			/*Start */

			List<SKU__C> skus = [select Id,Combination_Key__c from SKU__c where Combination_Key__c IN:skuCodes];
			List<String> skuList =  new List<String>();
			for(SKU__C skucode1:skus){
				System.debug('skucode 2 '+skucode1.Combination_Key__c);
				skuList.add(skucode1.Combination_Key__c);
			}

			for(String lineItem:rows){
				record = lineItem.split(massupload.Seperator__c);
				/*String tempSetting = 'Depot__r;SKU_Code__r;Depot_Code__r;UOM__c;E2E_Cost_UPC9_LC__c;E2E_Cost_UPC9_USD__c;Start_Date__c;End_Date__c';
				List<String> settings = tempSetting.split(';'); */ //Hard coded CSV Header Field 
				List<String> settings = csvFieldsMapDepot.get(massupload.File_Type__c);
				String depotCode = record[settings.indexOf('Depot__r')];
				System.debug('depotCode :'+depotCode);
				List<Sales_Area_Configuration__c> salesAreasConfigs = mapSalesAreaConfigs.get(depotCode);
				String depotCombination = '';
				System.debug('Before lineItem '+lineItem);
				List<String> columns = lineItem.split(massupload.Seperator__c,3);
				System.debug('After lineItem '+columns);
				String skucode = null;
				
				String startDateEndDate = todayString+massupload.Seperator__c+next30thDayString;
				if(salesAreasConfigs != null){
					String templineItem = lineItem;
				for(Sales_Area_Configuration__c config:salesAreasConfigs){
					depotCombination = config.Sales_Org__r.Sales_Org_Code__c+massupload.Seperator__c+ config.Distribution_Channel__r.Distribution_Channel_Code__c+massupload.Seperator__c+ config.Division__r.Division_Code__c+massupload.Seperator__c;
					skucode = depotCombination.remove(massupload.Seperator__c) + record[settings.indexOf('SKU_Code__r')].trim().leftPad(18,'0');
					if(skuList.contains(skucode)){
						if(massupload.File_Type__c=='SalesDeduction'){
							lineItem = columns[1]+massupload.Seperator__c+depotCombination+columns[2];
						}else if(massupload.File_Type__c=='PLN' || massupload.File_Type__c=='PLNCustomer'){
							lineItem = depotCombination+''+columns[1]+massupload.Seperator__c+columns[2];
						}else{
							lineItem = depotCombination+lineItem;
						}
						if(!alreadyDateIncluded.contains(massupload.File_Type__c)){
							lineItem = lineItem+massupload.Seperator__c+startDateEndDate;
						}
						rowsWithSalesAreaConfig.add(lineItem);
						lineItem =  templineItem;
					}else{
						lineItem = templineItem;
						System.debug(lineItem+' SKU Not Present');
						errList.add(lineItem+ 'SKU Not Present');
					}
				}
				}
			}
			/*End */
		}else{
			List<String> row1 = new List<String>();
			if(massupload.File_Type__c=='SalesDeduction' || massupload.File_Type__c=='E2ECost'){
				String startDateEndDate = todayString+massupload.Seperator__c+next30thDayString;
				for(String lineItem:rows){
					lineItem = lineItem+massupload.Seperator__c+startDateEndDate;
					row1.add(lineItem);
				}
			}else{
				row1 = rows;
			}
			rowsWithSalesAreaConfig = row1;
		}
			System.debug('rowsWithSalesAreaConfig '+rowsWithSalesAreaConfig);
			System.debug('rowsWithSalesAreaConfig size'+rowsWithSalesAreaConfig.size());


	        for(String lineItem: rowsWithSalesAreaConfig){ // LA0005	5100	Dc	Div	SKU Code	KG	11	0.58	30042022	31032023
	            obj= t.newSObject(); // Creating Price_Block_Margin_Matrix__c Object
	            ObjectcombinationKeyValue = '';
	            System.debug('lineItem '+lineItem);
				record = lineItem.split(massupload.Seperator__c); // (LA0005,5100,MX00,Dc,Div,SKU Code,KG,11,0.58,30042022,31032023)
                System.debug('recordsize is'+record.size());
				
	            if(record.size()>3){
                    System.debug('recordsize is'+record.size());
	                for(Integer j=0;j<=csvFields.size()-1;j++){ // loop on Fields of Price_Block_Margin_Matrix__c which is required to set (see MassUploadExternalIdRecords.CSVFields__c)
						System.debug('For Columns '+csvFields[j]);
						System.debug('And For record '+record[j]);
					// Start Here Preparing Combination Key Logic 	
	                if(ObjectcombinationKeyFields.contains(csvFields[j])){ // csvFields[j]=Profit_Center__r and ObjectcombinationKeyFields=Fields Used in Combination Key
	                    value = record[j]; // LA0005 First Time For salesdeduction
	                    if(mapLeftpad.get(csvFields[j]) != null){
	                        ObjectcombinationKeyValue = ObjectcombinationKeyValue+value.trim().leftpad(mapLeftpad.get(csvFields[j]), '0');
	                    }else{
	                        ObjectcombinationKeyValue = ObjectcombinationKeyValue+value; // Add LA0005 to Combination Key
	                    }
	                }
					// End Here Preparing Combination Key Logic 	

					// Start Here Preparing Lookup Object to tagged in Price Block Marin Matrix 	
	                if(csvFields[j].contains('__r')){
	                	String sObjectTypeLookup = mapObjectName.get(csvFields[j]).ObjectName__c; // SKU__C
	                    Schema.SObjectType schemaType = globalDescribe.get(sObjectTypeLookup); 
	                    SObject lookupObj = schemaType.newSObject(); // Object of SKU
	                    String key='';
	                    List<String> filedMapping = mapCombinationFields.get(csvFields[j]);// Getting Field used while Making Combination Key for Lookup Object on Price Block Margin Matrix
							if(filedMapping.size()>=1){
								for(String tempFields:filedMapping){
									if(!String.isEmpty(tempFields)){
										System.debug('tempFields '+tempFields+ 'CSV '+csvFields);
									tempRecord=record[csvFields.indexOf(tempFields)];
									if(mapLeftpad.get(tempFields) != null){
										tempRecord=record[csvFields.indexOf(tempFields)].trim().leftPad(mapLeftpad.get(tempFields), '0');
									}
									key = key+tempRecord;// SKU Combination Key
									}
								}
							}else{
								key = record[j];
							}
	                    lookupObj.put(mapExternalIdField.get(csvFields[j]),key);
	                    obj.putSObject(csvFields[j],lookupObj);
	                } // End Here Preparing Lookup Object to tagged in Price Block Marin Matrix 
					// Start Here tagging (Number,String,Date) value in Price Block Marin Matrix 
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
								System.debug('Text FieldName '+csvFields[j]+' value '+record[j]);
	                        	obj.put(csvFields[j], record[j]);    
	                        }
	                        if(fieldDataType=='Date'){
								String Date1 = record[j];
								Integer tempyear = Integer.valueOf(record[j].subString(4,8));
								if(tempyear > System.today().year()+100){
									tempyear = System.today().year()+100;
								}
								Date d = Date.newInstance(tempyear,Integer.valueOf(record[j].subString(2,4)), Integer.valueOf(record[j].subString(0,2)));
	                            obj.put(csvFields[j], d);    
	                        }
	                    }  
	                    }
	                }// End Here tagging (Number,String,Date) value in Price Block Marin Matrix 
	            }
	            if(!String.isEmpty(massupload.File_Type__c) && sObjectTypeApi=='Price_Block_Margin_Matrix__c'){
					if(massupload.File_Type__c=='PLNCustomer' || massupload.File_Type__c=='RebateCustomer'){
						massupload.File_Type__c = mapCustomerType.get(massupload.File_Type__c);
					}
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
				System.debug('Object ::'+sObjects[0]);
	        }
			System.debug('ObjectcombinationExternalIdField '+ObjectcombinationExternalIdField);
	        Database.UpsertResult [] cr =  Database.upsert(sObjects,ObjectcombinationExternalIdField,false);
	        System.debug('CR '+cr);
	        updateLogs(cr,massupload);
	        }
	        catch(Exception e){
				System.debug('Inside Exception log '+e.getLineNumber());
	            System.debug('Inside Exception log '+e.getMessage());
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
                mail.setToAddresses(new String[] { Mass_upload_Emails__c.getValues('MarginBlockEmails').email__c });
                mail.setSubject(massupload.File_Type__c+' ' +'Could Not  process');
                mail.setHtmlBody('Dear User,<br /><br />There was an error while uploading your records.<br /><br />Date: '+dateString+'<br /><br />Reason: '+ e.getMessage()+'<br /><br />Regards,<br/>UPL Salesforce Administrator<br />'); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
				// System.abortJob(bc.getJobId());
	        }
    }

	/**
     * updateLogs method update No. of Success , No. of error , assigned success and error file to split mass upload record.
     * @param cr The first parameter Database.UpsertResult.
     * @param massupload The Second parameter Mass_Upload_CSV__c.
     * @return void
    */
	public static void updateLogs(Database.UpsertResult [] cr,Mass_upload_csv__c massupload){
        String saperator = massupload.Seperator__c;
        String successCSV = '';
        String errorCSV = '';
        Integer errorCount=0;
        Integer successCount=0;
		
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

	/**
     * getNext30thDayString method brings 30th date from today.
     * @return return Date in String type
    */
	public static string getNext30thDayString(){
		// Get the current date
		Date currentDate = Date.today();
		// Add 30 days to the current date
		Date next30thDay = currentDate.addDays(30);
		// Format the next 30th day as a string in the "DDMMYYYY" format
		String next30thDayString = String.valueOf(next30thDay.day()).leftPad(2, '0') + 
								String.valueOf(next30thDay.month()).leftPad(2, '0') + 
								String.valueOf(next30thDay.year());
		return next30thDayString;
	}
}