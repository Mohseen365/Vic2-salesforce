import { createElement } from 'lwc';
import SnapshotFilmstrip from 'c/snapshotFilmstrip';
import getAllRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getAllRecentAnalyses';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetAllRecentAnalyses = registerApexTestWireAdapter(getAllRecentAnalyses);

jest.mock(
    '@salesforce/apex/TimeSeriesController.getEventTicks',
    () => ({ default: jest.fn().mockResolvedValue([]) }),
    { virtual: true }
);

describe('c-snapshot-filmstrip', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders snapshot filmstrip track when data is returned', async () => {
        const element = createElement('c-snapshot-filmstrip', {
            is: SnapshotFilmstrip
        });
        document.body.appendChild(element);

        mockGetAllRecentAnalyses.emit([
            { Id: 'a01000000000001', Save_File_Name__c: 'save1.v2', Ingame_Date__c: '1836-01-01', Total_World_GDP__c: 100000 },
            { Id: 'a01000000000002', Save_File_Name__c: 'save2.v2', Ingame_Date__c: '1837-01-01', Total_World_GDP__c: 120000 }
        ]);

        await Promise.resolve();

        const slotCards = element.shadowRoot.querySelectorAll('.filmstrip-slot');
        expect(slotCards.length).toBe(2);
    });
});
