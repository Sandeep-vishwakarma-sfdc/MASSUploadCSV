/*******************************************************************************************
* @Name         ITriggerHandler 
* @Author       Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
* @Date         20/06/2022
* @Group        SKI
* @Description  Common for all Triggers in organisation
*******************************************************************************************/
public interface ITriggerHandler {

    void beforeInsert(List<Sobject> newItems);
    void beforeUpdate(Map<Id,SObject> oldItems,Map<Id,SObject> newItems);
    void beforeDelete(Map<Id,SObject> oldItems);
    
    void afterInsert(Map<Id,SObject> newItems);
    void afterUpdate(Map<Id,SObject> oldItems,Map<Id,SObject> newItems);
    void afterDelete(Map<Id,SObject> oldItems,Map<Id,SObject> newItems);
    void afterUnDelete(Map<Id,SObject> oldItems);

    Boolean isDisabled();
}