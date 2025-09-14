//
//  Deck.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import Foundation

/// Gerenciador do baralho de cartas padrão (52 cartas)
struct Deck {
    private var cards: [Card]
    private var usedCards: Set<Card>
    
    /// Inicializa um baralho completo de 52 cartas
    init() {
        self.cards = []
        self.usedCards = Set<Card>()
        
        // Cria todas as combinações de rank × suit
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }
    
    /// Retorna todas as cartas do baralho (52 cartas)
    var allCards: [Card] {
        return cards
    }
    
    /// Retorna cartas disponíveis (não utilizadas)
    var availableCards: [Card] {
        return cards.filter { !usedCards.contains($0) }
    }
    
    /// Marca cartas como utilizadas
    mutating func markAsUsed(_ cards: [Card]) {
        for card in cards {
            usedCards.insert(card)
        }
    }
    
    /// Marca uma carta como utilizada
    mutating func markAsUsed(_ card: Card) {
        usedCards.insert(card)
    }
    
    /// Remove cartas da lista de utilizadas
    mutating func markAsAvailable(_ cards: [Card]) {
        for card in cards {
            usedCards.remove(card)
        }
    }
    
    /// Remove uma carta da lista de utilizadas
    mutating func markAsAvailable(_ card: Card) {
        usedCards.remove(card)
    }
    
    /// Verifica se uma carta está disponível
    func isAvailable(_ card: Card) -> Bool {
        return !usedCards.contains(card)
    }
    
    /// Limpa todas as cartas marcadas como utilizadas
    mutating func reset() {
        usedCards.removeAll()
    }
    
    /// Sorteia uma carta aleatória das disponíveis
    mutating func drawRandomCard() -> Card? {
        let available = availableCards
        guard !available.isEmpty else { return nil }
        
        let randomCard = available.randomElement()!
        markAsUsed(randomCard)
        return randomCard
    }
    
    /// Sorteia múltiplas cartas aleatórias
    mutating func drawRandomCards(count: Int) -> [Card] {
        var drawnCards: [Card] = []
        
        for _ in 0..<count {
            if let card = drawRandomCard() {
                drawnCards.append(card)
            } else {
                break // Não há mais cartas disponíveis
            }
        }
        
        return drawnCards
    }
    
    /// Cria uma cópia do baralho com as mesmas cartas utilizadas
    func copy() -> Deck {
        var newDeck = Deck()
        newDeck.usedCards = self.usedCards
        return newDeck
    }
    
    /// Número de cartas disponíveis
    var remainingCount: Int {
        return availableCards.count
    }
    
    /// Número total de cartas no baralho
    var totalCount: Int {
        return cards.count
    }
}
