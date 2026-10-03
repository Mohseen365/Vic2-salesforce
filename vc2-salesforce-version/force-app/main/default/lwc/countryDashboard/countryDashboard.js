import { LightningElement, api, wire } from 'lwc';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getCountryProductSummaries from '@salesforce/apex/EconomyAnalysisController.getCountryProductSummaries';

const COLUMNS = [
    { label: 'Commodity', fieldName: 'productCode', type: 'text', sortable: true },
    { label: 'Domestic Supply', fieldName: 'soldDomestic', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }, sortable: true },
    { label: 'Imports (£)', fieldName: 'importValue', type: 'currency', sortable: true },
    { label: 'Exports (£)', fieldName: 'exportValue', type: 'currency', sortable: true },
    { label: 'GDP Contribution (£)', fieldName: 'gdpContribution', type: 'currency', sortable: true }
];

export default class CountryDashboard extends LightningElement {
    @api analysisId;

    selectedCountryEconomyId;
    searchKey = '';
    sortedBy = 'productCode';
    sortedDirection = 'asc';

    countriesData = [];
    countriesErrorData;
    isCountriesLoading = false;

    productsData = [];
    productsErrorData;
    isProductsLoading = false;

    columns = COLUMNS;

    @wire(getCountrySummaries, { analysisId: '$analysisId' })
    wiredCountries(result) {
        this.isCountriesLoading = !result.data && !result.error && !!this.analysisId;
        if (result.data) {
            this.countriesData = result.data;
            this.countriesErrorData = undefined;
            this.isCountriesLoading = false;

            // Auto select first country or existing selection
            if (this.countriesData.length > 0) {
                const existing = this.countriesData.find(c => c.countryEconomyId === this.selectedCountryEconomyId);
                if (!existing) {
                    this.selectedCountryEconomyId = this.countriesData[0].countryEconomyId;
                }
            } else {
                this.selectedCountryEconomyId = undefined;
            }
        } else if (result.error) {
            this.countriesErrorData = result.error;
            this.countriesData = [];
            this.selectedCountryEconomyId = undefined;
            this.isCountriesLoading = false;
        }
    }

    @wire(getCountryProductSummaries, { countryEconomyId: '$selectedCountryEconomyId' })
    wiredProducts(result) {
        this.isProductsLoading = !result.data && !result.error && !!this.selectedCountryEconomyId;
        if (result.data) {
            this.productsData = result.data;
            this.productsErrorData = undefined;
            this.isProductsLoading = false;
        } else if (result.error) {
            this.productsErrorData = result.error;
            this.productsData = [];
            this.isProductsLoading = false;
        }
    }

    get countryOptions() {
        return this.countriesData.map(c => {
            const label = (c.countryName && c.countryName !== c.countryTag)
                ? `${c.countryTag} - ${c.countryName}`
                : c.countryTag;
            return {
                label: label,
                value: c.countryEconomyId
            };
        });
    }

    get selectedCountry() {
        if (!this.selectedCountryEconomyId || !this.countriesData) return null;
        return this.countriesData.find(c => c.countryEconomyId === this.selectedCountryEconomyId) || null;
    }

    get unemploymentRateDecimal() {
        if (!this.selectedCountry) return 0.0;
        // If unemploymentRate is 0.042 (decimal), percent-fixed expects 4.2
        const rate = this.selectedCountry.unemploymentRate || 0.0;
        return rate <= 1.0 ? rate * 100.0 : rate;
    }

    get countriesError() {
        return !!this.countriesErrorData;
    }

    get countriesErrorMessage() {
        if (!this.countriesErrorData) return '';
        if (typeof this.countriesErrorData === 'string') return this.countriesErrorData;
        if (this.countriesErrorData.body && this.countriesErrorData.body.message) return this.countriesErrorData.body.message;
        return JSON.stringify(this.countriesErrorData);
    }

    get isCountriesEmpty() {
        return !this.isCountriesLoading && !this.countriesErrorData && this.countriesData.length === 0;
    }

    get productsError() {
        return !!this.productsErrorData;
    }

    get productsErrorMessage() {
        if (!this.productsErrorData) return '';
        if (typeof this.productsErrorData === 'string') return this.productsErrorData;
        if (this.productsErrorData.body && this.productsErrorData.body.message) return this.productsErrorData.body.message;
        return JSON.stringify(this.productsErrorData);
    }

    get filteredProducts() {
        if (!this.productsData) return [];
        let list = [...this.productsData];

        if (this.searchKey && this.searchKey.trim() !== '') {
            const query = this.searchKey.trim().toLowerCase();
            list = list.filter(p => {
                const code = (p.productCode || '').toLowerCase();
                const name = (p.productName || '').toLowerCase();
                return code.includes(query) || name.includes(query);
            });
        }

        // Apply Sorting
        if (this.sortedBy) {
            const field = this.sortedBy;
            const reverse = this.sortedDirection === 'desc' ? -1 : 1;
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

    get hasProducts() {
        return !this.isProductsLoading && !this.productsErrorData && this.filteredProducts.length > 0;
    }

    get isProductsEmpty() {
        return !this.isProductsLoading && !this.productsErrorData && this.filteredProducts.length === 0;
    }

    handleCountryChange(event) {
        this.selectedCountryEconomyId = event.detail.value;
        this.searchKey = '';
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    handleOpenExport() {
        const evt = new CustomEvent('openexport', {
            detail: { scope: 'Countries' },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(evt);
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection: sortedDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortedDirection;
    }
}
