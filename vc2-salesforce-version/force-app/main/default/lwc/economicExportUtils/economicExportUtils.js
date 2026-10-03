/**
 * RFC 4180 compliant CSV utility module for Victoria 2 Economy Analyzer.
 */

export function escapeCsvValue(value) {
    if (value === null || value === undefined) {
        return '';
    }
    const str = String(value);
    if (str.includes('"') || str.includes(',') || str.includes('\n') || str.includes('\r')) {
        return `"${str.replace(/"/g, '""')}"`;
    }
    return str;
}

export function toCsv(rows, headers) {
    if (!headers || !headers.length) {
        return '';
    }

    const headerLine = headers.map(h => escapeCsvValue(h.label || h.key)).join(',');
    if (!rows || !rows.length) {
        return headerLine;
    }

    const lines = [headerLine];

    for (const row of rows) {
        const line = headers.map(h => {
            const rawVal = row[h.key];
            if (rawVal === null || rawVal === undefined) {
                return '';
            }
            if (typeof rawVal === 'number' && h.decimals !== undefined) {
                return escapeCsvValue(rawVal.toFixed(h.decimals));
            }
            return escapeCsvValue(rawVal);
        }).join(',');
        lines.push(line);
    }

    return lines.join('\n');
}

export function generateFilename(saveFileName, scope, ingameDate) {
    const cleanName = (saveFileName || 'Economy_Analysis').replace(/[^a-zA-Z0-9_-]/g, '_');
    const cleanScope = (scope || 'Export').toLowerCase();
    const dateStr = ingameDate ? `_${ingameDate}` : '';
    return `${cleanName}_${cleanScope}${dateStr}.csv`;
}

export function buildAnalysisCsv(summary) {
    const headers = [
        { key: 'analysisId', label: 'Analysis ID' },
        { key: 'saveFileName', label: 'Save File Name' },
        { key: 'sourceSaveFileName', label: 'Source File Name' },
        { key: 'ingameDate', label: 'Ingame Date' },
        { key: 'playerCountryTag', label: 'Player Country' },
        { key: 'totalWorldGdp', label: 'Total World GDP (£)', decimals: 2 },
        { key: 'totalWorldPopulation', label: 'Total World Population' },
        { key: 'totalWorldImports', label: 'Total World Imports (£)', decimals: 2 },
        { key: 'totalWorldExports', label: 'Total World Exports (£)', decimals: 2 },
        { key: 'importStatus', label: 'Import Status' }
    ];
    return toCsv(summary ? [summary] : [], headers);
}

export function buildCountriesCsv(countries) {
    const headers = [
        { key: 'countryTag', label: 'Tag' },
        { key: 'countryName', label: 'Official Name' },
        { key: 'gdpRank', label: 'GDP Rank' },
        { key: 'gdp', label: 'GDP (£)', decimals: 2 },
        { key: 'gdpPerCapita', label: 'GDP Per Capita (£)', decimals: 2 },
        { key: 'gdpShare', label: 'GDP Share %', decimals: 4 },
        { key: 'population', label: 'Population' },
        { key: 'workforce', label: 'Workforce' },
        { key: 'employment', label: 'Employment' },
        { key: 'unemploymentRate', label: 'Unemployment Rate %', decimals: 2 },
        { key: 'totalImports', label: 'Total Imports (£)', decimals: 2 },
        { key: 'totalExports', label: 'Total Exports (£)', decimals: 2 },
        { key: 'goldIncome', label: 'Gold Income (£)', decimals: 2 }
    ];
    return toCsv(countries || [], headers);
}

export function buildProductsCsv(products) {
    const headers = [
        { key: 'productCode', label: 'Product Code' },
        { key: 'productName', label: 'Product Name' },
        { key: 'price', label: 'Price (£)', decimals: 4 },
        { key: 'basePrice', label: 'Base Price (£)', decimals: 4 },
        { key: 'totalWorldSupply', label: 'Total World Supply', decimals: 4 },
        { key: 'realDemand', label: 'Real Demand', decimals: 4 },
        { key: 'maxDemand', label: 'Max Demand', decimals: 4 },
        { key: 'inflationPercent', label: 'Inflation %', decimals: 2 },
        { key: 'overproductionPercent', label: 'Overproduction %', decimals: 2 }
    ];
    return toCsv(products || [], headers);
}

export function buildCountryProductsCsv(junctions) {
    const headers = [
        { key: 'countryTag', label: 'Country Tag' },
        { key: 'productCode', label: 'Product Code' },
        { key: 'soldDomestic', label: 'Sold Domestic Qty', decimals: 4 },
        { key: 'boughtQuantity', label: 'Bought Qty', decimals: 4 },
        { key: 'thrownToMarket', label: 'Thrown To Market Qty', decimals: 4 },
        { key: 'actualSoldWorld', label: 'Actual Sold World Qty', decimals: 4 },
        { key: 'domesticSalesValue', label: 'Domestic Sales Value (£)', decimals: 2 },
        { key: 'importValue', label: 'Import Value (£)', decimals: 2 },
        { key: 'exportValue', label: 'Export Value (£)', decimals: 2 },
        { key: 'gdpContribution', label: 'GDP Contribution (£)', decimals: 2 }
    ];
    return toCsv(junctions || [], headers);
}

export function buildProvincesCsv(provinces) {
    const headers = [
        { key: 'externalProvinceId', label: 'Province ID' },
        { key: 'countryTag', label: 'Country Tag' },
        { key: 'population', label: 'Population' },
        { key: 'rgoProduction', label: 'RGO Production', decimals: 4 }
    ];
    return toCsv(provinces || [], headers);
}
