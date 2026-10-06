import { createElement } from 'lwc';
import LensView from 'c/lensView';

const MOCK_LENS = {
    capabilityId: 'CAP-D-001',
    title: 'Tax Rate vs. GDP Growth Rate',
    category: 'Economy × Politics',
    status: 'Optimal',
    headline: 'Ottoman Empire maintains an effective tax rate of 25.0% with a GDP growth rate of +4.25%.',
    primaryMetricFormatted: '25.0%',
    secondaryMetricFormatted: '+4.25%',
    countryTag: 'TUR',
    countryName: 'Ottoman Empire',
    dataPoints: [
        { x: 25.0, y: 4.25, size: 1.0, label: 'TUR', category: 'Country', meta: 'GDP: £7,010,392' },
        { x: 22.5, y: 2.10, size: 1.0, label: 'ENG', category: 'Country', meta: 'GDP: £3,866,996' }
    ],
    evidence: {
        sourceObjects: ['RichTax__c', 'MiddleTax__c', 'Country_Economy__c'],
        formulaDetails: 'Effective Tax Rate = (Rich Tax % + Middle Tax %) / 2',
        provenanceBadges: ['Phase 2 Engine', 'FEAT-17-lite']
    }
};

describe('c-lens-view', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders lens title and headline correctly', () => {
        const element = createElement('c-lens-view', {
            is: LensView
        });
        element.lensData = MOCK_LENS;
        document.body.appendChild(element);

        const card = element.shadowRoot.querySelector('[data-testid="lens-view-card"]');
        expect(card).not.toBeNull();

        const headline = element.shadowRoot.querySelector('.briefing-headline');
        expect(headline.textContent).toContain('Ottoman Empire maintains an effective tax rate');
    });

    it('toggles evidence drawer on button click', () => {
        const element = createElement('c-lens-view', {
            is: LensView
        });
        element.lensData = MOCK_LENS;
        document.body.appendChild(element);

        let drawer = element.shadowRoot.querySelector('[data-testid="evidence-drawer"]');
        expect(drawer).toBeNull();

        const toggleBtn = element.shadowRoot.querySelector('[data-testid="toggle-evidence-btn"]');
        toggleBtn.click();

        return Promise.resolve().then(() => {
            drawer = element.shadowRoot.querySelector('[data-testid="evidence-drawer"]');
            expect(drawer).not.toBeNull();
        });
    });
});
