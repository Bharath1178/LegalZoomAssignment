/**
 * @description       : This is a contactutility class 
 * @author            : Bharath Baddam
 * @group             :
 * @last modified on  : 01-20-2023
 * @last modified by  : 
 **/

public class ContactUtility {
    public void convertLead(List<Contact> conList, Map<Id,Contact> conOldMap){
        List<Lead> convertLeadList = new List<Lead>();
        Set<Id> oldAccountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact con : [select id,MailingAddress,AccountId,Account.Name,Description,DoNotCall,Email,HasOptedOutOfEmail,
                            Fax,HasOptedOutOfFax,FirstName,LastName,OwnerId,Owner.Name,LeadSource,Account.NumberOfEmployees,
                            Phone,Title,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet from contact 
                            Where Id IN :conList]
            ){
            Contact oldContactDetails = conOldMap.get(con.Id);
            if(con.AccountId != oldContactDetails.AccountId){
                convertLeadList.add(createLead(con));   
                oldAccountIdSet.add(oldContactDetails.AccountId); 
            }
        }
        if(convertLeadList.size() > 0){
            insert convertLeadList;
        }
        deleteOpportunityContactRoles(oldAccountIdSet);
        sendEmail2OpportunitySameOwner(oldAccountIdSet);
    }
    public static Lead createLead (Contact con){
        Lead lead = new Lead();
        lead.Title = con.Title;
        lead.Phone = con.Phone;
        lead.NumberOfEmployees = con.Account.NumberOfEmployees;
        lead.LeadSource = con.LeadSource;
        lead.OwnerId = con.OwnerId;
        lead.FirstName = con.FirstName;
        lead.LastName = con.LastName;
        lead.HasOptedOutOfFax = con.HasOptedOutOfFax;
        lead.Fax = con.Fax;
        lead.HasOptedOutOfEmail = con.HasOptedOutOfEmail;
        lead.Email = con.Email;
        lead.DoNotCall = con.DoNotCall;
        lead.Description = con.Description;
        lead.Company = con.Account.Name;
        lead.City = con.MailingCity;
        lead.Country = con.MailingCountry;
        lead.PostalCode = con.MailingPostalCode;
        lead.State = con.MailingState;
        lead.Street = con.MailingStreet;
        return lead;
    }
    public void deleteOpportunityContactRoles(Set<Id> oldAccountIdSet){
        if(oldAccountIdSet.size() > 0){
            delete [select id from OpportunityContactRole Where Opportunity.StageName NOT IN ('Closed Won','Closed Lost') AND Opportunity.AccountId In : oldAccountIdSet];
        }
    }
    public static void sendEmail2OpportunitySameOwner(Set<Id> accountIdSet){
        List<Opportunity> oppList = [Select Id,Name,StageName,OwnerId,Owner.Email From Opportunity Where AccountId IN : accountIdSet AND OwnerId =:UserInfo.getUserId()];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(oppList.size() > 0) {
            for(Opportunity oppRec : oppList){
                String body = 'Hi, <br/>';
                body += 'Opportunity account has been changed. Please review the same - <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppRec.Id+'">'+oppRec.Name+'</a><br/>';
                mails.add(returnSingleEmail(new List<String> {oppRec.Owner.Email},'Owner change notification alert',body));
            }
            if(mails.size() > 0)
            Messaging.sendEmail(mails); 
        }
    }
    public static void sendEmail2OpportunityOwner(Set<Id> contactIdSet){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<OpportunityContactRole> opportunityContactRoleList = [select id,ContactId,Contact.Name,OpportunityId,Opportunity.Name,Opportunity.OwnerId,Opportunity.Owner.Email from OpportunityContactRole Where ContactId IN : contactIdSet AND Opportunity.OwnerId !=:UserInfo.getUserId()];
        if(opportunityContactRoleList.size() > 0) {
            for(OpportunityContactRole opportunityContactRole : opportunityContactRoleList){
                String body = 'Hi, <br/>';
                body += 'Opportunity account has been changed. Please review the same - <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opportunityContactRole.OpportunityId+'">'+opportunityContactRole.Opportunity.Name+'</a><br/>';
                body += 'Contact link - <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opportunityContactRole.ContactId+'">'+opportunityContactRole.Contact.Name+'</a><br/>';
                mails.add(returnSingleEmail(new List<String> {opportunityContactRole.Opportunity.Owner.Email},'Owner change notification alert',body));
            }
            if(mails.size() > 0)
            Messaging.sendEmail(mails); 
        }
    }
    public static Messaging.SingleEmailMessage returnSingleEmail(List<String> recipientList, String subject, String emailBody){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setReplyTo('reply@chatter.salesforce.com');
        email.setSenderDisplayName('Bharath');
        email.setToAddresses(recipientList);
        email.setSubject(subject);
        email.setHtmlBody(emailBody);
        return email;
    }
}