import { LightningElement, api, track } from 'lwc';

export default class Resource extends LightningElement {
    @api resource;
    disabled = true;
    disabled2 = false;
    @track
    desde;
    @track
    hasta;


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
        console.log(this.desde)
    }
    handleChangehasta(event) {
        this.hasta = event.target.value;
        console.log(this.hasta)
    }
}