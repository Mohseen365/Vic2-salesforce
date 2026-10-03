import { LightningElement, api, wire } from 'lwc';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';
import getWorldTrend from '@salesforce/apex/EconomyAnalysisController.getWorldTrend';
import getCountryTrend from '@salesforce/apex/EconomyAnalysisController.getCountryTrend';
import getProductTrend from '@salesforce/apex/EconomyAnalysisController.getProductTrend';

const COLOR_PALETTE = [
    '#0070D2', '#04844B', '#DD7A00', '#9050E9', '#C23934',
    '#1B96FF', '#4BCA81', '#FFB75D', '#6200EE', '#04E0D7'
];

const DELTA_COLUMNS = [
    { label: 'Tag', fieldName: 'countryTag', type: 'text', initialWidth: 90 },
    { label: 'Country Name', fieldName: 'countryName', type: 'text' },
    { label: 'Base GDP (£)', fieldName: 'baseGdp', type: 'currency', typeAttributes: { currencyCode: 'GBP' } },
    { label: 'Latest GDP (£)', fieldName: 'latestGdp', type: 'currency', typeAttributes: { currencyCode: 'GBP' } },
    { label: 'Change (£)', fieldName: 'gdpDelta', type: 'currency', typeAttributes: { currencyCode: 'GBP' } },
    { label: 'Growth %', fieldName: 'growthPercentFormatted', type: 'text', initialWidth: 120 }
];

export default class MultiSaveTrend extends LightningElement {
    _analysisIds = [];
    _countryTags = [];
    _productCodes = [];

    @api
    get analysisIds() {
        return this._analysisIds;
    }
    set analysisIds(val) {
        this._analysisIds = Array.isArray(val) ? val : [];
        if (this._analysisIds.length > 0) {
            this.selectedAnalysisIds = this._analysisIds.slice(0, 12);
        }
    }

    @api
    get countryTags() {
        return this._countryTags;
    }
    set countryTags(val) {
        this._countryTags = Array.isArray(val) ? val : [];
    }

    @api
    get productCodes() {
        return this._productCodes;
    }
    set productCodes(val) {
        this._productCodes = Array.isArray(val) ? val : [];
    }

    recentAnalyses = [];
    selectedAnalysisIds = [];
    isCapExceeded = false;
    isLoading = false;
    errorMessage = undefined;

    worldTrendData = null;
    countryTrendData = null;
    productTrendData = null;

    deltaColumns = DELTA_COLUMNS;

