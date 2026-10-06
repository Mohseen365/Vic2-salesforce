import { createElement } from 'lwc';
import ScoreCard from 'c/scoreCard';

describe('c-score-card', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders metric header and score gauge correctly', () => {
        const element = createElement('c-score-card', {
            is: ScoreCard
        });
        element.metric = {
            metricId: 'MET-D-001',
            metricName: 'Human Development Index (HDI)',
            category: 'Composite Indices',
            score: 75.0,
            formattedScore: '75.0',
            delta: 2.5,
            deltaFormatted: '+2.5',
            status: 'Optimal',
            countryTag: 'TUR',
            countryName: 'Ottoman Empire',
            formulaVersion: 'v1.0.0',
            formulaDescription: '0.33 * (Literacy / 100) + 0.33 * ln(GDP/cap) + 0.34 * (Need Fulfillment / 100)',
            sourceFields: ['Pop__c.Literacy__c'],
            components: []
        };
        document.body.appendChild(element);

        const titleEl = element.shadowRoot.querySelector('h3');
        expect(titleEl.textContent).toContain('Human Development Index');

        const scoreEl = element.shadowRoot.querySelector('.score-value');
        expect(scoreEl.textContent).toContain('75.0');
    });

    it('toggles trust drawer on button click', () => {
        const element = createElement('c-score-card', {
            is: ScoreCard
        });
        document.body.appendChild(element);

        let drawer = element.shadowRoot.querySelector('[data-testid="trust-drawer"]');
        expect(drawer).toBeNull();

        const toggleBtn = element.shadowRoot.querySelector('[data-testid="trust-drawer-toggle"]');
        toggleBtn.click();

        return Promise.resolve().then(() => {
            drawer = element.shadowRoot.querySelector('[data-testid="trust-drawer"]');
            expect(drawer).not.toBeNull();
        });
    });
});
