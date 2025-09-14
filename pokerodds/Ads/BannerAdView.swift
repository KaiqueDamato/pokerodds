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
        print("🎯 Criando BannerView...")
        let banner = adManager.createBannerAd()
        
        // Configura o root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
            print("✅ Root view controller configurado")
        } else {
            print("⚠️ Root view controller não encontrado")
        }
        
        // Força o carregamento do banner
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            adManager.forceLoadBannerAd()
        }
        
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // Atualiza o root view controller se necessário
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            uiView.rootViewController = rootViewController
        }
    }
}

/// Container view que controla a exibição do banner ad
struct AdBannerContainer: View {
    @ObservedObject private var adManager = AdManager.shared
    let showAd: Bool
    
    var body: some View {
        if showAd && adManager.showBannerAd {
            VStack(spacing: 0) {
                // Separador sutil
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 0.5)
                
                // Banner ad ou placeholder
                if adManager.bannerAdLoaded {
                    BannerAdView()
                        .frame(width: 320, height: 50)
                        .background(Color(.systemBackground))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Placeholder para debug
                    VStack {
                        Text("🔄 Carregando anúncio...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Tentar novamente") {
                            adManager.forceLoadBannerAd()
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    }
                    .frame(width: 320, height: 50)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
            }
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
