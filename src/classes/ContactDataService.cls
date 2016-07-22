/****************************************
* @classname: ContactDataService.cls
* @author: mhavrilla
* @abstract:  Dataservice class for the Contact object
*****************************************/

public class ContactDataService {


  /**
  * Returns all contacts with associated payments. 
  * @retun contacts;
  */
  public static List<Contact> getAllContactsWithPayments() {
    List<Contact> contacts = new List<Contact>();
    
    contacts = [select Id, Name, Total_Payments_Applied__c, Last_Payment_Date__c,
                  (
                    select Id, Name, Contact__c, Project__r.Name, Project__c, Amount__c, Payment_Date__c
                      from Payments__r 
                     where Project__c != null
                  )
                  from Contact
                ];

    return contacts;
  }
}