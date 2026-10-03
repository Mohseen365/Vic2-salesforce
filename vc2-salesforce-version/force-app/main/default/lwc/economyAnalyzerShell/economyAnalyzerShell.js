import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';

export default class EconomyAnalyzerShell extends LightningElement {
    selectedAnalysisId;
    selectedProductEconomyId;
    analysesData = [];
    errorData;
    isLoading = false;
    wiredAnalysesResult;

    @wire(getRecentAnalyses, { limitCount: 50 })
    wiredRecentAnalyses(result) {
        this.wiredAnalysesResult = result;
        this.isLoading = !result.data && !result.error;
        if (result.data) {
            this.analysesData = result.data;
            this.errorData = undefined;
            this.isLoading = false;

            if (this.analysesData.length > 0) {
                const existing = this.analysesData.find(a => a.Id === this.selectedAnalysisId);
                if (!existing) {
                    this.selectedAnalysisId = this.analysesData[0].Id;
                }
            } else {
                this.selectedAnalysisId = undefined;
            }
        } else if (result.error) {
            this.errorData = result.error;
            this.analysesData = [];
            this.selectedAnalysisId = undefined;
            this.isLoading = false;
        }
    }

    handleWatcherStatusChange(event) {
        try {
            const detail = (event && event.detail) ? event.detail : {};
            const status = detail.status;
            if (status === 'COMPLETED' || status === 'REFRESH_REQUESTED') {
                if (this.wiredAnalysesResult) {
                    const p = refreshApex(this.wiredAnalysesResult);
                    if (p && typeof p.catch === 'function') {
                        p.catch(() => {});
                    }
                }
                // Trigger refresh on child header component if present
                const headerComp = this.shadowRoot.querySelector('c-economy-analysis-header');
                if (headerComp && typeof headerComp.handleRefresh === 'function') {
                    const p2 = headerComp.handleRefresh();
                    if (p2 && typeof p2.catch === 'function') {
                        p2.catch(() => {});
                    }
                }
            }
        } catch (e) {
            // Non-blocking in test mocks
        }
    }

    get analysisOptions() {
        return this.analysesData.map(ea => {
            const fileName = ea.Save_File_Name__c || 'Unnamed Analysis';
            const dateStr = ea.Ingame_Date__c ? ` (${ea.Ingame_Date__c})` : '';
            return {
                label: `${fileName}${dateStr}`,
                value: ea.Id
            };
        });
    }

    get hasAnalyses() {
        return this.analysesData && this.analysesData.length > 0;
    }

    handleAnalysisChange(event) {
        this.selectedAnalysisId = event.detail.value;
        this.selectedProductEconomyId = undefined;
    }

    handleProductSelect(event) {
        this.selectedProductEconomyId = event.detail.productEconomyId;
    }

    handleProductBack() {
        this.selectedProductEconomyId = undefined;
    }
}
