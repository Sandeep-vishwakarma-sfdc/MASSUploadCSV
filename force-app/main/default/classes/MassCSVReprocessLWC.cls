public with sharing class MassCSVReprocessLWC {
  /**
     * reprocess method use Re-Process the file for the selected month and year
     * @param folderName The first parameter String.
     * @param month The Second parameter String i.e (Jan,Feb,Mar).
     * @param year The Third parameter String (i.e 2023).
     * @return void
  */
  @AuraEnabled
  public static void reprocess(String folderName,String month,String year){
    
      SharepointSchedular sc = new SharepointSchedular(folderName);
     // system.schedule('Schedule MassCSVProcess', null, sc);
     sc.run();
      
  }

}