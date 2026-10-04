import { createElement } from 'lwc';
import ArtisanDashboard from 'c/artisanDashboard';
import getArtisanSummaries from '@salesforce/apex/EconomyAnalysisController.getArtisanSummaries';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetArtisanSummariesAdapter = registerApexTestWireAdapter(getArtisanSummaries);

const MOCK_ARTISANS = [
    {
        artisanEconomyId: 'a06000000000001AAA',
        artisanType: 'furniture',
        externalProvinceId: '1',
        countryTag: 'USA',
        stateCode: 'blank',
        spending: 1.6034,
        income: 2.3127,
        agdp: 0.7092,
        productionQuantity: 0.4534
    },
    {
        artisanEconomyId: 'a06000000000002AAA',
        artisanType: 'clothes',
        externalProvinceId: '2',
        countryTag: 'USA',
        stateCode: 'blank',
        spending: 2.1000,
        income: 3.5000,
        agdp: 1.4000,
        productionQuantity: 0.8000
    }
];

describe('c-artisan-dashboard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders artisan KPI cards and datatable when data is returned', async () => {
        const element = createElement('c-artisan-dashboard', {
            is: ArtisanDashboard
        });
        element.provinceEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetArtisanSummariesAdapter.emit(MOCK_ARTISANS);

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable');
        expect(datatable).not.toBeNull();
        expect(datatable.data.length).toBe(2);

        const headings = element.shadowRoot.querySelectorAll('.slds-text-heading_medium');
        expect(headings.length).toBe(4);
    });

    it('filters artisans when search input changes', async () => {
        const element = createElement('c-artisan-dashboard', {
            is: ArtisanDashboard
        });
        element.provinceEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetArtisanSummariesAdapter.emit(MOCK_ARTISANS);
        await Promise.resolve();

        const searchInput = element.shadowRoot.querySelector('lightning-input');
        searchInput.value = 'furniture';
        searchInput.dispatchEvent(new CustomEvent('change', { target: { value: 'furniture' } }));

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable');
        expect(datatable.data.length).toBe(1);
        expect(datatable.data[0].artisanType).toBe('furniture');
    });

    it('displays empty state message when wire returns empty array', async () => {
        const element = createElement('c-artisan-dashboard', {
            is: ArtisanDashboard
        });
        element.provinceEconomyId = 'p00000000000001AAA';
        document.body.appendChild(element);

        mockGetArtisanSummariesAdapter.emit([]);
        await Promise.resolve();

        const emptyMsg = element.shadowRoot.querySelector('.slds-text-color_weak.slds-text-align_center');
        expect(emptyMsg).not.toBeNull();
        expect(emptyMsg.textContent).toContain('No artisan economic data found');
    });
});
