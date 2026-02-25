//
//  AlertViewModifier.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 05/02/2026.
//

import SwiftUI

struct AlertViewModifier: ViewModifier {
	@Binding var alert: (any PyanAlert)?

	init(alert: Binding<(any PyanAlert)?>) {
		self._alert = alert
	}

	func body(content: Content) -> some View {
		if let currentAlert = alert {
			let isPresented = Binding<Bool>(
				get: { alert != nil },
				set: { value in
					if !value {
						alert = nil
					}
				}
			)

			content.alert(
				currentAlert.title,
				isPresented: isPresented,
				actions: { openActions(currentAlert) },
				message: { AnyView(currentAlert.message) }
			)
		} else {
			content
		}
	}

	private func openActions<T: PyanAlert>(_ alert: T) -> AnyView {
		if T.A.self == Never.self {
			if #available(iOS 26, tvOS 26, macOS 26, watchOS 26, visionOS 26, *) {
				return AnyView(Button("Close", role: .close, action: {}))
			} else {
				return AnyView(Button("Close", action: {}))
			}
		} else {
			return AnyView(alert.actions)
		}
	}
}

public extension View {
	/// Presents a ``PyanAlert`` when the binding's value is non-`nil`.
	///
	/// Setting the binding back to `nil` dismisses the alert.
	///
	/// ```swift
	/// @State private var alert: (any PyanAlert)? = nil
	///
	/// MyView()
	///     .alert($alert)
	/// ```
	func alert(_ alert: Binding<(any PyanAlert)?>) -> some View {
		modifier(AlertViewModifier(alert: alert))
	}
}
