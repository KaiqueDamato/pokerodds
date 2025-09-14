//
//  ContentView.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = OddsViewModel()
    @ObservedObject private var adManager = AdManager.shared
    
    // Computed property para controlar quando mostrar o banner
    private var shouldShowBanner: Bool {
        let hasResults = viewModel.simulationResult != nil
        let isSimulating = viewModel.isSimulationRunning
        
        // Atualiza a visibilidade no AdManager
        adManager.updateBannerVisibility(hasResults: hasResults, isSimulating: isSimulating)
        
        // Lógica simplificada: mostra banner quando não está simulando
        let shouldShow = !isSimulating
        
        print("🔍 ContentView Banner Debug:")
        print("   isSimulating: \(isSimulating)")
        print("   hasResults: \(hasResults)")
        print("   adManager.showBannerAd: \(adManager.showBannerAd)")
        print("   adManager.bannerAdLoaded: \(adManager.bannerAdLoaded)")
        print("   shouldShow final: \(shouldShow)")
        
        return shouldShow
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) { // Reduzido de 24 para 20
                            // Header
                            headerView
                            
                            // Player hand section
                            playerHandSection
                            
                            // Community cards section
                            communityCardsSection
                            
                            // Action buttons
                            actionButtonsSection
                            
                            // Results section
                            if let result = viewModel.simulationResult, viewModel.simulationState == .completed {
                                GeometryReader { geometry in
                                    ResultCardView(result: result)
                                        .onAppear {
                                            print("🎯 ResultCardView apareceu!")
                                            print("🎯 Posição Y: \(geometry.frame(in: .global).minY)")
                                            print("🎯 Altura da tela: \(UIScreen.main.bounds.height)")
                                            
                                            // Se o resultado está fora da tela, força scroll
                                            let screenHeight = UIScreen.main.bounds.height
                                            let resultY = geometry.frame(in: .global).minY
                                            
                                            if resultY > screenHeight * 0.8 {
                                                print("🎯 Resultado fora da tela, forçando scroll...")
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    withAnimation(.easeInOut(duration: 1.0)) {
                                                        proxy.scrollTo("simulationResult", anchor: .center)
                                                    }
                                                }
                                            }
                                        }
                                }
                                .frame(height: 300) // Altura estimada do ResultCardView
                                .id("simulationResult") // ID para scroll automático
                                .transition(.scale.combined(with: .opacity))
                                .debugScroll(id: "simulationResult")
                            } else if viewModel.validPlayerCards.isEmpty && viewModel.validCommunityCards.isEmpty {
                                EmptyStateView()
                                    .transition(.opacity)
                            }
                            
                            // Error state
                            if let error = viewModel.errorMessage {
                                ErrorStateView(message: error) {
                                    viewModel.errorMessage = nil
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Spacer para garantir que o conteúdo não fique colado no banner
                            Spacer(minLength: 100) // Aumentado para dar mais espaço
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .background(Color(.systemGroupedBackground))
                    .onChange(of: viewModel.shouldScrollToResult) { shouldScroll in
                        if shouldScroll {
                            print("🎯 Trigger de scroll ativado: \(shouldScroll)")
                            print("🎯 Estado da simulação: \(viewModel.simulationState)")
                            print("🎯 Resultado existe: \(viewModel.simulationResult != nil)")
                            
                            // Múltiplas tentativas de scroll para garantir que funcione
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                print("🎯 Tentativa 1 de scroll...")
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    proxy.scrollTo("simulationResult", anchor: .center)
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("🎯 Tentativa 2 de scroll...")
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    proxy.scrollTo("simulationResult", anchor: .center)
                                }
                            }
                            
                            // Reset do trigger após usar
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                viewModel.shouldScrollToResult = false
                            }
                        }
                    }
                }
                
                // Banner ad fixo na parte inferior, respeitando safe area
                AdBannerContainer(showAd: shouldShowBanner)
                    .background(Color(.systemBackground))
            }
            .navigationTitle(NSLocalizedString("Poker Odds", comment: "App title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                    .accessibilityLabel(NSLocalizedString("Settings", comment: "Settings button"))
                }
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.showingCardPicker) {
                if let position = viewModel.currentEditingPosition {
                    CardPickerView(
                        selectedCards: viewModel.allSelectedCards,
                        position: position,
                        onCardSelected: { card in
                            viewModel.selectCard(card, for: position)
                        },
                        onCancel: {
                            viewModel.showingCardPicker = false
                        }
                    )
                    .presentationDetents([.large])
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text(NSLocalizedString("Texas Hold'em Calculator", comment: "Subtitle"))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Help button
                Button(action: {}) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel(NSLocalizedString("Help", comment: "Help button"))
            }
            
            Text(NSLocalizedString("Calculate your winning odds against one opponent", comment: "Description"))
                .font(.footnote)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Player Hand Section
    
    private var playerHandSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(NSLocalizedString("Your Hand", comment: "Player hand section title"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !viewModel.validPlayerCards.isEmpty {
                    Button(NSLocalizedString("Clear", comment: "Clear button")) {
                        withAnimation(.easeInOut(duration: viewModel.shouldReduceMotion ? 0 : 0.2)) {
                            viewModel.playerCards = [nil, nil]
                            viewModel.simulationResult = nil
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                }
            }
            
            HStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { index in
                    CardSlotView(
                        card: viewModel.playerCards[index],
                        position: .playerCard(index),
                        onTap: {
                            viewModel.openCardPicker(for: .playerCard(index))
                        },
                        onRemove: {
                            withAnimation(.easeInOut(duration: viewModel.shouldReduceMotion ? 0 : 0.2)) {
                                viewModel.removeCard(at: .playerCard(index))
                            }
                        }
                    )
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Community Cards Section
    
    private var communityCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(NSLocalizedString("Board", comment: "Community cards section title"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !viewModel.validCommunityCards.isEmpty {
                    Button(NSLocalizedString("Clear", comment: "Clear button")) {
                        withAnimation(.easeInOut(duration: viewModel.shouldReduceMotion ? 0 : 0.2)) {
                            viewModel.communityCards = [nil, nil, nil, nil, nil]
                            viewModel.simulationResult = nil
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                }
            }
            
            // Community cards grid
            VStack(spacing: 8) {
                // Flop (3 cards)
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        CardSlotView(
                            card: viewModel.communityCards[index],
                            position: .communityCard(index),
                            onTap: {
                                viewModel.openCardPicker(for: .communityCard(index))
                            },
                            onRemove: {
                                withAnimation(.easeInOut(duration: viewModel.shouldReduceMotion ? 0 : 0.2)) {
                                    viewModel.removeCard(at: .communityCard(index))
                                }
                            }
                        )
                    }
                    
                    Spacer()
                }
                
                // Turn and River
                HStack(spacing: 12) {
                    ForEach(3..<5, id: \.self) { index in
                        CardSlotView(
                            card: viewModel.communityCards[index],
                            position: .communityCard(index),
                            onTap: {
                                viewModel.openCardPicker(for: .communityCard(index))
                            },
                            onRemove: {
                                withAnimation(.easeInOut(duration: viewModel.shouldReduceMotion ? 0 : 0.2)) {
                                    viewModel.removeCard(at: .communityCard(index))
                                }
                            }
                        )
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Main calculate button
            Button(action: {
                if viewModel.simulationState == .running {
                    viewModel.cancelSimulation()
                } else {
                    withAnimation(.easeInOut(duration: viewModel.shouldReduceMotion ? 0 : 0.2)) {
                        viewModel.runSimulation()
                    }
                }
            }) {
                HStack(spacing: 12) {
                    if viewModel.simulationState == .running {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        
                        Text(NSLocalizedString("Cancel", comment: "Cancel button"))
                    } else {
                        Image(systemName: "play.circle.fill")
                        Text(NSLocalizedString("Calculate Odds", comment: "Calculate button"))
                    }
                }
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.canRunSimulation ? Color.accentColor : Color.secondary
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.canRunSimulation && !viewModel.isSimulationRunning)
            .accessibilityLabel(
                viewModel.simulationState == .running ?
                NSLocalizedString("Cancel simulation", comment: "Cancel button accessibility") :
                NSLocalizedString("Calculate poker odds", comment: "Calculate button accessibility")
            )
            
            // Indicador de resultado disponível
            if viewModel.simulationResult != nil && viewModel.simulationState == .completed {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                        .scaleEffect(1.1)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: viewModel.simulationResult != nil)
                    
                    Text("Resultado disponível abaixo")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.accentColor)
                        .font(.caption)
                        .opacity(0.7)
                        .offset(y: 2)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.simulationResult != nil)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Progress bar
            if viewModel.simulationState == .running {
                VStack(spacing: 4) {
                    ProgressView(value: viewModel.simulationProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    
                    HStack {
                        Text(NSLocalizedString("Simulating...", comment: "Progress text"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.simulationProgress * 100))%")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                .transition(.opacity)
            }
            
            // Clear all button
            if viewModel.simulationResult != nil || !viewModel.allSelectedCards.isEmpty {
                Button(NSLocalizedString("Clear All", comment: "Clear all button")) {
                    withAnimation(.easeInOut(duration: viewModel.shouldReduceMotion ? 0 : 0.2)) {
                        viewModel.clearAllCards()
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        ContentView()
            .preferredColorScheme(.dark)
    }
}
