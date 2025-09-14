//
//  MonteCarloEngine.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import Foundation

/// Resultados da simulação Monte Carlo
struct SimulationResult {
    let wins: Int
    let ties: Int
    let losses: Int
    let totalSimulations: Int
    let elapsedTime: TimeInterval
    
    /// Percentual de vitórias
    var winPercentage: Double {
        return totalSimulations > 0 ? Double(wins) / Double(totalSimulations) * 100.0 : 0.0
    }
    
    /// Percentual de empates
    var tiePercentage: Double {
        return totalSimulations > 0 ? Double(ties) / Double(totalSimulations) * 100.0 : 0.0
    }
    
    /// Percentual de derrotas
    var lossPercentage: Double {
        return totalSimulations > 0 ? Double(losses) / Double(totalSimulations) * 100.0 : 0.0
    }
}

/// Token para cancelamento de simulação em progresso
class CancellationToken {
    private var _isCancelled = false
    private let lock = NSLock()
    
    var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isCancelled
    }
    
    func cancel() {
        lock.lock()
        defer { lock.unlock() }
        _isCancelled = true
    }
}

/// Callback para progresso da simulação
typealias ProgressCallback = (Double) -> Void

/// Engine de simulação Monte Carlo para cálculo de probabilidades no poker
class MonteCarloEngine {
    
    /// Executa simulação Monte Carlo para calcular probabilidades
    /// - Parameters:
    ///   - playerCards: Cartas do jogador (exatamente 2)
    ///   - communityCards: Cartas comunitárias (0 a 5)
    ///   - iterations: Número de iterações (mínimo 5.000, máximo 100.000)
    ///   - cancellationToken: Token para cancelar simulação
    ///   - progressCallback: Callback opcional para progresso
    /// - Returns: Resultado da simulação com wins/ties/losses
    static func simulate(
        playerCards: [Card],
        communityCards: [Card],
        iterations: Int,
        cancellationToken: CancellationToken? = nil,
        progressCallback: ProgressCallback? = nil
    ) async -> SimulationResult? {
        
        // Validações de entrada
        guard playerCards.count == 2 else {
            print("Erro: Jogador deve ter exatamente 2 cartas")
            return nil
        }
        
        guard communityCards.count <= 5 else {
            print("Erro: Máximo 5 cartas comunitárias")
            return nil
        }
        
        guard iterations >= 5000 && iterations <= AdConfiguration.maxPremiumIterations else {
            print("Erro: Iterações devem estar entre 5.000 e \(AdConfiguration.maxPremiumIterations)")
            return nil
        }
        
        // Verifica cartas duplicadas
        let allUsedCards = playerCards + communityCards
        guard Set(allUsedCards).count == allUsedCards.count else {
            print("Erro: Cartas duplicadas detectadas")
            return nil
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var wins = 0
        var ties = 0
        var losses = 0
        
        // Configuração inicial do baralho
        var deck = Deck()
        deck.markAsUsed(allUsedCards)
        
        let batchSize = 1000 // Processa em lotes para melhor performance e progresso
        let totalBatches = (iterations + batchSize - 1) / batchSize
        
        for batchIndex in 0..<totalBatches {
            // Verifica cancelamento
            if cancellationToken?.isCancelled == true {
                return nil
            }
            
            let currentBatchSize = min(batchSize, iterations - batchIndex * batchSize)
            let batchResult = await simulateBatch(
                playerCards: playerCards,
                communityCards: communityCards,
                iterations: currentBatchSize,
                deck: deck.copy()
            )
            
            wins += batchResult.wins
            ties += batchResult.ties
            losses += batchResult.losses
            
            // Atualiza progresso
            let progress = Double(batchIndex + 1) / Double(totalBatches)
            await MainActor.run {
                progressCallback?(progress)
            }
        }
        
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        
        return SimulationResult(
            wins: wins,
            ties: ties,
            losses: losses,
            totalSimulations: wins + ties + losses,
            elapsedTime: elapsedTime
        )
    }
    
    /// Executa um lote de simulações para melhor performance
    private static func simulateBatch(
        playerCards: [Card],
        communityCards: [Card],
        iterations: Int,
        deck: Deck
    ) async -> (wins: Int, ties: Int, losses: Int) {
        
        var wins = 0
        var ties = 0
        var losses = 0
        var workingDeck = deck
        
        for _ in 0..<iterations {
            // Reset do baralho para esta iteração
            _ = playerCards + communityCards // Cartas já em uso
            workingDeck = deck.copy()
            
            // Sorteia 2 cartas para o oponente
            let opponentCards = workingDeck.drawRandomCards(count: 2)
            guard opponentCards.count == 2 else {
                print("Erro: Não foi possível sortear cartas do oponente")
                continue
            }
            
            // Completa o board se necessário
            let cardsNeeded = 5 - communityCards.count
            let additionalCommunityCards = workingDeck.drawRandomCards(count: cardsNeeded)
            let fullCommunityCards = communityCards + additionalCommunityCards
            
            // Avalia as mãos
            let playerHand = HandEvaluator.evaluateHand(playerCards + fullCommunityCards)
            let opponentHand = HandEvaluator.evaluateHand(opponentCards + fullCommunityCards)
            
            // Compara resultados
            if playerHand > opponentHand {
                wins += 1
            } else if playerHand == opponentHand {
                ties += 1
            } else {
                losses += 1
            }
        }
        
        return (wins: wins, ties: ties, losses: losses)
    }
    
    /// Versão síncrona mais simples para testes ou uso em background
    static func simulateSync(
        playerCards: [Card],
        communityCards: [Card],
        iterations: Int
    ) -> SimulationResult? {
        
        // Reutiliza a versão assíncrona executando de forma síncrona
        var result: SimulationResult?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            result = await simulate(
                playerCards: playerCards,
                communityCards: communityCards,
                iterations: iterations
            )
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    /// Estima tempo de execução baseado no número de iterações
    static func estimatedDuration(iterations: Int) -> TimeInterval {
        // Baseado em benchmarks típicos (pode variar por dispositivo)
        let iterationsPerSecond: Double = 50000 // Estimativa conservadora
        return Double(iterations) / iterationsPerSecond
    }
    
    /// Validação rápida de configuração antes de executar simulação
    static func validateConfiguration(
        playerCards: [Card],
        communityCards: [Card],
        iterations: Int
    ) -> String? {
        
        if playerCards.count != 2 {
            return "Jogador deve ter exatamente 2 cartas"
        }
        
        if communityCards.count > 5 {
            return "Máximo 5 cartas comunitárias"
        }
        
        if iterations < 5000 {
            return "Mínimo 5.000 iterações"
        }
        
        if iterations > 100000 {
            return "Máximo 100.000 iterações"
        }
        
        let allCards = playerCards + communityCards
        if Set(allCards).count != allCards.count {
            return "Cartas duplicadas detectadas"
        }
        
        return nil // Configuração válida
    }
}
