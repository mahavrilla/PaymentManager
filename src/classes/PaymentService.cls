/****************************************
* @classname: PaymentService.cls
* @author: mhavrilla
* @abstract: Service class for handling update to Payments during trigger execution. 
*****************************************/

public class PaymentService {

	/**
    * Method that updates The following fields Project__c with the correct sum of all payments associated.
    * Also sets the Last Payment date and Total payments on Contact. 
    * @param payments
    */
	public static void updatePaymentDetails(Map<Id, Payment__c> payments) {

		// TODO: Enchance this so that we don't ahve to update EVERY record each time. 
		// Should be smart enough to derive the different. 

	    List<Contact> contactsToUpdate = ContactDataService.getAllContactsWithPayments();
	    List<Project__c> projectsToUpdate = new List<Project__c>();
	    Map<Id, Double> projectAmounts = new Map<Id, Double>();

	    // Loop over contacts and update Both Contacts and Projets
	    for( Contact contact : contactsToUpdate) {
            Decimal sumAmount = 0.0;
            DateTime mostRecentDate = null;

            // This first part just loops over 
            for( Payment__c payment : contact.Payments__r) {

                // Contact Object Changes
            	sumAmount += payment.Amount__c;

                if( mostRecentDate == null || mostRecentDate < payment.Payment_Date__c ) {
                 	mostRecentDate = payment.Payment_Date__c;
                }

                //Project Object Changes
                projectAmounts = buildProjectTotals( projectAmounts, payment);
            }

            // Set Contact values
            contact.Last_Payment_Date__c = mostRecentDate;
            contact.Total_Payments_Applied__c = sumAmount;
	    }

	    // Loop over the projects, and add the sum. Save DML and just instansiate a project object.
	    for( Id projectId : projectAmounts.keySet()) {
	    	
            Project__c project = new Project__c( Id = projectId);
	    	project.Total_Payment_Amounts__c = projectAmounts.get( projectId);
	    	projectsToUpdate.add( project);

	    }

	    // Now update the records
	    try {

	    	if( projectsToUpdate.size() > 0) {
	    		update projectsToUpdate;
	    	}

	    	if( contactsToUpdate.size() > 0) {
	    		update contactsToUpdate;
	    	}

    	} catch (Exception e) {
    		System.debug('DEBUG:::PaymentService.updatePaymentDetails:Error' + e.getMessage());
    		// Bubble up the exception. 
    		throw e;
    	}
	}


	/**
    * Builds the projectTotals
    * @param projectAmounts
    * @param payment
    * @retun projectAmounts;
    */
	public static Map<Id, Double> buildProjectTotals( Map<Id, Double> projectAmounts, Payment__c payment) {

		if( projectAmounts.containsKey( payment.Project__c)) {

      		Decimal projectAmount = projectAmounts.get( payment.Project__c);
      		projectAmount += payment.Amount__c;
      		projectAmounts.put( payment.Project__c, projectAmount);

      	} else {

      		projectAmounts.put( payment.Project__c, payment.Amount__c);
      	}

	    return projectAmounts;
	}
}