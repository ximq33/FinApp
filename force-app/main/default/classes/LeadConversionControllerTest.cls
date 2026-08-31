@isTest
private class LeadConversionControllerTest {
    

    // TODO Dodać test na sad path
    @isTest
    static void testConvertToLeadSuccess() {
        Lead_Request__c testRequest = new Lead_Request__c(
            First_Name__c = 'Jan',
            Last_Name__c = 'Kowalski',
            Email__c = 'jan.kowalski@test.com',
            Phone__c = '123456789',
            Property_Value__c = 500000,
            Request_Status__c = 'New'
        );
        insert testRequest;

        Test.startTest();
        String newLeadId = LeadRequestConversionController.convertToLead(testRequest.Id);
        Test.stopTest();

        System.assertNotEquals(null, newLeadId, 'Should return the ID of the newly created Lead.');

        Lead createdLead = [SELECT Id, FirstName, LastName, Email, Phone, Company, Status FROM Lead WHERE Id = :newLeadId];
        //TODO Zmien na Assert.areEqual();
        System.assertEquals('Jan', createdLead.FirstName, 'First name should be correctly mapped.');
        System.assertEquals('Kowalski', createdLead.LastName, 'Last name should be correctly mapped.');
        System.assertEquals('Jan Kowalski', createdLead.Company, 'Company field should be the concatenation of First and Last name.');
        System.assertEquals('In Progress', createdLead.Status, 'Status of the new Lead should be In Progress.');

        Lead_Request__c updatedRequest = [SELECT Request_Status__c, Conversion_Date__c FROM Lead_Request__c WHERE Id = :testRequest.Id];
        System.assertEquals('Converted', updatedRequest.Request_Status__c, 'Status of the Lead Request should be updated to Converted.');
        System.assertNotEquals(null, updatedRequest.Conversion_Date__c, 'Conversion date should be populated.');
    }
}