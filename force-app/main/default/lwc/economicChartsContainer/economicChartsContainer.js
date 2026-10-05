import { LightningElement, api, wire, track } from 'lwc';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getProductSummaries from '@salesforce/apex/EconomyAnalysisController.getProductSummaries';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';

const COLOR_PALETTE = [
    '#1B96FF', '#0070D2', '#004487', '#002B54', '#04E0D7',
    '#4BCA81', '#04844B', '#FFB75D', '#DD7A00', '#C23934',
    '#9050E9', '#6200EE', '#E91E63', '#009688', '#795548'
];

export default class EconomicChartsContainer extends LightningElement {
    @api analysisId;
    @api countryEconomyId;
    @api productEconomyId;

    @track activeTab = 'gdp-distribution';
    isLoading = true;
    errorMessage = null;

    countrySummaries = [];
    productSummaries = [];
    analysisSummary = null;

    @wire(getAnalysisSummary, { analysisId: '$analysisId' })
    wiredAnalysisSummary({ error, data }) {
        if (data) {
            this.analysisSummary = data;
        } else if (error) {
            this.errorMessage = this.extractErrorMessage(error);
            this.isLoading = false;
        }
    }

    @wire(getCountrySummaries, { analysisId: '$analysisId' })
    wiredCountrySummaries({ error, data }) {
        if (data) {
            this.countrySummaries = data;
            this.isLoading = false;
        } else if (error) {
            this.errorMessage = this.extractErrorMessage(error);
            this.isLoading = false;
        } else if (!this.analysisId) {
            this.isLoading = false;
        }
    }

    @wire(getProductSummaries, { analysisId: '$analysisId' })
    wiredProductSummaries({ error, data }) {
        if (data) {
            this.productSummaries = data;
            this.isLoading = false;
        } else if (error) {
            this.errorMessage = this.extractErrorMessage(error);
            this.isLoading = false;
        }
    }

    handleTabSelect(event) {
        this.activeTab = event.target.value;
    }

    extractErrorMessage(error) {
        if (!error) return 'An unknown error occurred while loading chart data.';
        if (typeof error === 'string') return error;

        let errObj = error;
        while (errObj && errObj.body) {
            errObj = errObj.body;
        }

        if (Array.isArray(errObj) && errObj.length > 0) {
            return errObj.map((e) => (typeof e === 'object' ? e.message || JSON.stringify(e) : String(e))).join(', ');
        } else if (errObj && typeof errObj === 'object' && errObj.message) {
            return errObj.message;
        } else if (error.message) {
            return error.message;
        }
        return 'An unknown error occurred while loading chart data.';
    }

    get hasData() {
        return !!(this.analysisId && (this.countrySummaries.length > 0 || this.productSummaries.length > 0));
    }

    get isGdpDistributionTab() {
        return this.activeTab === 'gdp-distribution';
    }

    get isTradeBalanceTab() {
        return this.activeTab === 'trade-balance';
    }

    get isCountryGdpTab() {
        return this.activeTab === 'country-gdp';
    }

    get isProductSupplyDemandTab() {
        return this.activeTab === 'product-supply-demand';
    }

    get isInflationOverproductionTab() {
        return this.activeTab === 'inflation-overproduction';
    }

    // -------------------------------------------------------------
    // 1. GDP DISTRIBUTION DONUT CHART
    // -------------------------------------------------------------
    get gdpDonutData() {
        if (!this.countrySummaries || this.countrySummaries.length === 0) {
            return { slices: [], legend: [] };
        }

        const totalGdp = this.countrySummaries.reduce((sum, c) => sum + (c.gdp || 0), 0);
        if (totalGdp <= 0) {
            return { slices: [], legend: [] };
        }

        const sorted = [...this.countrySummaries].sort((a, b) => (b.gdp || 0) - (a.gdp || 0));
        const top10 = sorted.slice(0, 10);
        const othersGdp = sorted.slice(10).reduce((sum, c) => sum + (c.gdp || 0), 0);

        const items = top10.map((c, index) => ({
            label: c.countryTag || c.countryName || 'Unknown',
            fullLabel: `${c.countryName || c.countryTag} (${c.countryTag})`,
            gdp: c.gdp || 0,
            percent: ((c.gdp || 0) / totalGdp) * 100,
            color: COLOR_PALETTE[index % COLOR_PALETTE.length]
        }));

        if (othersGdp > 0) {
            items.push({
                label: 'Others',
                fullLabel: 'Other Countries Combined',
                gdp: othersGdp,
                percent: (othersGdp / totalGdp) * 100,
                color: '#706E6B'
            });
        }

        let cumulativeAngle = 0;
        const slices = items.map((item) => {
            let angle = (item.percent / 100) * 360;
            if (angle >= 360) angle = 359.999;
            const startAngle = cumulativeAngle;
            const endAngle = cumulativeAngle + angle;
            cumulativeAngle += angle;

            const path = this.describeArc(200, 200, 150, 80, startAngle, endAngle);
            return {
                ...item,
                path,
                formattedGdp: this.formatCurrency(item.gdp),
                formattedPercent: `${item.percent.toFixed(2)}%`,
                ariaLabel: `${item.fullLabel}: ${item.formattedPercent} (${this.formatCurrency(item.gdp)})`
            };
        });

        return {
            slices,
            legend: slices.map((s) => ({ label: s.label, color: s.color, formattedPercent: s.formattedPercent, colorStyle: `background-color: ${s.color};` }))
        };
    }

