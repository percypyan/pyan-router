//
//  AnyAlert.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 06/02/2026.
//

import SwiftUI

/// A type that defines an alerts to be presented via the ``SwiftUICore/View/alert(_:)`` view modifier.
///
/// Conform to `PyanAlert` to create reusable alert definitions. If you omit the
/// `actions` property, a default "Close" button is provided automatically.
///
/// ```swift
/// struct DeleteAlert: PyanAlert {
///     let title: LocalizedStringKey = "Delete Item"
///
///     var message: some View {
///         Text("This action cannot be undone.")
///     }
///
///     var actions: some View {
///         Button("Delete", role: .destructive) { /* ... */ }
///     }
/// }
/// ```
public protocol PyanAlert {
	associatedtype A: View = Never
	associatedtype M: View

	/// The alert title.
	var title: LocalizedStringKey { get }

	/// The alert message content.
	@ViewBuilder var message: M { get }

	/// The alert action buttons. Defaults to a single "Close" button when omitted.
	@ViewBuilder var actions: A { get }
}

public extension PyanAlert where A == Never {
	var actions: Never { fatalError("This PyanAlert does not define any action") }
}
