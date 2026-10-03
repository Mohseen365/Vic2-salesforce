import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import ProductListView from 'c/productListView';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';

const mockGetProductSummariesAdapter = registerApexTestWireAdapter(getProductSummaries);

const MOCK_PRODUCTS = [
    {
        productEconomyId: 'p00000000000001AAA',
        productCode: 'small_arms',
        productName: 'Small Arms',
        price: 12.0,
        basePrice: 10.0,
        totalWorldSupply: 100.0,
        realDemand: 80.0,
        maxDemand: 120.0,
        inflationPercent: 20.0,
        overproductionPercent: 125.0
    },
    {
        productEconomyId: 'p00000000000002AAA',
        productCode: 'grain',
        productName: 'Grain',
        price: 2.5,
        basePrice: 2.0,
        totalWorldSupply: 5000.0,
        realDemand: 4800.0,
        maxDemand: 6000.0,
        inflationPercent: 25.0,
        overproductionPercent: 104.17
    }
];

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-product-list-view', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders loading spinner when analysisId is set but wire data is loading', () => {
        const element = createElement('c-product-list-view', {
            is: ProductListView
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        const spinner = element.shadowRoot.querySelector('[data-testid="loading-spinner"]');
        expect(spinner).not.toBeNull();
    });

    it('renders datatable with products when wire emits data', async () => {
        const element = createElement('c-product-list-view', {
            is: ProductListView
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const datatable = element.shadowRoot.querySelector('[data-testid="products-datatable"]');
        expect(datatable).not.toBeNull();
        expect(datatable.data.length).toBe(2);
    });

    it('filters rows when search query is entered', async () => {
        const element = createElement('c-product-list-view', {
            is: ProductListView
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const searchInput = element.shadowRoot.querySelector('[data-testid="search-input"]');
        searchInput.value = 'small_arms';
        searchInput.dispatchEvent(new CustomEvent('change', { target: searchInput }));

        await flushPromises();

        const datatable = element.shadowRoot.querySelector('[data-testid="products-datatable"]');
        expect(datatable.data.length).toBe(1);
        expect(datatable.data[0].productCode).toBe('small_arms');
    });

    it('dispatches productselect custom event when row action is clicked', async () => {
        const element = createElement('c-product-list-view', {
            is: ProductListView
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const handler = jest.fn();
        element.addEventListener('productselect', handler);

        const datatable = element.shadowRoot.querySelector('[data-testid="products-datatable"]');
        datatable.dispatchEvent(new CustomEvent('rowaction', {
            detail: {
                action: { name: 'view_product' },
                row: MOCK_PRODUCTS[0]
            }
        }));

        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.productEconomyId).toBe('p00000000000001AAA');
    });

    it('renders empty message when search query matches zero rows', async () => {
        const element = createElement('c-product-list-view', {
            is: ProductListView
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const searchInput = element.shadowRoot.querySelector('[data-testid="search-input"]');
        searchInput.value = 'nonexistent_commodity';
        searchInput.dispatchEvent(new CustomEvent('change', { target: searchInput }));

        await flushPromises();

        const emptyMsg = element.shadowRoot.querySelector('[data-testid="empty-message"]');
        expect(emptyMsg).not.toBeNull();
    });

    it('renders error message when wire returns error', async () => {
        const element = createElement('c-product-list-view', {
            is: ProductListView
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummariesAdapter.error({ message: 'SOQL limit exceeded' });

        await flushPromises();

        const errorDiv = element.shadowRoot.querySelector('[data-testid="error-message"]');
        expect(errorDiv).not.toBeNull();
        expect(errorDiv.textContent).toContain('SOQL limit exceeded');
    });
});
