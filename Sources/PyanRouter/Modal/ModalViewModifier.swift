//
//  ModalViewModifier.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 05/02/2026.
//

import SwiftUI

struct ModalView<SomeModal: Modal>: View {
	@Binding var modal: SomeModal?
	let onClose: (() -> Void)?

	@State private var lastAnimation: Animation?

	private var animationInUse: Animation { modal?.animation ?? lastAnimation ?? .default }

	var body: some View {
		ZStack {
			if let modal {
				modal.background
					.ignoresSafeArea()
					.transition(modal.backgroundTransition)
					.onTapGesture { self.modal = nil }
					.onDisappear { onClose?() }
					.zIndex(1)

				modal.content
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.ignoresSafeArea()
					.transition(modal.transition)
					.zIndex(2)
			}
		}
		.zIndex(9999)
		.animation(animationInUse, value: modal != nil)
		.onChange(of: modal?.animation, initial: true) {
			if let animation = modal?.animation {
				lastAnimation = animation
			}
		}
	}
}

public extension View {
	/// Presents a custom ``Modal`` overlay when the binding's value is non-`nil`.
	///
	/// Tapping the modal's background automatically sets the binding to `nil`
	/// and invokes the optional `onClose` callback.
	///
	/// - Parameters:
	///   - modal: A binding to the modal to present.
	///   - onClose: An optional closure called when the modal is dismissed by tapping the background.
	func modal<SomeModal: Modal>(_ modal: Binding<SomeModal?>, onClose: (() -> Void)? = nil) -> some View {
		return self.overlay(ModalView(modal: modal, onClose: onClose))
	}
}
