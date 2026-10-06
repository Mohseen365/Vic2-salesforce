import {
    getContext,
    setContext,
    updateContext,
    resetContext,
    subscribeContext,
    unsubscribeContext,
    DEFAULT_STATE,
    SAVE_CONTEXT_CHANNEL
} from 'c/contextStore';

describe('c-context-store singleton module', () => {
    beforeEach(() => {
        resetContext();
    });

    test('getContext returns initial default state', () => {
        const state = getContext();
        expect(state).toEqual({
            saveId: null,
            snapshotId: null,
            snapshotDate: null,
            countryTag: null,
            observerMode: false,
            baselineType: 'previous',
            baselineRef: null,
            rollupSchemaVersion: '1.0.0'
        });
    });

    test('setContext replaces state with new values merged over defaults', () => {
        const newState = setContext({
            saveId: 'save123',
            snapshotId: 'snap456',
            countryTag: 'EGY',
            observerMode: true
        });

        expect(newState.saveId).toBe('save123');
        expect(newState.snapshotId).toBe('snap456');
        expect(newState.countryTag).toBe('EGY');
        expect(newState.observerMode).toBe(true);
        expect(newState.baselineType).toBe('previous');
        expect(newState.rollupSchemaVersion).toBe('1.0.0');
    });

    test('updateContext updates specific properties without wiping others', () => {
        setContext({ saveId: 'save1', countryTag: 'EGY' });

        const updated = updateContext({ countryTag: 'TUR', baselineType: 'initial' });

        expect(updated.saveId).toBe('save1');
        expect(updated.countryTag).toBe('TUR');
        expect(updated.baselineType).toBe('initial');
    });

    test('resetContext restores default state', () => {
        updateContext({ countryTag: 'GBR', observerMode: true });
        const reset = resetContext();

        expect(reset).toEqual(DEFAULT_STATE);
    });

    test('subscribeContext invokes listener callback on state changes', () => {
        const callback = jest.fn();
        const unsubscribe = subscribeContext(callback);

        updateContext({ countryTag: 'FRA' });

        expect(callback).toHaveBeenCalledTimes(1);
        expect(callback).toHaveBeenCalledWith(expect.objectContaining({ countryTag: 'FRA' }));

        unsubscribe();
        updateContext({ countryTag: 'PRU' });

        expect(callback).toHaveBeenCalledTimes(1);
    });

    test('unsubscribeContext removes listener', () => {
        const callback = jest.fn();
        subscribeContext(callback);
        unsubscribeContext(callback);

        updateContext({ countryTag: 'RUS' });

        expect(callback).not.toHaveBeenCalled();
    });

    test('SAVE_CONTEXT_CHANNEL is exported', () => {
        expect(SAVE_CONTEXT_CHANNEL).toBeDefined();
    });
});
