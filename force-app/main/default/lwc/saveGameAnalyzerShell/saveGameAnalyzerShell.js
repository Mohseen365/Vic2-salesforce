import { LightningElement } from 'lwc';
import { getContext, updateContext, subscribeContext } from 'c/contextStore';

export default class SaveGameAnalyzerShell extends LightningElement {
    selectedAnalysisId = null;
    activeTabKey = 'economy';
    lastRefreshTime = new Date().toLocaleTimeString();
    unsubscribeStore = null;

    connectedCallback() {
        this.unsubscribeStore = subscribeContext((state) => {
            if (state.snapshotId && state.snapshotId !== this.selectedAnalysisId) {
                this.selectedAnalysisId = state.snapshotId;
            }
        });

        const ctx = getContext();
        if (ctx.snapshotId) {
            this.selectedAnalysisId = ctx.snapshotId;
        }
    }

    disconnectedCallback() {
        if (typeof this.unsubscribeStore === 'function') {
            this.unsubscribeStore();
        }
    }

    handleNavSelect(event) {
        const domainKey = event.detail.domainKey;
        if (domainKey) {
            this.activeTabKey = domainKey;
        }
    }

    handleTabSelect(event) {
        const activeTabKey = event.detail.activeTabKey;
        if (activeTabKey) {
            this.activeTabKey = activeTabKey;
        }
    }

    handleContextChange(event) {
        const detail = event.detail || {};
        if (detail.snapshotId && detail.snapshotId !== this.selectedAnalysisId) {
            this.selectedAnalysisId = detail.snapshotId;
        }
        this.lastRefreshTime = new Date().toLocaleTimeString();
        updateContext(detail);
    }

    handleNavCollapseToggle() {
        // Layout adjusts smoothly via CSS
    }
}
