import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class AlertDrawer extends LightningElement {
    @api channelName = '/event/Economy_Anomaly_Event__e';
    @track alerts = [];
    @track activeFilter = 'ALL';
    isOpen = false;
    subscription = {};

    connectedCallback() {
        this.registerEmpApi();
    }

    disconnectedCallback() {
        this.unregisterEmpApi();
    }

    registerEmpApi() {
        onError(error => {
            console.warn('empApi error: ', JSON.stringify(error));
        });

        subscribe(this.channelName, -1, response => {
            this.handleIncomingEvent(response);
        }).then(sub => {
            this.subscription = sub;
        });
    }

    unregisterEmpApi() {
        if (this.subscription && this.subscription.unsubscribe) {
            unsubscribe(this.subscription, () => {});
        }
    }

    handleIncomingEvent(response) {
        if (!response || !response.data || !response.data.payload) return;
        const p = response.data.payload;

        const newAlert = {
            id: 'evt_' + Date.now() + '_' + Math.floor(Math.random() * 1000),
            analysisId: p.Analysis_Id__c,
            countryTag: p.Country_Tag__c,
            type: p.Anomaly_Type__c || 'ANOMALY',
            severity: p.Severity__c || 'HIGH',
            title: p.Title__c || 'Anomaly Event Detected',
            message: p.Message__c || 'An unusual threshold breach occurred.',
            metricValue: p.Metric_Value__c,
            thresholdValue: p.Threshold_Value__c,
            timestamp: new Date(),
            timeAgo: 'Just now',
            targetTab: this.determineTargetTab(p.Anomaly_Type__c)
        };

        this.alerts = [newAlert, ...this.alerts];
    }

    determineTargetTab(type) {
        if (type === 'GDP_CRASH' || type === 'SOVEREIGN_DEFAULT_RISK') return 'economy';
        if (type === 'REBELLION_RISK') return 'politics';
        return 'overview';
    }

    get unreadCount() {
        return this.alerts.length;
    }

    get hasUnread() {
        return this.alerts.length > 0;
    }

    get filteredAlerts() {
        return this.alerts.filter(a => {
            if (this.activeFilter === 'ALL') return true;
            return (a.severity || '').toUpperCase() === this.activeFilter;
        }).map(a => {
            const sev = (a.severity || 'INFO').toUpperCase();
            let sevBadge = 'slds-badge slds-theme_info';
            let cardCls = 'alert-card slds-p-around_small slds-m-bottom_small slds-theme_shade slds-border_left';

            if (sev === 'CRITICAL') {
                sevBadge = 'slds-badge slds-theme_error';
                cardCls += ' border-critical';
            } else if (sev === 'HIGH') {
                sevBadge = 'slds-badge slds-theme_warning';
                cardCls += ' border-warning';
            } else {
                cardCls += ' border-info';
            }

            return {
                ...a,
                severityBadgeClass: sevBadge,
                cardClass: cardCls
            };
        });
    }

    get hasFilteredAlerts() {
        return this.filteredAlerts.length > 0;
    }

    get filterOptions() {
        const counts = { ALL: this.alerts.length, CRITICAL: 0, HIGH: 0, INFO: 0 };
        this.alerts.forEach(a => {
            const s = (a.severity || 'INFO').toUpperCase();
            if (counts[s] !== undefined) counts[s]++;
        });

        return [
            { key: 'ALL', label: 'All', count: counts.ALL, btnClass: this.getFilterBtnClass('ALL') },
            { key: 'CRITICAL', label: 'Critical', count: counts.CRITICAL, btnClass: this.getFilterBtnClass('CRITICAL') },
            { key: 'HIGH', label: 'High', count: counts.HIGH, btnClass: this.getFilterBtnClass('HIGH') },
            { key: 'INFO', label: 'Info', count: counts.INFO, btnClass: this.getFilterBtnClass('INFO') }
        ];
    }

    getFilterBtnClass(key) {
        const base = 'slds-button slds-button_x-small slds-m-right_xx-small ';
        return base + (this.activeFilter === key ? 'slds-button_brand' : 'slds-button_neutral');
    }

    toggleDrawer() {
        this.isOpen = !this.isOpen;
    }

    closeDrawer() {
        this.isOpen = false;
    }

    handleFilterChange(event) {
        this.activeFilter = event.currentTarget.dataset.key;
    }

    dismissAlert(event) {
        const id = event.currentTarget.dataset.id;
        this.alerts = this.alerts.filter(a => a.id !== id);
    }

    clearAllAlerts() {
        this.alerts = [];
    }

    handleInvestigate(event) {
        const tag = event.currentTarget.dataset.tag;
        const tab = event.currentTarget.dataset.tab;

        this.dispatchEvent(new CustomEvent('investigate', {
            bubbles: true,
            composed: true,
            detail: { countryTag: tag, tab: tab }
        }));

        this.isOpen = false;
    }
}
