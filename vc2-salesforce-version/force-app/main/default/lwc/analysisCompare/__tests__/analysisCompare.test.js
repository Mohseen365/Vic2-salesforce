import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import AnalysisCompare from 'c/analysisCompare';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';
import compareAnalyses from '@salesforce/apex/EconomyAnalysisController.compareAnalyses';

jest.mock(
    '@salesforce/apex/EconomyAnalysisController.compareAnalyses',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

const mockGetRecentAnalysesAdapter = registerApexTestWireAdapter(getRecentAnalyses);

const MOCK_ANALYSES = [
    { Id: 'a1', Save_File_Name__c: 'prussia_1848.v2', Ingame_Date__c: '1848-03-12' },
    { Id: 'a2', Save_File_Name__c: 'prussia_1850.v2', Ingame_Date__c: '1850-01-01' }
];

const MOCK_COMPARISON = {
    baseAnalysisId: 'a1',
    compareAnalysisId: 'a2',
    baseGdp: 500000.0,
    compareGdp: 600000.0,
    gdpGrowthPercent: 20.0,
    countryDeltas: [
        { countryTag: 'PRU', countryName: 'Prussia', baseGdp: 500000.0, compareGdp: 600000.0, gdpDelta: 100000.0, gdpDeltaPercent: 20.0, rankDelta: 0 }
    ],
    productDeltas: [
        { productCode: 'grain', productName: 'Grain', basePrice: 2.0, comparePrice: 2.5, priceDeltaPercent: 25.0, baseSupply: 1000.0, compareSupply: 1200.0, supplyDeltaPercent: 20.0 }
    ]
};

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-analysis-compare', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders analysis comboboxes populated from getRecentAnalyses', async () => {
        const element = createElement('c-analysis-compare', {
            is: AnalysisCompare
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const baseCombobox = element.shadowRoot.querySelector('[data-testid="base-combobox"]');
        const compareCombobox = element.shadowRoot.querySelector('[data-testid="compare-combobox"]');

        expect(baseCombobox).not.toBeNull();
        expect(compareCombobox).not.toBeNull();
        expect(baseCombobox.value).toBe('a1');
    });

    it('shows inline warning alert if identical analyses are selected', async () => {
        const element = createElement('c-analysis-compare', {
            is: AnalysisCompare
        });
        element.initialBaseAnalysisId = 'a1';
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const compareCombobox = element.shadowRoot.querySelector('[data-testid="compare-combobox"]');
        compareCombobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'a1' }
        }));

        await flushPromises();

        expect(element.shadowRoot.textContent).toContain('Base Analysis and Comparison Analysis must be different');
    });

    it('calls compareAnalyses and renders comparison summary and delta tables when distinct analyses are selected', async () => {
        compareAnalyses.mockResolvedValue(MOCK_COMPARISON);

        const element = createElement('c-analysis-compare', {
            is: AnalysisCompare
        });
        element.initialBaseAnalysisId = 'a1';
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const compareCombobox = element.shadowRoot.querySelector('[data-testid="compare-combobox"]');
        compareCombobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'a2' }
        }));

        await flushPromises();

        expect(compareAnalyses).toHaveBeenCalledWith({
            baseAnalysisId: 'a1',
            compareAnalysisId: 'a2'
        });

        const worldBlock = element.shadowRoot.querySelector('[data-testid="world-summary-block"]');
        expect(worldBlock).not.toBeNull();
        expect(element.shadowRoot.textContent).toContain('£500,000.00');
        expect(element.shadowRoot.textContent).toContain('£600,000.00');
        expect(element.shadowRoot.textContent).toContain('+20.00%');

        const countryTable = element.shadowRoot.querySelector('[data-testid="country-deltas-table"]');
        const productTable = element.shadowRoot.querySelector('[data-testid="product-deltas-table"]');
        expect(countryTable).not.toBeNull();
        expect(productTable).not.toBeNull();
    });

    it('renders error message when compareAnalyses throws an error', async () => {
        compareAnalyses.mockRejectedValue({ body: { message: 'Comparison Calculation Failed' } });

        const element = createElement('c-analysis-compare', {
            is: AnalysisCompare
        });
        element.initialBaseAnalysisId = 'a1';
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const compareCombobox = element.shadowRoot.querySelector('[data-testid="compare-combobox"]');
        compareCombobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'a2' }
        }));

        await flushPromises();

        expect(element.shadowRoot.textContent).toContain('Comparison Calculation Failed');
    });
});
