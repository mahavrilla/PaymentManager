/****************************************
* @classname: PaymentManagerExtensionTest.cls
* @author: mhavrilla
* @abstract: Test Class for PaymentManager app. Has no reliance on org data
* Uses Arrange/Act/Assert pattern
*****************************************/

@isTest (SeeAllData = false)
public class PaymentManagerExtensionTest {
	private static List<Contact> contacts;
	private static List<Project__c> projects;
	private static List<Payment__c> payments;

	static {

		// Create Contacts
		contacts = new List<Contact>();
		contacts.add( new Contact( FirstName = 'Richard', LastName = 'Hendricks', Phone = '(111) 111-1111', Email = 'richard.hendricks@test.com'));
		contacts.add( new Contact( FirstName = 'Erlich',  LastName = 'Bachman',   Phone = '(222) 222-2222', Email = 'erlich.bachman@test.com'));
		contacts.add( new Contact( FirstName = 'Bertram', LastName = 'Gilfoyle',  Phone = '(333) 333-3333', Email = 'bertam.gilfoyle@test.com'));

		insert contacts;


 		projects = new List<Project__c>();
        projects.add( new Project__c( Name = 'Pied Piper'));
        projects.add( new Project__c( Name = 'End Frame'));
        projects.add( new Project__c( Name = 'Nucleus'));

        insert projects;

        payments = new List<Payment__c>();
        payments.add( new Payment__c( Contact__c = contacts.get(0).Id, Payment_Date__c = Date.today().addDays(-10), Amount__c = 5000, Project__c = projects.get(0).Id));
        payments.add( new Payment__c( Contact__c = contacts.get(1).Id, Payment_Date__c = Date.today().addDays(-11), Amount__c = 5000, Project__c = projects.get(0).Id));
        payments.add( new Payment__c( Contact__c = contacts.get(1).Id, Payment_Date__c = Date.today().addDays(-12), Amount__c = 5000, Project__c = projects.get(1).Id));
        payments.add( new Payment__c( Contact__c = contacts.get(1).Id, Payment_Date__c = Date.today().addDays(-13), Amount__c = 6000, Project__c = projects.get(1).Id));
        payments.add( new Payment__c( Contact__c = contacts.get(2).Id, Payment_Date__c = Date.today().addDays(-14), Amount__c = 5000, Project__c = projects.get(2).Id));

        insert payments;

	}

	/* Positive Tests */
	static testMethod void testPaymentManagerInvocation() {  
        
        // Arrange
       	Payment__c payment = payments[0];

        // Act
        Test.startTest();
        	PageReference pymtManager = Page.PaymentManager;
			Test.setCurrentPage( pymtManager);

			ApexPages.StandardController controller = new ApexPages.StandardController( payment);
			PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);
			
			paymentExtension.buildPaymentsByContact();
        Test.stopTest();


