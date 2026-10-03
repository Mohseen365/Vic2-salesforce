import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import EconomyAnalyzerShell from 'c/economyAnalyzerShell';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';

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

    it('passes auto-selected analysisId to child header and country dashboard components', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const header = element.shadowRoot.querySelector('[data-testid="header-component"]');
        expect(header).not.toBeNull();
        expect(header.analysisId).toBe('a00000000000001AAA');

        const countryDash = element.shadowRoot.querySelector('[data-testid="country-dashboard-component"]');
        expect(countryDash).not.toBeNull();
        expect(countryDash.analysisId).toBe('a00000000000001AAA');
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

    it('renders all four workspace tabs', async () => {
        const element = createElement('c-economy-analyzer-shell', {
            is: EconomyAnalyzerShell
        });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_ANALYSES);

        await flushPromises();

        const tabGlobal = element.shadowRoot.querySelector('[data-testid="tab-global"]');
        const tabCountry = element.shadowRoot.querySelector('[data-testid="tab-country"]');
        const tabProduct = element.shadowRoot.querySelector('[data-testid="tab-product"]');
        const tabCompare = element.shadowRoot.querySelector('[data-testid="tab-compare"]');

        expect(tabGlobal).not.toBeNull();
        expect(tabCountry).not.toBeNull();
        expect(tabProduct).not.toBeNull();
        expect(tabCompare).not.toBeNull();
    });
});
