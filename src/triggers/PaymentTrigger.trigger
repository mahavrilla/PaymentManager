/******************************************
* @classname: PaymentTrigger.cls
* @author: mhavri
* @abstract: Trigger that runs on all PaymentTrigger events.
******************************************/

trigger PaymentTrigger on Payment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.run(new PaymentTriggerHandler());
}