import { LightningElement, api, wire, track } from 'lwc';
import getRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getRecentAnalyses';
import getCountrySummaries from '@salesforce/apex/EconomyAnalysisController.getCountrySummaries';
import getAnalysisSummary from '@salesforce/apex/EconomyAnalysisController.getAnalysisSummary';
import { getContext, updateContext, subscribeContext } from 'c/contextStore';

export default class GlobalContextBar extends LightningElement {
    @api selectedAnalysisId = null;

    recentAnalyses = [];
    countryList = [];
    summaryData = null;

    selectedCountryTag = 'EGY';
    playerCountryTag = 'EGY';
    observerMode = false;
    baselineType = 'previous';
    baselineRef = null;

    @track isAdvisorOpen = false;

    unsubscribeStore = null;

    connectedCallback() {
        this.unsubscribeStore = subscribeContext((state) => {
            if (state.snapshotId && state.snapshotId !== this.selectedAnalysisId) {
                this.selectedAnalysisId = state.snapshotId;
            }
            if (state.countryTag && state.countryTag !== this.selectedCountryTag) {
                this.selectedCountryTag = state.countryTag;
            }
            if (state.observerMode !== undefined) {
                this.observerMode = state.observerMode;
            }
            if (state.baselineType) {
                this.baselineType = state.baselineType;
            }
        });

        const ctx = getContext();
        if (ctx.snapshotId && !this.selectedAnalysisId) {
            this.selectedAnalysisId = ctx.snapshotId;
        }
        if (ctx.countryTag) {
            this.selectedCountryTag = ctx.countryTag;
        }
    }

    disconnectedCallback() {
        if (typeof this.unsubscribeStore === 'function') {
            this.unsubscribeStore();
        }
    }

    @wire(getRecentAnalyses, { limitCount: 50 })
    wiredAnalyses({ data, error }) {
        if (data) {
            this.recentAnalyses = data;
            if (!this.selectedAnalysisId && data.length > 0) {
                this.selectedAnalysisId = data[0].Id;
                this.updateGlobalContext({ snapshotId: data[0].Id, saveId: data[0].Save_File_Name__c || data[0].Id });
            }
        } else if (error) {
            console.error('Error fetching recent analyses:', error);
        }
    }

    @wire(getAnalysisSummary, { analysisId: '$selectedAnalysisId' })
    wiredSummary({ data, error }) {
        if (data) {
            this.summaryData = data;
            if (data.playerCountryTag) {
                this.playerCountryTag = data.playerCountryTag;
                this.checkObserverMode();
            }
            this.updateGlobalContext({
                snapshotId: this.selectedAnalysisId,
                snapshotDate: data.ingameDate || null,
                countryTag: this.selectedCountryTag
            });
        } else if (error) {
            console.error('Error fetching analysis summary:', error);
        }
    }

    @wire(getCountrySummaries, { analysisId: '$selectedAnalysisId' })
    wiredCountries({ data, error }) {
        if (data) {
            this.countryList = data;
        } else if (error) {
            console.error('Error fetching country summaries:', error);
        }
    }

    get saveOptions() {
        if (!this.recentAnalyses || this.recentAnalyses.length === 0) {
            return [];
        }
        return this.recentAnalyses.map((item) => {
            const label = `${item.Save_File_Name__c || 'Save'} (${item.Ingame_Date__c || 'Snapshot'})`;
            return {
                label,
                value: item.Id
            };
        });
    }

    get snapshotOptions() {
        if (!this.recentAnalyses || this.recentAnalyses.length === 0) {
            return [];
        }
        return this.recentAnalyses.map((item) => ({
            label: item.Ingame_Date__c ? `⏱ ${item.Ingame_Date__c}` : item.Name,
            value: item.Id
        }));
    }

    get countryOptions() {
        if (!this.countryList || this.countryList.length === 0) {
            return [{ label: 'EGY - Egypt', value: 'EGY' }];
        }
        return this.countryList.map((c) => ({
            label: `${c.countryTag} - ${c.countryName || c.countryTag}`,
            value: c.countryTag
        }));
    }

    get baselineOptions() {
        return [
            { label: 'Δ vs Previous Snapshot', value: 'previous' },
            { label: 'Δ vs Initial Snapshot (1836)', value: 'initial' },
            { label: 'Δ vs Pinned Baseline', value: 'pinned' }
        ];
    }

    get currentAnalysisRecord() {
        if (!this.recentAnalyses) return null;
        return this.recentAnalyses.find((a) => a.Id === this.selectedAnalysisId);
    }

    get statusChipText() {
        const rec = this.currentAnalysisRecord;
        if (!rec) return 'PUBLISHED';
        return rec.Import_Status__c || 'PUBLISHED';
    }

    get statusChipClass() {
        const status = this.statusChipText.toUpperCase();
        if (status === 'COMPLETED' || status === 'PUBLISHED') {
            return 'status-chip status-published';
        }
        if (status === 'PROCESSING' || status === 'VALIDATING' || status === 'CALCULATING') {
            return 'status-chip status-processing';
        }
        if (status === 'FAILED') {
            return 'status-chip status-failed';
        }
        return 'status-chip status-published';
    }

    get countryTag() {
        return this.selectedCountryTag || 'EGY';
    }

    get countryName() {
        const found = this.countryList.find((c) => c.countryTag === this.selectedCountryTag);
        return found ? found.countryName : this.countryTag;
    }

    checkObserverMode() {
        if (this.selectedCountryTag && this.playerCountryTag) {
            this.observerMode = this.selectedCountryTag !== this.playerCountryTag;
        } else {
            this.observerMode = false;
        }
    }

    toggleAdvisorDrawer() {
        this.isAdvisorOpen = !this.isAdvisorOpen;
    }

    closeAdvisorDrawer() {
        this.isAdvisorOpen = false;
    }

    handleSaveChange(event) {
        this.selectedAnalysisId = event.detail.value;
        const rec = this.currentAnalysisRecord;
        this.updateGlobalContext({
            snapshotId: this.selectedAnalysisId,
            saveId: rec ? (rec.Save_File_Name__c || rec.Id) : this.selectedAnalysisId
        });
        this.notifyContextChange();
    }

    handleSnapshotChange(event) {
        this.selectedAnalysisId = event.detail.value;
        this.updateGlobalContext({
            snapshotId: this.selectedAnalysisId
        });
        this.notifyContextChange();
    }

    handleCountryChange(event) {
        this.selectedCountryTag = event.detail.value;
        this.checkObserverMode();
        this.updateGlobalContext({
            countryTag: this.selectedCountryTag,
            observerMode: this.observerMode
        });
        this.notifyContextChange();
    }

    handleBaselineChange(event) {
        this.baselineType = event.detail.value;
        this.updateGlobalContext({
            baselineType: this.baselineType
        });
        this.notifyContextChange();
    }

    updateGlobalContext(partialState) {
        updateContext(partialState);
    }

    notifyContextChange() {
        this.dispatchEvent(
            new CustomEvent('contextchange', {
                bubbles: true,
                composed: true,
                detail: getContext()
            })
        );
    }
}
