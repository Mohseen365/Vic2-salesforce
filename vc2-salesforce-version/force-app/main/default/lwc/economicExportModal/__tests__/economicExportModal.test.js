import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import EconomicExportModal from 'c/economicExportModal';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';
import exportCsv from '@salesforce/apex/EconomyAnalysisController.exportCsv';

const mockGetAnalysisSummaryAdapter = registerApexTestWireAdapter(getAnalysisSummary);
const mockGetCountrySummariesAdapter = registerApexTestWireAdapter(getCountrySummaries);
const mockGetProductSummariesAdapter = registerApexTestWireAdapter(getProductSummaries);

jest.mock(
    '@salesforce/apex/EconomyAnalysisController.exportCsv',
    () => {
        return {
            default: jest.fn((args) => Promise.resolve(`Tag,Official Name\nPRU,Prussia`))
        };
    },
    { virtual: true }
);

const MOCK_SUMMARY = {
    analysisId: 'a00000000000001AAA',
    saveFileName: 'prussia_1848.v2',
    ingameDate: '1848-03-12',
    playerCountryTag: 'PRU'
};

const MOCK_COUNTRIES = [
    { countryTag: 'PRU', countryName: 'Prussia', gdpRank: 1, gdp: 500000 }
];

const MOCK_PRODUCTS = [
    { productCode: 'small_arms', productName: 'Small Arms', price: 12.0 }
];

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-economic-export-modal', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders modal when openModal is called', async () => {
        const element = createElement('c-economic-export-modal', {
            is: EconomicExportModal
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        element.openModal('Countries');

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const scopeSelector = element.shadowRoot.querySelector('[data-testid="scope-selector"]');
        expect(scopeSelector).not.toBeNull();
        expect(scopeSelector.value).toBe('Countries');
    });

    it('handles scope change and updates preview row count', async () => {
        const element = createElement('c-economic-export-modal', {
            is: EconomicExportModal
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        element.openModal('Countries');

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const scopeSelector = element.shadowRoot.querySelector('[data-testid="scope-selector"]');
        scopeSelector.dispatchEvent(new CustomEvent('change', { detail: { value: 'Summary' } }));

        await flushPromises();

        expect(scopeSelector.value).toBe('Summary');
    });

    it('triggers client-side export and emits close event on successful download', async () => {
        const element = createElement('c-economic-export-modal', {
            is: EconomicExportModal
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        element.openModal('Countries');

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        const closeHandler = jest.fn();
        element.addEventListener('close', closeHandler);

        // Mock URL.createObjectURL and URL.revokeObjectURL
        global.URL.createObjectURL = jest.fn(() => 'blob:http://localhost/123');
        global.URL.revokeObjectURL = jest.fn();

        const exportBtn = element.shadowRoot.querySelector('[data-testid="export-button"]');
        expect(exportBtn).not.toBeNull();
        exportBtn.click();

        await flushPromises();

        expect(closeHandler).toHaveBeenCalled();
    });

    it('invokes Apex fallback for high row count scopes like CountryProducts or Provinces', async () => {
        const element = createElement('c-economic-export-modal', {
            is: EconomicExportModal
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        element.openModal('Provinces');

        mockGetAnalysisSummaryAdapter.emit(MOCK_SUMMARY);
        mockGetCountrySummariesAdapter.emit(MOCK_COUNTRIES);
        mockGetProductSummariesAdapter.emit(MOCK_PRODUCTS);

        await flushPromises();

        global.URL.createObjectURL = jest.fn(() => 'blob:http://localhost/123');
        global.URL.revokeObjectURL = jest.fn();

        const exportBtn = element.shadowRoot.querySelector('[data-testid="export-button"]');
        exportBtn.click();

        await flushPromises();

        expect(exportCsv).toHaveBeenCalledWith({
            analysisId: 'a00000000000001AAA',
            scope: 'Provinces'
        });
    });

    it('emits close event when cancel button is clicked', async () => {
        const element = createElement('c-economic-export-modal', {
            is: EconomicExportModal
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        element.openModal('Countries');

        await flushPromises();

        const closeHandler = jest.fn();
        element.addEventListener('close', closeHandler);

        const cancelBtn = element.shadowRoot.querySelector('[data-testid="cancel-button"]');
        cancelBtn.click();

        await flushPromises();

        expect(closeHandler).toHaveBeenCalled();
    });
});
