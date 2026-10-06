import SAVE_CONTEXT_CHANNEL from '@salesforce/messageChannel/SaveContext__c';

const DEFAULT_STATE = Object.freeze({
    saveId: null,
    snapshotId: null,
    snapshotDate: null,
    countryTag: null,
    observerMode: false,
    baselineType: 'previous',
    baselineRef: null,
    rollupSchemaVersion: '1.0.0'
});

let currentState = { ...DEFAULT_STATE };
const listeners = new Set();

/**
 * Returns a shallow clone of the active context state.
 */
export function getContext() {
    return { ...currentState };
}

/**
 * Replaces the current state with new state values merged over defaults.
 * @param {Object} newState
 */
export function setContext(newState = {}) {
    currentState = {
        ...DEFAULT_STATE,
        ...newState
    };
    notifyListeners();
    return getContext();
}

/**
 * Updates specified properties in the active context state.
 * @param {Object} partialState
 */
export function updateContext(partialState = {}) {
    currentState = {
        ...currentState,
        ...partialState
    };
    notifyListeners();
    return getContext();
}

/**
 * Resets context state back to initial default values.
 */
export function resetContext() {
    currentState = { ...DEFAULT_STATE };
    notifyListeners();
    return getContext();
}

/**
 * Subscribes a listener callback function to state changes.
 * @param {Function} callback
 * @returns {Function} Unsubscribe function
 */
export function subscribeContext(callback) {
    if (typeof callback === 'function') {
        listeners.add(callback);
    }
    return () => unsubscribeContext(callback);
}

/**
 * Unsubscribes a listener callback function.
 * @param {Function} callback
 */
export function unsubscribeContext(callback) {
    listeners.delete(callback);
}

/**
 * Internal helper to notify all registered listeners.
 */
function notifyListeners() {
    const snapshot = getContext();
    listeners.forEach((callback) => {
        try {
            callback(snapshot);
        } catch (e) {
            // Prevent listener exceptions from breaking store execution
            console.error('Error in contextStore listener:', e);
        }
    });
}

export { SAVE_CONTEXT_CHANNEL, DEFAULT_STATE };
