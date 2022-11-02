import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProjectWrapper from '@salesforce/apex/GetRolesWithUsers.getProjectWrapper';
import metodoX from '@salesforce/apex/GetRolesWithUsers.metodoX';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Allocateresource extends LightningElement {
    @api recordId;
    error;
    roles = [];
    info;
    resources = [];
    resourcesValues = {};
    disable = true;

    @wire(getProjectWrapper, { projectId: '$recordId' })
    trail(result) {
        this.info = result;
        const { data, error } = result;
        if (data) {
            this.roles = [];
            for (const i in data.roles) {
                this.roles.push({
                    'role': data.roles[i].Role__c + ' Hours to cover ' +
                        data.roles[i].CoveredHours__c,
                    'resource': data.resources[data.roles[i].Role__c]
                });
            }
        }
    }

    handleSelected(event) {
        let realKey;
        let keyFakeArray = Object.keys(event.detail);
        keyFakeArray.forEach(key => realKey = key);

        this.resourcesValues[realKey] = event.detail[realKey]


        console.log(event.detail[realKey]);
        console.log(!event.detail[realKey].includes(undefined));
        console.log(!event.detail[realKey].includes(null));

        if (event.detail[realKey][0] == null && event.detail[realKey][1] == null) {
            delete this.resourcesValues[realKey];
            console.log(JSON.parse(JSON.stringify(this.resourcesValues)))
        }

        if (this.disable == false && (event.detail[realKey].includes(undefined) || event.detail[realKey].includes(null))) {
            this.disable = true
        } else if (this.disable == true && (!event.detail[realKey].includes(undefined)) && (!event.detail[realKey].includes(null))) {
            this.disable = false;
        }




    }

    handleSubmit() {
        metodoX({ projectId: this.recordId, resourcesMap: JSON.stringify(this.submitAnswers) })
            .then((status) => {
                if (status == 'Success') {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'WOOHOO!',
                        message: 'Youve got a shiny new badge',
                        variant: 'success'
                    }));
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Try again',
                        message: 'Youve got one or more wrong answers',
                        variant: 'error'
                    }));
                }
            })
            .catch((error) => {
                console.log(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                }));
            })
    }
}