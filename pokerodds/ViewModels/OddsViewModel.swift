//
//  OddsViewModel.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import Foundation
import SwiftUI

/// Estado atual da simulação
enum SimulationState: Equatable {
    case idle
    case running
    case completed
    case cancelled
    case error(String)
    
    static func == (lhs: SimulationState, rhs: SimulationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.running, .running),
             (.completed, .completed),
             (.cancelled, .cancelled):
            return true
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

/// ViewModel principal para gerenciar estado da calculadora de odds
@MainActor
class OddsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Cartas da mão do jogador (exatamente 2)
    @Published var playerCards: [Card?] = [nil, nil]
    
    /// Cartas comunitárias (0 a 5)
    @Published var communityCards: [Card?] = [nil, nil, nil, nil, nil]
    
    /// Estado atual da simulação
    @Published var simulationState: SimulationState = .idle
    
    /// Resultado atual da simulação
    @Published var simulationResult: SimulationResult?
    
    /// Trigger para scroll automático ao resultado
    @Published var shouldScrollToResult = false
    
    /// Progresso da simulação (0.0 a 1.0)
    @Published var simulationProgress: Double = 0.0
    
    /// Número de iterações da simulação
    @Published var iterationsCount: Int = 20000
    
    /// Modo rápido (8k iterações)
    @Published var fastMode: Bool = false {
        didSet {
            iterationsCount = fastMode ? 8000 : 20000
        }
    }
    
    /// Mensagem de erro atual
    @Published var errorMessage: String?
    
    /// Controla exibição das configurações
    @Published var showingSettings: Bool = false
    
    /// Controla exibição do seletor de cartas
    @Published var showingCardPicker: Bool = false
    
    // MARK: - Premium Features
    
    /// Indica se o modo de alta precisão está ativo
    @Published var isHighPrecisionModeActive: Bool = false
    
    /// Timestamp quando o modo premium expira
    private var premiumModeExpiryTime: Date?
    
    /// Timer para atualização do tempo restante
    private var premiumTimer: Timer?
    
    /// Força atualização do tempo restante na UI
    @Published private var timeUpdateTrigger = false
    
    /// Posição atual sendo editada no picker
    @Published var currentEditingPosition: CardPosition?
    
    // MARK: - Private Properties
    
    /// Baralho para controlar cartas disponíveis
    private var deck = Deck()
    
    /// Token de cancelamento da simulação
    private var cancellationToken: CancellationToken?
    
    // MARK: - Computed Properties
    
    /// Cartas não-nulas da mão do jogador
    var validPlayerCards: [Card] {
        return playerCards.compactMap { $0 }
    }
    
    /// Cartas não-nulas comunitárias
    var validCommunityCards: [Card] {
        return communityCards.compactMap { $0 }
    }
    
    /// Todas as cartas selecionadas (para controle de duplicatas)
    var allSelectedCards: [Card] {
        return validPlayerCards + validCommunityCards
    }
    
    /// Verifica se a mão do jogador está completa
    var playerHandIsComplete: Bool {
        return validPlayerCards.count == 2
    }
    
    /// Verifica se pode executar simulação
    var canRunSimulation: Bool {
        return playerHandIsComplete &&
               !isSimulationRunning &&
               !hasCardDuplicates
    }
    
    /// Verifica se simulação está em execução
    var isSimulationRunning: Bool {
        if case .running = simulationState {
            return true
        }
        return false
    }
    
    /// Verifica se há cartas duplicadas
    var hasCardDuplicates: Bool {
        let selected = allSelectedCards
        return Set(selected).count != selected.count
    }
    
    /// Cartas disponíveis no baralho (não selecionadas)
    var availableCards: [Card] {
        let usedCards = Set(allSelectedCards)
        return deck.allCards.filter { !usedCards.contains($0) }
    }
    
    // MARK: - Card Position Enum
    
    enum CardPosition {
        case playerCard(Int)
        case communityCard(Int)
        
