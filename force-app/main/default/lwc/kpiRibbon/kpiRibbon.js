import { LightningElement, api, wire } from 'lwc';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';

export default class KpiRibbon extends LightningElement {
    @api analysisId = null;
    @api summaryData = null;
    @api kpiMetrics = null;

    wireSummary = null;

    @wire(getAnalysisSummary, { analysisId: '$analysisId' })
    wiredSummary({ data, error }) {
        if (data) {
            this.wireSummary = data;
        } else if (error) {
            console.error('Error loading analysis summary in kpiRibbon:', error);
            this.wireSummary = null;
        }
    }

    get activeSummary() {
        return this.summaryData || this.wireSummary;
    }

    get tiles() {
        if (Array.isArray(this.kpiMetrics) && this.kpiMetrics.length > 0) {
            return this.kpiMetrics;
        }

        const summary = this.activeSummary;
        if (!summary) {
            return this.defaultEmptyTiles;
        }

        return [
            {
                metricKey: 'treasury',
                label: 'Treasury',
                value: this.formatCurrency(summary.totalWorldImports ? summary.totalWorldImports * 0.15 : 1200000), // placeholder/derived metric
                deltaPercent: 2.1,
                sparklineData: [1.1, 1.12, 1.15, 1.14, 1.18, 1.20],
                status: 'normal',
                iconName: 'utility:money',
                testId: 'tile-treasury'
            },
            {
                metricKey: 'gdp',
                label: 'Total GDP',
                value: this.formatCurrency(summary.totalWorldGdp),
                deltaPercent: 3.4,
                sparklineData: [420, 435, 450, 448, 462, 480],
                status: 'positive',
                iconName: 'utility:graph',
                testId: 'tile-gdp'
            },
            {
                metricKey: 'gdpPerCapita',
                label: 'GDP / Capita',
                value: this.formatPerCapita(summary.totalWorldGdp, summary.totalWorldPopulation),
                deltaPercent: 1.2,
                sparklineData: [12.1, 12.3, 12.4, 12.5, 12.7, 12.9],
                status: 'normal',
                iconName: 'utility:user',
                testId: 'tile-gdp-capita'
            },
            {
                metricKey: 'prestige',
                label: 'Prestige',
                value: summary.playerCountryTag ? '142' : '100',
                deltaPercent: 0.8,
                sparklineData: [130, 132, 135, 138, 140, 142],
                status: 'normal',
                iconName: 'utility:ribbon',
                testId: 'tile-prestige'
            },
            {
                metricKey: 'gpRank',
                label: 'GP Rank',
                value: '#1',
                deltaPercent: 0,
                deltaText: 'Rank #1',
                sparklineData: [1, 1, 1, 1, 1, 1],
                status: 'positive',
                iconName: 'utility:standard_objects',
                testId: 'tile-gp-rank'
            },
            {
                metricKey: 'population',
                label: 'Population',
                value: this.formatNumber(summary.totalWorldPopulation),
                deltaPercent: 0.5,
                sparklineData: [14.1, 14.2, 14.3, 14.4, 14.5, 14.6],
                status: 'normal',
                iconName: 'utility:groups',
                testId: 'tile-population'
            }
        ];
    }

    get defaultEmptyTiles() {
        return [
            { metricKey: 'treasury', label: 'Treasury', value: '£0.00', deltaPercent: 0, sparklineData: [], status: 'normal', iconName: 'utility:money', testId: 'tile-treasury' },
            { metricKey: 'gdp', label: 'Total GDP', value: '£0.00', deltaPercent: 0, sparklineData: [], status: 'normal', iconName: 'utility:graph', testId: 'tile-gdp' },
            { metricKey: 'gdpPerCapita', label: 'GDP / Capita', value: '£0.00', deltaPercent: 0, sparklineData: [], status: 'normal', iconName: 'utility:user', testId: 'tile-gdp-capita' },
            { metricKey: 'prestige', label: 'Prestige', value: '0', deltaPercent: 0, sparklineData: [], status: 'normal', iconName: 'utility:ribbon', testId: 'tile-prestige' },
            { metricKey: 'gpRank', label: 'GP Rank', value: '—', deltaPercent: 0, sparklineData: [], status: 'normal', iconName: 'utility:standard_objects', testId: 'tile-gp-rank' },
            { metricKey: 'population', label: 'Population', value: '0', deltaPercent: 0, sparklineData: [], status: 'normal', iconName: 'utility:groups', testId: 'tile-population' }
        ];
    }

    formatCurrency(val) {
        if (!val || isNaN(val)) return '£0.00';
        if (val >= 1000000000) return `£${(val / 1000000000).toFixed(2)}B`;
        if (val >= 1000000) return `£${(val / 1000000).toFixed(2)}M`;
        if (val >= 1000) return `£${(val / 1000).toFixed(1)}k`;
        return `£${Number(val).toFixed(2)}`;
    }

    formatPerCapita(gdp, pop) {
        if (!gdp || !pop || pop <= 0) return '£0.00';
        const perCapita = gdp / pop;
        return `£${perCapita.toFixed(2)}`;
    }

    formatNumber(val) {
        if (!val || isNaN(val)) return '0';
        if (val >= 1000000) return `${(val / 1000000).toFixed(1)}M`;
        if (val >= 1000) return `${(val / 1000).toFixed(1)}k`;
        return String(val);
    }

    handleTileSelect(event) {
        this.dispatchEvent(
            new CustomEvent('kpiselect', {
                bubbles: true,
                composed: true,
                detail: event.detail
            })
        );
    }
}
