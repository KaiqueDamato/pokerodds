//
//  BannerAdView.swift
//  PokerOdds
//
//  Created on 14/09/2025.
//

import SwiftUI
import GoogleMobileAds

/// View wrapper para banner ads do Google AdMob
struct BannerAdView: UIViewRepresentable {
    @ObservedObject var adManager = AdManager.shared
    
    func makeUIView(context: Context) -> BannerView {
        print("🎯 makeUIView chamado - obtendo BannerView...")
        
        // SEMPRE cria novo banner para evitar corrupção de dimensões
        print("🆕 Criando novo banner (evitando reutilização)")
        if let existingBanner = adManager.bannerAd {
            print("   Banner existente será substituído - size: \(existingBanner.adSize.size)")
            print("   Banner loaded: \(adManager.bannerAdLoaded)")
        }
        let banner = adManager.createBannerAd()
        // Registra o banner criado, evitando que outra criação paralela aconteça
        adManager.registerExternalBanner(banner)
        
        // Garante que o root view controller está configurado
        configureRootViewController(for: banner)
        
        // Nada a carregar aqui: AdManager já chama load automaticamente ao registrar/criar
        
        return banner
    }
    
    private func configureRootViewController(for banner: BannerView) {
        if banner.rootViewController == nil {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                banner.rootViewController = rootViewController
                print("✅ Root view controller configurado no makeUIView: \(type(of: rootViewController))")
            } else {
                print("⚠️ Root view controller não encontrado - tentando novamente...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.configureRootViewController(for: banner)
                }
            }
        } else {
            print("✅ Root view controller já configurado")
        }
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // Atualiza o root view controller se necessário
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            uiView.rootViewController = rootViewController
        }
    }
}

/// Container view que controla a exibição do banner ad seguindo Apple Design Guidelines
struct AdBannerContainer: View {
    @ObservedObject private var adManager = AdManager.shared
    let showAd: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Separador sutil seguindo design system da Apple
            Divider()
                .background(Color(.separator))
            
            // Banner ad ou placeholder - SEMPRE MOSTRA ALGO PARA DEBUG
            // Mostra SEMPRE o container do banner
            BannerAdView()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemBackground))
        }
        .onAppear {
            print("🎯 AdBannerContainer body executado!")
            print("   showAd: \(showAd)")
            print("   bannerAdLoaded: \(adManager.bannerAdLoaded)")
            print("   showBannerAd: \(adManager.showBannerAd)")
        }
    }
}

// MARK: - Preview

struct BannerAdView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            Text("Conteúdo do app")
                .font(.title)
            
            Spacer()
            
            AdBannerContainer(showAd: true)
        }
        .background(Color(.systemGroupedBackground))
    }
}
