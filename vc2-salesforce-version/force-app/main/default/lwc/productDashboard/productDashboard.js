import { LightningElement, api, wire } from 'lwc';
import getProductSummary from '@salesforce/apex/EconomyAnalysisController.getProductSummary';
import getCountryProductSummariesByProduct from '@salesforce/apex/EconomyAnalysisController.getCountryProductSummariesByProduct';

const SUB_TABLE_COLUMNS = [
    { label: 'Country Tag', fieldName: 'countryTag', type: 'text', sortable: true },
    { label: 'Country Name', fieldName: 'countryName', type: 'text', sortable: true },
    { label: 'GDP Contribution (£)', fieldName: 'gdpContribution', type: 'currency', sortable: true },
    { label: 'Domestic Supply', fieldName: 'soldDomestic', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }, sortable: true },
    { label: 'Imports (£)', fieldName: 'importValue', type: 'currency', sortable: true },
    { label: 'Exports (£)', fieldName: 'exportValue', type: 'currency', sortable: true }
];

export default class ProductDashboard extends LightningElement {
    @api productEconomyId;
    @api analysisId;

    productData;
    productErrorData;

    countryContributionsData = [];
    countryContributionsErrorData;
    isCountriesLoading = false;

    subSortedBy = 'gdpContribution';
    subSortedDirection = 'desc';

    subTableColumns = SUB_TABLE_COLUMNS;

    @wire(getProductSummary, { analysisId: '$analysisId', productEconomyId: '$productEconomyId' })
    wiredProduct(result) {
        if (result.data) {
            this.productData = result.data;
            this.productErrorData = undefined;
        } else if (result.error) {
            this.productErrorData = result.error;
            this.productData = undefined;
        }
    }

    @wire(getCountryProductSummariesByProduct, { productEconomyId: '$productEconomyId' })
    wiredCountries(result) {
        this.isCountriesLoading = !result.data && !result.error && !!this.productEconomyId;
        if (result.data) {
            this.countryContributionsData = result.data;
            this.countryContributionsErrorData = undefined;
            this.isCountriesLoading = false;
        } else if (result.error) {
            this.countryContributionsErrorData = result.error;
            this.countryContributionsData = [];
            this.isCountriesLoading = false;
        }
    }

    get product() {
        return this.productData;
    }

    get isLoading() {
        return !this.productData && !this.productErrorData && !!this.productEconomyId;
    }

    get error() {
        return !!this.productErrorData;
    }

    get errorMessage() {
        if (!this.productErrorData) return '';
        if (typeof this.productErrorData === 'string') return this.productErrorData;
        if (this.productErrorData.body && this.productErrorData.body.message) return this.productErrorData.body.message;
        return JSON.stringify(this.productErrorData);
    }

    get cardTitle() {
        if (!this.productData) return 'Commodity Detail';
        return `${this.productData.productName || this.productData.productCode} (${this.productData.productCode})`;
    }

    get productCodeDisplay() {
        return this.productData ? (this.productData.productCode || '') : '';
    }

    get inflationBadgeClass() {
        const rate = this.productData ? (this.productData.inflationPercent || 0) : 0;
        return rate > 0 ? 'slds-badge slds-theme_warning' : 'slds-badge slds-theme_success';
    }

    get overproductionBadgeClass() {
        const rate = this.productData ? (this.productData.overproductionPercent || 0) : 0;
        return rate > 100 ? 'slds-badge slds-theme_warning' : 'slds-badge slds-theme_success';
    }

    get countryContributions() {
        if (!this.countryContributionsData) return [];
        let list = [...this.countryContributionsData];

        if (this.subSortedBy) {
            const field = this.subSortedBy;
            const reverse = this.subSortedDirection === 'desc' ? -1 : 1;
            list.sort((a, b) => {
                let valA = a[field] != null ? a[field] : '';
                let valB = b[field] != null ? b[field] : '';
                if (typeof valA === 'string') {
                    valA = valA.toLowerCase();
                    valB = (valB || '').toLowerCase();
                }
                if (valA < valB) return -1 * reverse;
                if (valA > valB) return 1 * reverse;
                return 0;
            });
        }

        return list;
    }

    get hasCountryContributions() {
        return !this.isCountriesLoading && !this.countryContributionsErrorData && this.countryContributions.length > 0;
    }

    get isCountriesEmpty() {
        return !this.isCountriesLoading && !this.countryContributionsErrorData && this.countryContributions.length === 0;
    }

    handleSubSort(event) {
        const { fieldName: sortedBy, sortDirection: sortedDirection } = event.detail;
        this.subSortedBy = sortedBy;
        this.subSortedDirection = sortedDirection;
    }

    handleBackClick() {
        this.dispatchEvent(new CustomEvent('back', {
            bubbles: true,
            composed: true
        }));
    }
}
