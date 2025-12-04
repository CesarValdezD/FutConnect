public with sharing class FutIntegrationService {

    // Método principal que hace el callout
    @AuraEnabled(cacheable=false)
    public static String getPlayers() {
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            // Named Credential FutAPI
            req.setEndpoint('callout:FutAPI/api/v1/players');
            req.setMethod('GET');

            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                return 'ERROR: ' + res.getStatus() + ' - ' + res.getBody();
            }

        } catch (Exception e) {
            return 'EXCEPTION: ' + e.getMessage();
        }
    }
}