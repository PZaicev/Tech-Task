import { LightningElement, track } from 'lwc';
import getAccountWithRelatedContacts from "@salesforce/apex/AccountContactTreeController.getAccountWithRelatedContacts";

export default class AccountContactTreeViewMain extends LightningElement {

    @track selectedId;
    convertedAccCont;

    isLoad = true;

    connectedCallback(){
        getAccountWithRelatedContacts()
            .then((response) => {
                let convertedArray = JSON.parse(response);
                this.isLoad = false;

                this.convertedAccCont = convertedArray.length > 0 ? convertedArray : false;
            })
            .catch((error) => {
                console.log(error)
            });
    }

    handleSelectedId(event){
        this.selectedId = event.detail;
    }
}