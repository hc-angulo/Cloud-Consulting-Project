trigger ProjectSquadLeadAssignment on Project__c (before update) {
       ProjectSquadLeadAssignment.onBeforeUpdate(Trigger.New,Trigger.oldMap);
}