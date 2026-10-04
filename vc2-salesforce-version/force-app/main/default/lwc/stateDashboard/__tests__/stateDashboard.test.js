import { createElement } from 'lwc';
import StateDashboard from 'c/stateDashboard';
import getStateSummaries from '@salesforce/apex/EconomyAnalysisController.getStateSummaries';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetStateSummariesAdapter = registerApexTestWireAdapter(getStateSummaries);

const MOCK_STATES = [
    {
        stateEconomyId: 'a05000000000001AAA',
        stateCode: '294',
        countryTag: 'ENG',
        population: 1200000,
        gdp: 50000.0,
        gdpPerCapita: 0.0416,
        gdpRank: 1,
        rgoIncome: 10000.0,
        fgdp: 30000.0,
        pgdp: 15000.0,
        agdp: 5000.0,
        factoryEmployees: 99490
    },
    {
        stateEconomyId: 'a05000000000002AAA',
        stateCode: '295',
        countryTag: 'ENG',
        population: 800000,
        gdp: 30000.0,
        gdpPerCapita: 0.0375,
        gdpRank: 2,
        rgoIncome: 8000.0,
        fgdp: 15000.0,
        pgdp: 10000.0,
        agdp: 5000.0,
        factoryEmployees: 45000
    }
];

describe('c-state-dashboard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders state KPI cards and datatable when data is returned', async () => {
        const element = createElement('c-state-dashboard', {
            is: StateDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetStateSummariesAdapter.emit(MOCK_STATES);

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable');
        expect(datatable).not.toBeNull();
        expect(datatable.data.length).toBe(2);

        const headings = element.shadowRoot.querySelectorAll('.slds-text-heading_medium');
        expect(headings.length).toBe(4);
    });

    it('filters states when search input changes', async () => {
        const element = createElement('c-state-dashboard', {
            is: StateDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetStateSummariesAdapter.emit(MOCK_STATES);
        await Promise.resolve();

        const searchInput = element.shadowRoot.querySelector('lightning-input');
        searchInput.value = '294';
        searchInput.dispatchEvent(new CustomEvent('change', { target: { value: '294' } }));

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable');
        expect(datatable.data.length).toBe(1);
        expect(datatable.data[0].stateCode).toBe('294');
    });

    it('displays empty state message when wire returns empty array', async () => {
        const element = createElement('c-state-dashboard', {
            is: StateDashboard
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        mockGetStateSummariesAdapter.emit([]);
        await Promise.resolve();

        const emptyMsg = element.shadowRoot.querySelector('.slds-text-color_weak.slds-text-align_center');
        expect(emptyMsg).not.toBeNull();
        expect(emptyMsg.textContent).toContain('No state economic data found');
    });
});
