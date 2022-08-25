/*******************************************************************************************
* @Name         TriggerDispatcher 
* @Author       Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
* @Date         20/06/2022
* @Group        SKI
* @Description  Common for all Triggers in organisation use to dispatch event
*******************************************************************************************/
public without sharing class TriggerDispatcher {

    /*
    * @Description  Identify event and call handler 
    * @Param		TriggerHandler Interface 
    */
    public static void run(ITriggerHandler handler){
        if(handler.isDisabled()){
            return;
        }
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                handler.beforeInsert(Trigger.new);
            }
            if(Trigger.isUpdate){
                handler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
            }
            if(Trigger.isDelete){
                handler.beforeDelete(Trigger.oldMap);
            }
        }

        if(Trigger.isAfter){
            if(Trigger.isInsert){
                handler.afterInsert(Trigger.newMap);
            }
            if(Trigger.isUpdate){
                handler.afterUpdate(Trigger.oldMap, Trigger.newMap);
            }
            if(Trigger.isDelete){
                handler.afterDelete(Trigger.oldMap, Trigger.newMap);
            }
            if(Trigger.isUndelete){
                handler.afterUnDelete(Trigger.oldMap);
            }
        }
    }
}