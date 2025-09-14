//
//  PokerOddsApp.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI
import GoogleMobileAds // Package is configured but needs Xcode interface fix

@main
struct PokerOddsApp: App {
    
    init() {
        // Initialize Google AdMob
        MobileAds.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Support system appearance
        }
    }
}
