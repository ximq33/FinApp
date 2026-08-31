global class CleanupLeadRequestsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CleanupLeadRequestsBatch batch = new CleanupLeadRequestsBatch();
        Database.executeBatch(batch, 200);
    }
}