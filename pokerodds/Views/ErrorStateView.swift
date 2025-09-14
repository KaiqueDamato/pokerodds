//
//  ErrorStateView.swift
//  PokerOdds
//
//  Created on 12/09/2025.
//

import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundColor(.orange)
            
            // Error message
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel(NSLocalizedString("Dismiss error", comment: "Dismiss error button"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(NSLocalizedString("Error: \(message)", comment: "Error accessibility label"))
        .accessibilityHint(NSLocalizedString("Swipe right to dismiss", comment: "Error accessibility hint"))
    }
}

// MARK: - Preview

struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ErrorStateView(
                message: NSLocalizedString("Duplicate cards detected", comment: "Error message"),
                onDismiss: {}
            )
            
            ErrorStateView(
                message: NSLocalizedString("Select exactly 2 cards for your hand", comment: "Error message"),
                onDismiss: {}
            )
            
            ErrorStateView(
                message: NSLocalizedString("This is a longer error message to test how the view handles multiple lines of text properly", comment: "Long error message"),
                onDismiss: {}
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
        
        // Dark mode preview
        VStack(spacing: 16) {
            ErrorStateView(
                message: NSLocalizedString("Card already selected", comment: "Error message"),
                onDismiss: {}
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
