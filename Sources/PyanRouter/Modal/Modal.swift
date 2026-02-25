//
//  Modal.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 06/02/2026.
//

import SwiftUI

/// A type describing a custom modal overlay's content and presentation style.
///
/// Conform to this protocol to define what a modal looks like and how it
/// animates in and out. The ``RouteBuilder`` returns `Modal` instances from
/// its ``RouteBuilder/build(modal:)`` method.
///
/// Tapping the background automatically dismisses the modal.
///
/// ```swift
/// struct ConfirmationModal: Modal {
///     let transition: AnyTransition = .move(edge: .bottom)
///     let animation: Animation = .spring
///
///     var content: some View {
///         Text("Are you sure?")
///             .padding()
///             .background(.regularMaterial)
///             .clipShape(.rect(cornerRadius: 16))
///     }
/// }
/// ```
@MainActor
public protocol Modal {
	associatedtype Content: View

	/// The color drawn behind the modal content. Defaults to a semi-transparent black.
	var background: Color { get }

	/// The transition applied to the modal content when appearing and disappearing.
	var transition: AnyTransition { get }

	/// The transition applied to the background when appearing and disappearing.
	var backgroundTransition: AnyTransition { get }

	/// The animation used for the modal's transitions.
	var animation: Animation { get }

	/// The view content of the modal.
	@ViewBuilder @MainActor var content: Content { get }
}

public extension Modal {
	var background: Color { .black.opacity(0.6) }
	var transition: AnyTransition { .opacity }
	var backgroundTransition: AnyTransition { .opacity.animation(.linear) }
	var animation: Animation { .default }
}
