import { LightningElement, api, wire, track } from 'lwc';
import getFactorySummaries from '@salesforce/apex/EconomyAnalysisController.getFactorySummaries';

const COLUMNS = [
    { label: 'Building Type', fieldName: 'buildingType', type: 'text', sortable: true },
    { label: 'State', fieldName: 'stateCode', type: 'text', sortable: true, initialWidth: 100 },
    { label: 'Country', fieldName: 'countryTag', type: 'text', sortable: true, initialWidth: 100 },
    { label: 'Level', fieldName: 'level', type: 'number', sortable: true, initialWidth: 80 },
    { label: 'Employees', fieldName: 'employees', type: 'number', sortable: true },
    { label: 'Output Qty', fieldName: 'outputQuantity', type: 'number', typeAttributes: { minimumFractionDigits: 4, maximumFractionDigits: 4 }, sortable: true },
    { label: 'Unsold Qty', fieldName: 'unsoldQuantity', type: 'number', typeAttributes: { minimumFractionDigits: 4, maximumFractionDigits: 4 }, sortable: true },
    { label: 'Revenue (£)', fieldName: 'revenue', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Input Cost (£)', fieldName: 'inputCost', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Wages (£)', fieldName: 'wagesPaid', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Profit (£)', fieldName: 'profit', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Factory GDP (£)', fieldName: 'factoryGdp', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Productivity', fieldName: 'productivity', type: 'number', typeAttributes: { minimumFractionDigits: 4, maximumFractionDigits: 4 }, sortable: true }
];

export default class FactoryDashboard extends LightningElement {
    @api stateEconomyId;
    @track searchTerm = '';
    @track sortedBy = 'buildingType';
    @track sortDirection = 'asc';

    factoriesData = [];
    columns = COLUMNS;
    error;
    isLoading = true;

    @wire(getFactorySummaries, { stateEconomyId: '$stateEconomyId' })
    wiredFactories({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.factoriesData = data.map((item, index) => ({
                ...item,
                id: item.factoryEconomyId || `${item.buildingType}-${index}`
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.factoriesData = [];
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    get filteredFactories() {
        if (!this.factoriesData) return [];
        let filtered = this.factoriesData;
        if (this.searchTerm) {
            const term = this.searchTerm.toLowerCase();
            filtered = filtered.filter(f =>
                (f.buildingType && f.buildingType.toLowerCase().includes(term)) ||
                (f.stateCode && f.stateCode.toLowerCase().includes(term)) ||
                (f.countryTag && f.countryTag.toLowerCase().includes(term))
            );
        }
        return this.sortData(filtered, this.sortedBy, this.sortDirection);
    }

    get hasFactories() {
        return this.filteredFactories.length > 0;
    }

    get totalFactories() {
        return this.factoriesData.length;
    }

    get totalEmployees() {
        return this.factoriesData.reduce((sum, f) => sum + (f.employees || 0), 0);
    }

    get formattedTotalEmployees() {
        return this.totalEmployees.toLocaleString('en-GB');
    }

    get totalFactoryGdp() {
        return this.factoriesData.reduce((sum, f) => sum + (f.factoryGdp || 0), 0);
    }

    get formattedTotalFactoryGdp() {
        return `£${this.totalFactoryGdp.toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }

    get totalProfit() {
        return this.factoriesData.reduce((sum, f) => sum + (f.profit || 0), 0);
    }

    get formattedTotalProfit() {
        return `£${this.totalProfit.toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
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
