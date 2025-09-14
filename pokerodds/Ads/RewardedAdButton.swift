//
//  RewardedAdButton.swift
//  PokerOdds
//
//  Created on 14/09/2025.
//

import SwiftUI

/// Botão para assistir ads recompensados e desbloquear features premium
struct RewardedAdButton: View {
    @ObservedObject private var adManager = AdManager.shared
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            showRewardedAd()
        }) {
            HStack(spacing: 12) {
                // Ícone
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                // Textos
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Loading ou ícone de play
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!adManager.rewardedAdLoaded || isLoading)
        .opacity(adManager.rewardedAdLoaded && !isLoading ? 1.0 : 0.6)
    }
    
    private func showRewardedAd() {
        isLoading = true
        
        // Fecha a tela de configurações primeiro
        dismiss()
        
        // Aguarda um pouco para a tela fechar completamente
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            adManager.showRewardedAd { success in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if success {
                        // Usuário assistiu o ad completo
                        action()
                        
                        // Feedback háptico
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct RewardedAdButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RewardedAdButton(
                title: NSLocalizedString("Unlock High Precision", comment: "Rewarded ad title"),
                subtitle: NSLocalizedString("Watch ad for 200K iterations", comment: "Rewarded ad subtitle"),
                icon: "speedometer"
            ) {
                print("Premium feature unlocked!")
            }
            
            RewardedAdButton(
                title: NSLocalizedString("Detailed Analysis", comment: "Rewarded ad title"),
                subtitle: NSLocalizedString("Watch ad for street-by-street odds", comment: "Rewarded ad subtitle"),
                icon: "chart.bar.fill"
            ) {
                print("Detailed analysis unlocked!")
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
