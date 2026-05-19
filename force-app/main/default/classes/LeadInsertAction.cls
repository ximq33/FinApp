public with sharing class LeadInsertAction {

    public class FlowLeadException extends Exception {}

    @InvocableMethod(label='Insert Lead with Assignment Rules' description='Inserts a Lead and triggers default assignment rules' category='Lead')
    public static List<Id> insertLeads(List<Lead> leadsToInsert) {
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        
    
        for(Lead l : leadsToInsert) {
            l.setOptions(dmlOpts);
        }

        Database.SaveResult[] results = Database.insert(leadsToInsert, false);
        
        List<Id> newLeadIds = new List<Id>();

        for(Database.SaveResult sr : results) {
            if(sr.isSuccess()) {
                newLeadIds.add(sr.getId());
            } else {
              
                throw new FlowLeadException(sr.getErrors()[0].getMessage());
            }
        }
        
        return newLeadIds;
    }
}