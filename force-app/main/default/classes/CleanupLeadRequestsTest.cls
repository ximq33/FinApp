@isTest
private class CleanupLeadRequestsTest {
  @testSetup
  static void setupData() {
    List<Lead_Request__c> requestsToInsert = new List<Lead_Request__c>();

    requestsToInsert.add(
      new Lead_Request__c(
        First_Name__c = 'Stary',
        Last_Name__c = 'Wniosek',
        Request_Status__c = 'Converted',
        Property_Value__c = 300000,
        Conversion_Date__c = System.now().addDays(-735)
      )
    );

    requestsToInsert.add(
      new Lead_Request__c(
        First_Name__c = 'Swiezy',
        Last_Name__c = 'Wniosek',
        Request_Status__c = 'Converted',
        Property_Value__c = 400000,
        Conversion_Date__c = System.now().addDays(-10)
      )
    );

    requestsToInsert.add(
      new Lead_Request__c(
        First_Name__c = 'Aktywny',
        Last_Name__c = 'Wniosek',
        Property_Value__c = 500000,
        Request_Status__c = 'New'
      )
    );

    insert requestsToInsert;
  }

  @isTest
  static void testBatchExecution() {
    Test.startTest();
    CleanUpLeadRequestsBatch batch = new CleanUpLeadRequestsBatch();
    Database.executeBatch(batch);
    Test.stopTest();

    List<Lead_Request__c> remainingRequests = [
      SELECT Id, First_Name__c
      FROM Lead_Request__c
    ];

    //TODO Assert.equals pls
    System.assertEquals(
      2,
      remainingRequests.size(),
      'Batch should have deleted only the old converted lead request.'
    );

    for (Lead_Request__c req : remainingRequests) {
      System.assertNotEquals(
        'Stary',
        req.First_Name__c,
        'The old converted lead request should have been deleted.'
      );
    }
  }

  @isTest
  static void testSchedulerExecution() {
    Test.startTest();
    String cronExp = '0 0 0 * * ?';

    String jobId = System.schedule(
      'Test cleanup schedule',
      cronExp,
      new CleanUpLeadRequestsScheduler()
    );
    Test.stopTest();

    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered
      FROM CronTrigger
      WHERE Id = :jobId
    ];

    System.assertEquals(
      cronExp,
      ct.CronExpression,
      'Scheduled job expression should match.'
    );
    System.assertEquals(
      0,
      ct.TimesTriggered,
      'The job should not have been triggered yet.'
    );
  }
}
