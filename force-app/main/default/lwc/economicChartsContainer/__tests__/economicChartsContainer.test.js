import { createElement } from 'lwc';
import EconomicChartsContainer from 'c/economicChartsContainer';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetCountrySummariesAdapter = registerApexTestWireAdapter(getCountrySummaries);
const mockGetProductSummariesAdapter = registerApexTestWireAdapter(getProductSummaries);
const mockGetAnalysisSummaryAdapter = registerApexTestWireAdapter(getAnalysisSummary);

const MOCK_COUNTRIES = [
    { countryTag: 'EGY', countryName: 'Egypt', gdp: 500000, totalImports: 10000, totalExports: 25000 },
    { countryTag: 'ENG', countryName: 'United Kingdom', gdp: 2000000, totalImports: 80000, totalExports: 95000 },
    { countryTag: 'FRA', countryName: 'France', gdp: 1200000, totalImports: 40000, totalExports: 45000 }
];

const MOCK_PRODUCTS = [
    { productCode: 'cotton', productName: 'Cotton', totalWorldSupply: 1000, realDemand: 800, maxDemand: 1200, inflationPercent: 5.2, overproductionPercent: 12.0 },
    { productCode: 'grain', productName: 'Grain', totalWorldSupply: 2500, realDemand: 2400, maxDemand: 2600, inflationPercent: -2.1, overproductionPercent: 4.1 }
];

const MOCK_SUMMARY = {
    analysisId: 'a00000000000001AAA',
    totalWorldGdp: 3700000
};

describe('c-economic-charts-container', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it('renders empty message when no analysisId is provided', async () => {
        const element = createElement('c-economic-charts-container', {
            is: EconomicChartsContainer
        });
        document.body.appendChild(element);

        await flushPromises();

        const emptyMessage = element.shadowRoot.querySelector('[data-testid="empty-chart-message"]');
        expect(emptyMessage).not.toBeNull();
        expect(emptyMessage.textContent).toContain('No analysis data available');
    });

    it('renders charts and tabs when data is emitted', async () => {
        const element = createElement('c-economic-charts-container', {
            is: EconomicChartsContainer
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const tabset = element.shadowRoot.querySelector('[data-testid="chart-tabset"]');
        expect(tabset).not.toBeNull();

        const gdpDonutTab = element.shadowRoot.querySelector('[data-testid="tab-gdp-donut"]');
        expect(gdpDonutTab).not.toBeNull();

        const svgElement = element.shadowRoot.querySelector('svg');
        expect(svgElement).not.toBeNull();
        expect(svgElement.getAttribute('aria-label')).toBeTruthy();
    });

    it('renders error notification when wire fails', async () => {
        const element = createElement('c-economic-charts-container', {
            is: EconomicChartsContainer
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetCountrySummariesAdapter.error({ body: { message: 'Apex Error Loading Country Summaries' } });

        await flushPromises();

        const errorBanner = element.shadowRoot.querySelector('.slds-theme_error');
        expect(errorBanner).not.toBeNull();
        expect(errorBanner.textContent).toContain('Apex Error Loading Country Summaries');
    });
});
