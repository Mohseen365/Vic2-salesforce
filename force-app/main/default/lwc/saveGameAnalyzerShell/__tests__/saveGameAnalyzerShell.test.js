import { createElement } from 'lwc';
import SaveGameAnalyzerShell from 'c/saveGameAnalyzerShell';

describe('c-save-game-analyzer-shell', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('renders master header, global context bar, nav rail, workspace tabs, and status footer', () => {
        const element = createElement('c-save-game-analyzer-shell', { is: SaveGameAnalyzerShell });
        document.body.appendChild(element);

        const header = element.shadowRoot.querySelector('h1');
        expect(header.textContent.trim()).toBe('Victoria 2 Command Center');

        const contextBar = element.shadowRoot.querySelector('c-global-context-bar');
        expect(contextBar).not.toBeNull();

        const navRail = element.shadowRoot.querySelector('c-nav-rail');
        expect(navRail).not.toBeNull();

        const tabs = element.shadowRoot.querySelector('c-workspace-tabs');
        expect(tabs).not.toBeNull();

        const footer = element.shadowRoot.querySelector('[data-testid="status-footer"]');
        expect(footer).not.toBeNull();
    });

    test('updates activeTabKey when navselect or tabselect event fires', () => {
        const element = createElement('c-save-game-analyzer-shell', { is: SaveGameAnalyzerShell });
        document.body.appendChild(element);

        const navRail = element.shadowRoot.querySelector('c-nav-rail');
        navRail.dispatchEvent(
            new CustomEvent('navselect', {
                bubbles: true,
                composed: true,
                detail: { domainKey: 'pops' }
            })
        );

        return Promise.resolve().then(() => {
            const tabs = element.shadowRoot.querySelector('c-workspace-tabs');
            expect(tabs.activeTabKey).toBe('pops');
        });
    });
});
