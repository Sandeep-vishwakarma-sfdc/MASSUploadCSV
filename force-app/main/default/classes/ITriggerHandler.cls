/*******************************************************************************************
* @Name         ITriggerHandler 
* @Author       Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
* @Date         20/06/2022
* @Group        SKI
* @Description  Common for all Triggers in organisation
*******************************************************************************************/
public interface ITriggerHandler {

    /**
     * beforeInsert method act as Before Insert event of Trigger
     * @param newItems The first parameter List<Sobject>.
     * @return void
    */
    void beforeInsert(List<Sobject> newItems);

    /**
     * beforeUpdate method act as Before update event of Trigger
     * @param oldItems The first parameter Map<Id,SObject>.
     * @param newItems The second parameter Map<Id,SObject>.
     * @return void
    */
    void beforeUpdate(Map<Id,SObject> oldItems,Map<Id,SObject> newItems);

    /**
     * beforeDelete method act as Before delete event of Trigger
     * @param oldItems The first parameter Map<Id,SObject>.
     * @return void
    */
    void beforeDelete(Map<Id,SObject> oldItems);

    /**
     * afterInsert method act as After Insert event of Trigger
     * @param newItems The first parameter List<Sobject>.
     * @return void
    */
    void afterInsert(Map<Id,SObject> newItems);

    /**
     * afterUpdate method act as After update event of Trigger
     * @param oldItems The first parameter Map<Id,SObject>.
     * @param newItems The second parameter Map<Id,SObject>.
     * @return void
    */
    void afterUpdate(Map<Id,SObject> oldItems,Map<Id,SObject> newItems);

    /**
     * afterDelete method act as After Delete event of Trigger
     * @param oldItems The first parameter Map<Id,SObject>.
     * @param newItems The second parameter Map<Id,SObject>.
     * @return void
    */
    void afterDelete(Map<Id,SObject> oldItems,Map<Id,SObject> newItems);
    
    /**
     * afterUnDelete method act as After Undelete event of Trigger
     * @param oldItems The first parameter Map<Id,SObject>.
     * @param newItems The second parameter Map<Id,SObject>.
     * @return void
    */
    void afterUnDelete(Map<Id,SObject> oldItems);

    /**
     * isDisabled method use to check if trigger is Disabled or not.
     * @return Boolean
    */
    Boolean isDisabled();
}