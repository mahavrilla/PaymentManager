/****************************************
* @classname: PaymentManagerExtension.cls
* @author: mhavrilla
* @abstract: This extension handles all data for Payment Manager Page. 
*****************************************/

public class PaymentManagerExtension {
    public List<PaymentWrapper> contactPayments {get; set;}
    public String currentContactId {get; set; }

    /* ctor */
    public PaymentManagerExtension(ApexPages.StandardController stdController) {}

     /**
     * Action Function, builds out the inital list of all contacts wiht payments.
     */
    public PageReference buildPaymentsByContact() {
        ApexPages.getMessages().clear();
        contactPayments = new List<PaymentWrapper>();
        
        List<Contact> contacts = ContactDataService.getAllContactsWithPayments();

        for( Contact c : contacts ) {

            if( c.Payments__r.size() > 0) {

                PaymentWrapper paymentWrapper = new PaymentWrapper();
                paymentWrapper.contact = c;

                for( Payment__c p : c.Payments__r) {
                    paymentWrapper.payments.add( new PaymentListWrapper( p));
                }

                contactPayments.add( paymentWrapper);
            }
        }

        return null;
    }

    /**
    * Helper Method: Loops over Payment Wrappers and returns the paymentWrapper with the associated Id. 
    * @return PaymentWrapper
    */
    public PaymentWrapper getCurrentUserPaymentWrapper() {

        for( PaymentWrapper p : contactPayments) {
            if( currentContactId == p.contact.Id) {
                return p;
            }
        }

        return null;
    }

    /**
    * Page Action Function Method. Shows Add Payment Screen
    * Creates a new instance of newPaymentRecord to Contact PaymentWrapper class. 
    */
    public void showAddPayment() {
        PaymentWrapper p = getCurrentUserPaymentWrapper();
        if( p != null) {
            p.showAddPayment = true;
            p.newPaymentRecord = new Payment__c();
            p.newPaymentRecord.Contact__c = (Id) currentContactId;
        }
    }

    /**
    * Page Action Function Method. Closes Add Payment Screen
    */
    public void cancelAddPayment() {
        PaymentWrapper p = getCurrentUserPaymentWrapper();
        if( p != null) {
            p.showAddPayment = false;
        }
         
    }

    /**
    * Page Action Function Method. Inserts new payment record. 
    */
    public PageReference submitNewPayment() {
        PaymentWrapper p = getCurrentUserPaymentWrapper();
        if( p.newPaymentRecord.Amount__c == null) {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter an Amount Value'));
             return null;
        }

        if( p.newPaymentRecord.Payment_Date__c == null) {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter a Date Value'));
             return null;
        }

        try {
            
            if( p != null) {
                insert p.newPaymentRecord;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'New payment added successfully '));

            }
            
        } catch ( Exception e) {
            System.debug('DEBUG:::PaymentManagerExtensions.submitNewPayment:Error' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        
        
        return buildPaymentsByContact();
    }


    /**
    * Page Action Function Method. Deletes all payment 
    * @retun buildPaymentsByContact();
    */
    public PageReference deletePayment() {

        List<Payment__c> paymentsToDelete = new List<Payment__c>();

        for( PaymentWrapper p : contactPayments) {

            for( PaymentListWrapper pl : p.payments) {

                if( pl.shouldDelete && currentContactId == p.contact.Id) {
                    paymentsToDelete.add( pl.payment);
                }
            }
        }

        try {

            if( paymentsToDelete.size() > 0 ) {
                delete paymentsToDelete;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Payment records deleted Successfully '));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No payments selected for deletion '));
                return null;
            }

        } catch ( Exception e) {
            System.debug('DEBUG:::PaymentManagerExtensions.deletePayment:Error' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }

        return buildPaymentsByContact();
    }

    /**
    * Page Action Function Method. Updates the Payments with inline changes.
    * @retun buildPaymentsByContact();
    */
    public PageReference updatePayment() {
        List<Payment__c> paymentsToUpdate = new List<Payment__c>();
        PaymentWrapper p = getCurrentUserPaymentWrapper();

        for( PaymentListWrapper pList : p.payments) {

            if( pList.payment.Contact__c == currentContactId && p.hasChanges) {
                paymentsToUpdate.add( pList.payment);
            }
        }

        try {

             if( paymentsToUpdate.size() > 0 ) {
                p.hasChanges = false;
                update paymentsToUpdate;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Update successful'));

            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No changes have been made '));
                return null;
            }

        } catch ( Exception e) {
            System.debug('DEBUG:::PaymentManagerExtensions.updatePayment:Error' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
       

        return buildPaymentsByContact();
    }

    public void setHasChanges() {
        PaymentWrapper p = getCurrentUserPaymentWrapper();
        p.hasChanges = true;
    }


    /**
    * Wrapper object: Holds info related to contact and and payments. 
    */
    public class PaymentWrapper {
        public Contact contact {get; set;}
        public Boolean showAddPayment { get; set; }
        public Boolean hasChanges { get; set; }
        public Payment__c newPaymentRecord { get; set ;}
        public List<PaymentListWrapper> payments { get; set;}

        public PaymentWrapper() {
            payments = new List<PaymentListWrapper>();
            showAddPayment = false;
            hasChanges = false;
        }
    }


    /**
    * Wrapper object: Holds info related payment and delete info. 
    */
    public class PaymentListWrapper {
        public Payment__c payment { get; set;}
        public Boolean shouldDelete { get; set; }

        public PaymentListWrapper(Payment__c pymnt) {
            payment = pymnt;
            shouldDelete = false;
        }
    }
}