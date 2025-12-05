//
//  FavoritesView.swift
//  CountryWiki
//
//  Created by Volodymyr on 05.12.2025.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: CountryListViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favoriteCountries.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("List is empty")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(viewModel.favoriteCountries) { country in
                            NavigationLink(destination: CountryDetailView(country: country, viewModel: viewModel)) {
                                CountryRowView(country: country)
                            }
                        }
                        .onDelete(perform: viewModel.deleteFromFavorites)
                    }
                }
            }
            .navigationTitle("Selected")
        }
    }
}
