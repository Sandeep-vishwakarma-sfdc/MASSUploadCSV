@isTest
public with sharing class MockHttpSharepoint implements HttpCalloutMock{
    
    public HttpResponse respond(HTTPRequest req) {
        System.debug('Req '+req);
        return null;
    }
}
