public with sharing class LeadInsertAction {
    
    
    @InvocableMethod(label='Insert Lead with Assignment Rules' description='Inserts a Lead and triggers default assignment rules' category='Lead' iconName='slds:standard:record_create')
    public static List<Boolean> insertLeads(List<Lead> leadsToInsert) {
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        
        
        for(Lead l : leadsToInsert) {
            l.setOptions(dmlOpts);
        }
        
         List<Database.SaveResult> results = Database.insert(leadsToInsert, false);
         List<Boolean> insertionResults = new List<Boolean>();
        
         for (Database.SaveResult result : results) {
             insertionResults.add(result.isSuccess());
         }
        
        return insertionResults;
    }
}