/**
 * @description This controller class used for prepare and retrieve Account and Contact records
 * for AccountContactTreeMain lightning tab component. Test class - AccountContactTreeTest.
 *
 *
 * @author Pavel Zaitsau
 * @date 07.01.24
 */
public with sharing class AccountContactTreeController {

    /**
     * @return - Returns a list of all available Accounts and associated Contact names
     * generated for the lightning-tree component.
     */
    @AuraEnabled
    public static String getAccountWithRelatedContacts(){
        return JSON.serialize(AccountContactTreeHelper.selectAccountsWithContacts());
    }

    /**
     * @param objId - Id of Account or Contact.
     * @param fields - List of Account or Contact fields.
     *
     * @return - Returns selected Account or Contact object with passed from LWC fields.
     */
    @AuraEnabled
    public static String getObjectsInfos(String objId, List<String> fields) {
        return JSON.serialize(AccountContactTreeHelper.getObjectsInfo(objId, fields));
    }
}