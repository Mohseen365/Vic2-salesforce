import { LightningElement, api, track } from 'lwc';
import getAdvisorResponse from '@salesforce/apex/CampaignAdvisorController.getAdvisorResponse';
import logFeedback from '@salesforce/apex/CampaignAdvisorController.logFeedback';
import { getContext, subscribeContext } from 'c/contextStore';

export default class CampaignAdvisor extends LightningElement {
    @api snapshotId = null;
    @api countryTag = 'TUR';
    @api activeTabKey = 'economy';

    @track userQuery = '';
    @track isLoading = false;
    @track advisorResponse = null;
    @track showPayload = false;
    @track showProvenanceModal = false;
    @track feedbackSubmitted = false;
    @track isPositiveFeedback = null;

    saveFileName = 'egypt.v2';
    snapshotDate = '1836-01-01';
    countryName = 'Ottoman Empire';

    unsubscribeStore = null;

    connectedCallback() {
        this.unsubscribeStore = subscribeContext((state) => {
            if (state.snapshotId) this.snapshotId = state.snapshotId;
            if (state.countryTag) this.countryTag = state.countryTag;
            if (state.activeTabKey) this.activeTabKey = state.activeTabKey;
        });

        const ctx = getContext();
        if (ctx.snapshotId) this.snapshotId = ctx.snapshotId;
        if (ctx.countryTag) this.countryTag = ctx.countryTag;

        // Trigger initial advisor load
        this.fetchAdvisorData('Overview');
    }

    disconnectedCallback() {
        if (typeof this.unsubscribeStore === 'function') {
            this.unsubscribeStore();
        }
    }

    get activeTabName() {
        if (!this.activeTabKey) return 'General';
        const key = this.activeTabKey.toLowerCase();
        if (key === 'economy' || key === 'product' || key === 'country') return 'Economy';
        if (key === 'society' || key === 'politics' || key === 'pop') return 'Society';
        if (key === 'power' || key === 'military' || key === 'war') return 'Power';
        return 'General';
    }

    get activeQuickPrompts() {
        const tab = (this.activeTabKey || '').toLowerCase();

        if (tab === 'society' || tab === 'politics' || tab === 'pop') {
            return [
                { id: 'qp1', label: 'Why is rebellion risk rising?', prompt: 'Why is my rebellion risk rising?' },
                { id: 'qp2', label: 'What is driving POP militancy?', prompt: 'What is driving POP militancy?' },
                { id: 'qp3', label: 'National stability check', prompt: 'Give me a national stability check' }
            ];
        }

        if (tab === 'power' || tab === 'military' || tab === 'war') {
            return [
                { id: 'qp4', label: 'Is my military budget ratio sustainable?', prompt: 'Is my military budget ratio sustainable?' },
                { id: 'qp5', label: 'Compare military strength', prompt: 'Compare my military strength composite' },
                { id: 'qp6', label: 'Land vs Naval power breakdown', prompt: 'What is my land vs naval power breakdown?' }
            ];
        }

        // Economy or default
        return [
            { id: 'qp7', label: 'Why is rebellion risk spiking?', prompt: 'Why is rebellion risk spiking?' },
            { id: 'qp8', label: 'Compare industry to Great Britain', prompt: 'Compare my industry to Great Britain' },
            { id: 'qp9', label: "What's draining my treasury?", prompt: "What's draining my treasury?" },
            { id: 'qp10', label: 'Top traded goods overview', prompt: 'Give me top traded goods overview' }
        ];
    }

    get payloadButtonLabel() {
        return this.showPayload ? 'Hide Action Payload Data ▲' : 'Show Action Payload Data ▼';
    }

    get thumbsUpClass() {
        return 'slds-button slds-button_icon slds-button_icon-border-filled ' +
            (this.isPositiveFeedback === true ? 'slds-button_brand' : '');
    }

    get thumbsDownClass() {
        return 'slds-button slds-button_icon slds-button_icon-border-filled slds-m-left_xx-small ' +
            (this.isPositiveFeedback === false ? 'slds-button_brand' : '');
    }

    get provenanceData() {
        if (this.advisorResponse && this.advisorResponse.provenance) {
            return this.advisorResponse.provenance;
        }
        return {
            saveId: this.snapshotId || 'N/A',
            snapshotDate: this.snapshotDate,
            countryTag: this.countryTag,
            sourceFields: []
        };
    }

    handleQueryChange(event) {
        this.userQuery = event.target.value;
    }

    handleKeyUp(event) {
        if (event.keyCode === 13) {
            this.handleSubmitQuery();
        }
    }

    handleQuickPromptClick(event) {
        const prompt = event.currentTarget.dataset.prompt;
        this.userQuery = prompt;
        this.fetchAdvisorData(prompt);
    }

    handleSubmitQuery() {
        this.fetchAdvisorData(this.userQuery);
    }

    fetchAdvisorData(query) {
        this.isLoading = true;
        this.feedbackSubmitted = false;
        this.isPositiveFeedback = null;

        getAdvisorResponse({
            userQuery: query || 'Overview',
            saveId: this.snapshotId,
            countryTag: this.countryTag,
            activeTab: this.activeTabKey
        }).then(result => {
            this.advisorResponse = result;
            if (result) {
                if (result.snapshotDate) this.snapshotDate = result.snapshotDate;
                if (result.countryName) this.countryName = result.countryName;
                if (result.countryTag) this.countryTag = result.countryTag;
            }
            this.isLoading = false;
        }).catch(error => {
            console.warn('Error fetching Campaign Advisor response:', error);
            this.isLoading = false;
        });
    }

    handleTogglePayload() {
        this.showPayload = !this.showPayload;
    }

    handleOpenProvenanceModal() {
        this.showProvenanceModal = true;
    }

    handleCloseProvenanceModal() {
        this.showProvenanceModal = false;
    }

    handleThumbsUp() {
        this.submitFeedback(true);
    }

    handleThumbsDown() {
        this.submitFeedback(false);
    }

    submitFeedback(isPositive) {
        this.isPositiveFeedback = isPositive;
        logFeedback({
            saveId: this.snapshotId,
            countryTag: this.countryTag,
            promptText: this.userQuery,
            responseText: this.advisorResponse ? this.advisorResponse.interpretationText : '',
            isPositive: isPositive,
            feedbackComments: 'User feedback logged from c-campaign-advisor panel'
        }).then(() => {
            this.feedbackSubmitted = true;
        }).catch(() => {
            this.feedbackSubmitted = true;
        });
    }

    handleClosePanel() {
        this.dispatchEvent(new CustomEvent('closepanel', {
            bubbles: true,
            composed: true
        }));
    }
}
