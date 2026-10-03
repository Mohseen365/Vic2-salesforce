import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import CountryDashboard from 'c/countryDashboard';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getCountryProductSummaries from '@salesforce/apex/EconomyAnalysisController.getCountryProductSummaries';

const mockGetCountrySummariesAdapter = registerApexTestWireAdapter(getCountrySummaries);
const mockGetCountryProductSummariesAdapter = registerApexTestWireAdapter(getCountryProductSummaries);

const MOCK_COUNTRIES = [
    {
        countryEconomyId: 'c00000000000001AAA',
        countryTag: 'PRU',
        countryName: 'Prussia',
        flagUrl: 'https://example.com/pru.png',
        population: 14820000,
        workforce: 3705000,
        employment: 3550000,
        gdp: 890400.0,
        gdpPerCapita: 60.08,
        gdpRank: 5,
        gdpShare: 6.25,
        unemploymentRate: 0.042,
        totalImports: 15000.0,
        totalExports: 25000.0,
        goldIncome: 120.0
    },
    {
        countryEconomyId: 'c00000000000002AAA',
        countryTag: 'ENG',
        countryName: 'United Kingdom',
        flagUrl: 'https://example.com/eng.png',
        population: 25000000,
        workforce: 6000000,
        employment: 5800000,
        gdp: 2500000.0,
        gdpPerCapita: 100.0,
        gdpRank: 1,
        gdpShare: 17.54,
        unemploymentRate: 0.033,
        totalImports: 50000.0,
        totalExports: 80000.0,
        goldIncome: 500.0
    }
];

const MOCK_PRODUCTS = [
    {
        junctionId: 'j00000000000001AAA',
        productCode: 'small_arms',
        productName: 'Small Arms',
        soldDomestic: 120.4,
        importValue: 1200.0,
        exportValue: 4500.0,
        gdpContribution: 8900.0
    },
    {
        junctionId: 'j00000000000002AAA',
        productCode: 'grain',
        productName: 'Grain',
        soldDomestic: 1450.0,
        importValue: 0.0,
        exportValue: 12000.0,
        gdpContribution: 45000.0
    }
];

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-country-dashboard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders country combobox and auto-selects first country when wire emits countries', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);

        await flushPromises();

        const combobox = element.shadowRoot.querySelector('[data-testid="country-combobox"]');
        expect(combobox).not.toBeNull();
        expect(combobox.value).toBe('c00000000000001AAA');

        const kpiGrid = element.shadowRoot.querySelector('[data-testid="kpi-cards-grid"]');
        expect(kpiGrid).not.toBeNull();
    });

    it('renders KPI metrics for auto-selected country', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);

        await flushPromises();

        const gdpKpi = element.shadowRoot.querySelector('[data-testid="kpi-gdp"]');
        expect(gdpKpi).not.toBeNull();

        const popKpi = element.shadowRoot.querySelector('[data-testid="kpi-population"]');
        expect(popKpi).not.toBeNull();
    });

    it('renders product trade breakdown datatable when products wire emits data', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        await flushPromises();

        mockGetCountryProductSummariesAdapter.emit(MOCK_PRODUCTS);
        await flushPromises();

        const datatable = element.shadowRoot.querySelector('[data-testid="products-datatable"]');
        expect(datatable).not.toBeNull();
        expect(datatable.data.length).toBe(2);
    });

    it('filters datatable rows when search query is entered', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        await flushPromises();

        mockGetCountryProductSummariesAdapter.emit(MOCK_PRODUCTS);
        await flushPromises();

        const searchInput = element.shadowRoot.querySelector('[data-testid="search-input"]');
        expect(searchInput).not.toBeNull();

        searchInput.value = 'small_arms';
        searchInput.dispatchEvent(new CustomEvent('change', { target: searchInput }));

        await flushPromises();

        const datatable = element.shadowRoot.querySelector('[data-testid="products-datatable"]');
        expect(datatable.data.length).toBe(1);
        expect(datatable.data[0].productCode).toBe('small_arms');
    });

    it('updates selected country when user selects new item in combobox', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        await flushPromises();

        const combobox = element.shadowRoot.querySelector('[data-testid="country-combobox"]');
        combobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'c00000000000002AAA' }
        }));

        await flushPromises();

        expect(element.shadowRoot.querySelector('[data-testid="country-combobox"]').value).toBe('c00000000000002AAA');
    });

    it('displays empty state message when search matches zero products', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        await flushPromises();

        mockGetCountryProductSummariesAdapter.emit(MOCK_PRODUCTS);
        await flushPromises();

        const searchInput = element.shadowRoot.querySelector('[data-testid="search-input"]');
        searchInput.value = 'nonexistent_item';
        searchInput.dispatchEvent(new CustomEvent('change', { target: searchInput }));

        await flushPromises();

        const noProductsMsg = element.shadowRoot.querySelector('[data-testid="no-products-message"]');
        expect(noProductsMsg).not.toBeNull();
    });

    it('dispatches openexport event when Export Countries button is clicked', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        await flushPromises();

        const exportHandler = jest.fn();
        element.addEventListener('openexport', exportHandler);

        const exportBtn = element.shadowRoot.querySelector('[data-testid="export-countries-button"]');
        expect(exportBtn).not.toBeNull();
        exportBtn.click();

        expect(exportHandler).toHaveBeenCalledTimes(1);
        expect(exportHandler.mock.calls[0][0].detail).toEqual({ scope: 'Countries' });
    });

    it('displays error message when countries wire fails', async () => {
        const element = createElement('c-country-dashboard', {
            is: CountryDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.error({ message: 'SOQL Query Limit Exceeded' });

        await flushPromises();

        const errorDiv = element.shadowRoot.querySelector('[data-testid="countries-error"]');
        expect(errorDiv).not.toBeNull();
        expect(errorDiv.textContent).toContain('SOQL Query Limit Exceeded');
    });
});
