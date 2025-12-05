import SwiftUI

struct MainAppView: View {
    @StateObject private var viewModel = CountryListViewModel()
    
    var body: some View {
        TabView {
            WikiView(viewModel: viewModel)
                .tabItem {
                    Label("Wiki", systemImage: "globe.europe.africa")
                }
            
            FavoritesView(viewModel: viewModel)
                .tabItem {
                    Label("Selected", systemImage: "heart.fill")
                }
                .badge(viewModel.savedCountryIDs.count)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainAppView()
}
