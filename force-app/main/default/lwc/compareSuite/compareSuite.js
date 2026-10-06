import { LightningElement, track, wire } from 'lwc';
import getNarrowTimeSeries from '@salesforce/apex/TimeSeriesController.getNarrowTimeSeries';

export default class CompareSuite extends LightningElement {
    @track activeMode = 'TREND'; // 'TREND', 'SPLIT', 'BUMP'
    @track selectedAnalysisIds = [];
    @track baseSnapshotId;
    @track compareSnapshotId;

    @wire(getNarrowTimeSeries, { analysisIds: '$selectedAnalysisIds', metricType: 'WORLD_GDP', targetKey: '' })
    wiredNarrowWorldGdp;

    get isTrendMode() {
        return this.activeMode === 'TREND';
    }

    get isSplitMode() {
        return this.activeMode === 'SPLIT';
    }

    get isBumpMode() {
        return this.activeMode === 'BUMP';
    }

    get trendBtnClass() {
        return 'slds-button ' + (this.isTrendMode ? 'slds-button_brand' : 'slds-button_neutral');
    }

    get compareBtnClass() {
        return 'slds-button ' + (this.isSplitMode ? 'slds-button_brand' : 'slds-button_neutral');
    }

    get bumpBtnClass() {
        return 'slds-button ' + (this.isBumpMode ? 'slds-button_brand' : 'slds-button_neutral');
    }

    get snapshotOptions() {
        return this.selectedAnalysisIds.map((id, index) => ({
            label: `Snapshot #${index + 1} (${id.substring(0, 8)})`,
            value: id
        }));
    }

    get canCompareAB() {
        return this.baseSnapshotId && this.compareSnapshotId && this.baseSnapshotId !== this.compareSnapshotId;
    }

    handleModeSelect(event) {
        this.activeMode = event.currentTarget.dataset.mode;
    }

    handleSnapshotSelect(event) {
        const ids = event.detail.selectedAnalysisIds || [];
        this.selectedAnalysisIds = ids;

        if (ids.length >= 2) {
            this.baseSnapshotId = ids[0];
            this.compareSnapshotId = ids[ids.length - 1];
        } else if (ids.length === 1) {
            this.baseSnapshotId = ids[0];
            this.compareSnapshotId = null;
        } else {
            this.baseSnapshotId = null;
            this.compareSnapshotId = null;
        }
    }

    handleBaseChange(event) {
        this.baseSnapshotId = event.detail.value;
    }

    handleCompareChange(event) {
        this.compareSnapshotId = event.detail.value;
    }

    get bumpTableData() {
        if (!this.wiredNarrowWorldGdp || !this.wiredNarrowWorldGdp.data || this.wiredNarrowWorldGdp.data.length === 0) {
            return [
                {
                    key: 'worldGdp',
                    entityName: 'Total World GDP',
                    formattedBase: '£100,000.00',
                    formattedLatest: '£250,000.00',
                    formattedDelta: '+£150,000.00',
                    formattedPercent: '+150.00',
                    deltaClass: 'text-positive',
                    badgeClass: 'badge-positive'
                }
            ];
        }

        const points = this.wiredNarrowWorldGdp.data;
        const first = points[0];
        const last = points[points.length - 1];
        const baseVal = first.value || 0;
        const lastVal = last.value || 0;
        const delta = lastVal - baseVal;
        const pct = baseVal > 0 ? ((delta / baseVal) * 100).toFixed(2) : '0.00';
        const isPos = delta >= 0;

        return [
            {
                key: 'worldGdp',
                entityName: 'Total World GDP',
                formattedBase: '£' + baseVal.toLocaleString(),
                formattedLatest: '£' + lastVal.toLocaleString(),
                formattedDelta: (isPos ? '+' : '') + '£' + delta.toLocaleString(),
                formattedPercent: (isPos ? '+' : '') + pct,
                deltaClass: isPos ? 'text-positive' : 'text-negative',
                badgeClass: isPos ? 'badge-positive' : 'badge-negative'
            }
        ];
    }
}
