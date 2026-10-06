import { LightningElement, api } from 'lwc';

export default class KpiTile extends LightningElement {
    @api label = '';
    @api value = '';
    @api deltaPercent = null;
    @api deltaText = '';
    @api sparklineData = [];
    @api status = 'normal'; // normal, positive, warning, critical
    @api iconName = '';
    @api metricKey = '';

    get formattedValue() {
        if (this.value === null || this.value === undefined) {
            return '—';
        }
        return String(this.value);
    }

    get hasSparkline() {
        return Array.isArray(this.sparklineData) && this.sparklineData.length > 1;
    }

    get formattedDelta() {
        if (this.deltaText) {
            return this.deltaText;
        }
        if (this.deltaPercent === null || this.deltaPercent === undefined || isNaN(Number(this.deltaPercent))) {
            return '0.0%';
        }
        const num = Number(this.deltaPercent);
        const sign = num > 0 ? '+' : '';
        return `${sign}${num.toFixed(1)}%`;
    }

    get isPositive() {
        if (this.deltaPercent !== null && this.deltaPercent !== undefined) {
            return Number(this.deltaPercent) > 0;
        }
        return false;
    }

    get isNegative() {
        if (this.deltaPercent !== null && this.deltaPercent !== undefined) {
            return Number(this.deltaPercent) < 0;
        }
        return false;
    }

    get deltaArrow() {
        if (this.isPositive) {
            return '▲ ';
        }
        if (this.isNegative) {
            return '▼ ';
        }
        return '➖ ';
    }

    get deltaCssClass() {
        let base = 'kpi-delta slds-text-body_small ';
        if (this.isPositive) {
            return base + 'delta-positive';
        }
        if (this.isNegative) {
            return base + 'delta-negative';
        }
        return base + 'delta-neutral';
    }

    get tileCssClass() {
        return 'kpi-tile-card slds-card slds-p-around_small slds-interactive';
    }

    get statusDotClass() {
        if (this.status === 'critical') {
            return 'status-dot status-critical';
        }
        if (this.status === 'warning') {
            return 'status-dot status-warning';
        }
        if (this.status === 'positive') {
            return 'status-dot status-positive';
        }
        return '';
    }

    get statusTooltip() {
        return `Status: ${this.status}`;
    }

    get computedTitle() {
        return `${this.label}: ${this.formattedValue} (${this.formattedDelta})`;
    }

    get sparklinePath() {
        if (!this.hasSparkline) {
            return '';
        }
        const data = this.sparklineData;
        const width = 80;
        const height = 24;
        const padding = 2;

        const min = Math.min(...data);
        const max = Math.max(...data);
        const range = max - min || 1;

        const points = data.map((val, idx) => {
            const x = padding + (idx / (data.length - 1)) * (width - 2 * padding);
            const y = height - padding - ((val - min) / range) * (height - 2 * padding);
            return `${x.toFixed(1)},${y.toFixed(1)}`;
        });

        return `M ${points.join(' L ')}`;
    }

    get sparklineLineClass() {
        if (this.isPositive) return 'sparkline-line-positive';
        if (this.isNegative) return 'sparkline-line-negative';
        return 'sparkline-line-neutral';
    }

    handleTileClick() {
        this.dispatchEvent(
            new CustomEvent('tileselect', {
                bubbles: true,
                composed: true,
                detail: {
                    metricKey: this.metricKey || this.label,
                    label: this.label,
                    value: this.value
                }
            })
        );
    }
}
