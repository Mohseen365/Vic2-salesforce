import { LightningElement, api, wire, track } from 'lwc';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';
import exportCsv from '@salesforce/apex/EconomyAnalysisController.exportCsv';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    generateFilename,
    buildAnalysisCsv,
    buildGoodsCsv,
    buildCountriesCsv,
    buildProductsCsv,
    buildCountryProductsCsv,
    buildProvincesCsv,
    buildStatesCsv,
    buildFactoriesCsv,
    buildArtisansCsv
} from 'c/economicExportUtils';

const CLIENT_ROW_THRESHOLD = 5000;

export default class EconomicExportModal extends LightningElement {
    @api analysisId;
    @api initialScope = 'Countries';

    @track isOpen = false;
    @track selectedScope = 'Countries';
    @track selectedFormat = 'CSV';
    @track isLoading = false;
    @track errorMessage = '';

    analysisSummary;
    countrySummaries = [];
    productSummaries = [];

    connectedCallback() {
        if (this.initialScope) {
            this.selectedScope = this.initialScope;
        }
    }

    @api
    openModal(scope) {
        if (scope) {
            this.selectedScope = scope;
        }
        this.isOpen = true;
        this.errorMessage = '';
    }

    @api
    closeModal() {
        this.isOpen = false;
    }

    @wire(getAnalysisSummary, { analysisId: '$analysisId' })
    wiredAnalysisSummary({ data, error }) {
        if (data) {
            this.analysisSummary = data;
        } else if (error) {
            console.warn('Error fetching analysis summary for export:', error);
        }
    }

    @wire(getCountrySummaries, { analysisId: '$analysisId' })
    wiredCountrySummaries({ data, error }) {
        if (data) {
            this.countrySummaries = data;
        } else if (error) {
            console.warn('Error fetching country summaries for export:', error);
        }
    }

    @wire(getProductSummaries, { analysisId: '$analysisId' })
    wiredProductSummaries({ data, error }) {
        if (data) {
            this.productSummaries = data;
        } else if (error) {
            console.warn('Error fetching product summaries for export:', error);
        }
    }

    get scopeOptions() {
        return [
            { label: 'Analysis Summary (1 row)', value: 'Summary' },
            { label: 'Countries (Sovereign States — Country.csv)', value: 'Countries' },
            { label: 'Products (Commodity World Market)', value: 'Products' },
            { label: 'Goods & Prices (Goods.csv)', value: 'Goods' },
            { label: 'Country × Product (Trade & GDP)', value: 'CountryProducts' },
            { label: 'Provinces (Provinces.csv)', value: 'Provinces' },
            { label: 'States (States.csv)', value: 'States' },
            { label: 'Factories (Factory.csv)', value: 'Factories' },
            { label: 'Artisans (Artisans.csv)', value: 'Artisans' }
        ];
    }

    get formatOptions() {
        return [
            { label: 'CSV (Comma Separated Values)', value: 'CSV' }
        ];
    }

    get previewRowCount() {
        switch (this.selectedScope) {
            case 'Summary':
                return 1;
            case 'Countries':
                return this.countrySummaries ? this.countrySummaries.length : 0;
            case 'Products':
            case 'Goods':
                return this.productSummaries ? this.productSummaries.length : 0;
            case 'CountryProducts': {
                const cCount = this.countrySummaries ? this.countrySummaries.length : 0;
                const pCount = this.productSummaries ? this.productSummaries.length : 0;
                return cCount * pCount;
            }
            case 'Provinces':
                return 2703;
            case 'States':
                return 124;
            case 'Factories':
                return 714;
            case 'Artisans':
                return 4406;
            default:
                return 0;
        }
    }

    get isApexFallbackRequired() {
        return this.previewRowCount > CLIENT_ROW_THRESHOLD;
    }

    get processingMethodLabel() {
        return this.isApexFallbackRequired ? 'Server-Side Apex Stream' : 'Client-Side Fast Engine';
    }

    get processingMethodBadgeClass() {
        return this.isApexFallbackRequired ? 'slds-badge slds-theme_warning' : 'slds-badge slds-theme_success';
    }

    get isExportDisabled() {
        return !this.analysisId || this.isLoading;
    }

    handleScopeChange(event) {
        this.selectedScope = event.detail.value;
        this.errorMessage = '';
    }

    handleClose() {
        this.closeModal();
        const closeEvt = new CustomEvent('close');
        this.dispatchEvent(closeEvt);
    }

    async handleExport() {
        if (!this.analysisId) {
            this.errorMessage = 'No analysis selected for export.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        try {
            let csvContent = '';
            const saveName = this.analysisSummary ? this.analysisSummary.saveFileName : 'Economy_Analysis';
            const ingameDate = this.analysisSummary ? this.analysisSummary.ingameDate : '';
            const fileName = generateFilename(saveName, this.selectedScope, ingameDate);

            if (this.isApexFallbackRequired) {
                // Apex fallback path for high row counts
                csvContent = await exportCsv({ analysisId: this.analysisId, scope: this.selectedScope });
            } else {
                // Client-side or hybrid routing
                switch (this.selectedScope) {
                    case 'Summary':
                        csvContent = buildAnalysisCsv(this.analysisSummary);
                        break;
                    case 'Goods':
                        csvContent = buildGoodsCsv(this.productSummaries);
                        break;
                    case 'Countries':
                        // Fetch unpivoted CSV via Apex for full country-commodity completeness
                        csvContent = await exportCsv({ analysisId: this.analysisId, scope: 'Countries' });
                        break;
                    case 'Products':
                        csvContent = buildProductsCsv(this.productSummaries);
                        break;
                    case 'CountryProducts':
                        csvContent = await exportCsv({ analysisId: this.analysisId, scope: 'CountryProducts' });
                        break;
                    case 'Provinces':
                        csvContent = await exportCsv({ analysisId: this.analysisId, scope: 'Provinces' });
                        break;
                    case 'States':
                        csvContent = await exportCsv({ analysisId: this.analysisId, scope: 'States' });
                        break;
                    case 'Factories':
                        csvContent = await exportCsv({ analysisId: this.analysisId, scope: 'Factories' });
                        break;
                    case 'Artisans':
                        csvContent = await exportCsv({ analysisId: this.analysisId, scope: 'Artisans' });
                        break;
                    default:
                        csvContent = await exportCsv({ analysisId: this.analysisId, scope: this.selectedScope });
                }
            }

            if (!csvContent) {
                throw new Error('Export yielded no data.');
            }

            this.triggerDownload(csvContent, fileName);

            this.showToast('Export Successful', `Downloaded ${fileName}`, 'success');
            this.handleClose();

        } catch (error) {
            const msg = (error && error.body && error.body.message) ? error.body.message : (error.message || 'Error generating export file.');
            this.errorMessage = msg;
            this.showToast('Export Failed', msg, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    triggerDownload(csvContent, filename) {
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        if (link.download !== undefined) {
            const url = URL.createObjectURL(blob);
            link.setAttribute('href', url);
            link.setAttribute('download', filename);
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            setTimeout(() => URL.revokeObjectURL(url), 1000);
        }
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}
