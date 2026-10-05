import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import GlobalEconomyDashboard from 'c/globalEconomyDashboard';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';

const mockGetAnalysisSummaryAdapter = registerApexTestWireAdapter(getAnalysisSummary);
const mockGetCountrySummariesAdapter = registerApexTestWireAdapter(getCountrySummaries);
const mockGetProductSummariesAdapter = registerApexTestWireAdapter(getProductSummaries);

const MOCK_SUMMARY = {
    analysisId: 'a00000000000001AAA',
    saveFileName: 'egypt_1836.v2',
    playerCountryTag: 'ENG',
    totalWorldGdp: 5000000.0,
    totalWorldPopulation: 250000000,
    totalWorldImports: 450000.0,
    totalWorldExports: 480000.0,
    importStatus: 'COMPLETED'
};

const MOCK_COUNTRIES = [
    { countryEconomyId: 'c1', countryTag: 'ENG', countryName: 'United Kingdom', gdp: 1500000.0, gdpRank: 1, gdpShare: 30.0, gdpPerCapita: 500.0 },
    { countryEconomyId: 'c2', countryTag: 'FRA', countryName: 'France', gdp: 1200000.0, gdpRank: 2, gdpShare: 24.0, gdpPerCapita: 450.0 }
];

const MOCK_PRODUCTS = [
    { productEconomyId: 'p1', productCode: 'grain', productName: 'Grain', price: 2.5, totalWorldSupply: 10000.0, realDemand: 9500.0 },
    { productEconomyId: 'p2', productCode: 'iron', productName: 'Iron', price: 5.0, totalWorldSupply: 8000.0, realDemand: 7500.0 }
];

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-global-economy-dashboard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders empty state when analysisId is missing', async () => {
        const element = createElement('c-global-economy-dashboard', {
            is: GlobalEconomyDashboard
        });
        document.body.appendChild(element);

        await flushPromises();

        const emptyText = element.shadowRoot.textContent;
        expect(emptyText).toContain('No analysis data available');
    });

    it('renders KPI cards and datatables when data emits', async () => {
        const element = createElement('c-global-economy-dashboard', {
            is: GlobalEconomyDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const kpiGrid = element.shadowRoot.querySelector('[data-testid="kpi-grid"]');
        expect(kpiGrid).not.toBeNull();
        expect(element.shadowRoot.textContent).toContain('£5,000,000.00');
        expect(element.shadowRoot.textContent).toContain('250,000,000');
        expect(element.shadowRoot.textContent).toContain('ENG (United Kingdom)');

        const countriesTable = element.shadowRoot.querySelector('[data-testid="top-countries-table"]');
        expect(countriesTable).not.toBeNull();

        const productsTable = element.shadowRoot.querySelector('[data-testid="top-products-table"]');
        expect(productsTable).not.toBeNull();

        const chartsContainer = element.shadowRoot.querySelector('[data-testid="global-charts-container"]');
        expect(chartsContainer).not.toBeNull();
    });

    it('dispatches countryselect custom event on country row action', async () => {
        const element = createElement('c-global-economy-dashboard', {
            is: GlobalEconomyDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('countryselect', handler);

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const datatable = element.shadowRoot.querySelector('[data-testid="top-countries-table"] lightning-datatable');
        datatable.dispatchEvent(new CustomEvent('rowaction', {
            detail: {
                action: { name: 'view_country' },
                row: MOCK_COUNTRIES[0]
            }
        }));

        expect(handler).toHaveBeenCalledTimes(1);
        expect(handler.mock.calls[0][0].detail).toEqual({
            countryEconomyId: 'c1',
            countryTag: 'ENG'
        });
    });

    it('dispatches productselect custom event on product row action', async () => {
        const element = createElement('c-global-economy-dashboard', {
            is: GlobalEconomyDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('productselect', handler);

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const datatable = element.shadowRoot.querySelector('[data-testid="top-products-table"] lightning-datatable');
        datatable.dispatchEvent(new CustomEvent('rowaction', {
            detail: {
                action: { name: 'view_product' },
                row: MOCK_PRODUCTS[0]
            }
        }));

        expect(handler).toHaveBeenCalledTimes(1);
        expect(handler.mock.calls[0][0].detail).toEqual({
            productEconomyId: 'p1',
            productCode: 'grain'
        });
    });

    it('shows warning alert banner when analysis status is PROCESSING', async () => {
        const element = createElement('c-global-economy-dashboard', {
            is: GlobalEconomyDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetAnalysisSummaryAdapter.emit({
            ...MOCK_SUMMARY,
            importStatus: 'PROCESSING'
        });
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);

        await flushPromises();

        expect(element.shadowRoot.textContent).toContain('Analysis status is PROCESSING');
    });

    it('renders error card when Apex wire fails', async () => {
        const element = createElement('c-global-economy-dashboard', {
            is: GlobalEconomyDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetAnalysisSummaryAdapter.error({ body: { message: 'SOQL Query Limit Exception' } });

        await flushPromises();

        expect(element.shadowRoot.textContent).toContain('SOQL Query Limit Exception');
    });
});