        var description: String {
            switch self {
            case .playerCard(let index):
                return NSLocalizedString("Player Card \(index + 1)", comment: "Card position")
            case .communityCard(let index):
                let positions = [
                    NSLocalizedString("Flop 1", comment: "Community card position"),
                    NSLocalizedString("Flop 2", comment: "Community card position"),
                    NSLocalizedString("Flop 3", comment: "Community card position"),
                    NSLocalizedString("Turn", comment: "Community card position"),
                    NSLocalizedString("River", comment: "Community card position")
                ]
                return index < positions.count ? positions[index] : NSLocalizedString("Community Card \(index + 1)", comment: "Card position")
            }
        }
    }
    
    // MARK: - Premium Features Methods
    
    /// Ativa o modo de alta precisão temporariamente
    func activateHighPrecisionMode() {
        isHighPrecisionModeActive = true
        premiumModeExpiryTime = Date().addingTimeInterval(AdConfiguration.premiumFeatureDuration)
        
        // Define iterações para modo premium
        if !fastMode {
            iterationsCount = AdConfiguration.maxPremiumIterations
        }
        
        // Agenda verificação de expiração
        scheduleExpirationCheck()
    }
    
    /// Verifica se o modo premium ainda está ativo
    private func checkPremiumModeExpiry() {
        guard let expiryTime = premiumModeExpiryTime else { return }
        
        if Date() >= expiryTime {
            deactivateHighPrecisionMode()
        }
    }
    
    /// Desativa o modo de alta precisão
    private func deactivateHighPrecisionMode() {
        isHighPrecisionModeActive = false
        premiumModeExpiryTime = nil
        
        // Para o timer
        premiumTimer?.invalidate()
        premiumTimer = nil
        
        // Volta para iterações padrão se não estiver em fast mode
        if !fastMode && iterationsCount > 100000 {
            iterationsCount = 100000
        }
    }
    
