import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LEAD_ID from '@salesforce/schema/Lead.Id';
import LEAD_STATUS from '@salesforce/schema/Lead.Status';

export default class ReferLeadAction extends LightningElement {
    @api recordId;

    @api async invoke() {

        const fields = {};
        fields[LEAD_ID.fieldApiName] = this.recordId;
        fields[LEAD_STATUS.fieldApiName] = 'Being Referred';

        const recordInput = { fields };

        try {
        
            await updateRecord(recordInput);
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Lead status updated to Being Referred.',
                    variant: 'success'
                })
            );
        } catch (error) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }
}