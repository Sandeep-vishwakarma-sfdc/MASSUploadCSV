public with sharing class ConnectToSharePoint {

    public static String authentication(){
        AccessTokenResponse accessTokenObj = getSharePointAccessToken();
        String accessToken = accessTokenObj.access_token;
        return accessToken;
    }

    public static List<String> readFilesName(String folderName){
        List<String> fileNames = new List<String>();
        SharePointDetails__c sharepointDetail = getSharePointdetails();
        String accessToken = authentication();
        String authorizationHeader = 'Bearer '+accessToken;
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        String appendFolder = sharepointDetail.Get_Files_URL__c + folderName+'\')'+'/Files';
        request.setendPoint(appendFolder);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json;odata=verbose');
        request.setHeader('Authorization',authorizationHeader);
        httpResponse response = https.send(request);
        System.debug('STATUS CODE '+response.getStatuscode());
        System.debug('Body Files'+response.getbody());
        GetSharePointFilesResponse filesDetails = GetSharePointFilesResponse.parse(response.getbody());
        List<GetSharePointFilesResponse.Results> results = filesDetails.d.results;
        for(GetSharePointFilesResponse.Results result:results){
            System.debug('FileName '+result.Name);
            fileNames.add(result.Name);
        }
        return fileNames;
    }

    private static void fetchCSVContent(){

    }

    private static void createMassCSVOriginalFile(){

    }

    public static AccessTokenResponse getSharePointAccessToken(){
        SharePointDetails__c sharepointDetail = getSharePointdetails();
        Http https = new Http();
        HttpRequest request = new HttpRequest();
        request.setendPoint(sharepointDetail.AuthorizationURL__c);
        request.setMethod('GET');
        
        String requestBody = 'grant_type='+sharepointDetail.Grant_Type__c;
        requestBody +='&client_id='+sharepointDetail.Client_Id__c;
        requestBody += '&client_secret='+sharepointDetail.Client_Secret__c;
        requestBody += '&resource='+sharepointDetail.Resource__c;
        request.setBody(requestBody);
        httpResponse response = https.send(request);
        AccessTokenResponse accessTokenObj = new AccessTokenResponse();
        AccessTokenResponse accessToken = accessTokenObj.parse(response.getbody());
        return accessToken;
	}

    public static SharePointDetails__c getSharePointdetails(){
        SharePointDetails__c sharepointDetail = [select id,AuthorizationURL__c,Client_Id__c,Client_Secret__c,Get_CSV_File_URL__c,Get_Files_URL__c,Grant_Type__c,Resource__c from SharePointDetails__c where Name='MarginBlockCLI' limit 1];
        return sharepointDetail;
    }

    public class AccessTokenResponse {

        public String token_type;
        public String expires_in;
        public String not_before;
        public String expires_on;
        public String resource;
        public String access_token;
    
        
        public AccessTokenResponse parse(String json) {
            return (AccessTokenResponse) System.JSON.deserialize(json, AccessTokenResponse.class);
        }
    }
   
}
