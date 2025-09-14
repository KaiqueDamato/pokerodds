//
//  AdManager.swift
//  PokerOdds
//
//  Created on 14/09/2025.
//

import Foundation
import GoogleMobileAds
import SwiftUI

/// Gerenciador central de anúncios para o app
@MainActor
class AdManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Controla se os ads estão carregados e prontos
    @Published var bannerAdLoaded = false
    @Published var interstitialAdLoaded = false
    @Published var rewardedAdLoaded = false
    
    /// Controla exibição dos ads
    @Published var showBannerAd = true
    @Published var isShowingInterstitial = false
    
    // MARK: - Private Properties
    
    private var bannerAd: BannerView?
    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    
    // Controle de frequência
    private var lastInterstitialTime: Date?
    private var calculationCount = 0
    private let interstitialCooldown: TimeInterval = AdConfiguration.interstitialCooldownSeconds
    private let calculationsBeforeInterstitial = AdConfiguration.calculationsBeforeInterstitial
    
    // Ad Unit IDs configurados centralmente
    private var bannerAdUnitID: String { AdConfiguration.bannerAdUnitID }
    private var interstitialAdUnitID: String { AdConfiguration.interstitialAdUnitID }
    private var rewardedAdUnitID: String { AdConfiguration.rewardedAdUnitID }
    
    // MARK: - Singleton
    
    static let shared = AdManager()
    
    override init() {
        super.init()
        setupAds()
    }
    
    // MARK: - Setup
    
    private func setupAds() {
        // Inicializa Google AdMob com a API correta
        MobileAds.shared.start { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadAllAds()
            }
        }
    }
    
    private func loadAllAds() {
        loadBannerAd()
        loadInterstitialAd()
        loadRewardedAd()
    }
    
    // MARK: - Banner Ad
    
    func createBannerAd() -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = bannerAdUnitID
        banner.delegate = self
        self.bannerAd = banner
        return banner
    }
    
    private func loadBannerAd() {
        guard let banner = bannerAd else {
            print("❌ Banner ad não foi criado ainda")
            return
        }
        
        print("🔄 Carregando banner ad...")
        let request = Request()
        banner.load(request)
    }
    
    /// Força o carregamento do banner ad (útil para debug)
    func forceLoadBannerAd() {
        print("🔧 Forçando carregamento do banner ad...")
        if bannerAd == nil {
            _ = createBannerAd()
        }
        loadBannerAd()
    }
    
    func hideBannerDuringSimulation() {
        showBannerAd = false
    }
    
    func showBannerAfterSimulation() {
        showBannerAd = true
    }
    
    // MARK: - Interstitial Ad
    
    private func loadInterstitialAd() {
        print("🔄 Carregando interstitial ad com ID: \(interstitialAdUnitID)")
        let request = Request()
        
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erro ao carregar interstitial: \(error.localizedDescription)")
                    self?.interstitialAdLoaded = false
                    return
                }
                
                print("✅ Interstitial ad carregado com sucesso")
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.interstitialAdLoaded = true
            }
        }
    }
    
    func onCalculationCompleted() {
        calculationCount += 1
        print("📊 Cálculo completado! Total: \(calculationCount)")
        
        // Verifica se deve mostrar interstitial
        if shouldShowInterstitial() {
            print("✅ Condições atendidas, mostrando interstitial...")
            showInterstitialAd()
        } else {
            print("⏳ Interstitial não será mostrado ainda (condições não atendidas)")
        }
    }
    
    private func shouldShowInterstitial() -> Bool {
        print("🔍 Verificando condições para interstitial:")
        print("   📊 Cálculos: \(calculationCount)/\(calculationsBeforeInterstitial)")
        
        // Verifica frequência de cálculos
        guard calculationCount >= calculationsBeforeInterstitial else { 
            print("   ❌ Poucos cálculos ainda")
            return false 
        }
        
        // Verifica cooldown
        if let lastTime = lastInterstitialTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastTime)
            print("   ⏰ Cooldown: \(Int(timeSinceLastAd))s/\(Int(interstitialCooldown))s")
            guard timeSinceLastAd >= interstitialCooldown else { 
                print("   ❌ Ainda em cooldown")
                return false 
            }
        } else {
            print("   ✅ Primeiro interstitial")
        }
        
        // Verifica se o ad está carregado
        let isLoaded = interstitialAdLoaded && interstitialAd != nil
        print("   📱 Ad carregado: \(isLoaded)")
        
        return isLoaded
    }
    
    private func showInterstitialAd() {
        guard let interstitial = interstitialAd else {
            print("❌ Interstitial ad não está disponível")
            return
        }
        
        // Aguarda um pouco para garantir que outras views foram fechadas
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("❌ Root view controller não encontrado para interstitial")
                return
            }
            
            // Encontra o view controller mais adequado para apresentar o ad
            let presentingViewController = self.findBestPresentingViewController(from: rootViewController)
            
            print("✅ Apresentando interstitial ad de: \(type(of: presentingViewController))")
            interstitial.present(from: presentingViewController)
        }
        
        lastInterstitialTime = Date()
        calculationCount = 0
        
        // Recarrega o próximo ad
        loadInterstitialAd()
    }
    
    // MARK: - Rewarded Ad
    
    private func loadRewardedAd() {
        print("🔄 Carregando rewarded ad com ID: \(rewardedAdUnitID)")
        let request = Request()
        
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erro ao carregar rewarded ad: \(error.localizedDescription)")
                    self?.rewardedAdLoaded = false
                    return
                }
                
                print("✅ Rewarded ad carregado com sucesso")
                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.rewardedAdLoaded = true
            }
        }
    }
    
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        print("🎯 Tentando mostrar rewarded ad...")
        print("📊 Status: rewardedAdLoaded = \(rewardedAdLoaded)")
        
        guard let rewarded = rewardedAd else {
            print("❌ Rewarded ad não está carregado")
            completion(false)
            return
        }
        
        // Aguarda um pouco para garantir que outras views foram fechadas
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("❌ Root view controller não encontrado")
                completion(false)
                return
            }
            
            // Encontra o view controller mais adequado para apresentar o ad
            let presentingViewController = self.findBestPresentingViewController(from: rootViewController)
            
            print("✅ Apresentando rewarded ad de: \(type(of: presentingViewController))")
            rewarded.present(from: presentingViewController) {
                print("🎉 Usuário ganhou a recompensa!")
                completion(true)
            }
        }
        
        // Recarrega o próximo ad após apresentação
        loadRewardedAd()
    }
    
    /// Encontra o melhor view controller para apresentar ads
    private func findBestPresentingViewController(from viewController: UIViewController) -> UIViewController {
        // Se há um view controller apresentado, use ele
        if let presented = viewController.presentedViewController {
            return findBestPresentingViewController(from: presented)
        }
        
        // Se é um navigation controller, use o top view controller
        if let navController = viewController as? UINavigationController,
           let topViewController = navController.topViewController {
            return findBestPresentingViewController(from: topViewController)
        }
        
        // Se é um tab bar controller, use o selected view controller
        if let tabController = viewController as? UITabBarController,
           let selectedViewController = tabController.selectedViewController {
            return findBestPresentingViewController(from: selectedViewController)
        }
        
        return viewController
    }
    
    // MARK: - Utility Methods
    
    func resetAdFrequency() {
        calculationCount = 0
        lastInterstitialTime = nil
    }
    
    // MARK: - Debug Methods
    
    /// Força o carregamento de todos os ads (útil para debug)
    func forceLoadAllAds() {
        print("🔧 Forçando carregamento de todos os ads...")
        loadAllAds()
    }
    
    /// Força a exibição de um interstitial (para teste)
    func forceShowInterstitial() {
        print("🔧 Forçando exibição de interstitial...")
        if interstitialAdLoaded && interstitialAd != nil {
            showInterstitialAd()
        } else {
            print("❌ Interstitial não está carregado")
        }
    }
    
    /// Força a exibição de um rewarded ad (para teste)
    func forceShowRewardedAd(completion: @escaping (Bool) -> Void) {
        print("🔧 Forçando exibição de rewarded ad...")
        showRewardedAd(completion: completion)
    }
    
    /// Retorna status detalhado dos ads
    func getAdStatus() -> String {
        return """
        📊 Status dos Ads:
        • Banner: \(bannerAdLoaded ? "✅" : "❌") Carregado
        • Interstitial: \(interstitialAdLoaded ? "✅" : "❌") Carregado
        • Rewarded: \(rewardedAdLoaded ? "✅" : "❌") Carregado
        • Cálculos: \(calculationCount)/\(calculationsBeforeInterstitial)
        """
    }
}

// MARK: - GADBannerViewDelegate

extension AdManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        bannerAdLoaded = true
        print("Banner ad carregado com sucesso")
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        bannerAdLoaded = false
        print("Erro ao carregar banner: \(error.localizedDescription)")
    }
}

// MARK: - GADFullScreenContentDelegate

extension AdManager: FullScreenContentDelegate {
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Ad impression registrada")
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Erro ao apresentar ad: \(error.localizedDescription)")
        isShowingInterstitial = false
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingInterstitial = true
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingInterstitial = false
    }
}
