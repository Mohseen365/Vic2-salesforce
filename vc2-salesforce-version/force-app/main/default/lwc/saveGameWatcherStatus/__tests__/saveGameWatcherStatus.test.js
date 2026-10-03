import { createElement } from 'lwc';
import SaveGameWatcherStatus from 'c/saveGameWatcherStatus';
import { subscribe, unsubscribe } from 'lightning/empApi';

async function flushPromises() {
    return Promise.resolve().then(() => Promise.resolve());
}

describe('c-save-game-watcher-status', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('subscribes to empApi channel on connectedCallback and renders initial badge', async () => {
        const element = createElement('c-save-game-watcher-status', {
            is: SaveGameWatcherStatus
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        await flushPromises();

        expect(subscribe).toHaveBeenCalledWith('/event/Economy_Import_Event__e', -1, expect.any(Function));

        const badge = element.shadowRoot.querySelector('span.slds-badge');
        expect(badge).not.toBeNull();
        expect(badge.textContent.trim()).toBe('COMPLETED');
    });

    it('processes matching platform event, updates status badge, emits statuschange event and toast', async () => {
        subscribe.mockImplementation((channel, replayId, callback) => {
            subscribe.__callback = callback;
            return Promise.resolve({
                id: 'sub-123',
                channel,
                subscription: { channel }
            });
        });

        const element = createElement('c-save-game-watcher-status', {
            is: SaveGameWatcherStatus
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        await flushPromises();

        expect(subscribe).toHaveBeenCalled();
        const messageCallback = subscribe.__callback;
        expect(messageCallback).toBeDefined();

        const dispatchEventSpy = jest.spyOn(element, 'dispatchEvent');

        // Simulate incoming PROCESSING event
        messageCallback({
            data: {
                payload: {
                    Analysis_Id__c: 'a00000000000001AAA',
                    Status__c: 'PROCESSING',
                    Diagnostic_Message__c: ''
                }
            }
        });

        await flushPromises();

        expect(dispatchEventSpy).toHaveBeenCalledTimes(1);
        expect(dispatchEventSpy.mock.calls[0][0].type).toBe('statuschange');
        expect(dispatchEventSpy.mock.calls[0][0].detail).toEqual({
            analysisId: 'a00000000000001AAA',
            status: 'PROCESSING',
            diagnosticMessage: ''
        });

        let badge = element.shadowRoot.querySelector('span.slds-badge');
        expect(badge.textContent.trim()).toBe('PROCESSING');

        // Simulate incoming COMPLETED event
        messageCallback({
            data: {
                payload: {
                    Analysis_Id__c: 'a00000000000001AAA',
                    Status__c: 'COMPLETED',
                    Diagnostic_Message__c: ''
                }
            }
        });

        await flushPromises();

        expect(dispatchEventSpy).toHaveBeenCalledTimes(3); // 2 statuschange + 1 showtoast
        const dispatchedTypes = dispatchEventSpy.mock.calls.map(c => c[0].type);
        expect(dispatchedTypes).toContain('statuschange');
        expect(dispatchedTypes).toContain('lightning__showtoast');

        badge = element.shadowRoot.querySelector('span.slds-badge');
        expect(badge.textContent.trim()).toBe('COMPLETED');
    });

    it('ignores events for a different analysisId', async () => {
        subscribe.mockImplementation((channel, replayId, callback) => {
            subscribe.__callback = callback;
            return Promise.resolve({
                id: 'sub-123',
                channel,
                subscription: { channel }
            });
        });

        const element = createElement('c-save-game-watcher-status', {
            is: SaveGameWatcherStatus
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        await flushPromises();

        const messageCallback = subscribe.__callback;

        const statusChangeHandler = jest.fn();
        element.addEventListener('statuschange', statusChangeHandler);

        // Emit event with different analysisId
        messageCallback({
            data: {
                payload: {
                    Analysis_Id__c: 'a00000000000002BBB',
                    Status__c: 'FAILED',
                    Diagnostic_Message__c: 'Different record'
                }
            }
        });

        await flushPromises();

        expect(statusChangeHandler).not.toHaveBeenCalled();
        const badge = element.shadowRoot.querySelector('span.slds-badge');
        expect(badge.textContent.trim()).toBe('COMPLETED');
    });

    it('emits error toast when FAILED status event is received', async () => {
        subscribe.mockImplementation((channel, replayId, callback) => {
            subscribe.__callback = callback;
            return Promise.resolve({
                id: 'sub-123',
                channel,
                subscription: { channel }
            });
        });

        const element = createElement('c-save-game-watcher-status', {
            is: SaveGameWatcherStatus
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        await flushPromises();

        const messageCallback = subscribe.__callback;
        const dispatchEventSpy = jest.spyOn(element, 'dispatchEvent');

        messageCallback({
            data: {
                payload: {
                    Analysis_Id__c: 'a00000000000001AAA',
                    Status__c: 'FAILED',
                    Diagnostic_Message__c: 'Heap limit exceeded'
                }
            }
        });

        await flushPromises();

        expect(dispatchEventSpy).toHaveBeenCalledTimes(2); // statuschange + showtoast
        const dispatchedTypes = dispatchEventSpy.mock.calls.map(c => c[0].type);
        expect(dispatchedTypes).toContain('lightning__showtoast');

        const toastEvent = dispatchEventSpy.mock.calls.find(c => c[0].type === 'lightning__showtoast')[0];
        expect(toastEvent.detail.variant).toBe('error');
        expect(toastEvent.detail.message).toContain('Heap limit exceeded');

        const badge = element.shadowRoot.querySelector('span.slds-badge');
        expect(badge.textContent.trim()).toBe('FAILED');
    });

    it('unsubscribes on disconnectedCallback', async () => {
        subscribe.mockImplementation((channel, replayId, callback) => {
            return Promise.resolve({
                id: 'sub-123',
                channel,
                subscription: { channel }
            });
        });

        unsubscribe.mockImplementation((sub, cb) => {
            if (cb) cb({ isSuccess: true });
            return Promise.resolve({ isSuccess: true });
        });

        const element = createElement('c-save-game-watcher-status', {
            is: SaveGameWatcherStatus
        });
        element.analysisId = 'a00000000000001AAA';
        document.body.appendChild(element);

        await flushPromises();

        document.body.removeChild(element);

        await flushPromises();

        expect(unsubscribe).toHaveBeenCalled();
    });
});
