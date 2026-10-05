import { LightningElement, api, wire } from 'lwc';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';

const COLUMNS = [
    {
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'productCode' },
            name: 'view_product',
            variant: 'base'
        },
        label: 'Product Code',
        fieldName: 'productCode',
        sortable: true
    },
    { label: 'Product Name', fieldName: 'productName', type: 'text', sortable: true },
    { label: 'Price (£)', fieldName: 'price', type: 'currency', sortable: true },
    { label: 'Base Price (£)', fieldName: 'basePrice', type: 'currency', sortable: true },
    { label: 'Total World Supply', fieldName: 'totalWorldSupply', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }, sortable: true },
    { label: 'Real Demand', fieldName: 'realDemand', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }, sortable: true },
    { label: 'Max Demand', fieldName: 'maxDemand', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }, sortable: true },
    { label: 'Inflation %', fieldName: 'inflationPercent', type: 'number', typeAttributes: { minimumFractionDigits: 1, maximumFractionDigits: 1 }, sortable: true },
    { label: 'Overproduced %', fieldName: 'overproductionPercent', type: 'number', typeAttributes: { minimumFractionDigits: 1, maximumFractionDigits: 1 }, sortable: true }
];

export default class ProductListView extends LightningElement {
    @api analysisId;

    productsData;
    errorData;

    searchKey = '';
    sortedBy = 'productCode';
    sortedDirection = 'asc';

    columns = COLUMNS;

    @wire(getProductSummaries, { analysisId: '$analysisId' })
    wiredProducts(result) {
        if (result.data) {
            this.productsData = result.data;
            this.errorData = undefined;
        } else if (result.error) {
            this.errorData = result.error;
            this.productsData = undefined;
        }
    }

    get isLoading() {
        return !this.productsData && !this.errorData && !!this.analysisId;
    }

    get error() {
        return !!this.errorData;
    }

    get errorMessage() {
        if (!this.errorData) return '';
        if (typeof this.errorData === 'string') return this.errorData;
        if (this.errorData.body && this.errorData.body.message) return this.errorData.body.message;
        return JSON.stringify(this.errorData);
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
        return !this.isLoading && !this.errorData && this.filteredProducts.length > 0;
    }

    get isEmpty() {
        return !this.isLoading && !this.errorData && this.filteredProducts.length === 0;
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection: sortedDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortedDirection;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view_product' && row && row.productEconomyId) {
            this.dispatchEvent(new CustomEvent('productselect', {
                detail: {
                    productEconomyId: row.productEconomyId,
                    productCode: row.productCode
                },
                bubbles: true,
                composed: true
            }));
        }
    }
}
