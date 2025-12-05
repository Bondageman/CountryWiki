import Foundation

struct Country: Codable, Identifiable, Hashable {
    var id: String { name.common }
    let name: Name
    let flags: Flags
    let capital: [String]?
    let region: String
    let population: Int
    
    let currencies: [String: Currency]?
    let languages: [String: String]?
    let idd: IDD?
}


struct Name: Codable, Hashable {
    let common: String
    let official: String
}

struct Flags: Codable, Hashable {
    let png: String
    let svg: String
}

struct Currency: Codable, Hashable {
    let name: String
    let symbol: String?
}

struct IDD: Codable, Hashable {
    let root: String?
    let suffixes: [String]?
}
