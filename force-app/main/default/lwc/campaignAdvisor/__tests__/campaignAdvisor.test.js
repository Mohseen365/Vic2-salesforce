import { createElement } from 'lwc';
import CampaignAdvisor from 'c/campaignAdvisor';
import getAdvisorResponse from '@salesforce/apex/CampaignAdvisorController.getAdvisorResponse';
import logFeedback from '@salesforce/apex/CampaignAdvisorController.logFeedback';

jest.mock(
    '@salesforce/apex/CampaignAdvisorController.getAdvisorResponse',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/CampaignAdvisorController.logFeedback',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

const MOCK_ADVISOR_RESPONSE = {
    saveId: '001000000000000AAA',
    snapshotDate: '1864-03-01',
    countryTag: 'EGY',
    countryName: 'Egypt',
    userQuery: 'Why is rebellion risk rising?',
    actionType: 'REBELLION',
    isVerified: true,
    rejectionReason: '',
    facts: [
        { label: 'POP Militancy', value: '6.2 / 10', chipValue: '6.2 / 10', sourceField: 'Pop__c.Mil__c' },
        { label: 'Rebellion Risk Index (MET-D-041)', value: '62.0', chipValue: '62.0', sourceField: 'Movement__c.Radicalism__c' }
    ],
    interpretationText: 'Egypt exhibits elevated POP militancy of 6.2 / 10 and rebellion risk index of 62.0. Pass social reforms to pacify movements.',
    provenance: {
        saveId: '001000000000000AAA',
        snapshotDate: '1864-03-01',
        countryTag: 'EGY',
        sourceFields: ['Pop__c.Mil__c', 'Movement__c.Radicalism__c']
    },
    rawActionPayloadJson: '{\n  "countryTag": "EGY",\n  "rebellionRiskIndex": 62.0\n}'
};

describe('c-campaign-advisor', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders panel header and pinned context banner', async () => {
        getAdvisorResponse.mockResolvedValue(MOCK_ADVISOR_RESPONSE);

        const element = createElement('c-campaign-advisor', {
            is: CampaignAdvisor
        });
        element.snapshotId = '001000000000000AAA';
        element.countryTag = 'EGY';
        element.activeTabKey = 'society';
        document.body.appendChild(element);

        await Promise.resolve();

        const banner = element.shadowRoot.querySelector('[data-testid="pinned-context-banner"]');
        expect(banner).not.toBeNull();
        expect(banner.textContent).toContain('EGY');
    });

    it('renders context-aware quick prompt chips and triggers query on click', async () => {
        getAdvisorResponse.mockResolvedValue(MOCK_ADVISOR_RESPONSE);

        const element = createElement('c-campaign-advisor', {
            is: CampaignAdvisor
        });
        element.activeTabKey = 'society';
        document.body.appendChild(element);

        await Promise.resolve();

        const chips = element.shadowRoot.querySelectorAll('[data-testid="quick-prompt-chip"]');
        expect(chips.length).toBeGreaterThan(0);

        chips[0].click();
        await Promise.resolve();

        expect(getAdvisorResponse).toHaveBeenCalled();
    });

    it('displays FACTS and INTERPRETATION blocks upon receiving response', async () => {
        getAdvisorResponse.mockResolvedValue(MOCK_ADVISOR_RESPONSE);

        const element = createElement('c-campaign-advisor', {
            is: CampaignAdvisor
        });
        document.body.appendChild(element);

        await Promise.resolve();
        await Promise.resolve();

        const factsBlock = element.shadowRoot.querySelector('[data-testid="facts-block"]');
        expect(factsBlock).not.toBeNull();

        const chips = element.shadowRoot.querySelectorAll('[data-testid="fact-chip"]');
        expect(chips.length).toBe(2);
        expect(chips[0].textContent).toContain('6.2 / 10');

        const interpBlock = element.shadowRoot.querySelector('[data-testid="interpretation-block"]');
        expect(interpBlock).not.toBeNull();
        expect(interpBlock.textContent).toContain('Egypt exhibits elevated POP militancy');
    });

    it('toggles payload JSON box when "Show Action Payload Data" button is clicked', async () => {
        getAdvisorResponse.mockResolvedValue(MOCK_ADVISOR_RESPONSE);

        const element = createElement('c-campaign-advisor', {
            is: CampaignAdvisor
        });
        document.body.appendChild(element);

        await Promise.resolve();
        await Promise.resolve();

        const toggleBtn = element.shadowRoot.querySelector('[data-testid="toggle-payload-btn"]');
        expect(toggleBtn).not.toBeNull();

        toggleBtn.click();
        await Promise.resolve();

        const jsonBox = element.shadowRoot.querySelector('[data-testid="payload-json-box"]');
        expect(jsonBox).not.toBeNull();
        expect(jsonBox.textContent).toContain('rebellionRiskIndex');
    });

    it('opens and closes provenance modal when inspect button is clicked', async () => {
        getAdvisorResponse.mockResolvedValue(MOCK_ADVISOR_RESPONSE);

        const element = createElement('c-campaign-advisor', {
            is: CampaignAdvisor
        });
        document.body.appendChild(element);

        await Promise.resolve();
        await Promise.resolve();

        const inspectBtn = element.shadowRoot.querySelector('[data-testid="inspect-source-btn"]');
        expect(inspectBtn).not.toBeNull();

        inspectBtn.click();
        await Promise.resolve();

        const modal = element.shadowRoot.querySelector('[data-testid="provenance-modal"]');
        expect(modal).not.toBeNull();
        expect(modal.textContent).toContain('Pop__c.Mil__c');
    });

    it('logs feedback when thumbs up button is clicked', async () => {
        getAdvisorResponse.mockResolvedValue(MOCK_ADVISOR_RESPONSE);
        logFeedback.mockResolvedValue(true);

        const element = createElement('c-campaign-advisor', {
            is: CampaignAdvisor
        });
        document.body.appendChild(element);

        await Promise.resolve();
        await Promise.resolve();

        const thumbsUp = element.shadowRoot.querySelector('[data-testid="thumbs-up-btn"]');
        expect(thumbsUp).not.toBeNull();

        thumbsUp.click();
        await Promise.resolve();

        expect(logFeedback).toHaveBeenCalledWith(expect.objectContaining({
            isPositive: true
        }));
    });
});
