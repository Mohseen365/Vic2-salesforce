/**
 * RFC 4180 compliant CSV utility module for Victoria 2 Economy Analyzer.
 * Supports legacy flat CSV export parity and 49-good commodity unpivoting.
 */

export const GOLDEN_COMMODITIES = [
    'ammunition', 'small_arms', 'artillery', 'canned_food', 'barrels', 'aeroplanes',
    'cotton', 'dye', 'wool', 'silk', 'coal', 'sulphur', 'iron', 'timber', 'tropical_wood',
    'rubber', 'oil', 'precious_metal', 'precious_goods', 'steel', 'cement', 'machine_parts',
    'glass', 'fuel', 'fertilizer', 'explosives', 'clipper_convoy', 'steamer_convoy',
    'electric_gear', 'fabric', 'lumber', 'paper', 'cattle', 'fish', 'fruit', 'grain',
    'tobacco', 'tea', 'coffee', 'opium', 'automobiles', 'telephones', 'wine', 'liquor',
    'regular_clothes', 'luxury_clothes', 'furniture', 'luxury_furniture', 'radio'
];

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

export function formatCurrencyValue(val) {
    if (val === null || val === undefined) return '$0.00';
    if (typeof val === 'string' && val.startsWith('$')) return val;
    const num = Number(val);
    if (isNaN(num)) return '$0.00';
    const formatted = Math.abs(num).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return num < 0 ? `-$${formatted}` : `$${formatted}`;
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

export function buildGoodsCsv(goods) {
    const headers = [
        { key: 'good', label: 'Good' },
        { key: 'price', label: 'Price', decimals: 5 }
    ];
    const rows = (goods || []).map(g => ({
        good: g.productCode || g.Good || g.good || g.code || '',
        price: g.price != null ? g.price : (g.Price != null ? g.Price : (g.basePrice != null ? g.basePrice : 0.0))
    }));
    return toCsv(rows, headers);
}

export function buildCountriesCsv(countries, products, junctions) {
    if (!junctions && Array.isArray(countries) && countries.length > 0 && !countries[0].productStorages) {
        // Fallback for flat DTO list if unpivot data is not supplied
        const simpleHeaders = [
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
        return toCsv(countries || [], simpleHeaders);
    }

    // Unpivot map: `${countryTag}_${productCode}` -> qty
    const unpivotMap = new Map();
    if (Array.isArray(junctions)) {
        for (const j of junctions) {
            const tag = j.countryTag || (j.Country_Economy__r ? j.Country_Economy__r.Country_Tag__c : '');
            const code = j.productCode || j.Product_Code__c || '';
            const qty = j.soldDomestic != null ? j.soldDomestic : (j.Sold_Domestic__c != null ? j.Sold_Domestic__c : 0.0);
            if (tag && code) {
                unpivotMap.set(`${tag}_${code}`, qty);
            }
        }
    }

    const commodityOrder = GOLDEN_COMMODITIES;

    const headers = [
        { key: 'Rank', label: 'Rank' },
        { key: 'ID', label: 'ID' },
        { key: 'Name', label: 'Name' },
        { key: 'Population', label: 'Population', decimals: 1 },
        { key: 'Colony_Population', label: 'Colony_Population', decimals: 1 },
        { key: 'Total_Population', label: 'Total_Population', decimals: 1 },
        { key: 'FGDP', label: 'FGDP' },
        { key: 'PGDP', label: 'PGDP' },
        { key: 'AGDP', label: 'AGDP' },
        { key: 'GDP', label: 'GDP' },
        { key: 'GDPperCapita', label: 'GDPperCapita' },
        ...commodityOrder.map(comm => ({ key: comm, label: comm, decimals: 1 }))
    ];

    const rows = (countries || []).map(c => {
        const tag = c.countryTag || c.tag || c.ID || '';
        const name = c.countryTag || c.tag || c.Name || tag;
        const pop = c.corePopulation != null ? c.corePopulation : (c.Population != null ? c.Population : 0);
        const colPop = c.colonyPopulation != null ? c.colonyPopulation : (c.Colony_Population != null ? c.Colony_Population : 0);
        const totPop = c.population != null ? c.population : (c.Total_Population != null ? c.Total_Population : pop + colPop);

        const fgdp = formatCurrencyValue(c.factoryGdp != null ? c.factoryGdp : c.FGDP);
        const pgdp = formatCurrencyValue(c.provinceGdp != null ? c.provinceGdp : c.PGDP);
        const agdp = formatCurrencyValue(c.artisanGdp != null ? c.artisanGdp : c.AGDP);
        const gdp = formatCurrencyValue(c.gdp != null ? c.gdp : c.GDP);
        const gdpPerCapita = c.gdpPerCapita != null ? `$${c.gdpPerCapita.toFixed(2)}` : (c.GDPperCapita != null ? `$${Number(c.GDPperCapita).toFixed(2)}` : '$0.00');

        const row = {
            Rank: c.gdpRank != null ? c.gdpRank : c.Rank,
            ID: tag,
            Name: name,
            Population: pop,
            Colony_Population: colPop,
            Total_Population: totPop,
            FGDP: fgdp,
            PGDP: pgdp,
            AGDP: agdp,
            GDP: gdp,
            GDPperCapita: gdpPerCapita
        };

        // Populate product storages if attached directly to country DTO
        const countryStorages = c.productStorages || [];
        const storageMap = new Map();
        for (const ps of countryStorages) {
            const code = ps.productCode || ps.productName || '';
            const qty = ps.soldDomestic != null ? ps.soldDomestic : 0.0;
            if (code) storageMap.set(code, qty);
        }

        for (const comm of commodityOrder) {
            if (unpivotMap.has(`${tag}_${comm}`)) {
                row[comm] = unpivotMap.get(`${tag}_${comm}`);
            } else if (storageMap.has(comm)) {
                row[comm] = storageMap.get(comm);
            } else if (c[comm] != null) {
                row[comm] = Number(c[comm]);
            } else {
                row[comm] = 0.0;
            }
        }

        return row;
    });

    return toCsv(rows, headers);
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
        { key: 'ID', label: 'ID' },
        { key: 'Provid', label: 'Provid' },
        { key: 'Name', label: 'Name' },
        { key: 'Owner', label: 'Owner' },
        { key: 'Country', label: 'Country' },
        { key: 'State', label: 'State' },
        { key: 'Colony', label: 'Colony' },
        { key: 'Pop', label: 'Pop', decimals: 1 },
        { key: 'Goods_type', label: 'Goods_type' },
        { key: 'RGO_Production', label: 'RGO_Production', decimals: 6 },
        { key: 'Last_income', label: 'Last_income', decimals: 8 },
        { key: 'GDP', label: 'GDP', decimals: 8 },
        { key: 'Last_Spending', label: 'Last_Spending', decimals: 6 },
        { key: 'Production_Income', label: 'Production_Income', decimals: 6 },
        { key: 'AGDP', label: 'AGDP', decimals: 16 }
    ];

    const rows = (provinces || []).map(p => ({
        ID: p.id || p.ID || p.provinceId || p.externalProvinceId || '',
        Provid: p.provid || p.Provid || p.externalProvinceId || '',
        Name: p.name || p.Name || p.provinceName || '',
        Owner: p.owner || p.Owner || p.countryTag || '',
        Country: p.country || p.Country || p.countryTag || '',
        State: p.state || p.State || p.stateName || 'blank',
        Colony: p.colony != null ? (p.colony ? 'True' : 'False') : (p.Colony != null ? String(p.Colony) : 'False'),
        Pop: p.population != null ? p.population : (p.Pop != null ? p.Pop : 0.0),
        Goods_type: p.goodsType || p.Goods_type || p.rgoProduct || '',
        RGO_Production: p.rgoProduction != null ? p.rgoProduction : (p.RGO_Production != null ? p.RGO_Production : 0.0),
        Last_income: p.rgoIncome != null ? p.rgoIncome : (p.Last_income != null ? p.Last_income : 0.0),
        GDP: p.rgoGdp != null ? p.rgoGdp : (p.GDP != null ? p.GDP : 0.0),
        Last_Spending: p.artisanSpending != null ? p.artisanSpending : (p.Last_Spending != null ? p.Last_Spending : 0.0),
        Production_Income: p.artisanIncome != null ? p.artisanIncome : (p.Production_Income != null ? p.Production_Income : 0.0),
        AGDP: p.artisanGdp != null ? p.artisanGdp : (p.AGDP != null ? p.AGDP : 0.0)
    }));

    return toCsv(rows, headers);
}

export function buildStatesCsv(states) {
    const headers = [
        { key: 'Rank', label: 'Rank' },
        { key: 'Name', label: 'Name' },
        { key: 'Country', label: 'Country' },
        { key: 'Population', label: 'Population', decimals: 1 },
        { key: 'GDP', label: 'GDP' },
        { key: 'GDP_PerCapita', label: 'GDP_PerCapita' },
        { key: 'RGO_Income', label: 'RGO_Income' },
        { key: 'PGDP', label: 'PGDP' },
        { key: 'AGDP', label: 'AGDP' },
        { key: 'FGDP', label: 'FGDP' },
        { key: 'Employees', label: 'Employees' },
        { key: 'Revenue', label: 'Revenue' },
        { key: 'Profit', label: 'Profit' }
    ];

    const rows = (states || []).map((s, idx) => ({
        Rank: s.rank != null ? s.rank : (s.Rank != null ? s.Rank : idx + 1),
        Name: s.stateName || s.Name || 'blank',
        Country: s.countryTag || s.Country || '',
        Population: s.population != null ? s.population : (s.Population != null ? s.Population : 0.0),
        GDP: formatCurrencyValue(s.gdp != null ? s.gdp : s.GDP),
        GDP_PerCapita: s.gdpPerCapita != null ? `$${s.gdpPerCapita.toFixed(2)}` : (s.GDP_PerCapita != null ? `$${Number(s.GDP_PerCapita).toFixed(2)}` : '$0.00'),
        RGO_Income: formatCurrencyValue(s.rgoIncome != null ? s.rgoIncome : s.RGO_Income),
        PGDP: formatCurrencyValue(s.pgdp != null ? s.pgdp : s.PGDP),
        AGDP: formatCurrencyValue(s.agdp != null ? s.agdp : s.AGDP),
        FGDP: formatCurrencyValue(s.fgdp != null ? s.fgdp : s.FGDP),
        Employees: s.factoryEmployees != null ? s.factoryEmployees : (s.Employees != null ? s.Employees : 0),
        Revenue: formatCurrencyValue(s.factoryRevenue != null ? s.factoryRevenue : s.Revenue),
        Profit: formatCurrencyValue(s.factoryProfit != null ? s.factoryProfit : s.Profit)
    }));

    return toCsv(rows, headers);
}

export function buildFactoriesCsv(factories) {
    const headers = [
        { key: 'Rank', label: 'Rank' },
        { key: 'State', label: 'State' },
        { key: 'Tag', label: 'Tag' },
        { key: 'Country', label: 'Country' },
        { key: 'Building', label: 'Building' },
        { key: 'Level', label: 'Level' },
        { key: 'Employees', label: 'Employees', decimals: 1 },
        { key: 'Produces', label: 'Produces', decimals: 5 },
        { key: 'Leftover', label: 'Leftover', decimals: 5 },
        { key: 'Money', label: 'Money' },
        { key: 'Revenue', label: 'Revenue' },
        { key: 'Input Costs', label: 'Input Costs' },
        { key: 'Pops_paychecks', label: 'Pops_paychecks' },
        { key: 'Profit', label: 'Profit' },
        { key: 'GDP', label: 'GDP', decimals: 8 },
        { key: 'Productivity', label: 'Productivity', decimals: 16 },
        { key: 'AvgWage', label: 'AvgWage', decimals: 16 }
    ];

    const rows = (factories || []).map((f, idx) => ({
        Rank: f.profitRank != null ? f.profitRank : (f.Rank != null ? f.Rank : idx + 1),
        State: f.stateCode || f.State || '',
        Tag: f.countryTag || f.Tag || '',
        Country: f.countryTag || f.Country || '',
        Building: f.buildingType || f.Building || '',
        Level: f.level != null ? f.level : (f.Level != null ? f.Level : 1),
        Employees: f.employees != null ? f.employees : (f.Employees != null ? f.Employees : 0.0),
        Produces: f.outputQuantity != null ? f.outputQuantity : (f.Produces != null ? f.Produces : 0.0),
        Leftover: f.unsoldQuantity != null ? f.unsoldQuantity : (f.Leftover != null ? f.Leftover : 0.0),
        Money: formatCurrencyValue(f.capitalReserves != null ? f.capitalReserves : f.Money),
        Revenue: formatCurrencyValue(f.revenue != null ? f.revenue : f.Revenue),
        'Input Costs': formatCurrencyValue(f.inputCost != null ? f.inputCost : f['Input Costs']),
        Pops_paychecks: formatCurrencyValue(f.wagesPaid != null ? f.wagesPaid : f.Pops_paychecks),
        Profit: formatCurrencyValue(f.profit != null ? f.profit : f.Profit),
        GDP: f.factoryGdp != null ? f.factoryGdp : (f.GDP != null ? f.GDP : 0.0),
        Productivity: f.productivity != null ? f.productivity : (f.Productivity != null ? f.Productivity : 0.0),
        AvgWage: f.averageWage != null ? f.averageWage : (f.AvgWage != null ? f.AvgWage : 0.0)
    }));

    return toCsv(rows, headers);
}

export function buildArtisansCsv(artisans) {
    const headers = [
        { key: 'ID', label: 'ID' },
        { key: 'Provid', label: 'Provid' },
        { key: 'Name', label: 'Name' },
        { key: 'Country', label: 'Country' },
        { key: 'State', label: 'State' },
        { key: 'artisan_type', label: 'artisan_type' },
        { key: 'last_spending', label: 'last_spending', decimals: 8 },
        { key: 'production_income', label: 'production_income', decimals: 8 },
        { key: 'AGDP', label: 'AGDP', decimals: 16 },
        { key: 'Production', label: 'Production', decimals: 16 }
    ];

    const rows = (artisans || []).map((a, idx) => ({
        ID: a.id || a.ID || idx + 1,
        Provid: a.externalProvinceId || a.Provid || '',
        Name: a.provinceName || a.Name || '',
        Country: a.countryTag || a.Country || '',
        State: a.stateCode || a.State || 'blank',
        artisan_type: a.artisanType || a.artisan_type || '',
        last_spending: a.spending != null ? a.spending : (a.last_spending != null ? a.last_spending : 0.0),
        production_income: a.income != null ? a.income : (a.production_income != null ? a.production_income : 0.0),
        AGDP: a.agdp != null ? a.agdp : (a.AGDP != null ? a.AGDP : 0.0),
        Production: a.productionQuantity != null ? a.productionQuantity : (a.Production != null ? a.Production : 0.0)
    }));

    return toCsv(rows, headers);
}
