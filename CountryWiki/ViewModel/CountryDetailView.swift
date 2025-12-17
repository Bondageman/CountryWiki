import SwiftUI
import AVKit
import Photos

struct CountryDetailView: View {
    let country: Country
    @ObservedObject var viewModel: CountryListViewModel
    
    @State private var isVideoPresented = false
    @State private var localVideoUrl: URL?
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showSettingsAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImage(url: URL(string: country.flags.png)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
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
                        
                        Button { checkPermissionAndSave() } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        }.padding(.trailing, 8)
                        
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
                        InfoRow(icon: "building.2", title: "Capital", value: country.capital?.joined(separator: ", ") ?? "N/A")
                        InfoRow(icon: "person.3", title: "Population", value: country.population.formatted(.number.notation(.compactName)))
                        InfoRow(icon: "map", title: "Region", value: country.region)
                        if let currency = country.currencies?.values.first {
                            InfoRow(icon: "banknote", title: "Currency", value: "\(currency.name) (\(currency.symbol ?? ""))")
                        }
                    }
                }
                .padding()
            }
            
            if let videoUrl = localVideoUrl {
                Button {
                    isVideoPresented = true
                } label: {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                            .font(.title2)
                        Text("Watch video about")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .shadow(radius: 5)
                .fullScreenCover(isPresented: $isVideoPresented) {
                    VideoPlayerView(url: videoUrl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            findLocalVideo()
        }
        
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: { Text(alertMessage) }
        .alert("Photo Library Access Denied", isPresented: $showSettingsAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            Button("Cancel", role: .cancel) { }
        } message: { Text("Grant permission in the settings.") }
    }
    
    func findLocalVideo() {
        let fileName = country.name.common
        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") {
            print("Videos found for \(fileName)")
            self.localVideoUrl = url
        } else {
            print("Video for \(fileName) Not found in Bundle")
            self.localVideoUrl = nil
        }
    }
    
    func checkPermissionAndSave() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                if status == .authorized || status == .limited { saveFlagToGallery() }
            }
        case .restricted, .denied: showSettingsAlert = true
        case .authorized, .limited: saveFlagToGallery()
        @unknown default: break
        }
    }
    
    func saveFlagToGallery() {
        guard let url = URL(string: country.flags.png) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let uiImage = UIImage(data: data) else { return }
                let imageSaver = ImageSaver()
                imageSaver.onSuccess = {
                    DispatchQueue.main.async {
                        alertTitle = "Success!"
                        alertMessage = "Flag saved."
                        showingAlert = true
                    }
                }
                imageSaver.onError = { error in
                    DispatchQueue.main.async {
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
                imageSaver.writeToPhotoAlbum(image: uiImage)
            } catch { }
        }
    }
}

struct InfoRow: View {
    let icon: String; let title: String; let value: String
    var body: some View {
        HStack {
            Image(systemName: icon).frame(width: 25).foregroundColor(.blue)
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium).multilineTextAlignment(.trailing)
        }
    }
}
