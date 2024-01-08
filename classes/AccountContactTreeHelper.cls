/**
 * @description This helper class is used to maintain the AccountContactTreeController class.
 * Test class - AccountContactTreeTest.
 *
 * @author Pavel Zaitsau
 * @date 07.01.24
 */
public with sharing class AccountContactTreeHelper {

    /**
     * @return - List of wrapper objects for lightning tree component.
     */
    public static List<AccountContactTreeHelper.AccConWrapper> selectAccountsWithContacts(){
        List<Account> accounts = [
                SELECT Id, Name,
                        (SELECT Id, Name FROM Contacts)
                FROM Account
        ];

        return accountContactTreeConverter(accounts);
    }

    /**
     * @param objId - Id of Account or Contact.
     * @param fields - List of Account or Contact fields.
     *
     * @return - Returns selected Account or Contact object with passed from LWC fields.
     */
    public static SObject getObjectsInfo(String objId, List<String> fields){
        String objApiName = ((Id) objId).getSobjectType().getDescribe().getName();
        String selectQuery = 'SELECT ' + String.join(fields, ',')
                + ' FROM ' + objApiName + ' WHERE Id = \'' + objId+ '\'';

        return Database.query(selectQuery).get(0);
    }

    /**
     * @param accounts - All available Accounts name for current user with related Contacts name.
     *
     * @return - Converted Accounts to Wrapper object describing the structure of a lightning-tree.
     */
    private static List<AccConWrapper> accountContactTreeConverter(List<Account> accounts) {
        List<AccConWrapper> accConWrappers = new List<AccountContactTreeHelper.AccConWrapper>();

        for(Account acc : accounts) {
            List<AccConWrapper> contactWrappers = new List<AccountContactTreeHelper.AccConWrapper>();
            for (Contact cont : acc.Contacts){
                contactWrappers.add(
                        new AccConWrapper(cont.Name, cont.Id, null)
                );
            }

            accConWrappers.add(
                new AccConWrapper(acc.Name, acc.Id, contactWrappers)
            );
        }

        return accConWrappers;
    }

    /**
     * @description This Wrapper class describe the lightning-tree structure.
     */
    public class AccConWrapper {
        public String label;
        public String name;
        public List<AccConWrapper> items;

        public Boolean disabled = false;
        public Boolean expanded = false;

        public AccConWrapper (String label, String name, List<AccConWrapper> items) {
            this.label = label;
            this.name = name;
            this.items = items;
        }
    }
}