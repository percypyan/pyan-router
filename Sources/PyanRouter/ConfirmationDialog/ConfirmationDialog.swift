//
//  PyanConfirmationDialog.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 27/02/2026.
//

import SwiftUI

/// A protocol for defining confirmation dialogs presented via the
/// ``SwiftUICore/View/confirmationDialog(_:)`` view modifier.
///
/// Conform to `ConfirmationDialog` to create reusable dialog definitions with
/// a title, message, and action buttons.
public protocol ConfirmationDialog {
	associatedtype A: View = Never
	associatedtype M: View

	/// The dialog title.
	var title: LocalizedStringKey { get }

	/// Controls whether the title is visible. Defaults to `.automatic`.
	var titleVisibility: Visibility { get }

	/// The dialog message content.
	@ViewBuilder var message: M { get }

	/// The dialog action buttons.
	@ViewBuilder var actions: A { get }
}

public extension ConfirmationDialog {
	var titleVisibility: Visibility { .automatic }
}
