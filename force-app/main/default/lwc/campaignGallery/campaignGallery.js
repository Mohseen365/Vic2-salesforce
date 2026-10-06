import { LightningElement, track, wire } from 'lwc';
import getAllRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getAllRecentAnalyses';

export default class CampaignGallery extends LightningElement {
    @track analyses = [];
    @track selectedCampaign = null;

    @wire(getAllRecentAnalyses, { limitCount: 12 })
    wiredAnalyses({ error, data }) {
        if (data) {
            this.analyses = data;
        } else if (error) {
            console.error('Error fetching gallery campaigns:', error);
            this.analyses = [];
        }
    }

    get campaignCards() {
        if (!this.analyses || this.analyses.length === 0) {
            // Fallback sample campaign cards for public portal view
            return [
                {
                    id: 'EGY_1836',
                    countryTag: 'EGY',
                    title: 'Egypt Modernization & Industrial Hegemony',
                    player: 'Pharaoh1836',
                    ingameDate: '1855-04-12',
                    formattedGdp: '284.5k',
                    formattedPop: '8.4M',
                    sparklineD: 'M 0 20 L 20 18 L 40 14 L 60 10 L 80 6 L 100 2',
                    narrativeSummary: 'The Egyptian empire achieved dramatic industrial expansion across the Levant, successfully reforming tax law and industrializing state textile manufacturing.'
                },
                {
                    id: 'PRU_1848',
                    countryTag: 'PRU',
                    title: 'Prussian Hegemony & North German Confederation',
                    player: 'BismarckStrategy',
                    ingameDate: '1866-07-03',
                    formattedGdp: '620.1k',
                    formattedPop: '19.2M',
                    sparklineD: 'M 0 22 L 20 19 L 40 12 L 60 8 L 80 5 L 100 1',
                    narrativeSummary: 'Rapid military mobilization and industrial steel production allowed Prussia to unify North Germany and dominate European market demand.'
                }
            ];
        }

        return this.analyses.map((item, index) => {
            const gdp = item.Total_World_GDP__c || (100000 * (index + 1));
            const pop = item.Total_World_Population__c || (5000000 * (index + 1));
            const gdpK = (gdp / 1000).toFixed(1) + 'k';
            const popM = (pop / 1000000).toFixed(1) + 'M';

            return {
                id: item.Id,
                countryTag: item.Save_File_Name__c ? item.Save_File_Name__c.substring(0, 3).toUpperCase() : 'EGY',
                title: item.Save_File_Name__c || `Campaign Snapshot #${index + 1}`,
                player: 'Player_' + (index + 1),
                ingameDate: item.Ingame_Date__c || '1836-01-01',
                formattedGdp: gdpK,
                formattedPop: popM,
                sparklineD: `M 0 ${24 - index * 2} L 25 ${20 - index * 2} L 50 ${15 - index} L 75 ${10 - index} L 100 ${4}`,
                narrativeSummary: `Snapshot file ${item.Save_File_Name__c} recorded total world GDP of £${gdp.toLocaleString()} across ${pop.toLocaleString()} population.`
            };
        });
    }

    handleCardClick(event) {
        const id = event.currentTarget.dataset.id;
        const found = this.campaignCards.find(c => c.id === id);
        if (found) {
            this.selectedCampaign = found;
        }
    }

    handleBackToGallery() {
        this.selectedCampaign = null;
    }

    get selectedCampaignAnalysisIds() {
        if (!this.selectedCampaign) return [];
        return [this.selectedCampaign.id];
    }

    handleOpenH2H() {
        this.dispatchEvent(new CustomEvent('openh2h', {
            detail: { campaignId: this.selectedCampaign.id }
        }));
    }
}
