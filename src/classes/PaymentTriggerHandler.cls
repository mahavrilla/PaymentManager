/****************************************
* @classname: PaymentTriggerHandler.cls
* @author: mhavrilla
* @abstract: Handler for all Payments. Records should not be directly modified in this class
* unless it has to do with record validation. Delegate to other classes (e.g. services)
*****************************************/

public class PaymentTriggerHandler implements ITriggerHandler {
    public static Boolean disable = false;

    public Boolean isDisabled() {
        Boolean isDisabled = false;

        if (disable) {
            isDisabled = true;
        }

        return isDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        List<Payment__c> newPayments = (List<Payment__c>) newItems;
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Payment__c> newPayments = (Map<Id, Payment__c>) newItems;
        Map<Id, Payment__c> oldPayments = (Map<Id, Payment__c>) oldItems;

    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Map<Id, Payment__c> oldPayments = (Map<Id, Payment__c>) oldItems;
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, Payment__c> newPayments = (Map<Id, Payment__c>) newItems;

        PaymentService.updatePaymentDetails( newPayments);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Payment__c> newPayments = (Map<Id, Payment__c>) newItems;
        Map<Id, Payment__c> oldPayments = (Map<Id, Payment__c>) oldItems;

        PaymentService.updatePaymentDetails( newPayments);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        Map<Id, Payment__c> oldPayments = (Map<Id, Payment__c>) oldItems;

        PaymentService.updatePaymentDetails( oldPayments);
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {
        Map<Id, Payment__c> oldPayments = (Map<Id, Payment__c>) oldItems;
    }
}