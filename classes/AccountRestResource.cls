@RestResource(urlMapping='/v1/accounts/*')
global with sharing class AccountRestResource {

    @HttpPost
    global static void createAccount(){
        RestRequest request = RestContext.request;
        String requestStr = request.requestBody.toString();

        try {
            Account acc = ((AccountWrapper) JSON.deserialize(requestStr, AccountWrapper.class)).getAccountObject();

            Database.SaveResult sr = Database.insert(acc);

            if (sr.success){
                prepareResponse(201, serializeObject(new SinglePOSTResponse(sr.id)));
            } else {
                prepareResponse(501, serializeObject(new ErrorWrapper(sr.errors.toString())));
            }
        } catch (Exception ex) {
            System.debug('Error trying to insert records : '+ ex.getMessage());
            prepareResponse(500, serializeObject(new ErrorWrapper(ex.getMessage())));
        }
    }

    private static void prepareResponse(Integer statusCode, Blob responseBody){
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = responseBody;
        response.statusCode = statusCode;
    }

    private static Blob serializeObject(Object obj){
        return Blob.valueOf(JSON.serialize(obj));
    }

    class AccountWrapper {
        public String Name;
        public String Website;
        public String Phone;

        public Account getAccountObject(){
            return new Account(
                Name = this.Name,
                Website = this.Website,
                Phone = this.Phone
            );
        }
    }

    class SinglePOSTResponse {
        public String Id;

        SinglePOSTResponse(String Id){
            this.Id = Id;
        }
    }

    class ErrorWrapper {
        public String error;

        public ErrorWrapper(String error){
            this.error = error;
        }
    }

}