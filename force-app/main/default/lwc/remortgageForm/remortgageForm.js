import { LightningElement } from 'lwc';
import createLeadWithRules from '@salesforce/apex/RemortgageController.createLeadWithRules';

export default class RemortgageForm extends LightningElement {
    isSubmitted = false; 
    errorMessage = '';

    handleSubmit(event) {
    
        event.preventDefault(); 
        
        const fields = event.detail.fields;

        createLeadWithRules({ newLead: fields })
            .then(() => {
                this.isSubmitted = true;
                this.errorMessage = '';
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                console.error('Error while saving: ', error);
            });
    }
}