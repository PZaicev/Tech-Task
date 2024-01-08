@IsTest
private class AccountRestResourceTest {

    @IsTest
    static void testAccountInsertion() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;

        request.requestBody = Blob.valueOf('{"Name":"Test Account","Phone":"123123123","Website":"web"}');

        AccountRestResource.createAccount();

        List<Account> accounts = [
                SELECT Name, Phone, Website
                FROM Account
        ];

        System.assertEquals(201, RestContext.response.statusCode, 'Status code must be 201');
        System.assertEquals(1, accounts.size(), 'Must be crated only one Account');
        System.assertEquals('Test Account', accounts.get(0).Name, 'Name must be equal passed name');
        System.assertEquals('123123123', accounts.get(0).Phone, 'Phone must be equal passed phone');
        System.assertEquals('web', accounts.get(0).Website, 'Website must be equal passed website');
    }

    @IsTest
    static void testAccountWithoutName() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;

        request.requestBody = Blob.valueOf('{"Name":"","Phone":"123123123","Website":"web"}');

        AccountRestResource.createAccount();

        List<Account> accounts = [
                SELECT Name, Phone, Website
                FROM Account
        ];

        System.assertEquals(0, accounts.size(), 'Account must not be crated');
        System.assertEquals(500, RestContext.response.statusCode, 'Status code must be 500');
    }

    @IsTest
    static void testAccountWithWrongFieldValue() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;

        request.requestBody = Blob.valueOf('{"Name":"Test Account","Phone":"123123123",' +
            '"Website":"websitewebsitewebsitewebsitevwebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsite' +
                'websitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsite' +
                'websitewebsitewebsitewebsitevwebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsitewebsite"}');

        AccountRestResource.createAccount();

        List<Account> accounts = [
                SELECT Name, Phone, Website
                FROM Account
        ];

        System.assertEquals(0, accounts.size(), 'Account must not be crated');
        System.assertEquals(500, RestContext.response.statusCode, 'Status code must be 500');
    }
}