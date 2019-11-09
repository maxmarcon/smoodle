import i18nBuilder from "../src/i18n";

describe('i18n', () => {

    it('sets the correct locale', () => {

        expect(i18nBuilder(["de"]).locale).toEqual("de");
        expect(i18nBuilder(["de-AT"]).locale).toEqual("de");
        expect(i18nBuilder(["fr", "en-UK"]).locale).toEqual("en");
        expect(i18nBuilder(["fr", "de-AT"]).locale).toEqual("de");
        expect(i18nBuilder(["it", "en"]).locale).toEqual("it");
        expect(i18nBuilder("de").locale).toEqual("de");
        expect(i18nBuilder("de-AT").locale).toEqual("de");
        expect(i18nBuilder("fr").locale).toEqual("en");
        expect(i18nBuilder(null).locale).toEqual("en");
        expect(i18nBuilder([null, undefined]).locale).toEqual("en");

    });
});