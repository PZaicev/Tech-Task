@IsTest
private class AccountContactTreeTest {

    private static final Integer ACCOUNT_CONTACTS_COUNT = 10;

    @TestSetup
    private static void testSetup(){
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Custom: Sales Profile'
        ];
        User user = new User(
                Alias = 'tstusr', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='tstusr@testorg.com'
        );
        insert user;

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < ACCOUNT_CONTACTS_COUNT; i++){
            accounts.add(new Account(
                    Name = 'Test Account ' + i
            ));
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < ACCOUNT_CONTACTS_COUNT; i++){
            contacts.add(new Contact(
                    LastName = 'Test Contact ' + 1,
                    AccountId = accounts.get(i).Id
            ));
        }
        insert contacts;

    }

    @IsTest
    static void testAccountsVisibilityWithNoAvailableAccounts() {
        String str = null;

        User us = [
                SELECT Id
                FROM User
                WHERE UserName='tstusr@testorg.com'
        ];

        Test.startTest();
        System.runAs(us) {
            str = AccountContactTreeController.getAccountWithRelatedContacts();
        }
        Test.stopTest();

        System.assertEquals('[]', str, 'User without permission set must not see any Account records');
    }

    @IsTest
    static void testAccountsVisibilityWithBusinessPermSet() {
        String serializedWrapper = null;
        List<AccountContactTreeHelper.AccConWrapper> wrappers = null;

        User us = [
                SELECT Id
                FROM User
                WHERE UserName = 'tstusr@testorg.com'
        ];

        PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Business_Contacts_Accounts'
        ];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);

        Account acc = new Account(
                Name = 'Business Perm Acc'
        );

        Contact cont = new Contact(
                LastName = 'Business Perm Cont'
        );

        Test.startTest();
        System.runAs(us) {
            insert acc;

            cont.AccountId = acc.Id;
            insert cont;

            serializedWrapper = AccountContactTreeController.getAccountWithRelatedContacts();
            wrappers = AccountContactTreeHelper.selectAccountsWithContacts();
        }
        Test.stopTest();

        System.assertEquals(serializedWrapper, JSON.serialize(wrappers), 'Serialize object must be the same');
        System.assertEquals(1, wrappers.size(), 'User with Business_Contacts_Accounts perm set must get only one account');
        System.assertEquals(acc.Id, wrappers.get(0).name, 'Inserted Account Id and returned Account Id must be equal');

        System.assertEquals(1, wrappers.get(0).items.size(), 'User with Business_Contacts_Accounts perm set must get only one contact');
        System.assertEquals(cont.Id, wrappers.get(0).items.get(0).name, 'Inserted Contact Id and returned Contact Id must be equal');
    }

    @IsTest
    static void testAccountsVisibilityWithAdminPermSet() {
        String serializedWrapper = null;
        List<AccountContactTreeHelper.AccConWrapper> wrappers = null;

        User us = [
                SELECT Id
                FROM User
                WHERE UserName = 'tstusr@testorg.com'
        ];

        PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Admin_Contacts_Accounts'
        ];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);

        Test.startTest();
        System.runAs(us) {
            serializedWrapper = AccountContactTreeController.getAccountWithRelatedContacts();
            wrappers = AccountContactTreeHelper.selectAccountsWithContacts();
        }
        Test.stopTest();

        Integer countContact = 0;
        for (AccountContactTreeHelper.AccConWrapper wrap : wrappers){
            countContact += wrap.items.size();
        }

        System.assertEquals(serializedWrapper, JSON.serialize(wrappers), 'Serialize object must be the same');
        System.assertEquals(ACCOUNT_CONTACTS_COUNT, wrappers.size(), 'User with Business_Contacts_Accounts perm set must get '
                + ACCOUNT_CONTACTS_COUNT + ' accounts');

        System.assertEquals(ACCOUNT_CONTACTS_COUNT, countContact, 'User with Business_Contacts_Accounts' +
                ' perm set must get '+ ACCOUNT_CONTACTS_COUNT + ' contacts');
    }

    @IsTest
    static void testAccountContactInfoWith2FieldByContact() {
        String serializedSObject = null;
        SObject sObj = null;
        List<String> selectedFields = new List<String>{'Account.Name',
                'Account.Website', 'Contact.LastName', 'Contact.phone'};

        User us = [
                SELECT Id
                FROM User
                WHERE UserName = 'tstusr@testorg.com'
        ];

        PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Business_Contacts_Accounts'
        ];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);

        Account acc = new Account(
                Name = 'Business Perm Acc',
                Website = 'testWebsite'
        );

        Contact cont = new Contact(
                LastName = 'Business Perm Cont',
                Phone = '123123123'
        );

        Test.startTest();
        System.runAs(us){
            insert acc;

            cont.AccountId = acc.Id;
            insert cont;

            serializedSObject = AccountContactTreeController.getObjectsInfos(cont.Id, selectedFields);
            sObj = AccountContactTreeHelper.getObjectsInfo(cont.Id, selectedFields);
        }
        Test.stopTest();

        Contact returnedCont = (Contact) sObj;

        System.assertEquals(serializedSObject, JSON.serialize(sObj), 'Serialize object must be the same');
        System.assertEquals(cont.LastName, returnedCont.LastName, 'Returned Contact must contain ' +
                'LastName field and be equal to created one');
        System.assertEquals(cont.Phone, returnedCont.Phone, 'Returned Contact must contain ' +
                'Phone field and be equal to created one');
        System.assertEquals(acc.Name, returnedCont.Account.Name, 'Returned Contact must contain ' +
                'Account.Name and be equal to created one');
        System.assertEquals(acc.Website, returnedCont.Account.Website, 'Returned Contact must contain ' +
                'Account.Website and be equal to created one');
    }

    @IsTest
    static void testAccountContactInfoWith2FieldByAccount() {
        String serializedSObject = null;
        SObject sObj = null;
        List<String> selectedFields = new List<String>{'Account.Name', 'Account.Website'};

        User us = [
                SELECT Id
                FROM User
                WHERE UserName = 'tstusr@testorg.com'
        ];

        PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Business_Contacts_Accounts'
        ];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);

        Account acc = new Account(
                Name = 'Business Perm Acc',
                Website = 'testWebsite'
        );

        Contact cont = new Contact(
                LastName = 'Business Perm Cont',
                Phone = '123123123'
        );

        Test.startTest();
        System.runAs(us){
            insert acc;

            cont.AccountId = acc.Id;
            insert cont;

            serializedSObject = AccountContactTreeController.getObjectsInfos(acc.Id, selectedFields);
            sObj = AccountContactTreeHelper.getObjectsInfo(acc.Id, selectedFields);
        }
        Test.stopTest();

        Account returnedAcc = (Account) sObj;

        System.assertEquals(serializedSObject, JSON.serialize(sObj), 'Serialize object must be the same');
        System.assertEquals(acc.Name, returnedAcc.Name, 'Returned Contact must contain ' +
                'Account.Name and be equal to created one');
        System.assertEquals(acc.Website, returnedAcc.Website, 'Returned Contact must contain ' +
                'Account.Website and be equal to created one');
    }

}