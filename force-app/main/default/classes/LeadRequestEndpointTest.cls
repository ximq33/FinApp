@IsTest
private with sharing class LeadRequestEndpointTest {
    
    @IsTest
    static void testLeadRequestEndpoint() {
    
        Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());


    }



    private with sharing class YourHttpCalloutMockImpl implements HttpCalloutMock {
        String responseBody;
        Integer statusCode;

        public YourHttpCalloutMockImpl(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(this.responseBody);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }

    private with sharing class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"success": true, "message": "Lead request processed successfully."}');
            res.setStatusCode(200);
            return res;
        }
    }

    private with sharing class FailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"success": false, "message": "Failed to process lead request."}');
            res.setStatusCode(400);
            return res;
        }
    }















    //TODO Stworzyć Hierarchiczny Custom Setting, który pozwoli na pomijanie Validation RUles, FLows i Triggers, np
    // AutomationControl__c.DisableValidationRules__c;  // TODO Add to every Vaslidation RUle
    // AutomationControl__c.DisableFlows__c;    //  TODO Add to Every Trigger Flow
    // AutomationControl__c.DisableTriggerContact__c;   //
    // AutomationControl__c.DisableTriggerLeads__c; //

}