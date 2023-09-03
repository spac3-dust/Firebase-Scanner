//
//  DocumentScannerApp.swift
//  DocumentScanner
//
//  Created by Screening Eagle MB4 on 14/3/21.
//

import SwiftUI
import Firebase


@main
struct DocumentScannerApp: App {
    
    init() {
        
        FirebaseApp.configure()
        print("Configured")
    } 
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
