import { LightningElement, api, wire, track } from 'lwc';
import getLensGalleryData from '@salesforce/apex/CrossDomainAnalysisController.getLensGalleryData';
import { getContext, subscribeContext } from 'c/contextStore';

export default class LensGallery extends LightningElement {
    @api snapshotId = null;
    @api baseSnapshotId = null;
    @track selectedCountryTag = 'TUR';
    @track lenses = [];
    isLoading = true;
    unsubscribeStore = null;

    countryOptions = [
        { label: 'Ottoman Empire (TUR)', value: 'TUR' },
        { label: 'United Kingdom (ENG)', value: 'ENG' },
        { label: 'France (FRA)', value: 'FRA' },
        { label: 'Egypt (EGY)', value: 'EGY' },
        { label: 'Prussia (PRU)', value: 'PRU' },
        { label: 'Russia (RUS)', value: 'RUS' },
        { label: 'Austria (AUT)', value: 'AUT' }
    ];

    connectedCallback() {
        const ctx = getContext();
        if (ctx.snapshotId) {
            this.snapshotId = ctx.snapshotId;
        }
        if (ctx.countryTag) {
            this.selectedCountryTag = ctx.countryTag;
        }

        this.unsubscribeStore = subscribeContext((state) => {
            let updated = false;
            if (state.snapshotId && state.snapshotId !== this.snapshotId) {
                this.snapshotId = state.snapshotId;
                updated = true;
            }
            if (state.countryTag && state.countryTag !== this.selectedCountryTag) {
                this.selectedCountryTag = state.countryTag;
                updated = true;
            }
            if (updated) {
                this.loadGalleryData();
            }
        });

        this.loadGalleryData();
    }

    disconnectedCallback() {
        if (typeof this.unsubscribeStore === 'function') {
            this.unsubscribeStore();
        }
    }

    @wire(getLensGalleryData, { snapshotId: '$snapshotId', baseSnapshotId: '$baseSnapshotId', countryTag: '$selectedCountryTag' })
    wiredLenses({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.lenses = data;
        } else if (error) {
            console.error('Error loading lens gallery data', error);
            this.lenses = [];
        }
    }

    loadGalleryData() {
        this.isLoading = true;
        getLensGalleryData({
            snapshotId: this.snapshotId,
            baseSnapshotId: this.baseSnapshotId,
            countryTag: this.selectedCountryTag
        })
            .then((data) => {
                this.lenses = data || [];
                this.isLoading = false;
            })
            .catch((err) => {
                console.error('Error fetching gallery data', err);
                this.isLoading = false;
            });
    }

    handleCountryChange(event) {
        this.selectedCountryTag = event.detail.value;
        this.loadGalleryData();
    }
}
