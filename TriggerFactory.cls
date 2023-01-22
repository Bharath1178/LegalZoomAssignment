/**
 * @description       : This is a triggerfactory class for triggers.
 * @author            : Bharath Baddam
 * @group             :
 * @last modified on  : 01-20-2023
 * @last modified by  : 
 **/
 public with sharing class TriggerFactory {
    public static void createHandler(Schema.sObjectType soType) {
        ITrigger handler = getHandler(soType);
        if (handler == null) {
            system.debug('No Trigger Handler registered for Object Type: ' + soType);
        }
        execute(handler);
    }
    private static void execute(ITrigger handler) {
        if (Trigger.isBefore) {
            handler.bulkBefore();
        }
        else {
            handler.bulkAfter();
        }
    }
    private static ITrigger getHandler(Schema.sObjectType soType) {
        if (soType == Contact.sObjectType) {
            return new ContactTriggerHandler();
        }
        return null;
    }
}