public with sharing class SharepointSchedular implements Schedulable {

    String folderName = '';
    public SharepointSchedular(String folderName){
        this.folderName = folderName;
    }


    public void execute(SchedulableContext sc) {
        BatchGetCSVContent batch = new BatchGetCSVContent(folderName);
        Database.executeBatch(batch);
    }
}
