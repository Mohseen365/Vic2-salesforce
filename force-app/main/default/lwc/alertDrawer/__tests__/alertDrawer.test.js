import { createElement } from 'lwc';
import AlertDrawer from 'c/alertDrawer';

describe('c-alert-drawer', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('toggles notification panel on click', () => {
        const element = createElement('c-alert-drawer', {
            is: AlertDrawer
        });
        document.body.appendChild(element);

        let panel = element.shadowRoot.querySelector('[data-testid="alert-panel"]');
        expect(panel).toBeNull();

        const toggleBtn = element.shadowRoot.querySelector('[data-testid="alert-drawer-toggle"]');
        toggleBtn.click();

        return Promise.resolve().then(() => {
            panel = element.shadowRoot.querySelector('[data-testid="alert-panel"]');
            expect(panel).not.toBeNull();
        });
    });
});
