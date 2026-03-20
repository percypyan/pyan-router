//
//  Router.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 05/02/2026.
//

import SwiftUI

/// A type that defines the navigation API for a ``RouteBuilder``.
///
/// `Router` provides methods to push screens, present modals, and dismiss any
/// of those presentations.
///
/// Dismiss methods pass the resulting router to their completion closure.
/// This router represents the navigation context that becomes active after the
/// dismissal, letting you chain a new navigation action immediately:
///
/// ```swift
/// router.dismissSheet { router in
///     router.navigate(to: .home)
/// }
/// ```
///
/// You typically receive a router instance inside your views rather than
/// creating one yourself.
@MainActor
public protocol Router<Builder> {
	/// The builder type that defines the screen and modal keys for this router.
	associatedtype Builder: RouteBuilder

	/// The route builder associated with this router.
	var builder: Builder { get }

	#if !os(macOS)
	/// Whether a full-screen cover is currently presented.
	var showsFullScreenCover: Bool { get }
	#endif

	/// Whether a sheet is currently presented.
	var showsSheet: Bool { get }

	/// Navigates to a screen.
	///
	/// - Parameters:
	///   - screen: The screen key to navigate to.
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - completion: Called when the navigation animation finishes.
	func navigate(to screen: Builder.ScreenKey, animation: Animation?, completion: @escaping () -> Void)

	/// Presents a modal overlay.
	///
	/// - Parameters:
	///   - modal: The key of the modal to present.
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - completion: Called when the presentation animation finishes.
	///   - onClose: An optional closure invoked when the modal is dismissed.
	func present(
		_ modal: Builder.ModalKey,
		animation: Animation?,
		completion: @escaping () -> Void,
		onClose: (() -> Void)?
	)

	/// Dismisses the topmost modal or screen if no modal is presented.
	///
	/// - Parameters:
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - completion: Called when the dismiss animation finishes. The router
	///     passed to this closure is the resulting router after the dismissal,
	///     which you can use to chain further navigation actions.
	func dismiss(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void)

	/// Dismisses the topmost screen.
	///
	/// - Parameters:
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - completion: Called when the dismiss animation finishes. The router
	///     passed to this closure is the resulting router after the dismissal,
	///     which you can use to chain further navigation actions.
	func dismissScreen(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void)

	#if !os(macOS)
	/// Dismisses the currently presented full-screen cover and all screens that have been pushed on it.
	///
	/// - Parameters:
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - completion: Called when the dismiss animation finishes. The router
	///     passed to this closure is the resulting router after the dismissal,
	///     which you can use to chain further navigation actions.
	func dismissFullScreenCover(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void)
	#endif

	/// Dismisses the currently presented sheet and all screens that have been pushed on it.
	///
	/// - Parameters:
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - completion: Called when the dismiss animation finishes. The router
	///     passed to this closure is the resulting router after the dismissal,
	///     which you can use to chain further navigation actions.
	func dismissSheet(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void)

	/// Dismisses the currently presented modal.
	///
	/// - Parameters:
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - completion: Called when the dismiss animation finishes.
	func dismissModal(animation: Animation?, completion: @escaping () -> Void)

	/// Dismisses all presented screens and modals, unwinding the entire navigation stack.
	///
	/// When animated, each sheet and cover will be dismissed with animation until we reach to root of the stack.
	///
	/// - Parameters:
	///   - animation: The animation to use. Pass `nil` to disable animation.
	///   - animationSequence: How the dismiss animation should be sequenced.
	///   - completion: Called when all dismiss animations finish. The router
	///     passed to this closure is the resulting router after the dismissal
	///     (typically the root router), which you can use to chain further
	///     navigation actions.
	func dismissAll(
		animation: Animation?,
		animationSequence: DismissAnimationSequence,
		completion: @escaping (any Router<Builder>) -> Void
	)
}

// MARK: Shortcuts methods calls

public extension Router {
	func navigate(to screen: Builder.ScreenKey, animation: Animation?) {
		navigate(to: screen, animation: animation, completion: {})
	}

	func navigate(to screen: Builder.ScreenKey, completion: @escaping () -> Void = {}) {
		navigate(to: screen, animation: .default, completion: completion)
	}

	func present(_ modal: Builder.ModalKey, onClose: (() -> Void)?) {
		present(modal, animation: .default, completion: {}, onClose: onClose)
	}

	func present(_ modal: Builder.ModalKey, animation: Animation? = .default, completion: @escaping () -> Void = {}) {
		present(modal, animation: animation, completion: completion, onClose: nil)
	}

	func dismiss(animation: Animation? = .default) {
		dismiss(animation: animation, completion: { _ in })
	}

	func dismiss(completion: @escaping (any Router<Builder>) -> Void) {
		dismiss(animation: .default, completion: completion)
	}

	func dismissScreen(animation: Animation? = .default) {
		dismissScreen(animation: animation, completion: { _ in })
	}

	func dismissScreen(completion: @escaping (any Router<Builder>) -> Void) {
		dismissScreen(animation: .default, completion: completion)
	}

	#if !os(macOS)
	func dismissFullScreenCover(animation: Animation? = .default) {
		dismissFullScreenCover(animation: animation, completion: { _ in })
	}

	func dismissFullScreenCover(completion: @escaping (any Router<Builder>) -> Void) {
		dismissFullScreenCover(animation: .default, completion: completion)
	}
	#endif

	func dismissSheet(animation: Animation? = .default) {
		dismissSheet(animation: animation, completion: { _ in })
	}

	func dismissSheet(completion: @escaping (any Router<Builder>) -> Void) {
		dismissSheet(animation: .default, completion: completion)
	}

	func dismissModal(animation: Animation? = .default) {
		dismissModal(animation: animation, completion: {})
	}

	func dismissModal(completion: @escaping () -> Void) {
		dismissModal(animation: .default, completion: completion)
	}

	func dismissAll(
		animationSequence: DismissAnimationSequence = .sheetsAndCovers,
		completion: @escaping (any Router<Builder>) -> Void = { _ in }
	) {
		dismissAll(animation: .default, animationSequence: animationSequence, completion: completion)
	}

	func dismissAll(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void = { _ in }) {
		dismissAll(animation: animation, animationSequence: .sheetsAndCovers, completion: completion)
	}
}
