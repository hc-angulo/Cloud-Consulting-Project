trigger RegisterResource on Project_Resource__c (before insert) {
   RegisterResource.onBeforeInsert(Trigger.New);
}