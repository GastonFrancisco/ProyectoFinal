trigger ProjectResourceTrigger on Project_Resource__c (before insert) {
    ProjectResourceTriggerHelper.BeforeInsert(Trigger.new);
}