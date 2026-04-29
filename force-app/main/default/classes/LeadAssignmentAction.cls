@SuppressWarnings('PMD.ApexCRUDViolation')
public class LeadAssignmentAction {
    
    @InvocableMethod(label='Run Lead Assignment Rules' description='Wywołuje domyślne Assignment Rules dla przekazanych Leadów')
    public static void assignLeads(List<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            return;
        }
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        
        List<Lead> leadsToUpdate = [SELECT Id FROM Lead WHERE Id IN :leadIds];
        
        for (Lead l : leadsToUpdate) {
            l.setOptions(dmlOpts);
        }
        
        update leadsToUpdate;
    }
}