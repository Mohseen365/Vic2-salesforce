import { createElement } from 'lwc';
import CampaignGallery from 'c/campaignGallery';
import getAllRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getAllRecentAnalyses';
import { registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

const mockGetAllRecentAnalyses = registerApexTestWireAdapter(getAllRecentAnalyses);

describe('c-campaign-gallery', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders campaign cards gallery grid', async () => {
        const element = createElement('c-campaign-gallery', {
            is: CampaignGallery
        });
        document.body.appendChild(element);

        mockGetAllRecentAnalyses.emit([
            { Id: 'a01000000000001', Save_File_Name__c: 'EGY_1836.v2', Ingame_Date__c: '1836-01-01', Total_World_GDP__c: 100000 }
        ]);

        await Promise.resolve();

        const cards = element.shadowRoot.querySelectorAll('.campaign-card');
        expect(cards.length).toBeGreaterThan(0);
    });
});
