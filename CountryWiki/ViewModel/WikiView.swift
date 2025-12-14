//
//  WikiView.swift
//  CountryWiki
//
//  Created by Volodymyr on 05.12.2025.
//

import SwiftUI

struct WikiView: View {
    @ObservedObject var viewModel: CountryListViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Завантаження...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Помилка").font(.title)
                        Text(error).foregroundColor(.red)
                        Button("Спробувати ще") { viewModel.fetchCountries() }
                            .buttonStyle(.bordered)
                    }
                } else {
                    List(viewModel.filteredCountries) { country in
                        NavigationLink(destination: CountryDetailView(country: country, viewModel: viewModel)) {
                            CountryRowView(country: country)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Wiki Countries")
            .searchable(text: $viewModel.searchText, prompt: "Пошук країни...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Сортування") {
                            Picker("Sort", selection: $viewModel.selectedSortOption) {
                                Label("А-Я", systemImage: "textformat.abc").tag(SortOption.alphabeticalAscending)
                                Label("Я-А", systemImage: "textformat.abc.dottedunderline").tag(SortOption.alphabeticalDescending)
                                Label("Населення ↑", systemImage: "person.2").tag(SortOption.populationAscending)
                                Label("Населення ↓", systemImage: "person.3.fill").tag(SortOption.populationDescending)
                            }
                        }
                        Section("Регіон") {
                            Picker("Region", selection: $viewModel.selectedRegion) {
                                ForEach(RegionFilter.allCases, id: \.self) { region in
                                    Text(region.rawValue).tag(region)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.selectedRegion == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
            }
            .onAppear {
                if viewModel.countries.isEmpty {
                    viewModel.fetchCountries()
                }
            }
        }
    }
}

struct CountryRowView: View {
    let country: Country
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: country.flags.png)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 50, height: 35)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(radius: 1)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name.common)
                    .font(.headline)
                HStack {
                    Text(country.capital?.first ?? "N/A")
                    Text("•")
                    Text(country.region)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