    // SVG Donut Path Arc calculation helper
    describeArc(cx, cy, outerRadius, innerRadius, startAngle, endAngle) {
        const startRad = ((startAngle - 90) * Math.PI) / 180.0;
        const endRad = ((endAngle - 90) * Math.PI) / 180.0;

        const x1Outer = cx + outerRadius * Math.cos(startRad);
        const y1Outer = cy + outerRadius * Math.sin(startRad);
        const x2Outer = cx + outerRadius * Math.cos(endRad);
        const y2Outer = cy + outerRadius * Math.sin(endRad);

        const x1Inner = cx + innerRadius * Math.cos(endRad);
        const y1Inner = cy + innerRadius * Math.sin(endRad);
        const x2Inner = cx + innerRadius * Math.cos(startRad);
        const y2Inner = cy + innerRadius * Math.sin(startRad);

        const largeArcFlag = endAngle - startAngle <= 180 ? '0' : '1';

        return [
            `M ${x1Outer} ${y1Outer}`,
            `A ${outerRadius} ${outerRadius} 0 ${largeArcFlag} 1 ${x2Outer} ${y2Outer}`,
            `L ${x1Inner} ${y1Inner}`,
            `A ${innerRadius} ${innerRadius} 0 ${largeArcFlag} 0 ${x2Inner} ${y2Inner}`,
            'Z'
        ].join(' ');
    }

    // -------------------------------------------------------------
    // 2. TRADE BALANCE GROUPED BAR CHART (Top 10 Countries Imports vs Exports)
    // -------------------------------------------------------------
    get tradeBalanceData() {
        if (!this.countrySummaries || this.countrySummaries.length === 0) {
            return { bars: [], maxValue: 0 };
        }

        const sorted = [...this.countrySummaries]
            .sort((a, b) => ((b.totalImports || 0) + (b.totalExports || 0)) - ((a.totalImports || 0) + (a.totalExports || 0)))
            .slice(0, 10);

        let maxValue = 0;
        sorted.forEach((c) => {
            if ((c.totalImports || 0) > maxValue) maxValue = c.totalImports || 0;
            if ((c.totalExports || 0) > maxValue) maxValue = c.totalExports || 0;
        });
        if (maxValue === 0) maxValue = 1;

        const chartHeight = 220;
        const bars = sorted.map((c, index) => {
            const xGroup = 60 + index * 68;
            const importHeight = Math.max(((c.totalImports || 0) / maxValue) * chartHeight, 2);
            const exportHeight = Math.max(((c.totalExports || 0) / maxValue) * chartHeight, 2);

            return {
                countryTag: c.countryTag || 'UNK',
                countryName: c.countryName || c.countryTag,
                xGroup,
                xImport: xGroup,
                xExport: xGroup + 24,
                yImport: 260 - importHeight,
                yExport: 260 - exportHeight,
                importHeight,
                exportHeight,
                formattedImports: this.formatCurrency(c.totalImports || 0),
                formattedExports: this.formatCurrency(c.totalExports || 0),
                ariaLabel: `${c.countryName}: Imports ${this.formatCurrency(c.totalImports || 0)}, Exports ${this.formatCurrency(c.totalExports || 0)}`
            };
        });

        return { bars, formattedMax: this.formatCurrency(maxValue) };
    }

    // -------------------------------------------------------------
    // 3. COUNTRY GDP COMPARISON HORIZONTAL BAR CHART (Top 10)
    // -------------------------------------------------------------
    get countryGdpData() {
        if (!this.countrySummaries || this.countrySummaries.length === 0) {
            return { bars: [], maxValue: 0 };
        }

        const top10 = [...this.countrySummaries]
            .sort((a, b) => (b.gdp || 0) - (a.gdp || 0))
            .slice(0, 10);

        const maxGdp = Math.max(...top10.map((c) => c.gdp || 0), 1);
        const maxBarWidth = 480;

        const bars = top10.map((c, index) => {
            const width = ((c.gdp || 0) / maxGdp) * maxBarWidth;
            const y = 30 + index * 32;
            return {
                countryTag: c.countryTag || 'UNK',
                countryName: c.countryName || c.countryTag,
                gdp: c.gdp || 0,
                y,
                width: Math.max(width, 4),
                formattedGdp: this.formatCurrency(c.gdp || 0),
                color: COLOR_PALETTE[index % COLOR_PALETTE.length],
                ariaLabel: `${c.countryName}: GDP ${this.formatCurrency(c.gdp || 0)}`
            };
        });

        return { bars, formattedMax: this.formatCurrency(maxGdp) };
    }

