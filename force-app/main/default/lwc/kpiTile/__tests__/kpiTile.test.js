import { createElement } from 'lwc';
import KpiTile from 'c/kpiTile';

describe('c-kpi-tile', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('renders label, value and delta correctly', () => {
        const element = createElement('c-kpi-tile', { is: KpiTile });
        element.label = 'Treasury';
        element.value = '£1.2M';
        element.deltaPercent = 2.1;
        document.body.appendChild(element);

        const valueEl = element.shadowRoot.querySelector('[data-testid="kpi-value"]');
        expect(valueEl.textContent.trim()).toBe('£1.2M');

        const deltaEl = element.shadowRoot.querySelector('[data-testid="kpi-delta"]');
        expect(deltaEl.textContent).toContain('▲');
        expect(deltaEl.textContent).toContain('+2.1%');
        expect(deltaEl.className).toContain('delta-positive');
    });

    test('renders negative delta with downward arrow and negative class', () => {
        const element = createElement('c-kpi-tile', { is: KpiTile });
        element.label = 'Unemployment';
        element.value = '5.4%';
        element.deltaPercent = -1.5;
        document.body.appendChild(element);

        const deltaEl = element.shadowRoot.querySelector('[data-testid="kpi-delta"]');
        expect(deltaEl.textContent).toContain('▼');
        expect(deltaEl.textContent).toContain('-1.5%');
        expect(deltaEl.className).toContain('delta-negative');
    });

    test('renders sparkline when data is provided', () => {
        const element = createElement('c-kpi-tile', { is: KpiTile });
        element.label = 'GDP';
        element.value = '£100M';
        element.sparklineData = [10, 20, 15, 25, 30];
        document.body.appendChild(element);

        const sparklineEl = element.shadowRoot.querySelector('[data-testid="kpi-sparkline"]');
        expect(sparklineEl).not.toBeNull();

        const pathEl = element.shadowRoot.querySelector('path');
        expect(pathEl).not.toBeNull();
        expect(pathEl.getAttribute('d')).toContain('M');
    });

    test('emits tileselect event when clicked', () => {
        const element = createElement('c-kpi-tile', { is: KpiTile });
        element.label = 'Prestige';
        element.value = '142';
        element.metricKey = 'prestige';
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('tileselect', handler);

        const container = element.shadowRoot.querySelector('[data-testid="kpi-tile-container"]');
        container.click();

        expect(handler).toHaveBeenCalledTimes(1);
        expect(handler.mock.calls[0][0].detail).toEqual({
            metricKey: 'prestige',
            label: 'Prestige',
            value: '142'
        });
    });
});
