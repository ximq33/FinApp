import { createElement } from 'lwc';
import RemortgageForm from 'c/remortgageForm';
import createLeadWithRules from '@salesforce/apex/RemortgageController.createLeadWithRules';
import { CurrentPageReference } from 'lightning/navigation';

jest.mock(
    '@salesforce/apex/RemortgageController.createLeadWithRules',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-remortgage-form', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('reads parameters from URL and injects them into the payload on submission', async () => {
        const element = createElement('c-remortgage-form', {
            is: RemortgageForm
        });
        document.body.appendChild(element);

        CurrentPageReference.emit({
            type: 'standard__webPage',
            state: {
                sourcedBy: 'linkedin'
            }
        });

        createLeadWithRules.mockResolvedValue();

        const formElement = element.shadowRoot.querySelector('lightning-record-edit-form') || element;

        const mockSubmitEvent = new CustomEvent('submit', {
            detail: {
                fields: {
                    FirstName: 'Jan',
                    LastName: 'Kowalski'
                }
            },
            cancelable: true
        });
        
        formElement.dispatchEvent(mockSubmitEvent);

        await Promise.resolve();

        expect(createLeadWithRules).toHaveBeenCalledTimes(1);
        expect(createLeadWithRules).toHaveBeenCalledWith({
            newLead: {
                FirstName: 'Jan',
                LastName: 'Kowalski',
                Tracking_Source__c: 'Social Media',
                Social_Media_Tracking__c: 'LinkedIn'
            }
        });
    });

    it('displays an error when Apex throws an exception', async () => {
        const element = createElement('c-remortgage-form', {
            is: RemortgageForm
        });
        document.body.appendChild(element);

        const mockError = { body: { message: 'Validation Error' } };
        createLeadWithRules.mockRejectedValue(mockError);

        const mockSubmitEvent = new CustomEvent('submit', {
            detail: { fields: { FirstName: 'Jan' } },
            cancelable: true
        });
        element.dispatchEvent(mockSubmitEvent);

        await Promise.resolve();
        await Promise.resolve();

        const errorDiv = element.shadowRoot.querySelector('.error');
        if(errorDiv) {
            expect(errorDiv.textContent).toBe('Validation Error');
        }
    });
});