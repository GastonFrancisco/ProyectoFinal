import { LightningElement, api} from 'lwc';
import RESOURCETASK_OBJECT from '@salesforce/schema/ResourceTask__c';
import NAME_FIELD from '@salesforce/schema/ResourceTask__c.Name';
import STATUS_FIELD from '@salesforce/schema/ResourceTask__c.Status__c';
import APROXIMATEHOURS_FIELD from '@salesforce/schema/ResourceTask__c.AproximateHours__c';
import REGISTEREDHOURS_FIELD from '@salesforce/schema/ResourceTask__c.RegisteredHours__c';
export default class TasksComponent extends LightningElement {
    @api task
    resourcetask = RESOURCETASK_OBJECT;
    namefield = NAME_FIELD;
    statusfield = STATUS_FIELD;
    aproximatehoursfield = APROXIMATEHOURS_FIELD;
    registeredhoursfield = REGISTEREDHOURS_FIELD;



}