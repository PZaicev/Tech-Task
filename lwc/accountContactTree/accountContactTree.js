import { LightningElement, api } from "lwc";

import availableAccount from "@salesforce/label/c.AccContTree_Available_Accounts";
import accountsNotFound from "@salesforce/label/c.AccContTree_Account_Not_Found";

export default class accountContactTree extends LightningElement {

    @api convertedAccountContact;

    labels = {
        availableAccount,
        accountsNotFound
    }

    handleOnselect(event) {
        let selectEvent = new CustomEvent("getidelement", {
            detail: event.detail.name
        });

        this.dispatchEvent(selectEvent);
    }
}