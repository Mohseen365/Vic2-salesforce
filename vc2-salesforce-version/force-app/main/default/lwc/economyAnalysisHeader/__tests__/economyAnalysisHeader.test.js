import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import EconomyAnalysisHeader from 'c/economyAnalysisHeader';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import { refreshApex } from '@salesforce/apex';

const getAnalysisSummaryAdapter = registerApexTestWireAdapter(getAnalysisSummary);

jest.mock(
    '@salesforce/apex',
    () => {
        return {
            refreshApex: jest.fn(() => Promise.resolve())
        };
    },
    { virtual: true }
);

const MOCK_SUMMARY = {
    analysisId: 'a00000000000001AAA',
    saveFileName: 'prussia_1848.v2',
    sourceSaveFileName: 'prussia_1848.v2',
    ingameDate: '1848-03-12',
    analysisTimestamp: '2025-01-01T12:00:00.000Z',
    playerCountryTag: 'PRU',
    totalWorldGdp: 14250900.5,
    totalWorldPopulation: 420500000,
    totalWorldImports: 850000.0,
    totalWorldExports: 890000.0,
    importStatus: 'COMPLETED',
    importDiagnosticMessage: null
};

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-economy-analysis-header', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders loading spinner when analysisId is set but wire data is loading', () => {
        const element = createElement('c-economy-analysis-header', {
            is: EconomyAnalysisHeader
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        const spinner = element.shadowRoot.querySelector('[data-testid="loading-spinner"]');
        expect(spinner).not.toBeNull();
    });

    it('renders populated summary header and KPI metrics when wire emits data', async () => {
        const element = createElement('c-economy-analysis-header', {
            is: EconomyAnalysisHeader
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        getAnalysisSummaryAdapter.emit(MOCK_SUMMARY);

        await flushPromises();

        const badge = element.shadowRoot.querySelector('[data-testid="status-badge"]');
        expect(badge).not.toBeNull();
        expect(badge.textContent).toContain('COMPLETED');

        const gdpTile = element.shadowRoot.querySelector('[data-testid="world-gdp"]');
        expect(gdpTile).not.toBeNull();

        const popTile = element.shadowRoot.querySelector('[data-testid="world-population"]');
        expect(popTile).not.toBeNull();
    });

    it('renders diagnostic banner when import status is FAILED', async () => {
        const element = createElement('c-economy-analysis-header', {
            is: EconomyAnalysisHeader
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        getAnalysisSummaryAdapter.emit({
            ...MOCK_SUMMARY,
            importStatus: 'FAILED',
            importDiagnosticMessage: 'Parsing failed at byte 1024'
        });

        await flushPromises();

        const diagnosticBanner = element.shadowRoot.querySelector('[data-testid="diagnostic-banner"]');
        expect(diagnosticBanner).not.toBeNull();
        expect(diagnosticBanner.textContent).toContain('Parsing failed at byte 1024');
    });

    it('renders pending banner when import status is PROCESSING or CALCULATING', async () => {
        const element = createElement('c-economy-analysis-header', {
            is: EconomyAnalysisHeader
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        getAnalysisSummaryAdapter.emit({
            ...MOCK_SUMMARY,
            importStatus: 'CALCULATING'
        });

        await flushPromises();

        const pendingBanner = element.shadowRoot.querySelector('[data-testid="pending-banner"]');
        expect(pendingBanner).not.toBeNull();
    });

    it('triggers refreshApex when refresh button is clicked', async () => {
        const element = createElement('c-economy-analysis-header', {
            is: EconomyAnalysisHeader
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        getAnalysisSummaryAdapter.emit(MOCK_SUMMARY);

        await flushPromises();

        const refreshBtn = element.shadowRoot.querySelector('[data-testid="refresh-button"]');
        expect(refreshBtn).not.toBeNull();
        refreshBtn.click();

        expect(refreshApex).toHaveBeenCalled();
    });

    it('renders error message when wire returns error', async () => {
        const element = createElement('c-economy-analysis-header', {
            is: EconomyAnalysisHeader
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        getAnalysisSummaryAdapter.error({ message: 'Access Denied' });

        await flushPromises();

        const errorDiv = element.shadowRoot.querySelector('[data-testid="error-message"]');
        expect(errorDiv).not.toBeNull();
        expect(errorDiv.textContent).toContain('Access Denied');
    });
});
