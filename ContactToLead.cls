/**
 * @description       : This class is used for Contact to lead conversion and sending email alerts
 * @author            : Bharath Baddam
 * @group             :
 * @last modified on  : 01-20-2023
 * @last modified by  : 
 **/
public class ContactToLead {
    @AuraEnabled public static ContactLeadWrapper convertContactToLead(String contactId){
        Contact conRec = [select id,MailingAddress,AccountId,Account.Name,Description,DoNotCall,Email,HasOptedOutOfEmail,
                            Fax,HasOptedOutOfFax,FirstName,LastName,OwnerId,Owner.Name,LeadSource,Account.NumberOfEmployees,
                            Phone,Title,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet from contact 
                            Where Id =:contactId];
        Lead leadInsert = ContactUtility.createLead(conRec);
        ContactLeadWrapper contactLeadWrapper = new ContactLeadWrapper();
        contactLeadWrapper.leadRec = leadInsert;
        contactLeadWrapper.contactRec = conRec;
        
        insert leadInsert;
        ContactUtility.sendEmail2OpportunityOwner(new Set<Id> {conRec.Id});
        delete [Select Id From Contact where Id =: conRec.Id];
        return contactLeadWrapper;
    }
    public class ContactLeadWrapper {
        @AuraEnabled public Lead leadRec {get;set;}
        @AuraEnabled public Contact contactRec {get;set;}
    }
}