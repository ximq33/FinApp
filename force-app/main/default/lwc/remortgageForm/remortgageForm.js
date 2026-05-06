import { LightningElement, track } from 'lwc';

export default class RemortgageForm extends LightningElement {

    @track firstName = '';
    @track loanAmount = 0;

    
    handleInputChange(event) {
        const fieldName = event.target.name;
        const value = event.target.value;

        if (fieldName === 'firstName') {
            this.firstName = value;
        } else if (fieldName === 'loanAmount') {
            this.loanAmount = value;
        }
    }

    handleButtonClick() {
        alert('Cześć ' + this.firstName + '! Chcesz pożyczyć: ' + this.loanAmount);
    }
}