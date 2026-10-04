import { LightningElement, api, wire, track } from 'lwc';
import getStateSummaries from '@salesforce/apex/EconomyAnalysisController.getStateSummaries';

const COLUMNS = [
    { label: 'Rank', fieldName: 'gdpRank', type: 'number', sortable: true, initialWidth: 80 },
    { label: 'State Code', fieldName: 'stateCode', type: 'text', sortable: true },
    { label: 'Country', fieldName: 'countryTag', type: 'text', sortable: true, initialWidth: 100 },
    { label: 'Population', fieldName: 'population', type: 'number', sortable: true },
    { label: 'GDP (£)', fieldName: 'gdp', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'GDP / Capita (£)', fieldName: 'gdpPerCapita', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'RGO Income (£)', fieldName: 'rgoIncome', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'FGDP (£)', fieldName: 'fgdp', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'PGDP (£)', fieldName: 'pgdp', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'AGDP (£)', fieldName: 'agdp', type: 'currency', currencyCode: 'GBP', sortable: true },
    { label: 'Factory Employees', fieldName: 'factoryEmployees', type: 'number', sortable: true },
    {
        type: 'button',
        typeAttributes: {
            label: 'Select',
            name: 'select_state',
            title: 'Select State',
            variant: 'neutral'
        },
        initialWidth: 100
    }
];

export default class StateDashboard extends LightningElement {
    @api analysisId;
    @track searchTerm = '';
    @track sortedBy = 'gdpRank';
    @track sortDirection = 'asc';

    statesData = [];
    columns = COLUMNS;
    error;
    isLoading = true;

    @wire(getStateSummaries, { analysisId: '$analysisId' })
    wiredStates({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.statesData = data.map((item, index) => ({
                ...item,
                id: item.stateEconomyId || item.stateCode || `state-${index}`
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.statesData = [];
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    get filteredStates() {
        if (!this.statesData) return [];
        let filtered = this.statesData;
        if (this.searchTerm) {
            const term = this.searchTerm.toLowerCase();
            filtered = filtered.filter(s =>
                (s.stateCode && s.stateCode.toLowerCase().includes(term)) ||
                (s.countryTag && s.countryTag.toLowerCase().includes(term))
            );
        }
        return this.sortData(filtered, this.sortedBy, this.sortDirection);
    }

    get hasStates() {
        return this.filteredStates.length > 0;
    }

    get totalGdp() {
        return this.statesData.reduce((sum, s) => sum + (s.gdp || 0), 0);
    }

    get formattedTotalGdp() {
        return `£${this.totalGdp.toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }

    get totalPopulation() {
        return this.statesData.reduce((sum, s) => sum + (s.population || 0), 0);
    }

    get formattedTotalPopulation() {
        return this.totalPopulation.toLocaleString('en-GB');
    }

    get totalFgdp() {
        return this.statesData.reduce((sum, s) => sum + (s.fgdp || 0), 0);
    }

    get formattedTotalFgdp() {
        return `£${this.totalFgdp.toLocaleString('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }

    get totalEmployees() {
        return this.statesData.reduce((sum, s) => sum + (s.factoryEmployees || 0), 0);
    }

    get formattedTotalEmployees() {
        return this.totalEmployees.toLocaleString('en-GB');
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'select_state') {
            this.dispatchEvent(new CustomEvent('stateselect', {
                detail: {
                    stateEconomyId: row.stateEconomyId,
                    stateCode: row.stateCode,
                    countryTag: row.countryTag
                },
                bubbles: true,
                composed: true
            }));
        }
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
