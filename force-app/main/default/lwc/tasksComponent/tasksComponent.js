import { LightningElement, api} from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RESOURCETASK_OBJECT from '@salesforce/schema/ResourceTask__c';
import ID_FIELD from '@salesforce/schema/ResourceTask__c.Id'
import NAME_FIELD from '@salesforce/schema/ResourceTask__c.Name';
import STATUS_FIELD from '@salesforce/schema/ResourceTask__c.Status__c';
import APROXIMATEHOURS_FIELD from '@salesforce/schema/ResourceTask__c.AproximateHours__c';
import REGISTEREDHOURS_FIELD from '@salesforce/schema/ResourceTask__c.RegisteredHours__c';
export default class TasksComponent extends LightningElement {
    @api task
    hours
    disabled = true;
    resourcetask = RESOURCETASK_OBJECT;
    namefield = NAME_FIELD;
    statusfield = STATUS_FIELD;
    aproximatehoursfield = APROXIMATEHOURS_FIELD;
    registeredhoursfield = REGISTEREDHOURS_FIELD;

    handleChange(event) {
       if (!event.target.value) {
           event.target.reportValidity();
           this.disabled = true;
       }
       else {
            this.hours = event.target.value;
           this.disabled = false;
       }
    }

    iniateTask(event) {
            const taskId = event.target.dataset.id
            const fields = {};
            fields[ID_FIELD.fieldApiName] = taskId;
            fields[STATUS_FIELD.fieldApiName] = 'In Progress';

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Task started',
                            message: 'Task updated',
                            variant: 'success'
                        })
                    );
                    this.dispatchEvent(new CustomEvent('refresh', {
                        detail:{
                            refresh: true
                        }
                    }))
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error starting task',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
    }

    completeTask(event) {
        const taskId = event.target.dataset.id
        const fields = {};
        fields[ID_FIELD.fieldApiName] = taskId;
        fields[STATUS_FIELD.fieldApiName] = 'Completed';
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Task completed',
                        message: 'Task updated',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CustomEvent('refresh', {
                    detail:{
                        refresh: true
                    }
                }))
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error completing task',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    handleRegisterHours(event) {
        const taskId = event.target.dataset.id;
        const registeredHours = event.target.dataset.registeredhours;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = taskId;
        fields[REGISTEREDHOURS_FIELD.fieldApiName] = parseInt(registeredHours) + parseInt(this.hours);
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Hours loaded',
                        message: 'Task updated',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CustomEvent('refresh', {
                    detail:{
                        refresh: true
                    }
                }))
                this.template.querySelector('lightning-input').value = null;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error completing task',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}