import { createElement } from 'lwc';
import NavRail from 'c/navRail';

describe('c-nav-rail', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('renders expanded navigation rail by default with domain items', () => {
        const element = createElement('c-nav-rail', { is: NavRail });
        document.body.appendChild(element);

        const container = element.shadowRoot.querySelector('[data-testid="nav-rail-container"]');
        expect(container.className).toContain('nav-rail-expanded');

        const overviewLink = element.shadowRoot.querySelector('a[data-key="overview"]');
        expect(overviewLink).not.toBeNull();
    });

    test('toggles collapse state when toggle button clicked', () => {
        const element = createElement('c-nav-rail', { is: NavRail });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('collapsetoggle', handler);

        const toggleBtn = element.shadowRoot.querySelector('[data-testid="nav-collapse-toggle"]');
        toggleBtn.click();

        return Promise.resolve().then(() => {
            expect(handler).toHaveBeenCalledTimes(1);
            expect(handler.mock.calls[0][0].detail.isCollapsed).toBe(true);

            const container = element.shadowRoot.querySelector('[data-testid="nav-rail-container"]');
            expect(container.className).toContain('nav-rail-collapsed');
        });
    });

    test('dispatches navselect event when item clicked', () => {
        const element = createElement('c-nav-rail', { is: NavRail });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('navselect', handler);

        const economyLink = element.shadowRoot.querySelector('a[data-key="economy"]');
        economyLink.click();

        expect(handler).toHaveBeenCalledTimes(1);
        expect(handler.mock.calls[0][0].detail.domainKey).toBe('economy');
    });
});
