import { LightningElement, api, track } from 'lwc';

export default class Resource extends LightningElement {
    @api resource;
    disabled = true;
    disabled2 = false;
    @track
    desde;
    @track
    hasta;
    dates = []

    resourceObject = {}

    handleClick(event) {

        if (event.target.checked == true) {
            event.target.reportValidity();
            this.disabled = false;

        } else if (event.target.checked == false) {
            /*  this.hours = event.target.value; */
            this.disabled = true;

        }
    }


    handleChangedesde(event) {
        this.desde = event.target.value;
        this.dates[0] = this.desde;
        if(this.dates[1] === undefined){
            this.dates[1] = undefined;
        }
        this.resourceObject[this.resource.Id] = this.dates;
        console.log('hijo: ' + this.resourceObject);
        const selectedEvent = new CustomEvent('selected', { detail : this.resourceObject});
        
        this.dispatchEvent(selectedEvent);
    }
    handleChangehasta(event) {
        this.hasta = event.target.value;
        this.dates[1] = this.hasta;
        this.resourceObject[this.resource.Id] = this.dates;
        console.log('hijo: ' + this.resourceObject);
        const selectedEvent = new CustomEvent('selected', { detail : this.resourceObject});

        this.dispatchEvent(selectedEvent);
    }
}