//
//  AdConfiguration.swift
//  PokerOdds
//
//  Created on 14/09/2025.
//

import Foundation

/// Configurações centralizadas para anúncios
struct AdConfiguration {
    
    // MARK: - Test Ad Unit IDs (Google AdMob Test IDs)
    // Substitua pelos seus IDs reais quando publicar o app
    
    // IDs de teste oficiais do Google AdMob (funcionam no simulador)
    static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    static let testInterstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    static let testRewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    // MARK: - Production Ad Unit IDs
    // Configure com seus IDs reais para produção
    
    static let productionBannerAdUnitID = "ca-app-pub-8913194362956705/3008362472"
    static let productionInterstitialAdUnitID = "ca-app-pub-8913194362956705/2972208610" // Configure seu ID
    static let productionRewardedAdUnitID = "ca-app-pub-8913194362956705/9346045279" // Configure seu ID
    
    // MARK: - Current Configuration
    
    static var isTestMode: Bool {
        #if DEBUG
        return true
        #else
        return false // Mude para false quando tiver todos os IDs de produção
        #endif
    }
    
    static var bannerAdUnitID: String {
        return isTestMode ? testBannerAdUnitID : productionBannerAdUnitID
    }
    
    static var interstitialAdUnitID: String {
        return isTestMode ? testInterstitialAdUnitID : productionInterstitialAdUnitID
    }
    
    static var rewardedAdUnitID: String {
        return isTestMode ? testRewardedAdUnitID : productionRewardedAdUnitID
    }
    
    // MARK: - Ad Behavior Settings
    
    /// Número de cálculos antes de mostrar interstitial
    static let calculationsBeforeInterstitial = 3
    
    /// Tempo mínimo entre interstitials (em segundos)
    static let interstitialCooldownSeconds: TimeInterval = 300 // 5 minutos
    
    /// Duração máxima para premium features desbloqueadas (em segundos)
    static let premiumFeatureDuration: TimeInterval = 1800 // 30 minutos
    
    /// Máximo de iterações para modo premium
    static let maxPremiumIterations = 200000
}
