//
//  ScrollViewExtensions.swift
//  PokerOdds
//
//  Created on 14/09/2025.
//

import SwiftUI
import UIKit

// MARK: - ScrollView Extensions para Auto-Scroll

extension View {
    /// Força scroll para um elemento específico usando UIKit como fallback
    func forceScrollTo(id: String, anchor: UnitPoint = .center) {
        DispatchQueue.main.async {
            // Tenta encontrar o UIScrollView na hierarquia de views
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                findScrollView(in: window)?.scrollToElement(withId: id, anchor: anchor)
            }
        }
    }
    
    private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        
        for subview in view.subviews {
            if let scrollView = findScrollView(in: subview) {
                return scrollView
            }
        }
        
        return nil
    }
}

extension UIScrollView {
    /// Scroll para um elemento com ID específico
    func scrollToElement(withId id: String, anchor: UnitPoint) {
        // Esta é uma implementação simplificada
        // Em um caso real, você precisaria mapear os IDs para posições
        
        // Por enquanto, vamos fazer scroll para o final da view
        let bottomOffset = CGPoint(x: 0, y: max(0, contentSize.height - bounds.size.height))
        setContentOffset(bottomOffset, animated: true)
    }
}

// MARK: - View Modifier para Debug de Scroll

struct ScrollDebugModifier: ViewModifier {
    let id: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                print("🔍 View com ID '\(id)' apareceu na tela")
            }
            .onDisappear {
                print("🔍 View com ID '\(id)' desapareceu da tela")
            }
    }
}

extension View {
    func debugScroll(id: String) -> some View {
        modifier(ScrollDebugModifier(id: id))
    }
}
