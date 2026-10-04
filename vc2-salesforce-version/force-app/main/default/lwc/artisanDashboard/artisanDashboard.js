import { LightningElement, api, wire, track } from 'lwc';
import getArtisanSummaries from '@salesforce/apex/EconomyAnalysisController.getArtisanSummaries';

const COLUMNS = [
    { label: 'Artisan Type', fieldName: 'artisanType', type: 'text', sortable: true },
    { label: 'Province ID', fieldName: 'externalProvinceId', type: 'text', sortable: true, initialWidth: 120 },
    { label: 'Country', fieldName: 'countryTag', type: 'text', sortable: true, initialWidth: 100 },
    { label: 'State', fieldName: 'stateCode', type: 'text', sortable: true, initialWidth: 100 },
    { label: 'Spending (£)', fieldName: 'spending', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Income (£)', fieldName: 'income', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'AGDP (£)', fieldName: 'agdp', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Production Qty', fieldName: 'productionQuantity', type: 'number', typeAttributes: { minimumFractionDigits: 4, maximumFractionDigits: 4 }, sortable: true }
];

export default class ArtisanDashboard extends LightningElement {
    @api provinceEconomyId;
    @track searchTerm = '';
    @track sortedBy = 'artisanType';
    @track sortDirection = 'asc';

    artisansData = [];
    columns = COLUMNS;
    error;
    isLoading = true;

    @wire(getArtisanSummaries, { provinceEconomyId: '$provinceEconomyId' })
    wiredArtisans({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.artisansData = data.map((item, index) => ({
                ...item,
                id: item.artisanEconomyId || `${item.artisanType}-${index}`
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.artisansData = [];
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    get filteredArtisans() {
        if (!this.artisansData) return [];
        let filtered = this.artisansData;
        if (this.searchTerm) {
            const term = this.searchTerm.toLowerCase();
            filtered = filtered.filter(a =>
                (a.artisanType && a.artisanType.toLowerCase().includes(term)) ||
                (a.externalProvinceId && a.externalProvinceId.toLowerCase().includes(term)) ||
                (a.countryTag && a.countryTag.toLowerCase().includes(term)) ||
                (a.stateCode && a.stateCode.toLowerCase().includes(term))
            );
        }
        return this.sortData(filtered, this.sortedBy, this.sortDirection);
    }

    get hasArtisans() {
        return this.filteredArtisans.length > 0;
    }

    get totalArtisans() {
        return this.artisansData.length;
    }

    get totalIncome() {
        return this.artisansData.reduce((sum, a) => sum + (a.income || 0), 0);
    }

    get formattedTotalIncome() {
        return `£${this.totalIncome.toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }

    get totalSpending() {
        return this.artisansData.reduce((sum, a) => sum + (a.spending || 0), 0);
    }

    get formattedTotalSpending() {
        return `£${this.totalSpending.toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }

    get totalAgdp() {
        return this.artisansData.reduce((sum, a) => sum + (a.agdp || 0), 0);
    }

    get formattedTotalAgdp() {
        return `£${this.totalAgdp.toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    }

    sortData(data, fieldname, direction) {
        const parseData = [...data];
        const isReverse = direction === 'desc' ? -1 : 1;
        parseData.sort((x, y) => {
            let valX = x[fieldname] ?? '';
            let valY = y[fieldname] ?? '';
            return valX > valY ? 1 * isReverse : valX < valY ? -1 * isReverse : 0;
        });
        return parseData;
    }
}
