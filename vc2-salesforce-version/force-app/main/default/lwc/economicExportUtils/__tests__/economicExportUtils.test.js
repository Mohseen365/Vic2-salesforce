import {
    escapeCsvValue,
    toCsv,
    generateFilename,
    buildAnalysisCsv,
    buildCountriesCsv,
    buildProductsCsv,
    buildCountryProductsCsv,
    buildProvincesCsv
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

        it('builds Countries CSV correctly', () => {
            const countries = [
                {
                    countryTag: 'ENG',
                    countryName: 'United Kingdom',
                    gdpRank: 1,
                    gdp: 5000000.5,
                    gdpPerCapita: 120.5,
                    gdpShare: 0.3542,
                    population: 1000000,
                    workforce: 250000,
                    employment: 240000,
                    unemploymentRate: 4.0,
                    totalImports: 50000.0,
                    totalExports: 75000.0,
                    goldIncome: 1000.0
                }
            ];
            const csv = buildCountriesCsv(countries);
            expect(csv).toContain('Tag,Official Name,GDP Rank');
            expect(csv).toContain('ENG,United Kingdom,1,5000000.50,120.50,0.3542,1000000,250000,240000,4.00,50000.00,75000.00,1000.00');
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

        it('builds Provinces CSV correctly', () => {
            const provs = [
                { externalProvinceId: '101', countryTag: 'PRU', population: 45000, rgoProduction: 120.5 }
            ];
            const csv = buildProvincesCsv(provs);
            expect(csv).toContain('Province ID,Country Tag,Population');
            expect(csv).toContain('101,PRU,45000,120.5000');
        });
    });
});
