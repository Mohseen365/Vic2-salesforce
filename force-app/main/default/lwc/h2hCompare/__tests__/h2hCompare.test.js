import { createElement } from 'lwc';
import H2hCompare from 'c/h2hCompare';
import getAllRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getAllRecentAnalyses';
import getHeadToHeadComparison from '@salesforce/apex/TimeSeriesController.getHeadToHeadComparison';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetAllRecentAnalyses = registerApexTestWireAdapter(getAllRecentAnalyses);
const mockGetHeadToHeadComparison = registerApexTestWireAdapter(getHeadToHeadComparison);

describe('c-h2h-compare', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders scorecard grid when comparison data is available', async () => {
        const element = createElement('c-h2h-compare', {
            is: H2hCompare
        });
        document.body.appendChild(element);

        mockGetAllRecentAnalyses.emit([
            { Id: 'a01000000000001', Save_File_Name__c: 'saveA.v2' },
            { Id: 'a01000000000002', Save_File_Name__c: 'saveB.v2' }
        ]);

        mockGetHeadToHeadComparison.emit({
            baseId: 'a01000000000001',
            baseGdp: 200000,
            basePopulation: 10000000,
            baseImports: 30000,
            baseExports: 40000,
            compareId: 'a01000000000002',
            compareGdp: 300000,
            comparePopulation: 12000000,
            compareImports: 40000,
            compareExports: 50000
        });

        await Promise.resolve();

        const grid = element.shadowRoot.querySelector('.scorecard-grid');
        expect(grid).not.toBeNull();
    });
});
