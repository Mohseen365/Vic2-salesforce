import { createElement } from 'lwc';
import FactoryDashboard from 'c/factoryDashboard';
import getFactorySummaries from '@salesforce/apex/EconomyAnalysisController.getFactorySummaries';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetFactorySummariesAdapter = registerApexTestWireAdapter(getFactorySummaries);

const MOCK_FACTORIES = [
    {
        factoryEconomyId: 'f00000000000001AAA',
        buildingType: 'cement_factory',
        stateCode: '294',
        countryTag: 'ENG',
        level: 10,
        employees: 99490,
        outputQuantity: 37.3734,
        unsoldQuantity: 14.9845,
        capitalReserves: 10000.0,
        revenue: 547.16,
        inputCost: 376.35,
        wagesPaid: 3.09,
        profit: 167.72,
        factoryGdp: 62346.35,
        productivity: 0.6266
    },
    {
        factoryEconomyId: 'f00000000000002AAA',
        buildingType: 'steel_factory',
        stateCode: '294',
        countryTag: 'ENG',
        level: 5,
        employees: 45000,
        outputQuantity: 20.5000,
        unsoldQuantity: 5.0000,
        capitalReserves: 5000.0,
        revenue: 300.00,
        inputCost: 200.00,
        wagesPaid: 2.00,
        profit: 98.00,
        factoryGdp: 30000.00,
        productivity: 0.6666
    }
];

describe('c-factory-dashboard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders factory KPI cards and datatable when data is returned', async () => {
        const element = createElement('c-factory-dashboard', {
            is: FactoryDashboard
        });
        element.stateEconomyId = 's00000000000001AAA';
        document.body.appendChild(element);

        mockGetFactorySummariesAdapter.emit(MOCK_FACTORIES);

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable');
        expect(datatable).not.toBeNull();
        expect(datatable.data.length).toBe(2);

        const headings = element.shadowRoot.querySelectorAll('.slds-text-heading_medium');
        expect(headings.length).toBe(4);
    });

    it('filters factories when search input changes', async () => {
        const element = createElement('c-factory-dashboard', {
            is: FactoryDashboard
        });
        element.stateEconomyId = 's00000000000001AAA';
        document.body.appendChild(element);

        mockGetFactorySummariesAdapter.emit(MOCK_FACTORIES);
        await Promise.resolve();

        const searchInput = element.shadowRoot.querySelector('lightning-input');
        searchInput.value = 'cement';
        searchInput.dispatchEvent(new CustomEvent('change', { target: { value: 'cement' } }));

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable');
        expect(datatable.data.length).toBe(1);
        expect(datatable.data[0].buildingType).toBe('cement_factory');
    });

    it('displays empty state message when wire returns empty array', async () => {
        const element = createElement('c-factory-dashboard', {
            is: FactoryDashboard
        });
        element.stateEconomyId = 's00000000000001AAA';
        document.body.appendChild(element);

        mockGetFactorySummariesAdapter.emit([]);
        await Promise.resolve();

        const emptyMsg = element.shadowRoot.querySelector('.slds-text-color_weak.slds-text-align_center');
        expect(emptyMsg).not.toBeNull();
        expect(emptyMsg.textContent).toContain('No factory economic data found');
    });
});
