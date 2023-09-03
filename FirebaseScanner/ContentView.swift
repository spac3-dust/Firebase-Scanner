//
//  ContentView.swift
//  DocumentScanner
//
//  Created by Screening Eagle MB4 on 14/3/21.
//

import SwiftUI
import FirebaseStorage


struct ContentView: View {
    
    @State private var scannedImages = [UIImage]()
    
    @State private var isPresentedScanner = false
    
    private var isEmptyContent: Bool { scannedImages.isEmpty }
    
    
    var body: some View {
        NavigationView {
            VStack {
                contentView
                    .navigationTitle("Doc Scanner")
                
                Button {
                    Task {
                        do {
                            try await uploadDocument()
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("Upload")
                        .foregroundColor(.blue)
                }
                
            }
        }.fullScreenCover(isPresented: $isPresentedScanner) {
            scannerView
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if isEmptyContent {
            scanButton
                .font(.largeTitle)
        } else {
            ScrollView {
                GeometryReader { geometry in
                    let width = geometry.size.width * 0.5 - 24
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(scannedImages, id: \.self) { image in
                            NavigationLink(destination: ImagePreviewView(image: image)) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: width)
                                    .clipped()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    
    
    func uploadDocument() async throws {
        
        let storageRef = Storage.storage().reference()
        
        guard scannedImages.count != 0 else {
            throw URLError(.badURL)
        }
        
        for image in scannedImages { image
            // Convert UIImage to Data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to data")
                return
            }
            
            let fileRef = storageRef.child("images/\(UUID().uuidString).jpg")
            
            try await fileRef.putDataAsync(imageData)
                
        }
    }
    
    
    private var scanButton: some View {
        Button {
            if isPresentedScanner { return }
            isPresentedScanner = true
        } label: {
            Label(isEmptyContent ? "Scan Now" : "Scan", systemImage: "doc.text.viewfinder")
        }
    }
    
    private var scannerView: some View {
        ScannerView { result in
            switch result {
            case .success(let images):
                scannedImages.append(contentsOf: images)
            case .failure(let error):
                print(error.localizedDescription)
            }
            isPresentedScanner = false
        } didCancel: {
            isPresentedScanner = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
