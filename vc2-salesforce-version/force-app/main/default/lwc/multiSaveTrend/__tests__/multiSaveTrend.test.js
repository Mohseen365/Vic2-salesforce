import { createElement } from 'lwc';
import MultiSaveTrend from 'c/multiSaveTrend';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';
import getWorldTrend from '@salesforce/apex/EconomyAnalysisController.getWorldTrend';
import getCountryTrend from '@salesforce/apex/EconomyAnalysisController.getCountryTrend';
import getProductTrend from '@salesforce/apex/EconomyAnalysisController.getProductTrend';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetRecentAnalysesAdapter = registerApexTestWireAdapter(getRecentAnalyses);
const mockGetWorldTrendAdapter = registerApexTestWireAdapter(getWorldTrend);
const mockGetCountryTrendAdapter = registerApexTestWireAdapter(getCountryTrend);
const mockGetProductTrendAdapter = registerApexTestWireAdapter(getProductTrend);

const MOCK_RECENT_ANALYSES = [
    { Id: 'a01', Save_File_Name__c: 'england_1840.v2', Ingame_Date__c: '1840-01-01' },
    { Id: 'a02', Save_File_Name__c: 'england_1845.v2', Ingame_Date__c: '1845-01-01' },
    { Id: 'a03', Save_File_Name__c: 'england_1850.v2', Ingame_Date__c: '1850-01-01' }
];

const MOCK_WORLD_TREND = {
    points: [
        { analysisId: 'a01', saveFileName: 'england_1840.v2', ingameDate: '1840-01-01', totalWorldGdp: 1000000, totalWorldPopulation: 10000000, totalWorldImports: 50000, totalWorldExports: 55000 },
        { analysisId: 'a02', saveFileName: 'england_1845.v2', ingameDate: '1845-01-01', totalWorldGdp: 1200000, totalWorldPopulation: 10500000, totalWorldImports: 60000, totalWorldExports: 65000 },
        { analysisId: 'a03', saveFileName: 'england_1850.v2', ingameDate: '1850-01-01', totalWorldGdp: 1500000, totalWorldPopulation: 11000000, totalWorldImports: 75000, totalWorldExports: 80000 }
    ]
};

const MOCK_COUNTRY_TREND = {
    series: [
        {
            countryTag: 'ENG',
            countryName: 'United Kingdom',
            points: [
                { analysisId: 'a01', ingameDate: '1840-01-01', gdp: 500000, gdpPerCapita: 1.0, gdpRank: 1, imports: 20000, exports: 25000 },
                { analysisId: 'a02', ingameDate: '1845-01-01', gdp: 600000, gdpPerCapita: 1.1, gdpRank: 1, imports: 25000, exports: 30000 },
                { analysisId: 'a03', ingameDate: '1850-01-01', gdp: 750000, gdpPerCapita: 1.3, gdpRank: 1, imports: 30000, exports: 38000 }
            ]
        }
    ]
};

const MOCK_PRODUCT_TREND = {
    series: [
        {
            productCode: 'grain',
            productName: 'Grain',
            points: [
                { analysisId: 'a01', ingameDate: '1840-01-01', price: 10.0, totalWorldSupply: 500, realDemand: 450, inflationPercent: 0.0, overproductionPercent: 111.1 },
                { analysisId: 'a02', ingameDate: '1845-01-01', price: 11.0, totalWorldSupply: 550, realDemand: 490, inflationPercent: 10.0, overproductionPercent: 112.2 },
                { analysisId: 'a03', ingameDate: '1850-01-01', price: 12.0, totalWorldSupply: 600, realDemand: 520, inflationPercent: 20.0, overproductionPercent: 115.3 }
            ]
        }
    ]
};

describe('c-multi-save-trend', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders empty prompt state when fewer than 3 analyses selected', async () => {
        const element = createElement('c-multi-save-trend', { is: MultiSaveTrend });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_RECENT_ANALYSES.slice(0, 2));
        await Promise.resolve();

        const emptyState = element.shadowRoot.querySelector('[data-testid="empty-state"]');
        expect(emptyState).not.toBeNull();
    });

    it('renders main workspace and chart tabs when >= 3 analyses selected', async () => {
        const element = createElement('c-multi-save-trend', { is: MultiSaveTrend });
        element.analysisIds = ['a01', 'a02', 'a03'];
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_RECENT_ANALYSES);
        mockGetWorldTrendAdapter.emit(MOCK_WORLD_TREND);
        mockGetCountryTrendAdapter.emit(MOCK_COUNTRY_TREND);
        mockGetProductTrendAdapter.emit(MOCK_PRODUCT_TREND);
        await Promise.resolve();

        const tabset = element.shadowRoot.querySelector('[data-testid="trend-tabset"]');
        expect(tabset).not.toBeNull();

        const datatable = element.shadowRoot.querySelector('[data-testid="country-delta-datatable"]');
        expect(datatable).not.toBeNull();
        expect(datatable.data.length).toBe(1);
        expect(datatable.data[0].countryTag).toBe('ENG');
        expect(datatable.data[0].baseGdp).toBe(500000);
        expect(datatable.data[0].latestGdp).toBe(750000);
        expect(datatable.data[0].gdpDelta).toBe(250000);
    });

    it('verifies SVG chart accessibility attributes and assistive tables', async () => {
        const element = createElement('c-multi-save-trend', { is: MultiSaveTrend });
        element.analysisIds = ['a01', 'a02', 'a03'];
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_RECENT_ANALYSES);
        mockGetWorldTrendAdapter.emit(MOCK_WORLD_TREND);
        mockGetCountryTrendAdapter.emit(MOCK_COUNTRY_TREND);
        mockGetProductTrendAdapter.emit(MOCK_PRODUCT_TREND);
        await Promise.resolve();

        const svg = element.shadowRoot.querySelector('svg');
        expect(svg).not.toBeNull();
        expect(svg.getAttribute('role')).toBe('img');
        expect(svg.getAttribute('aria-label')).toBeTruthy();

        const title = svg.querySelector('title');
        expect(title).not.toBeNull();

        const assistiveTable = element.shadowRoot.querySelector('.slds-assistive-text table');
        expect(assistiveTable).not.toBeNull();
    });

    it('caps dual-listbox selections at 12 items', async () => {
        const element = createElement('c-multi-save-trend', { is: MultiSaveTrend });
        document.body.appendChild(element);

        mockGetRecentAnalysesAdapter.emit(MOCK_RECENT_ANALYSES);
        await Promise.resolve();

        const dualListbox = element.shadowRoot.querySelector('[data-testid="analysis-dual-listbox"]');
        expect(dualListbox).not.toBeNull();

        const fake14Ids = Array.from({ length: 14 }, (_, i) => `id_${i}`);
        dualListbox.dispatchEvent(new CustomEvent('change', { detail: { value: fake14Ids } }));
        await Promise.resolve();

        expect(element.shadowRoot.querySelector('.slds-alert_warning')).not.toBeNull();
    });
});
