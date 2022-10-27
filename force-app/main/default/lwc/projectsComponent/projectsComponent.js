import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTaskByUser from '@salesforce/apex/GetTask.getTaskByUser';
export default class ProjectsComponent extends LightningElement {
    info;
    @track
    projects = [];

    @wire(getTaskByUser)
    trail( result ) {
        this.info = result;
        const {data, error} = result;
        if(data) {
            this.projects = [];
            for(const project in data){
                this.projects.push({'project': project, 'info': data[project]});
            }
            console.log(this.projects);
        }
    }

    refresh(){
        return refreshApex(this.info);
    }
}