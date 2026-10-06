import { createElement } from 'lwc';
import CompareSuite from 'c/compareSuite';

jest.mock(
    '@salesforce/apex/TimeSeriesController.getNarrowTimeSeries',
    () => ({ default: jest.fn().mockResolvedValue([]) }),
    { virtual: true }
);

describe('c-compare-suite', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('defaults to overlay trend view mode', () => {
        const element = createElement('c-compare-suite', {
            is: CompareSuite
        });
        document.body.appendChild(element);

        const trendComp = element.shadowRoot.querySelector('c-multi-save-trend');
        expect(trendComp).not.toBeNull();
    });

    it('switches to split-screen A|B mode on mode button click', async () => {
        const element = createElement('c-compare-suite', {
            is: CompareSuite
        });
        document.body.appendChild(element);

        const splitBtn = element.shadowRoot.querySelector('button[data-mode="SPLIT"]');
        expect(splitBtn).not.toBeNull();
        splitBtn.click();

        await Promise.resolve();

        const splitControls = element.shadowRoot.querySelector('.split-controls');
        expect(splitControls).not.toBeNull();
    });
});
