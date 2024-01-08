import {api, LightningElement} from 'lwc';
import getObjectInfo from "@salesforce/apex/AccountContactTreeController.getObjectsInfos";

import ACCOUNT_NAME from "@salesforce/schema/Account.Name";
import ACCOUNT_TYPE from "@salesforce/schema/Account.Type";
import ACCOUNT_PHONE from "@salesforce/schema/Account.Phone";
import ACCOUNT_WEBSITE from "@salesforce/schema/Account.Website";

import CONTACT_NAME from "@salesforce/schema/Contact.Name";
import CONTACT_PHONE from "@salesforce/schema/Contact.Phone";
import CONTACT_EMAIL from "@salesforce/schema/Contact.Email";

import summary from "@salesforce/label/c.AccContTree_Summary";
import selectContact from "@salesforce/label/c.AccContTree_Select_Contact";
import accountInfo from "@salesforce/label/c.AccContTree_Account_Info";
import contactInfo from "@salesforce/label/c.AccContTree_Contact_Info";
import errorText from "@salesforce/label/c.AccContTree_Error_Message";

const ACCOUNT_FIELDS = [
    ACCOUNT_NAME,
    ACCOUNT_TYPE,
    ACCOUNT_PHONE,
    ACCOUNT_WEBSITE
]

const CONTACT_FIELDS = [
    CONTACT_NAME,
    CONTACT_PHONE,
    CONTACT_EMAIL
]

export default class AccountContactTreeInfo extends LightningElement {

    labels = {
        summary,
        selectContact,
        accountInfo,
        contactInfo,
        errorText
    }

    @api selectedId;
    previousId;

    accountInfo;
    accountLink;
    contactInfo;
    contactLink;

    showSelectText = true;
    hasError = false;

    removeFields = [
        'Id',
        'AccountId',
        'attributes'
    ]

    renderedCallback() {
        if(this.selectedId && this.selectedId !== this.previousId) {
            let strAccountFields = ACCOUNT_FIELDS.map(acc => acc.objectApiName + '.' + acc.fieldApiName);
            this.removeOldValues();

            if (this.selectedId.startsWith("001")) {
                this.retrieveIdInfo(strAccountFields);
            }
            else if (this.selectedId.startsWith("003")) {
                this.retrieveIdInfo(strAccountFields.concat(
                    CONTACT_FIELDS.map(cont => cont.objectApiName + '.' + cont.fieldApiName)
                ));
            }

            this.previousId = this.selectedId;
        }
    }

    retrieveIdInfo(fields) {
        getObjectInfo({
            objId: this.selectedId,
            fields: fields
        })
            .then(response => {
                let parseObject = JSON.parse(response);
                let fieldsArray = this.objectToFieldsArray(parseObject);
                let account = fieldsArray.find(field => field.label === 'Account')?.value;

                if (account) {
                    this.accountLink = this.generateAccountLink(account.Id);
                    this.accountInfo = this.objectToFieldsArray(account);

                    this.contactLink = this.generateContactLink(parseObject.Id);
                    this.contactInfo = fieldsArray.filter(e => e.label !== 'Account');
                } else {
                    this.accountLink = this.generateAccountLink(this.selectedId);
                    this.accountInfo = fieldsArray;
                }

                this.showSelectText = false;
            })
            .catch(error => {
                this.showSelectText = false;
                this.selectedId = false;
                this.hasError = true;
                console.log('error', error);
            })
    }

    objectToFieldsArray(obj) {
        return Object.entries(obj).map(
            ([label, value], id ) =>  ({ label, value, id })
        ).filter(field => !this.removeFields.includes(field.label));
    }

    removeOldValues(){
        this.accountInfo = null;
        this.accountLink = null;
        this.contactInfo = null;
        this.contactLink = null;
        this.showSelectText = true;
        this.hasError = false;
    }

    generateAccountLink(id){
        return '/lightning/r/Account/' + id + '/view';
    }

    generateContactLink(id){
        return '/lightning/r/Contact/' + id + '/view';
    }
}