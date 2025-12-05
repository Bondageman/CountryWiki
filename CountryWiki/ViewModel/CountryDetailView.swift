//
//  CountryDetailView.swift
//  CountryWiki
//
//  Created by Volodymyr on 05.12.2025.
//

import SwiftUI

struct CountryDetailView: View {
    let country: Country
    @ObservedObject var viewModel: CountryListViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: country.flags.png)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        Color.gray.frame(height: 200)
                    }
                }
                .cornerRadius(12)
                .shadow(radius: 5)
                
                HStack {
                    Text(country.name.common)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        viewModel.toggleFavorite(country)
                    } label: {
                        Image(systemName: viewModel.isFavorite(country) ? "heart.fill" : "heart")
                            .font(.system(size: 30))
                            .foregroundColor(viewModel.isFavorite(country) ? .red : .gray)
                    }
                }
                
                Divider()
                
                VStack(spacing: 15) {
                    InfoRow(icon: "building.2", title: "Столиця", value: country.capital?.joined(separator: ", ") ?? "N/A")
                    InfoRow(icon: "person.3", title: "Населення", value: "\(country.population)")
                    InfoRow(icon: "map", title: "Регіон", value: country.region)
                    
                    if let currency = country.currencies?.values.first {
                        InfoRow(icon: "banknote", title: "Валюта", value: "\(currency.name) (\(currency.symbol ?? ""))")
                    }
                    
                    if let root = country.idd?.root, let suffix = country.idd?.suffixes?.first {
                        InfoRow(icon: "phone", title: "Код", value: "\(root)\(suffix)")
                    }
                    
                    if let langs = country.languages?.values.joined(separator: ", ") {
                        InfoRow(icon: "bubble.left.and.bubble.right", title: "Мови", value: langs)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 25)
                .foregroundColor(.blue)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

