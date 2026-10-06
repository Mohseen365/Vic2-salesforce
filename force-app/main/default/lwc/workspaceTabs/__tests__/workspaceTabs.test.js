import { createElement } from 'lwc';
import WorkspaceTabs from 'c/workspaceTabs';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import getDerivedMetrics from '@salesforce/apex/DerivedIntelligenceController.getDerivedMetrics';

const mockGetDerivedMetrics = registerApexTestWireAdapter(getDerivedMetrics);

describe('c-workspace-tabs', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('renders economy tab view by default', () => {
        const element = createElement('c-workspace-tabs', { is: WorkspaceTabs });
        document.body.appendChild(element);

        const economyView = element.shadowRoot.querySelector('[data-testid="economy-view"]');
        expect(economyView).not.toBeNull();

        const shell = element.shadowRoot.querySelector('c-economy-analyzer-shell');
        expect(shell).not.toBeNull();
    });

    test('switches active tab view when tab link clicked', () => {
        const element = createElement('c-workspace-tabs', { is: WorkspaceTabs });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('tabselect', handler);

        const popsTabLink = element.shadowRoot.querySelector('a[data-key="pops"]');
        expect(popsTabLink).not.toBeNull();
        popsTabLink.click();

        return Promise.resolve().then(() => {
            expect(handler).toHaveBeenCalledTimes(1);
            expect(handler.mock.calls[0][0].detail.activeTabKey).toBe('pops');

            const popsView = element.shadowRoot.querySelector('[data-testid="pops-view"]');
            expect(popsView).not.toBeNull();
        });
    });

    test('renders overview tab when activeTabKey is overview', () => {
        const element = createElement('c-workspace-tabs', { is: WorkspaceTabs });
        element.activeTabKey = 'overview';
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const overviewView = element.shadowRoot.querySelector('[data-testid="overview-view"]');
            expect(overviewView).not.toBeNull();
        });
    });
});
