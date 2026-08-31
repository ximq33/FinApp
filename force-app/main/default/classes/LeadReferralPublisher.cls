public with sharing class LeadReferralPublisher {

    @InvocableMethod(
        label='Publish Lead Referral Event' 
        description='Generates dynamic JSON payload based on Record Type and publishes Platform Event.'
        category='Lead'
    )
    public static void publishReferralEvents(List<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            throw new IllegalArgumentException('No Lead IDs provided for referral event publishing.');
        }

        List<Lead> leads = [
            SELECT Id, FirstName, LastName, Email, Phone, Company, Status, RecordType.DeveloperName, Current_Lender__c, Property_Value__c, Deposit_Amount__c, First_Time_Buyer_Grant__c,
            Current_Interest_Rate__c, Remaining_Term__c, Is_Debtor__c, Last_Debt_Check__c
            FROM Lead 
            WHERE Id IN :leadIds
            WITH USER_MODE
        ];  

        List<Lead_Referral__e> eventsToPublish = new List<Lead_Referral__e>();

        for (Lead myLead : leads) {
            String serializedJson = JSON.serialize(Payload.create(myLead));

            Lead_Referral__e referralEvent = new Lead_Referral__e();
            referralEvent.Payload__c = serializedJson;
            eventsToPublish.add(referralEvent);
        }

        if (!eventsToPublish.isEmpty()) {
            LeadReferralEventCallback callback = new LeadReferralEventCallback(leads);
            
            List<Database.SaveResult> results = EventBus.publish(eventsToPublish, callback);  
            
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error enqueueing Platform Event: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                    return; 
                }
            }
        }
    }

    private abstract class Payload {
        public String leadId;
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public String company;
        public String recordType;
        public Decimal propertyValue;
        public Boolean isDebtor;
        public Datetime lastDebtCheck;

        public Payload(Lead lead) {
            this.leadId = lead.Id;
            this.firstName = lead.FirstName;
            this.lastName = lead.LastName;
            this.email = lead.Email;
            this.phone = lead.Phone;
            this.company = lead.Company;
            this.recordType = lead.RecordType.DeveloperName;
            this.propertyValue = lead.Property_Value__c;
            this.isDebtor = lead.Is_Debtor__c;
            this.lastDebtCheck = lead.Last_Debt_Check__c;
        }

    }

        public static Payload create(Lead lead) {
            switch on lead.RecordType.DeveloperName {
                when 'First_Time_Buyer' { 
                    return new FirstTimeBuyerPayload(lead);
                }
                when 'Remortgage' { 
                    return new RemortgagePayload(lead);
                }
                when else {
                    throw new IllegalArgumentException('Record type not supported: ' + lead.RecordType.DeveloperName);
                }
            }
        }

    private class FirstTimeBuyerPayload extends Payload {
        public String referralType = 'First Time Buyer Process';
        public Decimal depositAmount;
        public Boolean firstTimeBuyerGrant;

        public FirstTimeBuyerPayload(Lead lead) {
            super(lead);
            this.depositAmount = lead.Deposit_Amount__c;
            this.firstTimeBuyerGrant = lead.First_Time_Buyer_Grant__c;
        }
    }

    private class RemortgagePayload extends Payload {
        public String referralType = 'Remortgage Process';
        public Decimal currentInterestRate;
        public String currentLender;
        public Decimal remainingTerm;

        public RemortgagePayload(Lead lead) {
            super(lead); 
            this.currentInterestRate = lead.Current_Interest_Rate__c;
            this.currentLender = lead.Current_Lender__c;
            this.remainingTerm = lead.Remaining_Term__c;
        }
    }
}