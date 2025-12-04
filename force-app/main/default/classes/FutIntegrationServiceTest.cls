@IsTest
private class FutIntegrationServiceTest {

    // Fake response para pruebas
    private class MockPlayerResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data":[{"id":1,"first_name":"Test","last_name":"Player"}]}');
            return res;
        }
    }

    @IsTest
    static void testGetPlayers() {

        Test.setMock(HttpCalloutMock.class, new MockPlayerResponse());

        String response = FutIntegrationService.getPlayers();

        System.assert(response.contains('"first_name":"Test"'));
    }
}