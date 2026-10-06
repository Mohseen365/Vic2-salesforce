import { LightningElement, api } from 'lwc';

export default class NavRail extends LightningElement {
    @api activeDomain = 'overview';
    @api isCollapsed = false;

    get isExpanded() {
        return !this.isCollapsed;
    }

    get containerCssClass() {
        let base = 'nav-rail-panel slds-p-around_xx-small ';
        return this.isCollapsed ? base + 'nav-rail-collapsed' : base + 'nav-rail-expanded';
    }

    get toggleIconName() {
        return this.isCollapsed ? 'utility:chevronright' : 'utility:chevronleft';
    }

    get toggleTitle() {
        return this.isCollapsed ? 'Expand Navigation Rail' : 'Collapse Navigation Rail';
    }

    get navGroups() {
        const active = this.activeDomain || 'overview';

        return [
            {
                title: 'Command',
                items: [
                    {
                        key: 'overview',
                        label: 'Overview',
                        icon: 'standard:dashboard',
                        badge: null,
                        cssClass: active === 'overview' ? 'nav-item nav-item-active' : 'nav-item'
                    }
                ]
            },
            {
                title: 'Economy',
                items: [
                    {
                        key: 'economy',
                        label: 'Economy Explorer',
                        icon: 'standard:chart',
                        badge: null,
                        cssClass: active === 'economy' ? 'nav-item nav-item-active' : 'nav-item'
                    }
                ]
            },
            {
                title: 'Society',
                items: [
                    {
                        key: 'pops',
                        label: 'POP Demographics',
                        icon: 'standard:groups',
                        badge: null,
                        cssClass: active === 'pops' ? 'nav-item nav-item-active' : 'nav-item'
                    },
                    {
                        key: 'politics',
                        label: 'Politics & Reforms',
                        icon: 'standard:endorsement',
                        badge: null,
                        cssClass: active === 'politics' ? 'nav-item nav-item-active' : 'nav-item'
                    }
                ]
            },
            {
                title: 'Power',
                items: [
                    {
                        key: 'military',
                        label: 'Military OOB',
                        icon: 'standard:shield',
                        badge: null,
                        cssClass: active === 'military' ? 'nav-item nav-item-active' : 'nav-item'
                    }
                ]
            },
            {
                title: 'Foreign',
                items: [
                    {
                        key: 'diplomacy',
                        label: 'Diplomacy & Sphere',
                        icon: 'standard:hierarchy',
                        badge: null,
                        cssClass: active === 'diplomacy' ? 'nav-item nav-item-active' : 'nav-item'
                    }
                ]
            },
            {
                title: 'Time',
                items: [
                    {
                        key: 'compare',
                        label: 'Compare Views',
                        icon: 'standard:metrics',
                        badge: null,
                        cssClass: active === 'compare' ? 'nav-item nav-item-active' : 'nav-item'
                    }
                ]
            }
        ];
    }

    handleToggleCollapse() {
        this.isCollapsed = !this.isCollapsed;
        this.dispatchEvent(
            new CustomEvent('collapsetoggle', {
                bubbles: true,
                composed: true,
                detail: { isCollapsed: this.isCollapsed }
            })
        );
    }

    handleItemClick(event) {
        event.preventDefault();
        const domainKey = event.currentTarget.dataset.key;
        if (!domainKey) return;

        this.dispatchEvent(
            new CustomEvent('navselect', {
                bubbles: true,
                composed: true,
                detail: { domainKey }
            })
        );
    }
}
