import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import ProductDashboard from 'c/productDashboard';
import getProductSummary from '@salesforce/apex/EconomyAnalysisController.getProductSummary';
import getCountryProductSummariesByProduct from '@salesforce/apex/EconomyAnalysisController.getCountryProductSummariesByProduct';

const mockGetProductSummaryAdapter = registerApexTestWireAdapter(getProductSummary);
const mockGetCountryProductSummariesByProductAdapter = registerApexTestWireAdapter(getCountryProductSummariesByProduct);

const MOCK_PRODUCT_DETAIL = {
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
};

const MOCK_COUNTRY_CONTRIBUTIONS = [
    {
        junctionId: 'j00000000000001AAA',
        countryTag: 'PRU',
        countryName: 'Prussia',
        productCode: 'small_arms',
        soldDomestic: 50.0,
        importValue: 100.0,
        exportValue: 200.0,
        gdpContribution: 600.0
    }
];

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-product-dashboard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders loading spinner when productEconomyId is set but wire data is loading', () => {
        const element = createElement('c-product-dashboard', {
            is: ProductDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        element.productEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        const spinner = element.shadowRoot.querySelector('[data-testid="loading-spinner"]');
        expect(spinner).not.toBeNull();
    });

    it('renders KPI cards and metrics when product wire emits data', async () => {
        const element = createElement('c-product-dashboard', {
            is: ProductDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        element.productEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummaryAdapter.emit(MOCK_PRODUCT_DETAIL);

        await flushPromises();

        const priceKpi = element.shadowRoot.querySelector('[data-testid="kpi-price"]');
        expect(priceKpi).not.toBeNull();

        const supplyKpi = element.shadowRoot.querySelector('[data-testid="kpi-supply"]');
        expect(supplyKpi).not.toBeNull();

        const realDemandKpi = element.shadowRoot.querySelector('[data-testid="kpi-real-demand"]');
        expect(realDemandKpi).not.toBeNull();

        const maxDemandKpi = element.shadowRoot.querySelector('[data-testid="kpi-max-demand"]');
        expect(maxDemandKpi).not.toBeNull();
    });

    it('renders country breakdown sub-table when country wire emits data', async () => {
        const element = createElement('c-product-dashboard', {
            is: ProductDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        element.productEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummaryAdapter.emit(MOCK_PRODUCT_DETAIL);
        await flushPromises();

        mockGetCountryProductSummariesByProductAdapter.emit(MOCK_COUNTRY_CONTRIBUTIONS);
        await flushPromises();

        const subtable = element.shadowRoot.querySelector('[data-testid="subtable"]');
        expect(subtable).not.toBeNull();
        expect(subtable.data.length).toBe(1);
        expect(subtable.data[0].countryTag).toBe('PRU');
    });

    it('dispatches back custom event when Back button is clicked', async () => {
        const element = createElement('c-product-dashboard', {
            is: ProductDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        element.productEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummaryAdapter.emit(MOCK_PRODUCT_DETAIL);
        await flushPromises();

        const backHandler = jest.fn();
        element.addEventListener('back', backHandler);

        const backBtn = element.shadowRoot.querySelector('[data-testid="back-button"]');
        expect(backBtn).not.toBeNull();
        backBtn.click();

        expect(backHandler).toHaveBeenCalled();
    });

    it('dispatches openexport event when Export Products button is clicked', async () => {
        const element = createElement('c-product-dashboard', {
            is: ProductDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        element.productEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummaryAdapter.emit(MOCK_PRODUCT_DETAIL);
        await flushPromises();

        const exportHandler = jest.fn();
        element.addEventListener('openexport', exportHandler);

        const exportBtn = element.shadowRoot.querySelector('[data-testid="export-products-button"]');
        expect(exportBtn).not.toBeNull();
        exportBtn.click();

        expect(exportHandler).toHaveBeenCalledTimes(1);
        expect(exportHandler.mock.calls[0][0].detail).toEqual({ scope: 'Products' });
    });

    it('renders error message when product wire fails', async () => {
        const element = createElement('c-product-dashboard', {
            is: ProductDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        element.productEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetProductSummaryAdapter.error({ message: 'Record deleted or invalid' });

        await flushPromises();

        const errorDiv = element.shadowRoot.querySelector('[data-testid="error-message"]');
        expect(errorDiv).not.toBeNull();
        expect(errorDiv.textContent).toContain('Record deleted or invalid');
    });
});
