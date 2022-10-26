import { LightningElement, wire, track } from 'lwc';
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
            for(const project in data){
                this.projects.push({'project': project, 'info': data[project]});
            }
            console.log(this.projects);
            
            // console.log(Object.keys(data));
        }
    }
}