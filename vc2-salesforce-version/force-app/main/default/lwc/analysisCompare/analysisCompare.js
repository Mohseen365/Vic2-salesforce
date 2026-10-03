import { LightningElement, api, wire } from 'lwc';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';
import compareAnalyses from '@salesforce/apex/EconomyAnalysisController.compareAnalyses';

const COUNTRY_DELTA_COLUMNS = [
    { label: 'Tag', fieldName: 'countryTag', type: 'text', sortable: true, initialWidth: 80 },
    { label: 'Country Name', fieldName: 'countryName', type: 'text', sortable: true },
    { label: 'Base GDP (£)', fieldName: 'baseGdp', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'GBP' } },
    { label: 'Compare GDP (£)', fieldName: 'compareGdp', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'GBP' } },
    { label: 'Change (£)', fieldName: 'gdpDelta', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'GBP' } },
    { label: 'Change %', fieldName: 'gdpDeltaPercentFormatted', type: 'text', sortable: true, initialWidth: 110 },
    { label: 'Rank Change', fieldName: 'rankDelta', type: 'number', sortable: true, initialWidth: 120 }
];

const PRODUCT_DELTA_COLUMNS = [
    { label: 'Code', fieldName: 'productCode', type: 'text', sortable: true, initialWidth: 110 },
    { label: 'Product Name', fieldName: 'productName', type: 'text', sortable: true },
    { label: 'Base Price (£)', fieldName: 'basePrice', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'GBP', minimumFractionDigits: 2 } },
    { label: 'Compare Price (£)', fieldName: 'comparePrice', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'GBP', minimumFractionDigits: 2 } },
    { label: 'Price Change %', fieldName: 'priceDeltaPercentFormatted', type: 'text', sortable: true, initialWidth: 130 },
    { label: 'Base Supply', fieldName: 'baseSupply', type: 'number', sortable: true, typeAttributes: { maximumFractionDigits: 1 } },
    { label: 'Compare Supply', fieldName: 'compareSupply', type: 'number', sortable: true, typeAttributes: { maximumFractionDigits: 1 } },
    { label: 'Supply Change %', fieldName: 'supplyDeltaPercentFormatted', type: 'text', sortable: true, initialWidth: 140 }
];

export default class AnalysisCompare extends LightningElement {
    @api initialBaseAnalysisId;

    baseAnalysisId;
    compareAnalysisId;

    recentAnalyses = [];
    comparisonResult;
    isLoading = false;
    errorMessage;

    countryDeltaColumns = COUNTRY_DELTA_COLUMNS;
    productDeltaColumns = PRODUCT_DELTA_COLUMNS;

    countrySortedBy = 'absGdpDelta';
    countrySortDirection = 'desc';

    productSortedBy = 'absPriceDelta';
    productSortDirection = 'desc';

