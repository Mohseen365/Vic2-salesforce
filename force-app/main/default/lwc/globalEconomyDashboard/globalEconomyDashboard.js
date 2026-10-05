import { LightningElement, api, wire } from 'lwc';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';

const COUNTRY_COLUMNS = [
    { label: 'Rank', fieldName: 'gdpRank', type: 'number', initialWidth: 80 },
    { label: 'Tag', fieldName: 'countryTag', type: 'text', initialWidth: 80 },
    { label: 'Name', fieldName: 'countryName', type: 'text' },
    { label: 'GDP (£)', fieldName: 'gdp', type: 'currency', typeAttributes: { currencyCode: 'GBP' } },
    { label: 'GDP Share %', fieldName: 'gdpSharePercentFormatted', type: 'text', initialWidth: 110 },
    { label: 'GDP / 100k (£)', fieldName: 'gdpPerCapita', type: 'currency', typeAttributes: { currencyCode: 'GBP' } },
    {
        type: 'button',
        initialWidth: 90,
        typeAttributes: {
            label: 'View',
            name: 'view_country',
            title: 'Inspect Country Explorer',
            variant: 'neutral'
        }
    }
];

const PRODUCT_COLUMNS = [
    { label: 'Code', fieldName: 'productCode', type: 'text', initialWidth: 110 },
    { label: 'Name', fieldName: 'productName', type: 'text' },
    { label: 'Price (£)', fieldName: 'price', type: 'currency', typeAttributes: { currencyCode: 'GBP', minimumFractionDigits: 2 } },
    { label: 'World Supply', fieldName: 'totalWorldSupply', type: 'number', typeAttributes: { maximumFractionDigits: 1 } },
    { label: 'Real Demand', fieldName: 'realDemand', type: 'number', typeAttributes: { maximumFractionDigits: 1 } },
    { label: 'Inflation %', fieldName: 'inflationPercentFormatted', type: 'text', initialWidth: 110 },
    {
        type: 'button',
        initialWidth: 90,
        typeAttributes: {
            label: 'View',
            name: 'view_product',
            title: 'Inspect Product Market',
            variant: 'neutral'
        }
    }
];

export default class GlobalEconomyDashboard extends LightningElement {
    @api analysisId;

    analysisSummary;
    countrySummaries = [];
    productSummaries = [];

    countryColumns = COUNTRY_COLUMNS;
    productColumns = PRODUCT_COLUMNS;

    errorMessage;
    wiredSummaryResult;
    wiredCountriesResult;
    wiredProductsResult;

    @wire(getAnalysisSummary, { analysisId: '$analysisId' })
    wiredAnalysisSummary(result) {
        this.wiredSummaryResult = result;
        const { data, error } = result;
        if (data) {
            this.analysisSummary = data;
            this.errorMessage = undefined;
        } else if (error) {
            this.analysisSummary = undefined;
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    @wire(getCountrySummaries, { analysisId: '$analysisId' })
    wiredCountrySummaries(result) {
        this.wiredCountriesResult = result;
        const { data, error } = result;
        if (data) {
            this.countrySummaries = data;
        } else if (error) {
            this.countrySummaries = [];
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    @wire(getProductSummaries, { analysisId: '$analysisId' })
    wiredProductSummaries(result) {
        this.wiredProductsResult = result;
        const { data, error } = result;
        if (data) {
            this.productSummaries = data;
        } else if (error) {
            this.productSummaries = [];
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    get isLoading() {
        return Boolean(
            this.analysisId &&
            !this.analysisSummary &&
            !this.errorMessage
        );
    }

    get hasData() {
        return Boolean(this.analysisSummary && !this.errorMessage);
    }

    get isEmpty() {
        return !this.analysisId || (!this.isLoading && !this.hasData && !this.errorMessage);
    }

    get isStaleOrPending() {
        if (!this.analysisSummary) return false;
        const status = this.analysisSummary.importStatus;
        return status === 'PROCESSING' || status === 'CALCULATING' || status === 'RECEIVED';
    }

    get formattedGdp() {
        if (!this.analysisSummary || this.analysisSummary.totalWorldGdp == null) return '£0.00';
        return '£' + Number(this.analysisSummary.totalWorldGdp).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    get formattedPopulation() {
        if (!this.analysisSummary || this.analysisSummary.totalWorldPopulation == null) return '0';
        return Number(this.analysisSummary.totalWorldPopulation).toLocaleString('en-US');
    }

    get formattedImports() {
        if (!this.analysisSummary || this.analysisSummary.totalWorldImports == null) return '£0.00';
        return '£' + Number(this.analysisSummary.totalWorldImports).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    get formattedExports() {
        if (!this.analysisSummary || this.analysisSummary.totalWorldExports == null) return '£0.00';
        return '£' + Number(this.analysisSummary.totalWorldExports).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    get topGreatPower() {
        if (!this.countrySummaries || !this.countrySummaries.length) return 'N/A';
        const sorted = [...this.countrySummaries].sort((a, b) => (b.gdp || 0) - (a.gdp || 0));
        return sorted[0] ? `${sorted[0].countryTag} (${sorted[0].countryName})` : 'N/A';
    }

    get productsCount() {
        return this.productSummaries ? this.productSummaries.length : 0;
    }

    get topCountries() {
        if (!this.countrySummaries) return [];
        return [...this.countrySummaries]
            .sort((a, b) => (b.gdp || 0) - (a.gdp || 0))
            .slice(0, 10)
            .map(c => {
                let shareVal = c.gdpShare != null ? c.gdpShare : 0.0;
                if (shareVal > 0 && shareVal <= 1) shareVal = shareVal * 100;
                return {
                    ...c,
                    gdpSharePercentFormatted: shareVal.toFixed(2) + '%'
                };
            });
    }

    get topProducts() {
        if (!this.productSummaries) return [];
        return [...this.productSummaries]
            .sort((a, b) => (b.totalWorldSupply || 0) - (a.totalWorldSupply || 0))
            .slice(0, 10)
            .map(p => ({
                ...p,
                inflationPercentFormatted: (p.inflationPercent != null ? p.inflationPercent.toFixed(2) : '0.00') + '%'
            }));
    }

    handleCountryRowAction(event) {
        const row = event.detail.row;
        this.dispatchEvent(new CustomEvent('countryselect', {
            detail: {
                countryEconomyId: row.countryEconomyId,
                countryTag: row.countryTag
            },
            bubbles: true,
            composed: true
        }));
    }

    handleProductRowAction(event) {
        const row = event.detail.row;
        this.dispatchEvent(new CustomEvent('productselect', {
            detail: {
                productEconomyId: row.productEconomyId,
                productCode: row.productCode
            },
            bubbles: true,
            composed: true
        }));
    }

    extractErrorMessage(error) {
        if (!error) return 'An unexpected error occurred.';
        if (typeof error === 'string') return error;

        let errObj = error;
        while (errObj && errObj.body) {
            errObj = errObj.body;
        }

        if (Array.isArray(errObj) && errObj.length > 0) {
            return errObj.map((e) => (typeof e === 'object' ? e.message || JSON.stringify(e) : String(e))).join(', ');
        } else if (errObj && typeof errObj === 'object' && errObj.message) {
            return errObj.message;
        } else if (error.message) {
            return error.message;
        }
        return 'An unexpected error occurred.';
    }
}
