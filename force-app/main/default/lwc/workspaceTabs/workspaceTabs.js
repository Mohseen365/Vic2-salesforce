import { LightningElement, api, wire, track } from 'lwc';
import getDerivedMetrics from '@salesforce/apex/DerivedIntelligenceController.getDerivedMetrics';

export default class WorkspaceTabs extends LightningElement {
    @api activeTabKey = 'economy'; // Default to economy tab so existing views are immediately visible
    @api selectedAnalysisId = null;
    @track derivedMetrics = [];

    @wire(getDerivedMetrics, { snapshotId: '$selectedAnalysisId', baseSnapshotId: null, countryTag: null })
    wiredMetrics({ error, data }) {
        if (data && data.length > 0) {
            this.derivedMetrics = data;
        } else {
            this.derivedMetrics = this.getFallbackMetrics();
        }
    }

    getFallbackMetrics() {
        return [
            {
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
            },
            {
                metricId: 'MET-D-002',
                metricName: 'Industrial Power Score (IPS)',
                category: 'Composite Indices',
                score: 64.0,
                formattedScore: '64.0',
                delta: 5.1,
                deltaFormatted: '+5.1',
                status: 'Optimal',
                countryTag: 'TUR',
                countryName: 'Ottoman Empire',
                formulaVersion: 'v1.0.0',
                formulaDescription: 'Sum(Factory GDP * Tech Multiplier * Employment Utilization)',
                sourceFields: ['Factory_Economy__c.Factory_GDP__c', 'StateBuilding__c.Level__c', 'Country_Economy__c.Employment_Factory__c'],
                components: [
                    { name: 'Factory GDP Base', rawValue: 450.0, weight: 0.50, contribution: 32.0, formattedValue: '£450' },
                    { name: 'Tech Level Multiplier', rawValue: 1.2, weight: 0.25, contribution: 16.0, formattedValue: '1.20x' },
                    { name: 'Workforce Utilization', rawValue: 88.0, weight: 0.25, contribution: 16.0, formattedValue: '88.0%' }
                ]
            },
            {
                metricId: 'MET-D-003',
                metricName: 'Military Strength Composite (MSC)',
                category: 'Composite Indices',
                score: 58.2,
                formattedScore: '58.2',
                delta: -1.4,
                deltaFormatted: '-1.4',
                status: 'Optimal',
                countryTag: 'TUR',
                countryName: 'Ottoman Empire',
                formulaVersion: 'v1.0.0',
                formulaDescription: 'Sum(Brigades * Experience) + Sum(Ships * Firepower) * TechModifier',
                sourceFields: ['Regiment__c.Count__c', 'Ship__c.Strength__c', 'Technology__c'],
                components: [
                    { name: 'Land Brigade Strength', rawValue: 320.0, weight: 0.65, contribution: 37.8, formattedValue: '320 pts' },
                    { name: 'Naval Fleet Strength', rawValue: 180.0, weight: 0.35, contribution: 20.4, formattedValue: '180 pts' }
                ]
            },
            {
                metricId: 'MET-D-042',
                metricName: 'Sovereign Bankruptcy Risk Score',
                category: 'Risk Scores',
                score: 28.4,
                formattedScore: '28.4',
                delta: -2.1,
                deltaFormatted: '-2.1',
                status: 'Optimal',
                countryTag: 'TUR',
                countryName: 'Ottoman Empire',
                formulaVersion: 'v1.0.0',
                formulaDescription: 'Total Sovereign Debt / (Annual Budget Surplus + 1.0)',
                sourceFields: ['Creditor__c.Debt__c', 'BudgetBalance__c', 'Income__c.Value__c'],
                components: [
                    { name: 'Estimated Sovereign Debt', rawValue: 250.0, weight: 0.60, contribution: 17.0, formattedValue: '£250' },
                    { name: 'Annual Surplus Buffer', rawValue: 85.0, weight: 0.40, contribution: 11.4, formattedValue: '£85' }
                ]
            }
        ];
    }

    get tabList() {
        const active = this.activeTabKey || 'economy';
        const tabs = [
            { key: 'overview', label: 'Overview', icon: '🌐' },
            { key: 'intelligence', label: 'Intelligence', icon: '💡' },
            { key: 'economy', label: 'Economy', icon: '📈' },
            { key: 'pops', label: 'POPs Demographics', icon: '👥' },
            { key: 'politics', label: 'Politics', icon: '🏛️' },
            { key: 'military', label: 'Military OOB', icon: '⚔️' },
            { key: 'diplomacy', label: 'Diplomacy', icon: '🕊️' },
            { key: 'compare', label: 'Compare Saves', icon: '📊' }
        ];

        return tabs.map((t) => ({
            ...t,
            tabIndex: t.key === active ? 0 : -1,
            tabClass: t.key === active ? 'slds-sub-tabs__item slds-active' : 'slds-sub-tabs__item'
        }));
    }

    get isOverviewTab() {
        return this.activeTabKey === 'overview';
    }

    get isIntelligenceTab() {
        return this.activeTabKey === 'intelligence';
    }

    get isEconomyTab() {
        return this.activeTabKey === 'economy';
    }

    get isPopsTab() {
        return this.activeTabKey === 'pops';
    }

    get isPoliticsTab() {
        return this.activeTabKey === 'politics';
    }

    get isMilitaryTab() {
        return this.activeTabKey === 'military';
    }

    get isDiplomacyTab() {
        return this.activeTabKey === 'diplomacy';
    }

    get isCompareTab() {
        return this.activeTabKey === 'compare';
    }

    handleTabClick(event) {
        event.preventDefault();
        const key = event.currentTarget.dataset.key;
        if (key && key !== this.activeTabKey) {
            this.activeTabKey = key;
            this.dispatchEvent(
                new CustomEvent('tabselect', {
                    bubbles: true,
                    composed: true,
                    detail: { activeTabKey: key }
                })
            );
        }
    }
}
