@IsTest
private class LeadConvertActionTest {

    @TestSetup
    static void setupData() {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser) {

            Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
            
            User mdmUser = new User(
                Alias = 'mdmInt',
                Email = 'mdm.integration@test.salesforce.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'MDM Integration',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'mdm.int.' + DateTime.now().getTime() + '@test.salesforce.com'
            );
            insert mdmUser;
        }

        Lead testLead = new Lead(
            FirstName = 'test',
            LastName = 'lead',
            Company = 'test',
            Status = 'Reffered' 
        );
        insert testLead;
    }

    @IsTest
    static void testSuccessfulLeadConversion() {

        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        List<Id> leadIds = new List<Id>{testLead.Id};

        Test.startTest();
        LeadConvertAction.convertLeads(leadIds);
        Test.stopTest();

        Lead convertedLead = [
            SELECT IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId 
            FROM Lead 
            WHERE Id = :testLead.Id
        ];
        
        Assert.isTrue(convertedLead.IsConverted, 'Lead should be marked as converted.');
        Assert.isNotNull(convertedLead.ConvertedAccountId, 'A new Account should be created.');
        Assert.isNotNull(convertedLead.ConvertedContactId, 'A new Contact should be created.');
        Assert.isNotNull(convertedLead.ConvertedOpportunityId, 'A new Opportunity should be created.');
    }

    @IsTest
    static void testFailedLeadConversion() {
        String keyPrefix = Lead.SObjectType.getDescribe().getKeyPrefix();
        Id fakeLeadId = (Id)(keyPrefix + '000000000AAA'); 
        List<Id> leadIds = new List<Id>{fakeLeadId};

        Test.startTest();
        try {
            LeadConvertAction.convertLeads(leadIds);
            Assert.fail('should have thrown an exception due to invalid Lead ID.');
        } catch (Exception e) {
            Assert.isTrue(
                e.getMessage().contains('INVALID_CROSS_REFERENCE_KEY') || e.getMessage().contains('ENTITY_IS_DELETED'), 
                'should throw an exception due to invalid Lead ID.' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testEmptyConvertListDoesNotThrowException() {
        List<Database.LeadConvert> emptyConvertsToProcess = new List<Database.LeadConvert>();
        
        Test.startTest();
        
        try {
            Database.LeadConvertResult[] results = Database.convertLead(emptyConvertsToProcess, false);
            
            Assert.isNotNull(results, 'Result should not be null');
            Assert.isTrue(results.isEmpty(), 'List should be empty');
            
            List<Lead> leadsWithErrors = new List<Lead>();
            update as user leadsWithErrors; 
            
        } catch (Exception e) {
            Assert.fail('Passing an empty list to Database.convertLead() should not throw an exception. Received: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
}