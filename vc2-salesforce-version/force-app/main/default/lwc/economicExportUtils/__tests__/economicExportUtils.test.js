import {
    escapeCsvValue,
    toCsv,
    generateFilename,
    buildAnalysisCsv,
    buildGoodsCsv,
    buildCountriesCsv,
    buildProductsCsv,
    buildCountryProductsCsv,
    buildProvincesCsv,
    buildStatesCsv,
    buildFactoriesCsv,
    buildArtisansCsv,
    GOLDEN_COMMODITIES
} from 'c/economicExportUtils';

describe('economicExportUtils', () => {
    describe('escapeCsvValue', () => {
        it('returns empty string for null and undefined', () => {
            expect(escapeCsvValue(null)).toBe('');
            expect(escapeCsvValue(undefined)).toBe('');
        });

        it('returns plain string when no special characters present', () => {
            expect(escapeCsvValue('hello')).toBe('hello');
            expect(escapeCsvValue(123)).toBe('123');
        });

        it('wraps string in quotes and doubles embedded quotes when comma, quote, or newline present', () => {
            expect(escapeCsvValue('hello,world')).toBe('"hello,world"');
            expect(escapeCsvValue('hello "world"')).toContain('hello ""world""');
            expect(escapeCsvValue('line1\nline2')).toBe('"line1\nline2"');
        });
    });

    describe('toCsv', () => {
        it('returns empty string if headers empty', () => {
            expect(toCsv([{ a: 1 }], [])).toBe('');
        });

        it('returns header line if rows empty', () => {
            const headers = [{ key: 'a', label: 'Col A' }, { key: 'b', label: 'Col B' }];
            expect(toCsv([], headers)).toBe('Col A,Col B');
        });

        it('formats numbers with specified decimals', () => {
            const headers = [{ key: 'price', label: 'Price', decimals: 2 }];
            const rows = [{ price: 12.3456 }];
            expect(toCsv(rows, headers)).toBe('Price\n12.35');
        });
    });

    describe('generateFilename', () => {
        it('generates filename with sanitized save name, scope, and ingame date', () => {
            const name = generateFilename('prussia_1848.v2', 'Countries', '1848-03-12');
            expect(name).toBe('prussia_1848_v2_countries_1848-03-12.csv');
        });
    });

    describe('builders', () => {
        it('builds Analysis CSV correctly', () => {
            const summary = {
                analysisId: 'a001',
                saveFileName: 'egypt.v2',
                ingameDate: '1836-01-01',
                playerCountryTag: 'EGY',
                totalWorldGdp: 1234567.89
            };
            const csv = buildAnalysisCsv(summary);
            expect(csv).toContain('Analysis ID,Save File Name');
            expect(csv).toContain('a001,egypt.v2');
            expect(csv).toContain('1234567.89');
        });

        it('builds Goods CSV correctly', () => {
            const goods = [
                { productCode: 'ammunition', price: 18.8313 }
            ];
            const csv = buildGoodsCsv(goods);
            expect(csv).toContain('Good,Price');
            expect(csv).toContain('ammunition,18.83130');
        });

        it('builds Countries CSV with 49-good unpivot correctly', () => {
            const countries = [
                {
                    countryTag: 'TUR',
                    gdpRank: 1,
                    corePopulation: 13252500,
                    colonyPopulation: 34229316,
                    population: 47481816,
                    factoryGdp: 280400.13,
                    provinceGdp: 6726168.0,
                    artisanGdp: 3824.0,
                    gdp: 7010392.13,
                    gdpPerCapita: 0.53
                }
            ];
            const junctions = [
                { countryTag: 'TUR', productCode: 'ammunition', soldDomestic: 25.5 },
                { countryTag: 'TUR', productCode: 'small_arms', soldDomestic: 8.4 }
            ];
            const csv = buildCountriesCsv(countries, null, junctions);
            expect(csv).toContain('Rank,ID,Name,Population,Colony_Population,Total_Population,FGDP,PGDP,AGDP,GDP,GDPperCapita');
            for (const comm of GOLDEN_COMMODITIES) {
                expect(csv).toContain(comm);
            }
            expect(csv).toContain('1,TUR,TUR,13252500.0,34229316.0,47481816.0,"$280,400.13","$6,726,168.00","$3,824.00","$7,010,392.13",$0.53,25.5,8.4');
        });

        it('builds Products CSV correctly', () => {
            const products = [
                { productCode: 'small_arms', productName: 'Small Arms', price: 12.5, basePrice: 10.0 }
            ];
            const csv = buildProductsCsv(products);
            expect(csv).toContain('Product Code,Product Name,Price (£)');
            expect(csv).toContain('small_arms,Small Arms,12.5000,10.0000');
        });

        it('builds Country Products CSV correctly', () => {
            const cp = [
                { countryTag: 'PRU', productCode: 'small_arms', soldDomestic: 50.0, importValue: 120.0 }
            ];
            const csv = buildCountryProductsCsv(cp);
            expect(csv).toContain('Country Tag,Product Code');
            expect(csv).toContain('PRU,small_arms,50.0000');
        });

        it('builds Provinces CSV matching golden structure', () => {
            const provs = [
                { id: '1', provid: '1', name: 'Sitka', owner: 'USA', country: 'USA', state: 'blank', colony: true, population: 2702.0, goodsType: 'precious_metal', rgoProduction: 0.817749 }
            ];
            const csv = buildProvincesCsv(provs);
            expect(csv).toContain('ID,Provid,Name,Owner,Country,State,Colony,Pop,Goods_type,RGO_Production,Last_income,GDP,Last_Spending,Production_Income,AGDP');
            expect(csv).toContain('1,1,Sitka,USA,USA,blank,True,2702.0,precious_metal,0.817749');
        });

        it('builds States CSV matching golden structure', () => {
            const states = [
                { rank: 1, stateName: 'blank', countryTag: 'TUR', population: 47481816.0, gdp: 6729992.3, gdpPerCapita: 0.14 }
            ];
            const csv = buildStatesCsv(states);
            expect(csv).toContain('Rank,Name,Country,Population,GDP,GDP_PerCapita,RGO_Income,PGDP,AGDP,FGDP,Employees,Revenue,Profit');
            expect(csv).toContain('1,blank,TUR,47481816.0,"$6,729,992.30",$0.14');
        });

        it('builds Factories CSV matching golden structure', () => {
            const factories = [
                { profitRank: 1, stateCode: '294', countryTag: 'ENG', buildingType: 'cement_factory', level: 10, employees: 99490.0, outputQuantity: 37.37341, unsoldQuantity: 14.9845, capitalReserves: 10000.0, revenue: 547.16, inputCost: 376.35, wagesPaid: 3.09, profit: 167.72, factoryGdp: 62346.35086205, productivity: 0.6266594719273294, averageWage: 0.000031077243944114984 }
            ];
            const csv = buildFactoriesCsv(factories);
            expect(csv).toContain('Rank,State,Tag,Country,Building,Level,Employees,Produces,Leftover,Money,Revenue,Input Costs,Pops_paychecks,Profit,GDP,Productivity,AvgWage');
            expect(csv).toContain('1,294,ENG,ENG,cement_factory,10,99490.0,37.37341,14.98450,"$10,000.00",$547.16,$376.35,$3.09,$167.72,62346.35086205,0.6266594719273294,0.0000310772439441');
        });

        it('builds Artisans CSV matching golden structure', () => {
            const artisans = [
                { id: 1, externalProvinceId: '1', provinceName: 'Sitka', countryTag: 'USA', stateCode: 'blank', artisanType: 'furniture', spending: 1.60348511, income: 2.31274414, agdp: 0.70925903, productionQuantity: 0.45346235 }
            ];
            const csv = buildArtisansCsv(artisans);
            expect(csv).toContain('ID,Provid,Name,Country,State,artisan_type,last_spending,production_income,AGDP,Production');
            expect(csv).toContain('1,1,Sitka,USA,blank,furniture,1.60348511,2.31274414,0.7092590300000000,0.4534623500000000');
        });
    });
});
