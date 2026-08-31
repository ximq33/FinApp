@RestResource(urlMapping='/partner/v1/lead-requests/*')
global with sharing class LeadRequestEndpoint {

    @HttpPost
    global static ResponseWrapper createLeadRequest() {
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        ResponseWrapper response = new ResponseWrapper();

        try {
            String requestURI = restRequest.requestURI;
            String endpointPath = requestURI.substring(requestURI.lastIndexOf('/') + 1).toLowerCase();

            String recordTypeDevName;
            
            if (endpointPath == 'remortgage') {
                recordTypeDevName = 'Remortgage';
            } else if (endpointPath == 'first-time-buyer') {
                recordTypeDevName = 'First_Time_Buyer'; 
            } else {
                restResponse.statusCode = 404;
                response.isSuccess = false;
                response.message = 'Unsupported endpoint. Use /remortgage or /first-time-buyer.';
                return response;
            }

            RequestPayload payload = (RequestPayload) JSON.deserialize(restRequest.requestBody.toString(), RequestPayload.class);

            RecordType recordType = [
                SELECT Id FROM RecordType 
                WHERE SobjectType = 'Lead_Request__c' AND DeveloperName = :recordTypeDevName 
                WITH USER_MODE
                LIMIT 1
            ]; 

            String queueDevName = recordTypeDevName + '_Queue';
            Group targetQueue = [
                SELECT Id FROM Group 
                WHERE Type = 'Queue' AND DeveloperName = :queueDevName 
                WITH USER_MODE
                LIMIT 1
            ]; 

            Lead_Request__c newRequest = new Lead_Request__c(
                RecordTypeId = recordType.Id,
                OwnerId = targetQueue.Id,
                Request_Status__c = 'New',
                First_Name__c = payload.firstName,
                Last_Name__c = payload.lastName,
                Email__c = payload.email,
                Phone__c = payload.phone
            );

            switch on recordTypeDevName {
                when 'Remortgage' {
                    newRequest.Current_Lender__c = payload.currentLender;
                    newRequest.Current_Interest_Rate__c = payload.currentInterestRate;
                    newRequest.Remaining_Term__c = payload.remainingTerm;
                    newRequest.Property_Value__c = payload.propertyValue;
                }
                when 'First_Time_Buyer' {
                    newRequest.Deposit_Amount__c = payload.depositAmount;
                    newRequest.First_Time_Buyer_Grant__c = payload.firstTimeBuyerGrant;
                    newRequest.Property_Value__c = payload.propertyValue;
                }
            }

            insert as user newRequest;

            response.isSuccess = true;
            response.recordId = newRequest.Id;
            response.message = 'Lead request created.';
            restResponse.statusCode = 201;

        } catch (Exception e) {
            response.isSuccess = false;
            response.message = 'Error: ' + e.getMessage();
            restResponse.statusCode = 400;
        }

        return response;
    }

    global class RequestPayload {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        
        public String currentLender;
        public Decimal currentInterestRate;
        public Decimal remainingTerm;
        public Decimal propertyValue;
        
        public Decimal depositAmount;
        public Boolean firstTimeBuyerGrant;
    }

    global class ResponseWrapper {
        public Boolean isSuccess;
        public String message;
        public String recordId;
    }
}