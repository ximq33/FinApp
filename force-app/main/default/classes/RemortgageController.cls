public with sharing class RemortgageController {
    
    @AuraEnabled
    public static void createLeadWithRules(Lead newLead) {
        try {

            Id remortgageRtId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                .get('Remortgage') 
                .getRecordTypeId();
            
            newLead.RecordTypeId = remortgageRtId;

            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            newLead.setOptions(dmlOpts);
            
            insert newLead;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}