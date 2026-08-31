public with sharing class DebtCheckService {
    
    private static final Integer MAX_TIMEOUT = 10000;
    
    public class DebtCheckException extends Exception {}
    
    @InvocableMethod(
    label='Check Debt Status via API'
        description='Calls external KRS API to check if Lead is a debtor'
        callout=true
        iconName='slds:standard:record_lookup')
    public static List<Boolean> checkDebtorStatus(List<Lead> leadsToCheckDebtor) {
        
        List<Boolean> flowResults = new List<Boolean>();
        
        if (leadsToCheckDebtor.size() > 1) {
            throw new DebtCheckException('List size bigger than 1.');
        }
        for (Lead l : leadsToCheckDebtor) {
            if (String.isBlank(l.PESEL__c)) {
                throw new DebtCheckException('Lead does not have PESEL value.');
            }
            Boolean isDebtor;
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:KRS_Mock/' + l.PESEL__c);
                request.setMethod('GET');
                request.setTimeout(MAX_TIMEOUT);
                
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    isDebtor = true;
                } else if (response.getStatusCode() == 404) {
                    isDebtor = false;
                } else {
                    throw new DebtCheckException('API Error. Status: ' + response.getStatusCode() + ' Body: ' + response.getBody());
                }
            } catch (Exception e) {
                throw new DebtCheckException('Callout failed: ' + e.getMessage());
            }
            
            l.Is_Debtor__c = isDebtor;
            
            flowResults.add(isDebtor);
        }
        
        return flowResults;
    }
}