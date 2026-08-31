import { LightningElement, wire, track } from 'lwc';
import createLeadWithRules from '@salesforce/apex/RemortgageController.createLeadWithRules';
import { CurrentPageReference } from 'lightning/navigation';

export default class RemortgageForm extends LightningElement {
    isSubmitted = false; 
    errorMessage = '';
    @track trackingSource = null;
    @track socialMediaTracking = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state) {
            const sourcedBy = currentPageReference.state.sourcedBy;
        
            if (sourcedBy) {
                this.mapTrackingValues(sourcedBy);
            }
        }
    }

    mapTrackingValues(sourcedByValue) {
        switch (sourcedByValue) {
            case 'bankPartner':
                this.trackingSource = 'Bank Partner';
                this.socialMediaTracking = null;
                break;
            case 'mortgagePartner':
                this.trackingSource = 'Mortgage Partner';
                this.socialMediaTracking = null;
                break;
            case 'linkedin':
                this.trackingSource = 'Social Media';
                this.socialMediaTracking = 'LinkedIn';
                break;
            default:
                this.trackingSource = null;
                this.socialMediaTracking = null;
        }
        
        console.log('Tracking Source:', this.trackingSource);
        console.log('Social Media:', this.socialMediaTracking);
    }

    // TODO Custom metadata

handleSubmit(event) {
        event.preventDefault(); 
        
        const fields = { ...event.detail.fields };

        if (this.trackingSource) {
            fields.Tracking_Source__c = this.trackingSource;
        }
        if (this.socialMediaTracking) {
            fields.Social_Media_Tracking__c = this.socialMediaTracking;
        }

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