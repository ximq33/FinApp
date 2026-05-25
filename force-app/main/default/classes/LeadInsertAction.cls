public with sharing class LeadInsertAction {
// Custom exception, żeby ładnie rzucać błędy do naszego Fault Path
    public class FlowLeadException extends Exception {}

    @InvocableMethod(label='Insert Lead with Assignment Rules' description='Inserts a Lead and triggers default assignment rules' category='Lead')
    public static List<Id> insertLeads(List<Lead> leadsToInsert) {
        
        // Konfiguracja DML Options, żeby odpalić Assignment Rules
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        
        // (Opcjonalnie) Jeśli masz włączone auto-response rules dla maili:
        // dmlOpts.EmailHeader.triggerAutoResponseEmail = true;

        for(Lead l : leadsToInsert) {
            l.setOptions(dmlOpts);
        }

        // Insert rekordów
        Database.SaveResult[] results = Database.insert(leadsToInsert, false);
        
        List<Id> newLeadIds = new List<Id>();

        for(Database.SaveResult sr : results) {
            if(sr.isSuccess()) {
                newLeadIds.add(sr.getId());
            } else {
                // Jeśli wywali błąd (np. brak wymaganego pola), wyrzucamy go do Flow
                throw new FlowLeadException(sr.getErrors()[0].getMessage());
            }
        }
        
        return newLeadIds;
    }
}