    @wire(getRecentAnalyses, { limitCount: 50 })
    wiredRecentAnalyses({ error, data }) {
        if (data) {
            this.recentAnalyses = data;
            if (!this.baseAnalysisId && this.initialBaseAnalysisId) {
                this.baseAnalysisId = this.initialBaseAnalysisId;
            } else if (!this.baseAnalysisId && data.length > 0) {
                this.baseAnalysisId = data[0].Id;
            }
        } else if (error) {
            this.recentAnalyses = [];
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    get recentAnalysisOptions() {
        if (!this.recentAnalyses) return [];
        return this.recentAnalyses.map(a => ({
            label: `${a.Save_File_Name__c || a.Name} (${a.Ingame_Date__c || 'N/A'})`,
            value: a.Id
        }));
    }

    get isIdenticalSelection() {
        return Boolean(
            this.baseAnalysisId &&
            this.compareAnalysisId &&
            this.baseAnalysisId === this.compareAnalysisId
        );
    }

    get hasComparisonData() {
        return Boolean(this.comparisonResult && !this.isIdenticalSelection && !this.errorMessage);
    }

    get isEmptyPrompt() {
        return !this.isLoading && !this.hasComparisonData && !this.errorMessage && !this.isIdenticalSelection;
    }

    get formattedBaseGdp() {
        if (!this.comparisonResult || this.comparisonResult.baseGdp == null) return '£0.00';
        return '£' + Number(this.comparisonResult.baseGdp).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    get formattedCompareGdp() {
        if (!this.comparisonResult || this.comparisonResult.compareGdp == null) return '£0.00';
        return '£' + Number(this.comparisonResult.compareGdp).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    get formattedGdpGrowth() {
        if (!this.comparisonResult || this.comparisonResult.gdpGrowthPercent == null) return '0.00%';
        const val = this.comparisonResult.gdpGrowthPercent;
        const prefix = val > 0 ? '+' : '';
        return `${prefix}${val.toFixed(2)}%`;
    }

    get growthBadgeClass() {
        const val = this.comparisonResult ? this.comparisonResult.gdpGrowthPercent || 0 : 0;
        return val >= 0
            ? 'slds-badge slds-theme_success'
            : 'slds-badge slds-theme_warning';
    }

    get countryDeltaRows() {
        if (!this.comparisonResult || !this.comparisonResult.countryDeltas) return [];
        let rows = this.comparisonResult.countryDeltas.map(c => ({
            ...c,
            gdpDeltaPercentFormatted: (c.gdpDeltaPercent != null ? (c.gdpDeltaPercent > 0 ? '+' : '') + c.gdpDeltaPercent.toFixed(2) : '0.00') + '%',
            absGdpDelta: Math.abs(c.gdpDelta || 0)
        }));

        return this.sortData(rows, this.countrySortedBy, this.countrySortDirection);
    }

    get productDeltaRows() {
        if (!this.comparisonResult || !this.comparisonResult.productDeltas) return [];
        let rows = this.comparisonResult.productDeltas.map(p => ({
            ...p,
            priceDeltaPercentFormatted: (p.priceDeltaPercent != null ? (p.priceDeltaPercent > 0 ? '+' : '') + p.priceDeltaPercent.toFixed(2) : '0.00') + '%',
            supplyDeltaPercentFormatted: (p.supplyDeltaPercent != null ? (p.supplyDeltaPercent > 0 ? '+' : '') + p.supplyDeltaPercent.toFixed(2) : '0.00') + '%',
            absPriceDelta: Math.abs(p.priceDeltaPercent || 0)
        }));

        return this.sortData(rows, this.productSortedBy, this.productSortDirection);
    }

    handleBaseAnalysisChange(event) {
        this.baseAnalysisId = event.detail.value;
        this.fetchComparisonData();
    }

    handleCompareAnalysisChange(event) {
        this.compareAnalysisId = event.detail.value;
        this.fetchComparisonData();
    }

    async fetchComparisonData() {
        if (!this.baseAnalysisId || !this.compareAnalysisId || this.baseAnalysisId === this.compareAnalysisId) {
            this.comparisonResult = undefined;
            return;
        }

        this.isLoading = true;
        this.errorMessage = undefined;

        try {
            const data = await compareAnalyses({
                baseAnalysisId: this.baseAnalysisId,
                compareAnalysisId: this.compareAnalysisId
            });
            this.comparisonResult = data;
        } catch (error) {
            this.comparisonResult = undefined;
            this.errorMessage = this.extractErrorMessage(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleCountrySort(event) {
        this.countrySortedBy = event.detail.fieldName;
        this.countrySortDirection = event.detail.sortDirection;
    }

    handleProductSort(event) {
        this.productSortedBy = event.detail.fieldName;
        this.productSortDirection = event.detail.sortDirection;
    }

    sortData(data, fieldName, direction) {
        const clone = [...data];
        const isAsc = direction === 'asc';
        clone.sort((a, b) => {
            let valA = a[fieldName] != null ? a[fieldName] : '';
            let valB = b[fieldName] != null ? b[fieldName] : '';
            if (typeof valA === 'string') valA = valA.toLowerCase();
            if (typeof valB === 'string') valB = valB.toLowerCase();
            if (valA < valB) return isAsc ? -1 : 1;
            if (valA > valB) return isAsc ? 1 : -1;
            return 0;
        });
        return clone;
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
