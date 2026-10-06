import { createElement } from 'lwc';
import GlobalContextBar from 'c/globalContextBar';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import { setContext, getContext } from 'c/contextStore';

const mockGetRecentAnalyses = registerApexTestWireAdapter(getRecentAnalyses);
const mockGetCountrySummaries = registerApexTestWireAdapter(getCountrySummaries);
const mockGetAnalysisSummary = registerApexTestWireAdapter(getAnalysisSummary);

describe('c-global-context-bar', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    test('renders top-level controls and status chip', () => {
        const element = createElement('c-global-context-bar', { is: GlobalContextBar });
        document.body.appendChild(element);

        mockGetRecentAnalyses.emit([
            { Id: 'a01000000000001AAA', Name: 'Analysis 1', Save_File_Name__c: 'save_1836.v2', Ingame_Date__c: '1836-01-01', Import_Status__c: 'PUBLISHED' }
        ]);

        return Promise.resolve().then(() => {
            const statusChip = element.shadowRoot.querySelector('[data-testid="status-chip"]');
            expect(statusChip).not.toBeNull();
            expect(statusChip.textContent.trim()).toBe('PUBLISHED');
        });
    });

    test('updates selected save on combobox change and fires contextchange', () => {
        const element = createElement('c-global-context-bar', { is: GlobalContextBar });
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('contextchange', handler);

        mockGetRecentAnalyses.emit([
            { Id: 'a01000000000001AAA', Save_File_Name__c: 'save1' },
            { Id: 'a01000000000002AAA', Save_File_Name__c: 'save2' }
        ]);

        return Promise.resolve().then(() => {
            const saveCombobox = element.shadowRoot.querySelector('[data-testid="save-selector"]');
            saveCombobox.dispatchEvent(new CustomEvent('change', { detail: { value: 'a01000000000002AAA' } }));

            expect(handler).toHaveBeenCalledTimes(1);
            expect(getContext().snapshotId).toBe('a01000000000002AAA');
        });
    });

    test('toggles advisor drawer overlay', () => {
        const element = createElement('c-global-context-bar', { is: GlobalContextBar });
        document.body.appendChild(element);

        const advisorBtn = element.shadowRoot.querySelector('[data-testid="advisor-toggle-btn"]');
        expect(advisorBtn).not.toBeNull();

        advisorBtn.click();

        return Promise.resolve().then(() => {
            const overlay = element.shadowRoot.querySelector('[data-testid="advisor-drawer-overlay"]');
            expect(overlay).not.toBeNull();
        });
    });
});
