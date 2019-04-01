//
//  Country.swift
//  CountryFacts
//
//  Created by Rob Baldwin on 01/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import Foundation

struct Country: Codable {
    var name: String
    var topLevelDomain: [String]
    var alpha2Code: String
    var alpha3Code: String
    var callingCodes: [String]
    var capital: String
    var altSpellings: [String]
    var region: String
    var subregion: String
    var population: Int
    var latlng: [Double]
    var demonym: String
    var area: Double?
    var gini: Double?
    var timezones: [String]
    var borders: [String]
    var nativeName: String
    var numericCode: String?
    var currencies: [Currency]
    var languages: [Language]
    var translations: Translation
    var flag: String
    var regionalBlocs: [RegionalBloc]
    var cioc: String?
}

struct Currency: Codable {
    var code: String?
    var name: String?
    var symbol: String?
}

struct Language: Codable {
    var iso639_1: String?
    var iso639_2: String
    var name: String
    var nativeName: String
}

struct Translation: Codable {
    var de: String?
    var es: String?
    var fr: String?
    var ja: String?
    var it: String?
    var br: String?
    var pt: String?
    var nl: String?
    var hr: String?
    var fa: String?
}

struct RegionalBloc: Codable {
    var acronym: String
    var name: String
    var otherAcronyms: [String]
    var otherNames: [String]
}