    // -------------------------------------------------------------
    // 4. PRODUCT SUPPLY VS DEMAND GROUPED BAR CHART (Top 15 Commodities)
    // -------------------------------------------------------------
    get productSupplyDemandData() {
        if (!this.productSummaries || this.productSummaries.length === 0) {
            return { bars: [], maxValue: 0 };
        }

        const top15 = [...this.productSummaries]
            .sort((a, b) => (b.totalWorldSupply || 0) - (a.totalWorldSupply || 0))
            .slice(0, 15);

        let maxValue = 0;
        top15.forEach((p) => {
            if ((p.totalWorldSupply || 0) > maxValue) maxValue = p.totalWorldSupply;
            if ((p.realDemand || 0) > maxValue) maxValue = p.realDemand;
            if ((p.maxDemand || 0) > maxValue) maxValue = p.maxDemand;
        });
        if (maxValue === 0) maxValue = 1;

        const chartHeight = 220;
        const bars = top15.map((p, index) => {
            const xGroup = 50 + index * 48;
            const supplyH = Math.max(((p.totalWorldSupply || 0) / maxValue) * chartHeight, 2);
            const realH = Math.max(((p.realDemand || 0) / maxValue) * chartHeight, 2);
            const maxH = Math.max(((p.maxDemand || 0) / maxValue) * chartHeight, 2);

            return {
                productCode: p.productCode || 'PRD',
                xGroup,
                xSupply: xGroup,
                xReal: xGroup + 12,
                xMax: xGroup + 24,
                ySupply: 260 - supplyH,
                yReal: 260 - realH,
                yMax: 260 - maxH,
                supplyH,
                realH,
                maxH,
                formattedSupply: (p.totalWorldSupply || 0).toLocaleString(),
                formattedReal: (p.realDemand || 0).toLocaleString(),
                formattedMax: (p.maxDemand || 0).toLocaleString(),
                ariaLabel: `${p.productCode}: Supply ${p.totalWorldSupply || 0}, Real Demand ${p.realDemand || 0}, Max Demand ${p.maxDemand || 0}`
            };
        });

        return { bars, formattedMax: maxValue.toLocaleString() };
    }

    // -------------------------------------------------------------
    // 5. INFLATION VS OVERPRODUCTION SCATTER PLOT
    // -------------------------------------------------------------
    get scatterData() {
        if (!this.productSummaries || this.productSummaries.length === 0) {
            return { points: [] };
        }

        const maxSupply = Math.max(...this.productSummaries.map((p) => p.totalWorldSupply || 0), 1);

        // Chart dimensions: X: Inflation (-100% to +100%), Y: Overproduction (0% to +200%)
        const width = 680;
        const height = 300;
        const padding = 50;

        const points = this.productSummaries.map((p) => {
            const inf = p.inflationPercent || 0;
            const overp = p.overproductionPercent || 0;

            // Scale X: -100% maps to padding, +100% maps to width - padding
            const clampedInf = Math.max(-100, Math.min(100, inf));
            const cx = padding + ((clampedInf + 100) / 200) * (width - 2 * padding);

            // Scale Y: 0% maps to height - padding, +200% maps to padding
            const clampedOverp = Math.max(0, Math.min(200, overp));
            const cy = (height - padding) - (clampedOverp / 200) * (height - 2 * padding);

            // Scale radius proportional to world supply: min 5, max 18
            const r = 5 + Math.sqrt((p.totalWorldSupply || 0) / maxSupply) * 13;

            return {
                productCode: p.productCode || 'PRD',
                productName: p.productName || p.productCode,
                cx,
                cy,
                r,
                inf,
                overp,
                formattedInf: `${inf.toFixed(1)}%`,
                formattedOverp: `${overp.toFixed(1)}%`,
                formattedSupply: (p.totalWorldSupply || 0).toLocaleString(),
                ariaLabel: `${p.productCode}: Inflation ${inf.toFixed(1)}%, Overproduction ${overp.toFixed(1)}%, Supply ${p.totalWorldSupply || 0}`
            };
        });

        return { points };
    }

    formatCurrency(val) {
        if (val == null) return '£0';
        return '£' + Math.round(val).toLocaleString();
    }
}
