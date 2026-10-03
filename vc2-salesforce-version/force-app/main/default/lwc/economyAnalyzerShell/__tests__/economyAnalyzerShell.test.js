import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import EconomyAnalyzerShell from 'c/economyAnalyzerShell';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';

jest.mock(
    '@salesforce/apex',
    () => {
        return {
            refreshApex: jest.fn(() => Promise.resolve())
        };
    },
    { virtual: true }
);

const mockGetRecentAnalysesAdapter = registerApexTestWireAdapter(getRecentAnalyses);

const MOCK_ANALYSES = [
    {
        Id: 'a00000000000001AAA',
        Save_File_Name__c: 'prussia_1848.v2',
        Ingame_Date__c: '1848-03-12',
        Player_Country_Tag__c: 'PRU',
        Import_Status__c: 'COMPLETED'
    },
    {
        Id: 'a00000000000002AAA',
        Save_File_Name__c: 'egypt_1836.v2',
        Ingame_Date__c: '1836-01-01',
        Player_Country_Tag__c: 'EGY',
        Import_Status__c: 'COMPLETED'
    }
];

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-economy-analyzer-shell', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders application header title and analysis combobox', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const combobox = element.shadowRoot.querySelector('[data-testid="analysis-combobox"]');
        expect(combobox).not.toBeNull();
        expect(combobox.value).toBe('a00000000000001AAA');
    });

    it('passes auto-selected analysisId to watcher status, child header, and country dashboard components', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const watcher = element.shadowRoot.querySelector('[data-testid="watcher-status-component"]');
        expect(watcher).not.toBeNull();
        expect(watcher.analysisId).toBe('a00000000000001AAA');

        const header = element.shadowRoot.querySelector('[data-testid="header-component"]');
        expect(header).not.toBeNull();
        expect(header.analysisId).toBe('a00000000000001AAA');

        const countryDash = element.shadowRoot.querySelector('[data-testid="country-dashboard-component"]');
        expect(countryDash).not.toBeNull();
        expect(countryDash.analysisId).toBe('a00000000000001AAA');

        const countryCharts = element.shadowRoot.querySelector('[data-testid="country-charts-component"]');
        expect(countryCharts).not.toBeNull();
        expect(countryCharts.analysisId).toBe('a00000000000001AAA');
    });

    it('renders mounted Global Overview and Compare Saves components', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const globalDash = element.shadowRoot.querySelector('[data-testid="global-economy-dashboard-component"]');
        expect(globalDash).not.toBeNull();
        expect(globalDash.analysisId).toBe('a00000000000001AAA');

        const compareComp = element.shadowRoot.querySelector('[data-testid="analysis-compare-component"]');
        expect(compareComp).not.toBeNull();
        expect(compareComp.initialBaseAnalysisId).toBe('a00000000000001AAA');
    });

    it('handles countryselect and productselect events from Global Overview tab', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const globalDash = element.shadowRoot.querySelector('[data-testid="global-economy-dashboard-component"]');
        const tabset = element.shadowRoot.querySelector('[data-testid="tabset"]');

        globalDash.dispatchEvent(new CustomEvent('countryselect', {
            detail: { countryEconomyId: 'c1', countryTag: 'PRU' },
            bubbles: true,
            composed: true
        }));

        await flushPromises();

        expect(tabset.activeTabValue).toBe('country-explorer');

        globalDash.dispatchEvent(new CustomEvent('productselect', {
            detail: { productEconomyId: 'p1', productCode: 'grain' },
            bubbles: true,
            composed: true
        }));

        await flushPromises();

        expect(tabset.activeTabValue).toBe('product-market');
    });

    it('handles watcher statuschange event and triggers refresh on COMPLETED status', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const watcher = element.shadowRoot.querySelector('[data-testid="watcher-status-component"]');
        expect(watcher).not.toBeNull();

        watcher.dispatchEvent(new CustomEvent('statuschange', {
            detail: { analysisId: 'a00000000000001AAA', status: 'COMPLETED', diagnosticMessage: '' },
            bubbles: true,
            composed: true
        }));

        await flushPromises();

        expect(watcher.analysisId).toBe('a00000000000001AAA');
    });

    it('updates selectedAnalysisId when user selects new analysis in combobox', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const combobox = element.shadowRoot.querySelector('[data-testid="analysis-combobox"]');
        combobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'a00000000000002AAA' }
        }));

        await flushPromises();

        const header = element.shadowRoot.querySelector('[data-testid="header-component"]');
        expect(header.analysisId).toBe('a00000000000002AAA');
    });

    it('renders all workspace tabs including dedicated Analytics tab and supports full tab switching', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const tabset = element.shadowRoot.querySelector('[data-testid="tabset"]');
        const tabGlobal = element.shadowRoot.querySelector('[data-testid="tab-global"]');
        const tabCountry = element.shadowRoot.querySelector('[data-testid="tab-country"]');
        const tabProduct = element.shadowRoot.querySelector('[data-testid="tab-product"]');
        const tabAnalytics = element.shadowRoot.querySelector('[data-testid="tab-analytics"]');
        const tabCompare = element.shadowRoot.querySelector('[data-testid="tab-compare"]');

        expect(tabset).not.toBeNull();
        expect(tabGlobal).not.toBeNull();
        expect(tabCountry).not.toBeNull();
        expect(tabProduct).not.toBeNull();
        expect(tabAnalytics).not.toBeNull();
        expect(tabCompare).not.toBeNull();

        // Verify active tab default and switch tabs
        expect(tabset.activeTabValue).toBe('country-explorer');

        tabset.activeTabValue = 'global-overview';
        await flushPromises();
        expect(tabset.activeTabValue).toBe('global-overview');

        tabset.activeTabValue = 'product-market';
        await flushPromises();
        expect(tabset.activeTabValue).toBe('product-market');

        tabset.activeTabValue = 'analytics';
        await flushPromises();
        expect(tabset.activeTabValue).toBe('analytics');

        tabset.activeTabValue = 'compare-saves';
        await flushPromises();
        expect(tabset.activeTabValue).toBe('compare-saves');

        const dedicatedCharts = element.shadowRoot.querySelector('[data-testid="dedicated-charts-component"]');
        expect(dedicatedCharts).not.toBeNull();
        expect(dedicatedCharts.analysisId).toBe('a00000000000001AAA');
    });

    it('renders mounted export modal component', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const exportModal = element.shadowRoot.querySelector('[data-testid="export-modal-component"]');
        expect(exportModal).not.toBeNull();
        expect(exportModal.analysisId).toBe('a00000000000001AAA');
    });

    it('swaps from product list to product dashboard on productselect event and back on back event', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const productListComp = element.shadowRoot.querySelector('[data-testid="product-list-component"]');
        expect(productListComp).not.toBeNull();

        // Simulate product select event
        productListComp.dispatchEvent(new CustomEvent('productselect', {
            detail: { productEconomyId: 'p00000000000001AAA', productCode: 'small_arms' },
            bubbles: true,
            composed: true
        }));

        await flushPromises();

        const productDashComp = element.shadowRoot.querySelector('[data-testid="product-dashboard-component"]');
        expect(productDashComp).not.toBeNull();
        expect(productDashComp.productEconomyId).toBe('p00000000000001AAA');

        // Simulate back event
        productDashComp.dispatchEvent(new CustomEvent('back', {
            bubbles: true,
            composed: true
        }));

        await flushPromises();

        expect(element.shadowRoot.querySelector('[data-testid="product-list-component"]')).not.toBeNull();
    });

    it('captures openexport event from child components and routes to export modal', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const headerComp = element.shadowRoot.querySelector('[data-testid="header-component"]');
        expect(headerComp).not.toBeNull();

        headerComp.dispatchEvent(new CustomEvent('openexport', {
            detail: { scope: 'Countries' },
            bubbles: true,
            composed: true
        }));

        await flushPromises();

        const exportModal = element.shadowRoot.querySelector('[data-testid="export-modal-component"]');
        expect(exportModal).not.toBeNull();
    });
});
