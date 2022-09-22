public with sharing class SharepointSchedular implements Schedulable {

    String folderName = '';
    String month = '';
    String year = '';
    public SharepointSchedular(String folderName,String month,String year){
        this.folderName = folderName;
        this.month = month;
        this.year = year;
    }


    public void execute(SchedulableContext sc) {
        BatchGetCSVContent batch = new BatchGetCSVContent(this.folderName,this.month,this.year);
        Database.executeBatch(batch);
    }
}