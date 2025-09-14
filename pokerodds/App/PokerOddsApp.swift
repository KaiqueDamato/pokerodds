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
        // TODO: Initialize Google AdMob when import is fixed
        // GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Support system appearance
        }
    }
}