        // Assert
        System.debug( 'The expected value is 3 and the actual value is ' + paymentExtension.contactPayments.size());
        System.assertEquals( paymentExtension.contactPayments.size(), 3);
    }

    /* Test that adding a new payment is successful */
   	static testMethod void testPaymentManagerAddNewPayment() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
       	Contact currentContact = contacts[0];
       	Project__c currentProject = projects[0];

        // Act
        Test.startTest();
        	PageReference pymtManager = Page.PaymentManager;
			Test.setCurrentPage( pymtManager);

			ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
			PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

			paymentExtension.buildPaymentsByContact();
			paymentExtension.currentContactId = currentContact.Id;
			paymentExtension.showAddPayment();
			for( PaymentManagerExtension.PaymentWrapper contactPayment : paymentExtension.contactPayments) {
				if( contactPayment.contact.Id == paymentExtension.currentContactId) {
					contactPayment.newPaymentRecord.Amount__c = 1000.00;
					contactPayment.newPaymentRecord.Payment_Date__c = Date.today().addDays(-5);
					contactPayment.newPaymentRecord.Project__c = currentProject.Id;
				}
			}

			paymentExtension.submitNewPayment();

        Test.stopTest();

        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        // Validate Contact is updated properly
        System.debug( 'The expected value is 6000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c,  6000);

        // Validate the Last Payment Date, is the most recent. 
        System.debug( 'The expected value is ' + Date.today().addDays(-5) + ' and the actual value is ' + contact.Last_Payment_Date__c);
        System.assertEquals( contact.Last_Payment_Date__c,  Date.today().addDays(-5));

        // Validate project is updated properly
        System.debug( 'The expected value is 11000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 11000);

        System.debug( 'The expected value is false and the actual value is ' + paymentExtension.contactPayments[0].showAddPayment);
        System.assertEquals( paymentExtension.contactPayments[0].showAddPayment, false);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());

    }

    /* Test that adding a new payment is successful */
    static testMethod void testPaymentManagerAddNewPaymentNoAmount() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
        Contact currentContact = contacts[0];
        Project__c currentProject = projects[0];

        // Act
        Test.startTest();
            PageReference pymtManager = Page.PaymentManager;
            Test.setCurrentPage( pymtManager);

            ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
            PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

            paymentExtension.buildPaymentsByContact();
            paymentExtension.currentContactId = currentContact.Id;
            paymentExtension.showAddPayment();
            for( PaymentManagerExtension.PaymentWrapper contactPayment : paymentExtension.contactPayments) {
                if( contactPayment.contact.Id == paymentExtension.currentContactId) {
                    contactPayment.newPaymentRecord.Amount__c = null;
                    contactPayment.newPaymentRecord.Payment_Date__c = Date.today().addDays(-5);
                    contactPayment.newPaymentRecord.Project__c = currentProject.Id;
                }
            }

            paymentExtension.submitNewPayment();

        Test.stopTest();

        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        // Validate Contact is updated properly
        System.debug( 'The expected value is 5000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c,  5000);

        // Validate the Last Payment Date, is the most recent. 
        System.debug( 'The expected value is ' + Date.today().addDays(-10) + ' and the actual value is ' + contact.Last_Payment_Date__c);
        System.assertEquals( contact.Last_Payment_Date__c,  Date.today().addDays(-10));

        // Validate project is updated properly
        System.debug( 'The expected value is 11000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 10000);

        System.debug( 'The expected value is true and the actual value is ' + paymentExtension.contactPayments[0].showAddPayment);
        System.assertEquals( paymentExtension.contactPayments[0].showAddPayment, true);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());

    }

        /* Test that adding a new payment is successful */
    static testMethod void testPaymentManagerAddNewPaymentNoDate() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
        Contact currentContact = contacts[0];
        Project__c currentProject = projects[0];

        // Act
        Test.startTest();
            PageReference pymtManager = Page.PaymentManager;
            Test.setCurrentPage( pymtManager);

            ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
            PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

            paymentExtension.buildPaymentsByContact();
            paymentExtension.currentContactId = currentContact.Id;
            paymentExtension.showAddPayment();
            for( PaymentManagerExtension.PaymentWrapper contactPayment : paymentExtension.contactPayments) {
                if( contactPayment.contact.Id == paymentExtension.currentContactId) {
                    contactPayment.newPaymentRecord.Amount__c = 1000.00;
                    contactPayment.newPaymentRecord.Payment_Date__c = null;
                    contactPayment.newPaymentRecord.Project__c = currentProject.Id;
                }
            }

            paymentExtension.submitNewPayment();

        Test.stopTest();

        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        // Validate Contact is updated properly
        System.debug( 'The expected value is 5000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c,  5000);

        // Validate the Last Payment Date, is the most recent. 
        System.debug( 'The expected value is ' + Date.today().addDays(-10) + ' and the actual value is ' + contact.Last_Payment_Date__c);
        System.assertEquals( contact.Last_Payment_Date__c,  Date.today().addDays(-10));

        // Validate project is updated properly
        System.debug( 'The expected value is 10000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 10000);

        System.debug( 'The expected value is true and the actual value is ' + paymentExtension.contactPayments[0].showAddPayment);
        System.assertEquals( paymentExtension.contactPayments[0].showAddPayment, true);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());

    }

	/* Test that adding a cancel payment has no impact*/ 
    static testMethod void testPaymentManagerCancelAddNewPayment() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
       	Contact currentContact = contacts[0];
       	Project__c currentProject = projects[0];

        // Act
        Test.startTest();
        	PageReference pymtManager = Page.PaymentManager;
			Test.setCurrentPage( pymtManager);

			ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
			PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

			paymentExtension.buildPaymentsByContact();
			paymentExtension.currentContactId = currentContact.Id;
			paymentExtension.showAddPayment();
			paymentExtension.cancelAddPayment();

        Test.stopTest();

        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        System.debug( 'The expected value is 3 and the actual value is ' + paymentExtension.contactPayments.size());
        System.assertEquals( paymentExtension.contactPayments[0].showAddPayment, false);


    }

    static testMethod void testPaymentManagerDeletePayments() {  
        
        // Arrange
        Payment__c payment = payments[0];
       	Contact currentContact = contacts[1];
       	Project__c currentProject = projects[1];

        // Act
        Test.startTest();
        	PageReference pymtManager = Page.PaymentManager;
			Test.setCurrentPage( pymtManager);

			ApexPages.StandardController controller = new ApexPages.StandardController( payment);
			PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

			paymentExtension.buildPaymentsByContact();
			paymentExtension.currentContactId = currentContact.Id;

			for( PaymentManagerExtension.PaymentWrapper contactPayment : paymentExtension.contactPayments) {
				for( PaymentManagerExtension.PaymentListWrapper p : contactPayment.payments) {
					if( contactPayment.contact.Id == paymentExtension.currentContactId && p.payment.Project__c == currentProject.Id && p.payment.Amount__c == 5000) {
						p.shouldDelete = true;
					}
				}
			}

			paymentExtension.deletePayment();

        Test.stopTest();


        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];
        
        // Assert
        System.debug( 'The expected value is 11000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c, 11000);

        System.debug( 'The expected value is ' + Date.today().addDays(-11) + ' and the actual value is ' + contact.Last_Payment_Date__c);
        System.assertEquals( contact.Last_Payment_Date__c,  Date.today().addDays(-11));

        System.debug( 'The expected value is 6000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 6000);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());

    }

    static testMethod void testPaymentManagerNoPaymentsSelectedForDeletion() {  
        
        // Arrange
        Payment__c payment = payments[0];
        Contact currentContact = contacts[1];
        Project__c currentProject = projects[1];

        // Act
        Test.startTest();
            PageReference pymtManager = Page.PaymentManager;
            Test.setCurrentPage( pymtManager);

            ApexPages.StandardController controller = new ApexPages.StandardController( payment);
            PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

            paymentExtension.buildPaymentsByContact();
            paymentExtension.currentContactId = currentContact.Id;

            paymentExtension.deletePayment();

        Test.stopTest();


        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];
        
        // Assert
        System.debug( 'The expected value is 16000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c, 16000);

        System.debug( 'The expected value is 11000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 11000);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());

    }

    static testMethod void testPaymentManagerUpdatePayments() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
       	Contact currentContact = contacts[0];
       	Project__c currentProject = projects[0];

        // Act
        Test.startTest();
        	PageReference pymtManager = Page.PaymentManager;
			Test.setCurrentPage( pymtManager);

			ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
			PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

			paymentExtension.buildPaymentsByContact();
			paymentExtension.currentContactId = currentContact.Id;

			for( PaymentManagerExtension.PaymentWrapper contactPayment : paymentExtension.contactPayments) {
				for( PaymentManagerExtension.PaymentListWrapper p : contactPayment.payments) {
					if( contactPayment.contact.Id == paymentExtension.currentContactId && p.payment.Project__c == currentProject.Id) {
						p.payment.Amount__c = 8000.00;
						p.payment.Payment_Date__c = Date.today().addDays(-1);
                        paymentExtension.setHasChanges();
					}
				}
			}
          

			paymentExtension.updatePayment();

        Test.stopTest();


        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        System.debug( 'The expected value is 8000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c,  8000);

        System.debug( 'The expected value is ' + Date.today().addDays(-1) + ' and the actual value is ' + contact.Last_Payment_Date__c);
        System.assertEquals( contact.Last_Payment_Date__c,  Date.today().addDays(-1));

        System.debug( 'The expected value is 13000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 13000);

        System.debug( 'The expected value is false and the actual value is ' + paymentExtension.contactPayments[0].showAddPayment);
        System.assertEquals( paymentExtension.contactPayments[0].showAddPayment, false);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
    }

    static testMethod void testPaymentManagerNothingUpdate() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
        Contact currentContact = contacts[0];
        Project__c currentProject = projects[0];

        // Act
        Test.startTest();
            PageReference pymtManager = Page.PaymentManager;
            Test.setCurrentPage( pymtManager);

            ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
            PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

            paymentExtension.buildPaymentsByContact();
            paymentExtension.currentContactId = currentContact.Id;

            paymentExtension.updatePayment();

        Test.stopTest();


        Contact contact = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        System.debug( 'The expected value is 5000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c,  5000);

        System.debug( 'The expected value is false and the actual value is ' + paymentExtension.contactPayments[0].hasChanges);
        System.assertEquals( paymentExtension.contactPayments[0].hasChanges, false);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
    }

    static testMethod void testPaymentManagerUpdateInvalidData() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
       	Contact currentContact = contacts[0];
       	Project__c currentProject = projects[0];


        // Act
        Test.startTest();
        	PageReference pymtManager = Page.PaymentManager;
			Test.setCurrentPage( pymtManager);

			ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
			PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

			paymentExtension.buildPaymentsByContact();
			paymentExtension.currentContactId = currentContact.Id;

			for( PaymentManagerExtension.PaymentWrapper contactPayment : paymentExtension.contactPayments) {
				for( PaymentManagerExtension.PaymentListWrapper p : contactPayment.payments) {
					if( contactPayment.contact.Id == paymentExtension.currentContactId && p.payment.Project__c == currentProject.Id) {
						//p.payment.Amount__c = '8000.00';
						//p.payment.Payment_Date__c = Date.today().addDays(-10);
					}
				}
			}

			paymentExtension.updatePayment();

        Test.stopTest();


        Contact contact = [select Id, Name, Total_Payments_Applied__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        System.debug( 'The expected value is 5000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c,  5000);

        System.debug( 'The expected value is 5000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 10000);

        System.debug( 'The expected value is false and the actual value is ' + paymentExtension.contactPayments[0].showAddPayment);
        System.assertEquals( paymentExtension.contactPayments[0].showAddPayment, false);

        // Make sure there is a page message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
    }

    // Test that the trigger was disabled, and no downstream changes were made. 
    static testMethod void testTriggerDisabled() {  
        
        // Arrange
        Payment__c currentPayment = payments[0];
       	Contact currentContact = contacts[0];
       	Project__c currentProject = projects[0];


        // Act
        Test.startTest();
        	PageReference pymtManager = Page.PaymentManager;
			Test.setCurrentPage( pymtManager);

			ApexPages.StandardController controller = new ApexPages.StandardController( currentPayment);
			PaymentManagerExtension paymentExtension = new PaymentManagerExtension( controller);

			paymentExtension.buildPaymentsByContact();
			paymentExtension.currentContactId = currentContact.Id;

			for( PaymentManagerExtension.PaymentWrapper contactPayment : paymentExtension.contactPayments) {
				for( PaymentManagerExtension.PaymentListWrapper p : contactPayment.payments) {
					if( contactPayment.contact.Id == paymentExtension.currentContactId && p.payment.Project__c == currentProject.Id) {
						p.payment.Amount__c = 8000.00;
						p.payment.Payment_Date__c = Date.today().addDays(-10);
					}
				}
			}

			PaymentTriggerHandler.disable = true;
			
			paymentExtension.updatePayment();
			
			PaymentTriggerHandler.disable = false;

        Test.stopTest();


        Contact contact = [select Id, Name, Total_Payments_Applied__c from Contact where Id = :currentContact.Id];
        Project__c updatedProject = [select Id, Name, Total_Payment_Amounts__c  from Project__c where Id = :currentProject.Id];

        // Assert
        System.debug( 'The expected value is 5000 and the actual value is ' + contact.Total_Payments_Applied__c);
        System.assertEquals( contact.Total_Payments_Applied__c,  5000);

        System.debug( 'The expected value is 5000 and the actual value is ' + updatedProject.Total_Payment_Amounts__c);
        System.assertEquals( updatedProject.Total_Payment_Amounts__c, 10000);

        System.debug( 'The expected value is false and the actual value is ' + paymentExtension.contactPayments[0].showAddPayment);
        System.assertEquals( paymentExtension.contactPayments[0].showAddPayment, false);
    }
}