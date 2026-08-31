global class CleanupLeadRequestsBatch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    String query =
      'SELECT Id FROM Lead_Request__c ' +
      'WHERE Request_Status__c = \'Converted\' ' +
      'AND Conversion_Date__c < LAST_N_DAYS:730';
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext bc,
    List<Lead_Request__c> scope
  ) {
    delete as user scope; // TODO empty recycle bin
  }

  global void finish(Database.BatchableContext bc) {
  }
}
