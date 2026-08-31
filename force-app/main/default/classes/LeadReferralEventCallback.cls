public with sharing class LeadReferralEventCallback implements EventBus.EventPublishFailureCallback, EventBus.EventPublishSuccessCallback {

    private List<Lead> leadsToProcess;
    
    public LeadReferralEventCallback(List<Lead> leadsToProcess) {
        this.leadsToProcess = leadsToProcess;
    }

    public void onFailure(EventBus.FailureResult result) {

        List<Task> tasksToInsert = new List<Task>();
        for (Lead lead : leadsToProcess) {
            tasksToInsert.add(new Task(
                Subject = 'MDM Lead Referral Event Publish Failure',
                Description = 'Platform event failed for lead. Event UUIDs: ' + String.valueOf(result.getEventUuids()),
                WhoId = lead.Id,
                Priority = 'High',
                Status = 'Not Started'
            ));
        }
        if (!tasksToInsert.isEmpty()) insert as system tasksToInsert;
    }

    public void onSuccess(EventBus.SuccessResult result) {
        for (Lead lead : leadsToProcess) {
            lead.Status = 'Referred';
        }
        update as system leadsToProcess;
    }
}
