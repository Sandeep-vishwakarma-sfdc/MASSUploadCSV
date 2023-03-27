public with sharing class MassCSVReprocessLWC {
    @AuraEnabled
  public static void reprocess(String folderName,String month,String year){
    
      SharepointSchedular sc = new SharepointSchedular(folderName);
     // system.schedule('Schedule MassCSVProcess', null, sc);
     sc.run();
      
  }

}