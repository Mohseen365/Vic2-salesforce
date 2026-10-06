import { LightningElement, api } from 'lwc';

export default class WorkspaceTabs extends LightningElement {
    @api activeTabKey = 'economy'; // Default to economy tab so existing views are immediately visible
    @api selectedAnalysisId = null;

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
