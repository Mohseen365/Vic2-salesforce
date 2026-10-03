import { LightningElement, api, wire } from 'lwc';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import { refreshApex } from '@salesforce/apex';

export default class EconomyAnalysisHeader extends LightningElement {
    @api analysisId;

    wiredSummaryResult;
    summaryData;
    errorData;

    @wire(getAnalysisSummary, { analysisId: '$analysisId' })
    wiredSummary(result) {
        this.wiredSummaryResult = result;
        if (result.data) {
            this.summaryData = result.data;
            this.errorData = undefined;
        } else if (result.error) {
            this.errorData = result.error;
            this.summaryData = undefined;
        }
    }

    get summary() {
        return this.summaryData;
    }

    get error() {
        return this.errorData;
    }

    get isLoading() {
        return !this.summaryData && !this.errorData && !!this.analysisId;
    }

    get errorMessage() {
        if (!this.errorData) return '';
        if (typeof this.errorData === 'string') return this.errorData;
        if (this.errorData.body && this.errorData.body.message) return this.errorData.body.message;
        if (this.errorData.message) return this.errorData.message;
        return JSON.stringify(this.errorData);
    }

    get saveFileNameDisplay() {
        return this.summaryData ? (this.summaryData.saveFileName || 'Unnamed Analysis') : 'Economy Analysis Header';
    }

    get ingameDateDisplay() {
        return this.summaryData ? this.summaryData.ingameDate : '';
    }

    get playerCountryTagDisplay() {
        return this.summaryData ? this.summaryData.playerCountryTag : '';
    }

    get statusDisplay() {
        return this.summaryData ? this.summaryData.importStatus : '';
    }

    get statusBadgeClass() {
        const status = this.summaryData ? this.summaryData.importStatus : '';
        switch (status) {
            case 'COMPLETED':
                return 'slds-badge slds-theme_success';
            case 'PROCESSING':
            case 'CALCULATING':
                return 'slds-badge slds-theme_warning';
            case 'FAILED':
                return 'slds-badge slds-theme_error';
            case 'RECEIVED':
            default:
                return 'slds-badge slds-theme_info';
        }
    }

    get isFailed() {
        return this.summaryData && this.summaryData.importStatus === 'FAILED';
    }

    get isPending() {
        return this.summaryData && (this.summaryData.importStatus === 'PROCESSING' || this.summaryData.importStatus === 'CALCULATING' || this.summaryData.importStatus === 'RECEIVED');
    }

    get showRefreshButton() {
        return !!this.summaryData || !!this.errorData;
    }

    get diagnosticMessage() {
        return (this.summaryData && this.summaryData.importDiagnosticMessage)
            ? this.summaryData.importDiagnosticMessage
            : 'An error occurred during import or calculation processing.';
    }

    @api
    handleRefresh() {
        if (this.wiredSummaryResult) {
            try {
                const p = refreshApex(this.wiredSummaryResult);
                if (p && typeof p.catch === 'function') {
                    p.catch(() => {});
                }
                return p;
            } catch (e) {
                // Non-blocking in test mocks
            }
        }
        return Promise.resolve();
    }
}
