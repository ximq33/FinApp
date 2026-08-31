public with sharing class LeadConvertAction {
    
    @InvocableMethod(
        label='Convert Leads (MDM Dedicated)' 
        description='Automates Lead Conversion assigning the running MDM user as owner' 
        category='Lead' 
        iconName='slds:standard:lead'
    )
    public static void convertLeads(List<Id> leadIds) {
        
        if (leadIds == null || leadIds.isEmpty()) return;
        
        LeadStatus convertStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true WITH SYSTEM_MODE LIMIT 1];
        User mdmUser = [SELECT Id FROM User WHERE Alias = 'mdmInt' WITH SYSTEM_MODE LIMIT 1];
        List<Database.LeadConvert> convertsToProcess = new List<Database.LeadConvert>();
        
        for (Id leadId : leadIds) {
            Database.LeadConvert leadToConvert = new Database.LeadConvert();
            leadToConvert.setLeadId(leadId);
            leadToConvert.setConvertedStatus(convertStatus.MasterLabel);
            leadToConvert.setDoNotCreateOpportunity(false);
            leadToConvert.setOwnerId(mdmUser.Id);
            
            convertsToProcess.add(leadToConvert);
        }
        
        if (!convertsToProcess.isEmpty()) {
            Database.LeadConvertResult[] results = Database.convertLead(convertsToProcess, false); 
            List<Lead> leadsWithErrors = new List<Lead>();
            
            for (Database.LeadConvertResult leadConvertResult : results) {
                if (!leadConvertResult.isSuccess()) {
                    String errorMessage = 'BŁĄD KONWERSJI MDM: ';
                    for (Database.Error err : leadConvertResult.getErrors()) {
                        errorMessage += err.getStatusCode() + ' - ' + err.getMessage() + ' ';
                    }
                    
                    leadsWithErrors.add(new Lead(
                        Id = leadConvertResult.getLeadId(),
                        Status = 'Conversion Failed', 
                        Description = errorMessage
                    ));
                }
            }
            
            update as user leadsWithErrors;
        }
    }
}