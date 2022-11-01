import { LightningElement, wire, api } from 'lwc';
import getProjectWrapper from '@salesforce/apex/GetRolesWithUsers.getProjectWrapper';
export default class Allocateresource extends LightningElement {
    @api recordId;
    error;
    roles = [];
    info;


    @wire(getProjectWrapper, { projectId: '$recordId' })
    trail(result) {
        this.info = result;
        const { data, error } = result;
        if (data) {
            this.roles = [];
            console.log(data)
            for (const i in data.roles) {
                this.roles.push({
                    'role': data.roles[i].Role__c + ' Hours to cover ' +
                        data.roles[i].CoveredHours__c,
                    'resource': data.resources[data.roles[i].Role__c]
                });
            }
            console.log(this.roles);
        }
    }
}