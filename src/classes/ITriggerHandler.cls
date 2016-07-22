/****************************************
* @classname: ITriggerHandler.cls
* @author: mhavrilla
* @abstract: This interface should be implemented by all trigger handler classes. 
* Complete the implemented methods which are required for the trigger
*****************************************/

public interface ITriggerHandler {

	Boolean isDisabled();

	void beforeInsert(List<SObject> newItems);

	void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

	void beforeDelete(Map<Id, SObject> oldItems);

	void afterInsert(Map<Id, SObject> newItems);

	void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

	void afterDelete(Map<Id, SObject>oldItems);

	void afterUndelete(Map<Id, SObject> oldItems);

}