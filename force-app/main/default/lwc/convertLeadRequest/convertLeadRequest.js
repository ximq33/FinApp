import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import convertToLead from '@salesforce/apex/LeadRequestConversionController.convertToLead';

export default class ConvertLeadRequest extends NavigationMixin(LightningElement) {
    @api recordId;

    @api invoke() {
        convertToLead({ requestId: this.recordId })
            .then(newLeadId => {
                this.showToast('Success', 'Request converted successfully', 'success');
                this.navigateToRecord(newLeadId);
            })
            .catch(error => {
                this.showToast('Conversion Error', error.body.message, 'error');
            });
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    } 

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}