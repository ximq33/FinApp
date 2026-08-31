@IsTest
private class LeadReferralPublisherTest {

    @TestSetup
    static void setupData() {

        Id firstTimeBuyerRtId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('First_Time_Buyer')?.getRecordTypeId();
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Referral',
            Company = 'test',
            Status = 'Being Referred'
        );
        
        if (firstTimeBuyerRtId != null) {
            testLead.RecordTypeId = firstTimeBuyerRtId;
        }
        
        insert testLead;
    }

    @IsTest
    static void testPublishReferralEvents_Success() {
       
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        List<Id> leadIds = new List<Id>{ testLead.Id };

        
        Test.startTest();
        
        LeadReferralPublisher.publishReferralEvents(leadIds);
        
        Test.stopTest(); 

        Lead updatedLead = [SELECT Status FROM Lead WHERE Id = :testLead.Id];
        Assert.areEqual('Referred', updatedLead.Status, 'status should be updated to Referred after successful event publish');
    }

    @IsTest
    static void testPublishReferralEvents_EmptyList_ThrowsException() {
       
        List<Id> emptyLeadIds = new List<Id>();

        Test.startTest();
        try {
            LeadReferralPublisher.publishReferralEvents(emptyLeadIds);
            Assert.fail('Expected IllegalArgumentException for empty list, but code continued.');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('No Lead IDs provided'), 'Expected error message not found.');
        } catch (Exception e) {
            Assert.fail('Expected IllegalArgumentException, but received: ' + e.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void testPublishReferralEvents_NullList_ThrowsException() {
        Test.startTest();
        try {
            LeadReferralPublisher.publishReferralEvents(null);
            Assert.fail('Expected IllegalArgumentException for null list, but code continued.');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('No Lead IDs provided'), 'Expected error message not found.');
        } catch (Exception e) {
            Assert.fail('Expected IllegalArgumentException, but received: ' + e.getTypeName());
        }
        Test.stopTest();
    }
}