//
//  SettingsSheet.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var viewModel: OddsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                // Simulation settings section
                simulationSettingsSection
                
                // Premium features section
                premiumFeaturesSection
                
                // Quick actions section
                quickActionsSection
                
                // Debug section (only in DEBUG builds)
                #if DEBUG
                debugSection
                #endif
                
                // Information section
                informationSection
            }
            .navigationTitle(NSLocalizedString("Settings", comment: "Settings title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Done", comment: "Done button")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .alert(
            NSLocalizedString("Reset All Data", comment: "Reset confirmation title"),
            isPresented: $showingResetConfirmation
        ) {
            Button(NSLocalizedString("Cancel", comment: "Cancel button"), role: .cancel) { }
            Button(NSLocalizedString("Reset", comment: "Reset button"), role: .destructive) {
                withAnimation {
                    viewModel.clearAllCards()
                }
            }
        } message: {
            Text(NSLocalizedString("This will clear all selected cards and results. This action cannot be undone.", comment: "Reset confirmation message"))
        }
    }
    
    // MARK: - Simulation Settings Section
    
    private var simulationSettingsSection: some View {
        Section {
            // Fast Mode Toggle
            Toggle(isOn: $viewModel.fastMode) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("Fast Mode", comment: "Fast mode setting"))
                        .font(.body)
                    
                    Text(NSLocalizedString("8,000 iterations for quicker results", comment: "Fast mode description"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.accentColor)
            
            // Iterations count
            if !viewModel.fastMode {
                iterationsSlider
            }
            
            // Estimated time
            HStack {
                Text(NSLocalizedString("Estimated Time", comment: "Estimated time label"))
                
                Spacer()
                
                Text(viewModel.estimatedDuration)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            
        } header: {
            Text(NSLocalizedString("Simulation", comment: "Simulation section header"))
        } footer: {
            Text(NSLocalizedString("Monte Carlo simulation randomly deals opponent cards and completes the board to calculate winning probabilities.", comment: "Simulation section footer"))
        }
    }
    
    // MARK: - Iterations Slider
    
    private var iterationsSlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(NSLocalizedString("Iterations", comment: "Iterations label"))
                
                Spacer()
                
                Text(NumberFormatter.localizedString(from: NSNumber(value: viewModel.iterationsCount), number: .decimal))
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
            }
            
            Slider(
                value: Binding(
                    get: { Double(viewModel.iterationsCount) },
                    set: { viewModel.updateIterations(Int($0)) }
                ),
                in: 5000...100000,
                step: 1000
            ) {
                Text(NSLocalizedString("Iterations", comment: "Slider label"))
            } minimumValueLabel: {
                Text("5K")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } maximumValueLabel: {
                Text("100K")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .tint(.accentColor)
            
            HStack {
                Text(NSLocalizedString("Fewer", comment: "Fewer iterations"))
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
                
                Spacer()
                
                Text(NSLocalizedString("More Accurate", comment: "More accurate"))
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
    }
    
    // MARK: - Premium Features Section
    
    private var premiumFeaturesSection: some View {
        Section {
            // High precision simulation
            RewardedAdButton(
                title: NSLocalizedString("High Precision Mode", comment: "Premium feature title"),
                subtitle: NSLocalizedString("Unlock 200,000 iterations for maximum accuracy", comment: "Premium feature description"),
                icon: "speedometer"
            ) {
                // Unlock high precision temporarily
                viewModel.updateIterations(200000)
                
                // Show success message
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            
            // Detailed analysis (future feature)
            RewardedAdButton(
                title: NSLocalizedString("Street Analysis", comment: "Premium feature title"),
                subtitle: NSLocalizedString("Coming soon: Odds breakdown by street", comment: "Premium feature description"),
                icon: "chart.bar.fill"
            ) {
                // Future feature - detailed street-by-street analysis
                print("Street analysis feature unlocked (coming soon)")
            }
            
        } header: {
            Text(NSLocalizedString("Premium Features", comment: "Premium section header"))
        } footer: {
            Text(NSLocalizedString("Watch short ads to unlock premium features temporarily. No subscription required!", comment: "Premium section footer"))
        }
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        Section {
            // Reset all button
            Button(action: {
                showingResetConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    
                    Text(NSLocalizedString("Reset All Cards", comment: "Reset all button"))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
            }
            .disabled(viewModel.allSelectedCards.isEmpty && viewModel.simulationResult == nil)
            
        } header: {
            Text(NSLocalizedString("Quick Actions", comment: "Quick actions section header"))
        }
    }
    
    // MARK: - Information Section
    
    private var informationSection: some View {
        Section {
            // App version
            HStack {
                Text(NSLocalizedString("Version", comment: "Version label"))
                
                Spacer()
                
                Text("1.0")
                    .foregroundColor(.secondary)
            }
            
            // Game variant info
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("Game Variant", comment: "Game variant label"))
                
                Text(NSLocalizedString("Texas Hold'em (Heads-up)", comment: "Game variant description"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            // Simulation method info
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("Method", comment: "Method label"))
                
                Text(NSLocalizedString("Monte Carlo Simulation", comment: "Method description"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
        } header: {
            Text(NSLocalizedString("Information", comment: "Information section header"))
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("This calculator simulates thousands of random scenarios to estimate your winning probability against one unknown opponent in Texas Hold'em poker.", comment: "App description footer"))
                
                Text(NSLocalizedString("Results are statistical estimates and may vary between simulations.", comment: "Disclaimer footer"))
                    .font(.footnote)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
    }
    
    // MARK: - Debug Section (DEBUG only)
    
    #if DEBUG
    private var debugSection: some View {
        Section {
            // Ad Status
            VStack(alignment: .leading, spacing: 8) {
                Text("📊 Status dos Ads")
                    .font(.headline)
                
                Text(AdManager.shared.getAdStatus())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            
            // Force load ads
            Button("🔄 Recarregar Todos os Ads") {
                AdManager.shared.forceLoadAllAds()
            }
            
            // Test interstitial
            Button("🎯 Testar Interstitial") {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AdManager.shared.forceShowInterstitial()
                }
            }
            
            // Test rewarded
            Button("🎁 Testar Rewarded") {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AdManager.shared.forceShowRewardedAd { success in
                        print("Rewarded ad result: \(success)")
                    }
                }
            }
            
            // Reset ad frequency
            Button("🔄 Reset Frequência") {
                AdManager.shared.resetAdFrequency()
            }
            
        } header: {
            Text("🐛 Debug - Ads")
        } footer: {
            Text("Seção disponível apenas em builds de DEBUG para testar funcionalidades de anúncios.")
        }
    }
    #endif
}

// MARK: - Preview

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheet(viewModel: OddsViewModel())
        
        SettingsSheet(viewModel: OddsViewModel())
            .preferredColorScheme(.dark)
    }
}
