import { createElement } from 'lwc';
import LensGallery from 'c/lensGallery';

describe('c-lens-gallery', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders lens gallery component container', () => {
        const element = createElement('c-lens-gallery', {
            is: LensGallery
        });
        document.body.appendChild(element);

        const gallery = element.shadowRoot.querySelector('[data-testid="lens-gallery"]');
        expect(gallery).not.toBeNull();
    });
});
