//
//  ConfirmationDialogViewModifier.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 27/02/2026.
//

import SwiftUI

struct ConfirmationDialogViewModifier: ViewModifier {
	@Binding var dialog: (any ConfirmationDialog)?

	init(dialog: Binding<(any ConfirmationDialog)?>) {
		self._dialog = dialog
	}

	func body(content: Content) -> some View {
		if let currentDialog = dialog {
			let isPresented = Binding<Bool>(
				get: { dialog != nil },
				set: { value in
					if !value {
						dialog = nil
					}
				}
			)

			content.confirmationDialog(
				currentDialog.title,
				isPresented: isPresented,
				titleVisibility: currentDialog.titleVisibility,
				actions: { AnyView(currentDialog.actions) },
				message: { AnyView(currentDialog.message) }
			)
		} else {
			content
		}
	}
}

public extension View {
	/// Presents a ``ConfirmationDialog`` when the binding's value is non-`nil`.
	///
	/// Setting the binding back to `nil` dismisses the dialog.
	///
	/// ```swift
	/// @State private var dialog: (any ConfirmationDialog)? = nil
	///
	/// MyView()
	///     .confirmationDialog($dialog)
	/// ```
	func confirmationDialog(_ dialog: Binding<(any ConfirmationDialog)?>) -> some View {
		modifier(ConfirmationDialogViewModifier(dialog: dialog))
	}
}
