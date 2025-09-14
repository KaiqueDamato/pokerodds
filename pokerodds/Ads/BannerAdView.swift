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
        
        // Usa o banner já criado ou cria um novo
        let banner = adManager.bannerAd ?? adManager.createBannerAd()
        
        // Garante que o root view controller está configurado
        configureRootViewController(for: banner)
        
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
            if showAd {
                if adManager.bannerAdLoaded {
                    BannerAdView()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .frame(height: 50)
                        .background(Color(.systemBackground))
                        .clipped()
                } else {
                    // Placeholder para debug - SEMPRE VISÍVEL
                    VStack(spacing: 4) {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            
                            Text("Carregando anúncio...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Recarregar") {
                                print("🔧 Botão Recarregar pressionado")
                                adManager.forceLoadBannerAd()
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        }
                        
                        // Info de debug
                        Text("ID: \(AdConfiguration.bannerAdUnitID)")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                }
            } else {
                // Debug: mostra por que não está aparecendo
                HStack {
                    Text("🚫 Banner oculto (showAd: \(showAd))")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Debug") {
                        print("🔧 AdManager Debug:")
                        print("   showBannerAd: \(adManager.showBannerAd)")
                        print("   bannerAdLoaded: \(adManager.bannerAdLoaded)")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .frame(height: 50)
                .background(Color(.systemGray6))
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
