import { createElement } from 'lwc';
import KpiRibbon from 'c/kpiRibbon';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';

const getAnalysisSummaryWireAdapter = registerApexTestWireAdapter(getAnalysisSummary);

describe('c-kpi-ribbon', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('renders default KPI tiles when no summary or metrics provided', () => {
        const element = createElement('c-kpi-ribbon', { is: KpiRibbon });
        document.body.appendChild(element);

        const tiles = element.shadowRoot.querySelectorAll('c-kpi-tile');
        expect(tiles.length).toBe(6);
    });

    test('renders KPI tiles from wired getAnalysisSummary data', () => {
        const element = createElement('c-kpi-ribbon', { is: KpiRibbon });
        element.analysisId = 'a01000000000001AAA';
        document.body.appendChild(element);

        getAnalysisSummaryWireAdapter.emit({
            totalWorldGdp: 1500000000,
            totalWorldPopulation: 25000000,
            totalWorldImports: 12000000,
            playerCountryTag: 'EGY'
        });

        return Promise.resolve().then(() => {
            const tiles = element.shadowRoot.querySelectorAll('c-kpi-tile');
            expect(tiles.length).toBe(6);
        });
    });

    test('handles wire summary error gracefully', () => {
        const element = createElement('c-kpi-ribbon', { is: KpiRibbon });
        element.analysisId = 'a01000000000001AAA';
        document.body.appendChild(element);

        getAnalysisSummaryWireAdapter.error('API error');

        return Promise.resolve().then(() => {
            const tiles = element.shadowRoot.querySelectorAll('c-kpi-tile');
            expect(tiles.length).toBe(6);
        });
    });

    test('renders KPI tiles from provided summaryData prop', () => {
        const element = createElement('c-kpi-ribbon', { is: KpiRibbon });
        element.summaryData = {
            totalWorldGdp: 5000000,
            totalWorldPopulation: 100000,
            totalWorldImports: 2000,
            playerCountryTag: 'GBR'
        };
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const tiles = element.shadowRoot.querySelectorAll('c-kpi-tile');
            expect(tiles.length).toBe(6);
        });
    });

    test('renders custom kpiMetrics when provided', () => {
        const element = createElement('c-kpi-ribbon', { is: KpiRibbon });
        element.kpiMetrics = [
            { metricKey: 'custom1', label: 'Custom Metric 1', value: '100', deltaPercent: 5.0, sparklineData: [1, 2, 3] },
            { metricKey: 'custom2', label: 'Custom Metric 2', value: '200', deltaPercent: -2.0, sparklineData: [5, 4, 3] }
        ];
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const tiles = element.shadowRoot.querySelectorAll('c-kpi-tile');
            expect(tiles.length).toBe(2);
        });
    });

    test('bubbles kpiselect event when child tile dispatches tileselect', () => {
        const element = createElement('c-kpi-ribbon', { is: KpiRibbon });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('kpiselect', handler);

        const tile = element.shadowRoot.querySelector('c-kpi-tile');
        tile.dispatchEvent(
            new CustomEvent('tileselect', {
                bubbles: true,
                composed: true,
                detail: { metricKey: 'treasury', label: 'Treasury', value: '£1.2M' }
            })
        );

        expect(handler).toHaveBeenCalledTimes(1);
        expect(handler.mock.calls[0][0].detail.metricKey).toBe('treasury');
    });
});
