### What problem it is solving.

Mass upload CSV , A Module built for salesforce data upload from CSV file. Uploading data is easy task , while it become complex when we have to apply multiple lookup to bring record Id and prepare a sheet to upload file , this process requires multiple sheet extraction just to bring record Id in the source CSV file.

    for e.g // Without using this product
                        let suppose, You want to upload opportunity record with their accounts.
                        steps to complete the above requirement
                        1) Extract account from salesforce
                        2) Prepare a sheet for Opportunity with account Id
                        3) apply lookup based on some common and unique fields
                        4) upload using data-loader
                        

What if we can do this thing in a single step , just we need do some prior setup and configuration This product is eliminating above steps and save time so that you can focus on quality of data instead of uploading activity.

#### Steps to upload records

1.  Prepare sheet with external Id (Note : Required external Id Field for lookup relationship)
2.  Configure fields and configuration in salesforce

Technical Information
=====================

### Custom Setting : MassUploadExternalIdRecords

Important Fields of custom setting

*   Name : Name of the Object you want to upload records

*   ObjectName : Name of the object you want to upload records
    
    > In this example it is Opportunity
    
*   TypeApiName : If Object has type , then place Api Name of Type Field
*   Type: For Which type record this configuration is done.
*   FieldUseInCombinationKey : Field you have used as a unique key so that it will insert/update record based on that key and remove duplicate records.
*   CSVFields : Salesforce Fields you want to map with your csv sheet fields.
    
    > *   e.g `OpportunitySheet.csv` You want to upload this sheet having Account Number (External Id on Account)
    

Opportunity Name

Account Number

Amount

Opp 1

AC001

50

Opp 2

AC001

40

> CSVFields value will be : Name,_**Account\_\_r**_,Amount\_\_c Now, has you can see Account\_\_r ( \_\_r mean relationship) , so to get that relationship external Id field you need to create _**one more record**_ of _**MassUploadExternalIdRecords**_ for New MassUploadExternalIdRecords
> 
> *   Name : Account\_\_r
> *   ExteranlId : AccountNumber\_\_c (This is External Id on Account)
> *   ObjectName : Account
> *   DataType : Lookup
> *   FieldUseInCombinationKey : AccountNumber\_\_r