//
//  BasicConfirmationDialog.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 27/02/2026.
//

import SwiftUI

/// A ready-made ``ConfirmationDialog`` with "Continue" and "Cancel" buttons.
///
/// ```swift
/// confirmationDialog = BasicConfirmationDialog {
///     performDeletion()
/// }
/// ```
public struct BasicConfirmationDialog: ConfirmationDialog {
	private let onConfirmation: () -> Void

	public let title: LocalizedStringKey = "Are you sure?"

	public var message: some View {
		EmptyView()
	}

	public var actions: some View {
		if #available(iOS 26, tvOS 26, macOS 26, watchOS 26, visionOS 26, *) {
			Button("Continue", role: .confirm, action: onConfirmation)
		} else {
			Button("Continue", action: onConfirmation)
		}
		Button("Cancel", role: .cancel) {}
	}

	/// Creates a basic confirmation dialog.
	///
	/// - Parameter onConfirmation: The closure to execute when the user taps "Continue".
	public init(onConfirmation: @escaping () -> Void) {
		self.onConfirmation = onConfirmation
	}
}
