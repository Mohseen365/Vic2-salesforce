import { LightningElement, api, wire, track } from 'lwc';
import getAllRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getAllRecentAnalyses';
import getHeadToHeadComparison from '@salesforce/apex/TimeSeriesController.getHeadToHeadComparison';

export default class H2hCompare extends LightningElement {
    @api baseSnapshotId;
    @api compareSnapshotId;
    @track analyses = [];
    @track comparisonData = null;

    @wire(getAllRecentAnalyses, { limitCount: 12 })
    wiredAnalyses({ error, data }) {
        if (data) {
            this.analyses = data;
            if (!this.baseSnapshotId && data.length > 0) this.baseSnapshotId = data[0].Id;
            if (!this.compareSnapshotId && data.length > 1) this.compareSnapshotId = data[1].Id;
        } else if (error) {
            console.error('Error fetching analyses for H2H:', error);
        }
    }

    @wire(getHeadToHeadComparison, { baseSnapshotId: '$baseSnapshotId', compareSnapshotId: '$compareSnapshotId' })
    wiredComparison({ error, data }) {
        if (data) {
            this.comparisonData = data;
        } else if (error) {
            console.error('Error fetching H2H comparison:', error);
            this.comparisonData = null;
        }
    }

    get snapshotOptions() {
        return this.analyses.map((item, index) => ({
            label: item.Save_File_Name__c || `Snapshot #${index + 1}`,
            value: item.Id
        }));
    }

    handleBaseChange(event) {
        this.baseSnapshotId = event.detail.value;
    }

    handleCompareChange(event) {
        this.compareSnapshotId = event.detail.value;
    }

    get hasData() {
        return !!this.comparisonData && Object.keys(this.comparisonData).length > 0;
    }

    get scorecardRows() {
        if (!this.hasData) {
            // Sample baseline comparison data
            return [
                {
                    metricKey: 'gdp',
                    title: 'Total World GDP',
                    valAFormatted: '£250,000.00',
                    valBFormatted: '£320,000.00',
                    barAStyle: 'width: 43.8%',
                    barBStyle: 'width: 56.2%'
                },
                {
                    metricKey: 'pop',
                    title: 'Total Population',
                    valAFormatted: '12.5M',
                    valBFormatted: '15.0M',
                    barAStyle: 'width: 45.4%',
                    barBStyle: 'width: 54.6%'
                },
                {
                    metricKey: 'trade',
                    title: 'Total World Trade',
                    valAFormatted: '£45,000.00',
                    valBFormatted: '£50,000.00',
                    barAStyle: 'width: 47.3%',
                    barBStyle: 'width: 52.7%'
                }
            ];
        }

        const data = this.comparisonData;
        const gdpA = data.baseGdp || 0;
        const gdpB = data.compareGdp || 0;
        const totalGdp = gdpA + gdpB || 1;
        const pctGdpA = ((gdpA / totalGdp) * 100).toFixed(1);
        const pctGdpB = ((gdpB / totalGdp) * 100).toFixed(1);

        const popA = data.basePopulation || 0;
        const popB = data.comparePopulation || 0;
        const totalPop = popA + popB || 1;
        const pctPopA = ((popA / totalPop) * 100).toFixed(1);
        const pctPopB = ((popB / totalPop) * 100).toFixed(1);

        const tradeA = (data.baseImports || 0) + (data.baseExports || 0);
        const tradeB = (data.compareImports || 0) + (data.compareExports || 0);
        const totalTrade = tradeA + tradeB || 1;
        const pctTradeA = ((tradeA / totalTrade) * 100).toFixed(1);
        const pctTradeB = ((tradeB / totalTrade) * 100).toFixed(1);

        return [
            {
                metricKey: 'gdp',
                title: 'Total World GDP',
                valAFormatted: '£' + gdpA.toLocaleString(),
                valBFormatted: '£' + gdpB.toLocaleString(),
                barAStyle: `width: ${pctGdpA}%`,
                barBStyle: `width: ${pctGdpB}%`
            },
            {
                metricKey: 'pop',
                title: 'Total Population',
                valAFormatted: (popA / 1000000).toFixed(1) + 'M',
                valBFormatted: (popB / 1000000).toFixed(1) + 'M',
                barAStyle: `width: ${pctPopA}%`,
                barBStyle: `width: ${pctPopB}%`
            },
            {
                metricKey: 'trade',
                title: 'Total World Trade',
                valAFormatted: '£' + tradeA.toLocaleString(),
                valBFormatted: '£' + tradeB.toLocaleString(),
                barAStyle: `width: ${pctTradeA}%`,
                barBStyle: `width: ${pctTradeB}%`
            }
        ];
    }
}
