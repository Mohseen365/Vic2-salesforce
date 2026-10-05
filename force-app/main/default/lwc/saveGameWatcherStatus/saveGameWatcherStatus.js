import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const CHANNEL_NAME = '/event/Economy_Import_Event__e';

export default class SaveGameWatcherStatus extends LightningElement {
    @api analysisId;

    @track currentStatus = 'COMPLETED';
    @track diagnosticMessage = '';
    @track isEmpUnavailable = false;

    subscription = {};

    connectedCallback() {
        this.registerEmpApiErrorHandler();
        this.subscribeToPlatformEvent();
    }

    disconnectedCallback() {
        this.unsubscribeFromPlatformEvent();
    }

    registerEmpApiErrorHandler() {
        onError((error) => {
            console.warn('empApi error encountered in saveGameWatcherStatus:', JSON.stringify(error));
            this.isEmpUnavailable = true;
        });
    }

    subscribeToPlatformEvent() {
        // empApi subscribe callback
        const messageCallback = (response) => {
            if (!response || !response.data || !response.data.payload) {
                return;
            }

            const payload = response.data.payload;
            const eventAnalysisId = payload.Analysis_Id__c;
            const status = payload.Status__c;
            const diagMsg = payload.Diagnostic_Message__c;

            // Filter events by active analysisId if set, or accept if matching
            if (this.analysisId && eventAnalysisId && this.analysisId !== eventAnalysisId) {
                return;
            }

            this.currentStatus = status || 'COMPLETED';
            this.diagnosticMessage = diagMsg || '';

            // Emit custom event to notify parent shell/components
            const statusChangeEvent = new CustomEvent('statuschange', {
                detail: {
                    analysisId: eventAnalysisId || this.analysisId,
                    status: this.currentStatus,
                    diagnosticMessage: this.diagnosticMessage
                },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(statusChangeEvent);

            // Toast notifications on COMPLETED and FAILED
            if (this.currentStatus === 'COMPLETED') {
                this.showToast('Import Complete', 'Economy analysis recalculation has finished successfully.', 'success');
            } else if (this.currentStatus === 'FAILED') {
                const msg = this.diagnosticMessage ? `Error: ${this.diagnosticMessage}` : 'An error occurred during save game processing.';
                this.showToast('Import Failed', msg, 'error');
            }
        };

        subscribe(CHANNEL_NAME, -1, messageCallback)
            .then((res) => {
                this.subscription = res;
                this.isEmpUnavailable = false;
            })
            .catch((err) => {
                console.warn('Unable to subscribe to empApi channel:', err);
                this.isEmpUnavailable = true;
            });
    }

    unsubscribeFromPlatformEvent() {
        if (this.subscription && this.subscription.subscription) {
            unsubscribe(this.subscription, (response) => {
                console.log('Unsubscribed from empApi channel:', response);
            });
        }
    }

    handleManualRefresh() {
        const refreshEvent = new CustomEvent('statuschange', {
            detail: {
                analysisId: this.analysisId,
                status: 'REFRESH_REQUESTED',
                diagnosticMessage: 'User requested manual refresh'
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(refreshEvent);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    get badgeClass() {
        switch (this.currentStatus) {
            case 'RECEIVED':
                return 'slds-badge slds-theme_info';
            case 'PROCESSING':
            case 'CALCULATING':
                return 'slds-badge slds-theme_warning';
            case 'COMPLETED':
                return 'slds-badge slds-theme_success';
            case 'FAILED':
                return 'slds-badge slds-theme_error';
            default:
                return 'slds-badge';
        }
    }

    get badgeIcon() {
        switch (this.currentStatus) {
            case 'RECEIVED':
                return 'utility:download';
            case 'PROCESSING':
            case 'CALCULATING':
                return 'utility:sync';
            case 'COMPLETED':
                return 'utility:success';
            case 'FAILED':
                return 'utility:error';
            default:
                return 'utility:info';
        }
    }

    get badgeLabel() {
        return this.currentStatus ? this.currentStatus : 'UNKNOWN';
    }

    get badgeTooltip() {
        if (this.currentStatus === 'FAILED' && this.diagnosticMessage) {
            return `Failed: ${this.diagnosticMessage}`;
        }
        return `Import Status: ${this.badgeLabel}`;
    }
}
