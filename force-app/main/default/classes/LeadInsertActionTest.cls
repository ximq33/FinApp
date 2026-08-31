@IsTest
private with sharing class LeadInsertActionTest {

    //TODO: Przenieś tworzenie rekordów w testSetup (we wsyzstkich testach) do TestFactory (mozna znalezc w google)
    @IsTest
    static void shouldInsertLead() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'test@example.com'
        );
        
        LeadInsertAction.insertLeads(new List<Lead>{testLead});

        
        Lead insertedLead = [SELECT Id, FirstName, LastName, Company, Email FROM Lead WHERE Id = :testLead.Id] ?? null;
        Assert.isNotNull(insertedLead.Id, 'Lead record should be retured after insertion.');
        Assert.isNotNull(insertedLead.Email, 'Email should be populated on Lead record.');
    }


@IsTest
    static void shouldAssignLeadsToCorrectQueuesBasedOnRecordType() {
        
    
        Id firstTimeBuyerRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('First-Time Buyer').getRecordTypeId();
        Id remortgageRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Remortgage').getRecordTypeId();

        Group firstTimeBuyerQueue;
        Group remortgageQueue;
        
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('First_Time_Buyer_Queue', 'Remortgage_Queue')]) {
            if (g.DeveloperName == 'First_Time_Buyer_Queue') {
                firstTimeBuyerQueue = g;
            } else if (g.DeveloperName == 'Remortgage_Queue') {
                remortgageQueue = g;
            }
        }

        Lead firstTimeLead = new Lead(
            FirstName = 'Anna',
            LastName = 'FirstTimeTest',
            Company = 'Test Co 1',
            RecordTypeId = firstTimeBuyerRTId
        );

        Lead remortgageLead = new Lead(
            FirstName = 'Jan',
            LastName = 'RemortgageTest',
            Company = 'Test Co 2',
            RecordTypeId = remortgageRTId
        );
        
        List<Lead> leadsToInsert = new List<Lead>{ firstTimeLead, remortgageLead };

        Test.startTest();
        List<Boolean> results = LeadInsertAction.insertLeads(leadsToInsert);
        Test.stopTest();

        Assert.isTrue(results[0], 'Lead First-Time Buyer powinien się zapisać.');
        Assert.isTrue(results[1], 'Lead Remortgage powinien się zapisać.');

        Map<Id, Lead> insertedLeadsMap = new Map<Id, Lead>([
            SELECT Id, RecordTypeId, OwnerId 
            FROM Lead 
            WHERE Id IN :leadsToInsert
        ]);

        Lead processedFirstTime = insertedLeadsMap.get(leadsToInsert[0].Id);
        Lead processedRemortgage = insertedLeadsMap.get(leadsToInsert[1].Id);

        if (firstTimeBuyerQueue != null) {
            Assert.areEqual(firstTimeBuyerQueue.Id, processedFirstTime.OwnerId, 'Lead z typem First-Time Buyer powinien trafić do kolejki First-Time Buyer Queue!');
        } else {
            System.debug('Brak kolejki First_Time_Buyer_Queue na orgu testowym - sprawdź API Name w kodzie testu.');
        }

        if (remortgageQueue != null) {
            Assert.areEqual(remortgageQueue.Id, processedRemortgage.OwnerId, 'Lead z typem Remortgage powinien trafić do kolejki Remortgage Queue!');
        } else {
            System.debug('Brak kolejki Remortgage_Queue na orgu testowym - sprawdź API Name w kodzie testu.');
        }
    }

@IsTest
static void shouldInsertLeadInBulkWithPartialSuccess() { 
    Lead validLead = new Lead(
        FirstName = 'Janek',
        LastName = 'janekowski',
        Company = 'Firma',
        Email = 'email@email.com'
    );

    Lead invalidLead = new Lead(
        FirstName = 'invalid'
    );

    List<Lead> leadsToInsert = new List<Lead>{validLead, invalidLead};
    
    Test.startTest();
    List<Boolean> results = LeadInsertAction.insertLeads(leadsToInsert);
    Test.stopTest();

    Assert.areEqual(2, results.size(), 'Metoda powinna zwrócić wynik dla każdego przekazanego rekordu.');
    Assert.isTrue(results[0], 'Pierwszy (poprawny) Lead powinien mieć status sukcesu (true).');
    Assert.isFalse(results[1], 'Drugi (zepsuty) Lead powinien mieć status porażki (false).');

    List<Lead> insertedLeads = [SELECT Id FROM Lead];
    Assert.areEqual(1, insertedLeads.size(), 'W bazie powinien znaleźć się dokładnie jeden (ten poprawny) rekord.');    
}










@IsTest
static void shouldAssignSOcialMediaFields() {
    SocialMediaTracking___mdt socialMediaMetadata = new SocialMediaTracking___mdt(
        MasterLabel = 'Test Social Media',
        Twitter_Handle__c = '@testhandle',
        LinkedIn_Profile__c = 'https://www.linkedin.com/in/testprofile',
        Facebook_Profile__c = 'https://www.facebook.com/testprofile'
    );

    insert socialMediaMetadata;
    // Exception - w testach sie nie da

    // Normalnie, robi sie tak:
    // List<SocialMediaTracking___mdt> socialMediaTrackings = SocialMediaTracking___mdt.getAll();


    //Ale dla tetów, chcemy mój robić Injection recordów 
    TriggerServiceHandler.socialMediaTrackings = new Map<String, SocialMediaTracking___mdt>{
        socialMediaMetadata.DeveloperName => socialMediaMetadata
    };



}


private class TriggerServiceHandler {

    //lazy loaded singleton with metadata records
    @TestVisible
    private static Map<String, SocialMediaTracking___mdt> socialMediaTrackings {
        get {
            socialMediaTrackings = socialMediaTrackings ?? SocialMediaTracking___mdt.getAll();
            retrun socialMediaTrackings;
        }
        set;
    }

}

}