    /// Agenda verificação de expiração do modo premium
    private func scheduleExpirationCheck() {
        // Para timer anterior se existir
        premiumTimer?.invalidate()
        
        // Cria novo timer para atualizar o tempo restante a cada segundo
        premiumTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Força atualização da UI no main thread
            DispatchQueue.main.async {
                // Força uma atualização das propriedades @Published
                self.timeUpdateTrigger.toggle()
                
                // Verifica se deve expirar
                self.checkPremiumModeExpiry()
                
                // Para o timer quando o modo expira
                if !self.isHighPrecisionModeActive {
                    timer.invalidate()
                    self.premiumTimer = nil
                }
            }
        }
    }
    
    /// Tempo restante do modo premium em segundos
    var premiumTimeRemaining: TimeInterval {
        guard let expiryTime = premiumModeExpiryTime else { return 0 }
        return max(0, expiryTime.timeIntervalSinceNow)
    }
    
    /// Texto formatado do tempo restante
    var premiumTimeRemainingText: String {
        let remaining = premiumTimeRemaining
        if remaining <= 0 { return "" }
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // MARK: - Public Methods
    
    /// Inicia simulação Monte Carlo
    func runSimulation() {
        guard canRunSimulation else {
            errorMessage = validateConfiguration()
            return
        }
        
        Task {
            await performSimulation()
        }
    }
    
    /// Cancela simulação em progresso
    func cancelSimulation() {
        cancellationToken?.cancel()
        simulationState = .cancelled
        simulationProgress = 0.0
    }
    
    /// Limpa seleção de cartas
    func clearAllCards() {
        playerCards = [nil, nil]
        communityCards = [nil, nil, nil, nil, nil]
        simulationResult = nil
        simulationState = .idle
        simulationProgress = 0.0
        errorMessage = nil
    }
    
    /// Remove uma carta específica
    func removeCard(at position: CardPosition) {
        switch position {
        case .playerCard(let index):
            if index < playerCards.count {
                playerCards[index] = nil
            }
        case .communityCard(let index):
            if index < communityCards.count {
                communityCards[index] = nil
            }
        }
        
        // Limpa resultado se cartas mudaram
        if simulationResult != nil {
            simulationResult = nil
            simulationState = .idle
        }
    }
    
    /// Seleciona uma carta para posição específica
    func selectCard(_ card: Card, for position: CardPosition) {
        // Verifica se carta já está em uso
        if allSelectedCards.contains(card) {
            errorMessage = NSLocalizedString("Card already selected", comment: "Error message")
            return
        }
        
        switch position {
        case .playerCard(let index):
            if index < playerCards.count {
                playerCards[index] = card
            }
        case .communityCard(let index):
            if index < communityCards.count {
                communityCards[index] = card
            }
        }
        
        // Limpa resultado se cartas mudaram
        if simulationResult != nil {
            simulationResult = nil
            simulationState = .idle
        }
        
        errorMessage = nil
        showingCardPicker = false
    }
    
    /// Abre seletor de cartas para posição específica
    func openCardPicker(for position: CardPosition) {
        currentEditingPosition = position
        showingCardPicker = true
    }
    
    /// Atualiza número de iterações com validação
    func updateIterations(_ newValue: Int) {
        // Permite mais iterações se o modo de alta precisão estiver ativo
        let maxIterations = isHighPrecisionModeActive ? AdConfiguration.maxPremiumIterations : 100000
        iterationsCount = max(5000, min(maxIterations, newValue))
    }
    
    // MARK: - Private Methods
    
    /// Executa a simulação Monte Carlo
    private func performSimulation() async {
        simulationState = .running
        simulationProgress = 0.0
        cancellationToken = CancellationToken()
        
        let result = await MonteCarloEngine.simulate(
            playerCards: validPlayerCards,
            communityCards: validCommunityCards,
            iterations: iterationsCount,
            cancellationToken: cancellationToken
        ) { progress in
            Task { @MainActor in
                self.simulationProgress = progress
            }
        }
        
        if let result = result {
            simulationResult = result
            simulationState = .completed
            
            // Trigger scroll para o resultado após um pequeno delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.shouldScrollToResult = true
            }
            
            // Feedback háptico de sucesso
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Notifica AdManager sobre cálculo completado
            AdManager.shared.onCalculationCompleted()
        } else if cancellationToken?.isCancelled == true {
            simulationState = .cancelled
        } else {
            simulationState = .error(NSLocalizedString("Simulation failed", comment: "Error message"))
        }
        
        // Banner permanece sempre visível
        
        simulationProgress = 0.0
        cancellationToken = nil
    }
    
    /// Valida configuração atual
    private func validateConfiguration() -> String? {
        if validPlayerCards.count != 2 {
            return NSLocalizedString("Select exactly 2 cards for your hand", comment: "Validation error")
        }
        
        if hasCardDuplicates {
            return NSLocalizedString("Duplicate cards detected", comment: "Validation error")
        }
        
        if iterationsCount < 5000 {
            return NSLocalizedString("Minimum 5,000 iterations required", comment: "Validation error")
        }
        
        // Permite mais iterações se o modo de alta precisão estiver ativo
        let maxIterations = isHighPrecisionModeActive ? AdConfiguration.maxPremiumIterations : 100000
        if iterationsCount > maxIterations {
            let maxText = isHighPrecisionModeActive ? "200,000" : "100,000"
            return NSLocalizedString("Maximum \(maxText) iterations allowed", comment: "Validation error")
        }
        
        return nil
    }
    
    /// Formata percentual para exibição
    func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
    
    /// Estima duração da simulação
    var estimatedDuration: String {
        let seconds = MonteCarloEngine.estimatedDuration(iterations: iterationsCount)
        
        if seconds < 1.0 {
            return NSLocalizedString("< 1 second", comment: "Duration estimate")
        } else if seconds < 60.0 {
            return String(format: NSLocalizedString("~%.0f seconds", comment: "Duration estimate"), seconds)
        } else {
            return String(format: NSLocalizedString("~%.1f minutes", comment: "Duration estimate"), seconds / 60.0)
        }
    }
    
    /// Verifica se deve reduzir animações
    var shouldReduceMotion: Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
}
