import { LightningElement, api } from 'lwc';

export default class ScoreCard extends LightningElement {
    @api metric = {
        metricId: 'MET-D-001',
        metricName: 'Human Development Index (HDI)',
        category: 'Composite Indices',
        score: 72.5,
        formattedScore: '72.5',
        delta: 3.2,
        deltaFormatted: '+3.2',
        status: 'Optimal',
        countryTag: 'TUR',
        countryName: 'Ottoman Empire',
        formulaVersion: 'v1.0.0',
        formulaDescription: '0.33 * (Literacy / 100) + 0.33 * ln(GDP/cap) + 0.34 * (Need Fulfillment / 100)',
        sourceFields: ['Pop__c.Literacy__c', 'Country_Economy__c.GDP_Per_Capita__c', 'Pop_Need__c.Value__c'],
        components: [
            { name: 'Literacy Rate', rawValue: 85.0, weight: 0.33, contribution: 28.1, formattedValue: '85.0%' },
            { name: 'GDP/Capita Factor', rawValue: 65.0, weight: 0.33, contribution: 21.5, formattedValue: '£2.40' },
            { name: 'Need Fulfillment', rawValue: 67.5, weight: 0.34, contribution: 22.9, formattedValue: '67.5%' }
        ]
    };

    isDrawerOpen = false;

    get statusBadgeClass() {
        const s = (this.metric.status || 'Informational').toLowerCase();
        if (s === 'optimal') return 'slds-badge slds-theme_success';
        if (s === 'warning') return 'slds-badge slds-theme_warning';
        if (s === 'critical') return 'slds-badge slds-theme_error';
        return 'slds-badge slds-theme_info';
    }

    get strokeDashArray() {
        const score = Math.min(100, Math.max(0, this.metric.score || 0));
        return `${score}, 100`;
    }

    get gaugeArcClass() {
        const s = (this.metric.status || 'Informational').toLowerCase();
        if (s === 'optimal') return 'gauge-arc arc-optimal';
        if (s === 'warning') return 'gauge-arc arc-warning';
        if (s === 'critical') return 'gauge-arc arc-critical';
        return 'gauge-arc arc-info';
    }

    get deltaClass() {
        const d = this.metric.delta || 0;
        if (d > 0) return 'delta-value delta-positive';
        if (d < 0) return 'delta-value delta-negative';
        return 'delta-value delta-neutral';
    }

    get deltaIcon() {
        const d = this.metric.delta || 0;
        if (d > 0) return '↑';
        if (d < 0) return '↓';
        return '→';
    }

    get formattedSourceFields() {
        return (this.metric.sourceFields || []).join(', ');
    }

    get drawerButtonLabel() {
        return this.isDrawerOpen ? 'Hide Calculation Trust Drawer ▲' : 'How computed (v1.0.0 Trust Drawer) ▼';
    }

    toggleTrustDrawer() {
        this.isDrawerOpen = !this.isDrawerOpen;
    }
}
