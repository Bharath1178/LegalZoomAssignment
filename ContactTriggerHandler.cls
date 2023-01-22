/**
 * @description       : This class used to operate with different methods
 * @author            : Bharath Baddam
 * @group             :
 * @last modified on  : 01-20-2023
 * @last modified by  : 
 **/
 public with sharing class ContactTriggerHandler implements ITrigger {
    //@Method: Before operatitions will be under this method
    public void bulkBefore() {
    }
    //@Method: Before operatitions will be under this method
    public void bulkAfter() {
        if (trigger.isInsert) {
            //Here we will call after insert actions
        }else if (trigger.isUpdate) {
            ContactUtility conTriggerHelper = new ContactUtility();
            conTriggerHelper.convertLead((List<Contact>)trigger.new, (Map<Id, Contact>)trigger.oldMap);
        }
    }
}