public with sharing class LeadRequestConversionController {
    
    @AuraEnabled
    public static String convertToLead(Id requestId) {
        try {
            Lead_Request__c request = [
                SELECT First_Name__c, Last_Name__c, Email__c, Phone__c, OwnerId 
                FROM Lead_Request__c 
                WHERE Id = :requestId
                WITH USER_MODE 
                LIMIT 1
            ];

            Lead newLead = new Lead(
                FirstName = request.First_Name__c,
                LastName = request.Last_Name__c,
                Email = request.Email__c,
                Phone = request.Phone__c,
                Status = 'In Progress',
                Company = request.First_Name__c + ' ' + request.Last_Name__c, 
                OwnerId = request.OwnerId
            );
            
            insert newLead;

            request.Request_Status__c = 'Converted';
            request.Conversion_Date__c = System.now();
            request.Converted_Lead__c = newLead.Id;
            update request;

            return newLead.Id;

        } catch (Exception e) {
            throw new AuraHandledException('Error while converting lead: ' + e.getMessage());
        }
    }
}