//
//  CountryListViewModel.swift
//  CountryWiki
//
//  Created by Volodymyr on 05.12.2025.
//

import SwiftUI
import Combine

enum SortOption {
    case alphabeticalAscending
    case alphabeticalDescending
    case populationAscending
    case populationDescending
}

enum RegionFilter: String, CaseIterable {
    case all = "Всі"
    case africa = "Africa"
    case americas = "Americas"
    case asia = "Asia"
    case europe = "Europe"
    case oceania = "Oceania"
    case antarctic = "Antarctic"
}

@MainActor
class CountryListViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var savedCountryIDs: Set<String> = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedSortOption: SortOption = .alphabeticalAscending
    @Published var selectedRegion: RegionFilter = .all
    
    private let saveKey = "SavedCountries"

    init() {
        loadFavorites()
    }
    
    var filteredCountries: [Country] {
        var result = countries
        
        if selectedRegion != .all {
            result = result.filter { $0.region == selectedRegion.rawValue }
        }
        
        if !searchText.isEmpty {
            result = result.filter { country in
                country.name.common.localizedCaseInsensitiveContains(searchText) ||
                (country.capital?.first?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch selectedSortOption {
        case .alphabeticalAscending:
            result.sort { $0.name.common < $1.name.common }
        case .alphabeticalDescending:
            result.sort { $0.name.common > $1.name.common }
        case .populationAscending:
            result.sort { $0.population < $1.population }
        case .populationDescending:
            result.sort { $0.population > $1.population }
        }
        
        return result
    }
    
    var favoriteCountries: [Country] {
        countries.filter { savedCountryIDs.contains($0.id) }
    }
    
    func fetchCountries() {
        let urlString = "https://restcountries.com/v3.1/all?fields=name,capital,flags,region,population,currencies,languages,idd"
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedCountries = try JSONDecoder().decode([Country].self, from: data)
                self.countries = decodedCountries
                self.isLoading = false
            } catch {
                self.errorMessage = "Помилка: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    
    func toggleFavorite(_ country: Country) {
        if savedCountryIDs.contains(country.id) {
            savedCountryIDs.remove(country.id)
        } else {
            savedCountryIDs.insert(country.id)
        }
        saveFavorites()
    }
    
    func isFavorite(_ country: Country) -> Bool {
        savedCountryIDs.contains(country.id)
    }
    
    func deleteFromFavorites(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { favoriteCountries[$0] }
        itemsToDelete.forEach { country in
            savedCountryIDs.remove(country.id)
        }
        saveFavorites()
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(savedCountryIDs) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            savedCountryIDs = decoded
        }
    }
}