    @wire(getRecentAnalyses, { limitCount: 50 })
    wiredRecentAnalyses({ error, data }) {
        if (data) {
            this.recentAnalyses = data;
            if (this.selectedAnalysisIds.length === 0 && data.length >= 3) {
                // Pre-select first 3 chronologically/recently
                this.selectedAnalysisIds = data.slice(0, Math.min(data.length, 5)).map(a => a.Id);
            }
        } else if (error) {
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    @wire(getWorldTrend, { analysisIds: '$activeAnalysisIds' })
    wiredWorldTrend({ error, data }) {
        if (data) {
            this.worldTrendData = data;
        } else if (error) {
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    @wire(getCountryTrend, { countryTags: '$activeCountryTags', analysisIds: '$activeAnalysisIds' })
    wiredCountryTrend({ error, data }) {
        if (data) {
            this.countryTrendData = data;
        } else if (error) {
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    @wire(getProductTrend, { productCodes: '$activeProductCodes', analysisIds: '$activeAnalysisIds' })
    wiredProductTrend({ error, data }) {
        if (data) {
            this.productTrendData = data;
        } else if (error) {
            this.errorMessage = this.extractErrorMessage(error);
        }
    }

    get analysisOptions() {
        if (!this.recentAnalyses) return [];
        return this.recentAnalyses.map(a => ({
            label: `${a.Save_File_Name__c || a.Name} (${a.Ingame_Date__c || 'N/A'})`,
            value: a.Id
        }));
    }

    get activeAnalysisIds() {
        return this.selectedAnalysisIds;
    }

    get activeCountryTags() {
        return this.countryTags;
    }

    get activeProductCodes() {
        return this.productCodes;
    }

    get isFewerThanThreeSelected() {
        return !this.selectedAnalysisIds || this.selectedAnalysisIds.length < 3;
    }

    get hasEnoughSnapshots() {
        return Boolean(this.selectedAnalysisIds && this.selectedAnalysisIds.length >= 3);
    }

    get hasWorldTrendData() {
        return Boolean(this.worldTrendData && this.worldTrendData.points && this.worldTrendData.points.length > 0);
    }

    get hasCountryTrendData() {
        return Boolean(this.countryTrendData && this.countryTrendData.series && this.countryTrendData.series.length > 0);
    }

    get hasProductTrendData() {
        return Boolean(this.productTrendData && this.productTrendData.series && this.productTrendData.series.length > 0);
    }

    handleAnalysisPickerChange(event) {
        const selected = event.detail.value || [];
        if (selected.length > 12) {
            this.isCapExceeded = true;
            this.selectedAnalysisIds = selected.slice(0, 12);
        } else {
            this.isCapExceeded = false;
            this.selectedAnalysisIds = selected;
        }
    }

    // -----------------------------------------------------------------
    // 1. WORLD TREND CHART DATA & SVG PATHS
    // -----------------------------------------------------------------
    get worldGdpPoints() {
        if (!this.hasWorldTrendData) return [];
        const pts = this.worldTrendData.points;
        const maxGdp = Math.max(...pts.map(p => p.totalWorldGdp || 0), 1);

        return pts.map((p, idx) => {
            const cx = 60 + (idx / Math.max(pts.length - 1, 1)) * 580;
            const cy = 260 - ((p.totalWorldGdp || 0) / maxGdp) * 220;
            return {
                id: p.analysisId || idx,
                cx,
                cy,
                ariaLabel: `${p.ingameDate || p.saveFileName}: World GDP £${Math.round(p.totalWorldGdp || 0).toLocaleString()}`
            };
        });
    }

    get worldGdpPath() {
        return this.buildSvgPath(this.worldGdpPoints);
    }

    get worldPopPoints() {
        if (!this.hasWorldTrendData) return [];
        const pts = this.worldTrendData.points;
        const maxPop = Math.max(...pts.map(p => p.totalWorldPopulation || 0), 1);

        return pts.map((p, idx) => {
            const cx = 60 + (idx / Math.max(pts.length - 1, 1)) * 580;
            const cy = 260 - ((p.totalWorldPopulation || 0) / maxPop) * 220;
            return {
                id: p.analysisId || idx,
                cx,
                cy,
                ariaLabel: `${p.ingameDate || p.saveFileName}: Population ${(p.totalWorldPopulation || 0).toLocaleString()}`
            };
        });
    }

    get worldPopPath() {
        return this.buildSvgPath(this.worldPopPoints);
    }

    get worldImportsPoints() {
        if (!this.hasWorldTrendData) return [];
        const pts = this.worldTrendData.points;
        const maxTrade = Math.max(...pts.map(p => Math.max(p.totalWorldImports || 0, p.totalWorldExports || 0)), 1);

        return pts.map((p, idx) => {
            const cx = 60 + (idx / Math.max(pts.length - 1, 1)) * 580;
            const cy = 260 - ((p.totalWorldImports || 0) / maxTrade) * 220;
            return {
                id: p.analysisId || idx,
                cx,
                cy,
                ariaLabel: `${p.ingameDate}: Imports £${Math.round(p.totalWorldImports || 0).toLocaleString()}`
            };
        });
    }

    get worldImportsPath() {
        return this.buildSvgPath(this.worldImportsPoints);
    }

    get worldExportsPoints() {
        if (!this.hasWorldTrendData) return [];
        const pts = this.worldTrendData.points;
        const maxTrade = Math.max(...pts.map(p => Math.max(p.totalWorldImports || 0, p.totalWorldExports || 0)), 1);

        return pts.map((p, idx) => {
            const cx = 60 + (idx / Math.max(pts.length - 1, 1)) * 580;
            const cy = 260 - ((p.totalWorldExports || 0) / maxTrade) * 220;
            return {
                id: p.analysisId || idx,
                cx,
                cy,
                ariaLabel: `${p.ingameDate}: Exports £${Math.round(p.totalWorldExports || 0).toLocaleString()}`
            };
        });
    }

    get worldExportsPath() {
        return this.buildSvgPath(this.worldExportsPoints);
    }

    get worldTrendTableRows() {
        if (!this.hasWorldTrendData) return [];
        return this.worldTrendData.points.map((p, i) => ({
            id: p.analysisId || i,
            date: p.ingameDate || p.saveFileName,
            gdp: `£${Math.round(p.totalWorldGdp || 0).toLocaleString()}`,
            pop: (p.totalWorldPopulation || 0).toLocaleString()
        }));
    }

    get worldTradeTableRows() {
        if (!this.hasWorldTrendData) return [];
        return this.worldTrendData.points.map((p, i) => ({
            id: p.analysisId || i,
            date: p.ingameDate || p.saveFileName,
            imports: `£${Math.round(p.totalWorldImports || 0).toLocaleString()}`,
            exports: `£${Math.round(p.totalWorldExports || 0).toLocaleString()}`
        }));
    }

    // -----------------------------------------------------------------
    // 2. COUNTRY GDP TREND LINES
    // -----------------------------------------------------------------
    get countryGdpLines() {
        if (!this.hasCountryTrendData) return [];
        const seriesList = this.countryTrendData.series.slice(0, 10); // top 10 series
        let maxGdp = 0;
        seriesList.forEach(s => {
            s.points.forEach(p => {
                if ((p.gdp || 0) > maxGdp) maxGdp = p.gdp || 0;
            });
        });
        if (maxGdp === 0) maxGdp = 1;

        return seriesList.map((s, idx) => {
            const color = COLOR_PALETTE[idx % COLOR_PALETTE.length];
            const pts = s.points.map((p, pIdx) => {
                const cx = 60 + (pIdx / Math.max(s.points.length - 1, 1)) * 580;
                const cy = 260 - ((p.gdp || 0) / maxGdp) * 220;
                return { cx, cy };
            });
            return {
                tag: s.countryTag,
                color,
                path: this.buildSvgPath(pts)
            };
        });
    }

    get countryGdpDots() {
        if (!this.hasCountryTrendData) return [];
        const seriesList = this.countryTrendData.series.slice(0, 10);
        let maxGdp = 0;
        seriesList.forEach(s => {
            s.points.forEach(p => {
                if ((p.gdp || 0) > maxGdp) maxGdp = p.gdp || 0;
            });
        });
        if (maxGdp === 0) maxGdp = 1;

        const dots = [];
        seriesList.forEach((s, idx) => {
            const color = COLOR_PALETTE[idx % COLOR_PALETTE.length];
            s.points.forEach((p, pIdx) => {
                const cx = 60 + (pIdx / Math.max(s.points.length - 1, 1)) * 580;
                const cy = 260 - ((p.gdp || 0) / maxGdp) * 220;
                dots.push({
                    id: `${s.countryTag}_${p.analysisId || pIdx}`,
                    cx,
                    cy,
                    color,
                    ariaLabel: `${s.countryName || s.countryTag} (${p.ingameDate}): GDP £${Math.round(p.gdp || 0).toLocaleString()}`
                });
            });
        });
        return dots;
    }

    get countryLegends() {
        if (!this.hasCountryTrendData) return [];
        return this.countryTrendData.series.slice(0, 10).map((s, idx) => ({
            tag: s.countryTag,
            label: s.countryName || s.countryTag,
            style: `background-color: ${COLOR_PALETTE[idx % COLOR_PALETTE.length]};`
        }));
    }

    get countryGdpTableRows() {
        if (!this.hasCountryTrendData) return [];
        const rows = [];
        this.countryTrendData.series.forEach(s => {
            s.points.forEach((p, i) => {
                rows.push({
                    id: `${s.countryTag}_${p.analysisId || i}`,
                    tag: s.countryName || s.countryTag,
                    date: p.ingameDate || 'N/A',
                    gdp: `£${Math.round(p.gdp || 0).toLocaleString()}`
                });
            });
        });
        return rows;
    }

    // -----------------------------------------------------------------
    // 3. PRODUCT PRICE & SUPPLY/DEMAND LINES
    // -----------------------------------------------------------------
    get productPriceLines() {
        if (!this.hasProductTrendData) return [];
        const seriesList = this.productTrendData.series.slice(0, 10);
        let maxPrice = 0;
        seriesList.forEach(s => {
            s.points.forEach(p => {
                if ((p.price || 0) > maxPrice) maxPrice = p.price || 0;
            });
        });
        if (maxPrice === 0) maxPrice = 1;

        return seriesList.map((s, idx) => {
            const color = COLOR_PALETTE[idx % COLOR_PALETTE.length];
            const pts = s.points.map((p, pIdx) => {
                const cx = 60 + (pIdx / Math.max(s.points.length - 1, 1)) * 580;
                const cy = 260 - ((p.price || 0) / maxPrice) * 220;
                return { cx, cy };
            });
            return {
                code: s.productCode,
                color,
                path: this.buildSvgPath(pts)
            };
        });
    }

    get productPriceDots() {
        if (!this.hasProductTrendData) return [];
        const seriesList = this.productTrendData.series.slice(0, 10);
        let maxPrice = 0;
        seriesList.forEach(s => {
            s.points.forEach(p => {
                if ((p.price || 0) > maxPrice) maxPrice = p.price || 0;
            });
        });
        if (maxPrice === 0) maxPrice = 1;

        const dots = [];
        seriesList.forEach((s, idx) => {
            const color = COLOR_PALETTE[idx % COLOR_PALETTE.length];
            s.points.forEach((p, pIdx) => {
                const cx = 60 + (pIdx / Math.max(s.points.length - 1, 1)) * 580;
                const cy = 260 - ((p.price || 0) / maxPrice) * 220;
                dots.push({
                    id: `${s.productCode}_${p.analysisId || pIdx}`,
                    cx,
                    cy,
                    color,
                    ariaLabel: `${s.productCode} (${p.ingameDate}): Price £${(p.price || 0).toFixed(2)}`
                });
            });
        });
        return dots;
    }

    get productLegends() {
        if (!this.hasProductTrendData) return [];
        return this.productTrendData.series.slice(0, 10).map((s, idx) => ({
            code: s.productCode,
            style: `background-color: ${COLOR_PALETTE[idx % COLOR_PALETTE.length]};`
        }));
    }

    get productPriceTableRows() {
        if (!this.hasProductTrendData) return [];
        const rows = [];
        this.productTrendData.series.forEach(s => {
            s.points.forEach((p, i) => {
                rows.push({
                    id: `${s.productCode}_${p.analysisId || i}`,
                    code: s.productCode,
                    date: p.ingameDate || 'N/A',
                    price: `£${(p.price || 0).toFixed(2)}`
                });
            });
        });
        return rows;
    }

    get supplyDemandLines() {
        if (!this.hasProductTrendData) return [];
        const seriesList = this.productTrendData.series.slice(0, 1); // target first selected product
        if (seriesList.length === 0) return [];

        const s = seriesList[0];
        let maxVal = 0;
        s.points.forEach(p => {
            if ((p.totalWorldSupply || 0) > maxVal) maxVal = p.totalWorldSupply || 0;
            if ((p.realDemand || 0) > maxVal) maxVal = p.realDemand || 0;
        });
        if (maxVal === 0) maxVal = 1;

        const supplyPts = s.points.map((p, pIdx) => ({
            cx: 60 + (pIdx / Math.max(s.points.length - 1, 1)) * 580,
            cy: 260 - ((p.totalWorldSupply || 0) / maxVal) * 220
        }));

        const demandPts = s.points.map((p, pIdx) => ({
            cx: 60 + (pIdx / Math.max(s.points.length - 1, 1)) * 580,
            cy: 260 - ((p.realDemand || 0) / maxVal) * 220
        }));

        return [
            { id: `${s.productCode}_supply`, color: '#0070D2', dash: '', path: this.buildSvgPath(supplyPts) },
            { id: `${s.productCode}_demand`, color: '#DD7A00', dash: '4,4', path: this.buildSvgPath(demandPts) }
        ];
    }

    get supplyDemandDots() {
        if (!this.hasProductTrendData) return [];
        const seriesList = this.productTrendData.series.slice(0, 1);
        if (seriesList.length === 0) return [];

        const s = seriesList[0];
        let maxVal = 0;
        s.points.forEach(p => {
            if ((p.totalWorldSupply || 0) > maxVal) maxVal = p.totalWorldSupply || 0;
            if ((p.realDemand || 0) > maxVal) maxVal = p.realDemand || 0;
        });
        if (maxVal === 0) maxVal = 1;

        const dots = [];
        s.points.forEach((p, pIdx) => {
            const cx = 60 + (pIdx / Math.max(s.points.length - 1, 1)) * 580;
            dots.push({
                id: `sup_${pIdx}`,
                cx,
                cy: 260 - ((p.totalWorldSupply || 0) / maxVal) * 220,
                color: '#0070D2',
                ariaLabel: `Supply ${s.productCode}: ${(p.totalWorldSupply || 0).toLocaleString()}`
            });
            dots.push({
                id: `dem_${pIdx}`,
                cx,
                cy: 260 - ((p.realDemand || 0) / maxVal) * 220,
                color: '#DD7A00',
                ariaLabel: `Real Demand ${s.productCode}: ${(p.realDemand || 0).toLocaleString()}`
            });
        });
        return dots;
    }

    get supplyDemandTableRows() {
        if (!this.hasProductTrendData) return [];
        const rows = [];
        this.productTrendData.series.slice(0, 1).forEach(s => {
            s.points.forEach((p, i) => {
                rows.push({
                    id: `${s.productCode}_sd_${i}`,
                    code: s.productCode,
                    date: p.ingameDate || 'N/A',
                    supply: (p.totalWorldSupply || 0).toLocaleString(),
                    demand: (p.realDemand || 0).toLocaleString()
                });
            });
        });
        return rows;
    }

    // -----------------------------------------------------------------
    // 4. COUNTRY DELTA DATATABLE (First vs Last Selected Snapshot)
    // -----------------------------------------------------------------
    get countryDeltaRows() {
        if (!this.hasCountryTrendData) return [];
        return this.countryTrendData.series.map(s => {
            const firstPt = (s.points && s.points.length > 0) ? s.points[0] : {};
            const lastPt = (s.points && s.points.length > 0) ? s.points[s.points.length - 1] : {};

            const baseGdp = firstPt.gdp || 0.0;
            const latestGdp = lastPt.gdp || 0.0;
            const gdpDelta = latestGdp - baseGdp;
            const growthPercent = (baseGdp > 0) ? (gdpDelta / baseGdp) * 100.0 : 0.0;
            const growthPercentFormatted = (growthPercent >= 0 ? '+' : '') + growthPercent.toFixed(2) + '%';

            return {
                countryTag: s.countryTag,
                countryName: s.countryName || s.countryTag,
                baseGdp,
                latestGdp,
                gdpDelta,
                growthPercentFormatted
            };
        });
    }

    // Helper SVG Path builder
    buildSvgPath(points) {
        if (!points || points.length === 0) return '';
        return points.map((p, idx) => `${idx === 0 ? 'M' : 'L'} ${p.cx} ${p.cy}`).join(' ');
    }

    extractErrorMessage(error) {
        if (!error) return 'An error occurred while fetching trend data.';
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
        return 'An error occurred while fetching trend data.';
    }
}
