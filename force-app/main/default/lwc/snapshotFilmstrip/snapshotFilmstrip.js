import { LightningElement, api, wire, track } from 'lwc';
import getAllRecentAnalyses from '@salesforce/apex/EconomyAnalysisController.getAllRecentAnalyses';
import getEventTicks from '@salesforce/apex/TimeSeriesController.getEventTicks';

export default class SnapshotFilmstrip extends LightningElement {
    @track snapshots = [];
    @track selectedIds = new Set();
    @track eventMap = new Map();

    @wire(getAllRecentAnalyses, { limitCount: 15 })
    wiredAnalyses({ error, data }) {
        if (data) {
            this.snapshots = data.map(item => ({
                id: item.Id,
                saveFileName: item.Save_File_Name__c || item.Id,
                ingameDate: item.Ingame_Date__c,
                totalWorldGdp: item.Total_World_GDP__c || 0
            }));

            // Default selection: select up to first 12
            this.selectedIds = new Set(this.snapshots.slice(0, 12).map(s => s.id));
            this.fetchEventTicks();
            this.notifySelectionChange();
        } else if (error) {
            console.error('Error fetching filmstrip analyses:', error);
            this.snapshots = [];
        }
    }

    fetchEventTicks() {
        const ids = this.snapshots.map(s => s.id);
        if (ids.length === 0) return;

        getEventTicks({ analysisIds: ids })
            .then(ticks => {
                const map = new Map();
                ticks.forEach(t => {
                    map.set(t.snapshotId, t);
                });
                this.eventMap = map;
            })
            .catch(err => {
                console.error('Error loading event ticks:', err);
            });
    }

    get hasSnapshots() {
        return this.snapshots && this.snapshots.length > 0;
    }

    get selectedCount() {
        return this.selectedIds.size;
    }

    get processedSnapshots() {
        return this.snapshots.map(snap => {
            const isSelected = this.selectedIds.has(snap.id);
            const evt = this.eventMap.get(snap.id);
            const hasEvent = !!evt;

            let slotClass = 'filmstrip-slot';
            if (isSelected) slotClass += ' selected';

            let badgeClass = 'event-badge';
            if (hasEvent) {
                if (evt.eventType === 'WAR') badgeClass += ' badge-war';
                else if (evt.eventType === 'REFORM') badgeClass += ' badge-reform';
                else if (evt.eventType === 'CRISIS') badgeClass += ' badge-crisis';
            }

            return {
                ...snap,
                isSelected,
                slotClass,
                badgeClass,
                hasEvent,
                eventType: hasEvent ? evt.eventType : '',
                eventDescription: hasEvent ? `${evt.title}: ${evt.description}` : '',
                formattedDate: snap.ingameDate || '1836-01-01',
                formattedGdp: (snap.totalWorldGdp / 1000).toFixed(1) + 'k'
            };
        });
    }

    handleSlotClick(event) {
        const id = event.currentTarget.dataset.id;
        if (!id) return;

        const newSelected = new Set(this.selectedIds);
        if (newSelected.has(id)) {
            if (newSelected.size > 3) {
                newSelected.delete(id);
            }
        } else {
            if (newSelected.size < 12) {
                newSelected.add(id);
            }
        }

        this.selectedIds = newSelected;
        this.notifySelectionChange();
    }

    handleSelectAll() {
        const ids = this.snapshots.slice(0, 12).map(s => s.id);
        this.selectedIds = new Set(ids);
        this.notifySelectionChange();
    }

    handleClearSelection() {
        const ids = this.snapshots.slice(0, 3).map(s => s.id);
        this.selectedIds = new Set(ids);
        this.notifySelectionChange();
    }

    notifySelectionChange() {
        const selectedList = Array.from(this.selectedIds);
        this.dispatchEvent(new CustomEvent('snapshotselect', {
            detail: { selectedAnalysisIds: selectedList }
        }));
    }
}
