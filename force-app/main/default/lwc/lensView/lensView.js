import { LightningElement, api } from 'lwc';

export default class LensView extends LightningElement {
    @api lensData = null;
    isDrawerOpen = false;

    get lensTitle() {
        return this.lensData ? this.lensData.title : 'Lens Intelligence';
    }

    get lensCategory() {
        return this.lensData ? this.lensData.category : 'Cross-Domain';
    }

    get lensCapabilityId() {
        return this.lensData ? this.lensData.capabilityId : 'CAP-D-000';
    }

    get lensStatus() {
        return this.lensData ? this.lensData.status : 'Informational';
    }

    get lensHeadline() {
        return this.lensData ? this.lensData.headline : 'Analysis in progress...';
    }

    get primaryMetricFormatted() {
        return this.lensData ? this.lensData.primaryMetricFormatted : '0.0%';
    }

    get secondaryMetricFormatted() {
        return this.lensData ? this.lensData.secondaryMetricFormatted : '£0.00';
    }

    get evidenceSourceObjects() {
        return (this.lensData && this.lensData.evidence && this.lensData.evidence.sourceObjects)
            ? this.lensData.evidence.sourceObjects
            : [];
    }

    get evidenceFormula() {
        return (this.lensData && this.lensData.evidence && this.lensData.evidence.formulaDetails)
            ? this.lensData.evidence.formulaDetails
            : 'Formula details pending calculation.';
    }

    get evidenceBadges() {
        return (this.lensData && this.lensData.evidence && this.lensData.evidence.provenanceBadges)
            ? this.lensData.evidence.provenanceBadges
            : [];
    }

    get cardCssClass() {
        return 'slds-card lens-card slds-m-bottom_medium';
    }

    get badgeCssClass() {
        const status = (this.lensStatus || '').toLowerCase();
        if (status === 'optimal') return 'slds-badge slds-theme_success';
        if (status === 'warning') return 'slds-badge slds-theme_warning';
        if (status === 'critical') return 'slds-badge slds-theme_error';
        return 'slds-badge slds-theme_info';
    }

    get toggleDrawerLabel() {
        return this.isDrawerOpen ? 'Hide Evidence' : 'Show Evidence';
    }

    get toggleDrawerIcon() {
        return this.isDrawerOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get renderedPoints() {
        if (!this.lensData || !this.lensData.dataPoints || this.lensData.dataPoints.length === 0) {
            return [
                { id: 'p1', transform: 'translate(100, 100)', r: 12, fill: '#1b96ff', stroke: '#005fb2', label: 'TUR' },
                { id: 'p2', transform: 'translate(250, 60)', r: 16, fill: '#2e844a', stroke: '#1c512d', label: 'ENG' },
                { id: 'p3', transform: 'translate(400, 130)', r: 14, fill: '#fe9339', stroke: '#a84b00', label: 'FRA' }
            ];
        }

        const pts = this.lensData.dataPoints.slice(0, 12);
        const xVals = pts.map((p) => (p.x != null ? p.x : 0));
        const yVals = pts.map((p) => (p.y != null ? p.y : 0));

        let minX = Math.min(...xVals);
        let maxX = Math.max(...xVals);
        let minY = Math.min(...yVals);
        let maxY = Math.max(...yVals);

        if (minX === maxX) {
            minX = minX - 1;
            maxX = maxX + 1;
        }
        if (minY === maxY) {
            minY = minY - 1;
            maxY = maxY + 1;
        }

        const xMinPadding = 60;
        const xMaxPadding = 450;
        const yMinPadding = 160;
        const yMaxPadding = 30;

        return pts.map((pt, idx) => {
            const rawX = pt.x != null ? pt.x : 0;
            const rawY = pt.y != null ? pt.y : 0;

            const normX = (rawX - minX) / (maxX - minX);
            const normY = (rawY - minY) / (maxY - minY);

            const cx = xMinPadding + normX * (xMaxPadding - xMinPadding);
            const cy = yMinPadding - normY * (yMinPadding - yMaxPadding);

            const isTarget = pt.label === this.lensData.countryTag;

            return {
                id: 'dp-' + idx,
                transform: `translate(${cx.toFixed(1)}, ${cy.toFixed(1)})`,
                r: isTarget ? 14 : 9,
                fill: isTarget ? '#0176d3' : (rawY < 0 ? '#ea001e' : '#4bca81'),
                stroke: isTarget ? '#001529' : '#ffffff',
                label: pt.label
            };
        });
    }

    handleToggleDrawer() {
        this.isDrawerOpen = !this.isDrawerOpen;
    }
}
