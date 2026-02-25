//
//  NavigationRoot.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 05/02/2026.
//

import SwiftUI

/// The concrete ``Router`` implementation that drives SwiftUI navigation.
///
/// `NavigationRoot` wraps a `NavigationStack` and manages push navigation,
/// full-screen covers, sheets, and custom modal overlays. You rarely create
/// this type directly -- instead, call ``RouteBuilder/root()`` which returns a
/// `NavigationRoot` configured with the builder's root screen.
///
/// When a screen is presented as a sheet or full-screen cover, `NavigationRoot`
/// creates a child router so that the presented screen gets its own navigation
/// stack.
@MainActor
public struct NavigationRoot<RootContent: View, Builder: RouteBuilder>: View, Router {
	@Environment(\.dismiss) private var dismiss

	public let builder: Builder
	let parentRouter: (any Builder.AssociatedRouter)?
	let rootContent: (any Builder.AssociatedRouter) -> RootContent

	@State private var path: [AnyDestination] = []

	@State private var modal: AnyModal?
	@State private var onModalClose: (() -> Void)?

	@State private var sheet: AnyDestination?
	@State private var onCurrentSheetDismiss: (() -> Void)?
	public var showsSheet: Bool { sheet != nil }

	#if !os(macOS)
	@State private var fullScreenCover: AnyDestination?
	@State private var onCurrentFullScreenCoverDismiss: (() -> Void)?

	public var showsFullScreenCover: Bool { fullScreenCover != nil }
	#endif

	init(builder: Builder, rootContent: @escaping (any Builder.AssociatedRouter) -> RootContent) {
		self.builder = builder
		self.parentRouter = nil
		self.rootContent = rootContent
	}

	private init(
		builder: Builder,
		parentRouter: (any Builder.AssociatedRouter)? = nil,
		rootContent: @escaping (any Builder.AssociatedRouter) -> RootContent
	) {
		self.builder = builder
		self.parentRouter = parentRouter
		self.rootContent = rootContent
	}

	public var body: some View {
		#if os(macOS)
		sharedBody
		#else
		sharedBody
			.fullScreenCover(item: $fullScreenCover, onDismiss: onFullScreenCoverDismiss) { $0.content() }
		#endif
	}

	private var sharedBody: some View {
		NavigationStack(path: $path) {
			rootContent(self)
				.navigationDestination(for: AnyDestination.self) { $0.content() }
		}
		.sheet(item: $sheet, onDismiss: onSheetDismiss) { $0.content() }
		.modal($modal, onClose: onModalClose)
	}

	#if !os(macOS)
	private func onFullScreenCoverDismiss() {
		onCurrentFullScreenCoverDismiss?()
		onCurrentFullScreenCoverDismiss = nil
	}
	#endif

	private func onSheetDismiss() {
		onCurrentSheetDismiss?()
		onCurrentSheetDismiss = nil
	}

	// MARK: - Router API

	public func navigate(
		to screen: Builder.ScreenKey,
		animation: Animation? = .default,
		completion: @escaping () -> Void = {}
	) {
		withOptionalAnimation(animation) {
			switch screen.segue {
			case .push:
				path.append(AnyDestination(content: { AnyView(builder.build(screen: screen, with: self)) }))
			#if !os(macOS)
			case .fullScreenCover:
				precondition(sheet == nil, "A sheet is already presented")
				precondition(fullScreenCover == nil, "A full screen cover is already presented")
				fullScreenCover = AnyDestination {
					NavigationRoot(builder: builder, parentRouter: self) { childRouter in
						AnyView(builder.build(screen: screen, with: childRouter)) as! RootContent
					}
				}
			#endif
			case .sheet:
				#if !os(macOS)
				precondition(fullScreenCover == nil, "A full screen cover is already presented")
				#endif
				precondition(sheet == nil, "A sheet is already presented")
				sheet = AnyDestination {
					NavigationRoot(builder: builder, parentRouter: self) { childRouter in
						AnyView(builder.build(screen: screen, with: childRouter)) as! RootContent
					}
				}
			}
		} completion: { completion() }
	}

	public func present(
		_ modal: Builder.ModalKey,
		animation: Animation? = .default,
		completion: @escaping () -> Void = {},
		onClose: (() -> Void)? = nil
	) {
		withOptionalAnimation(animation) {
			let anyModal = builder.build(modal: modal)
			self.modal = AnyModal(
				background: anyModal.background,
				transition: anyModal.transition,
				animation: anyModal.animation,
				backgroundTransition: anyModal.backgroundTransition,
				content: { AnyView(anyModal.content) }
			)
			self.onModalClose = onClose
		} completion: { completion() }
	}

	public func dismiss(animation: Animation? = .default, completion: @escaping () -> Void = {}) {
		if modal != nil {
			dismissModal(animation: animation, completion: completion)
		} else {
			dismissScreen(animation: animation, completion: completion)
		}
	}

	public func dismissScreen(animation: Animation? = .default, completion: @escaping () -> Void = {}) {
		#if !os(macOS)
		if fullScreenCover != nil {
			onCurrentFullScreenCoverDismiss = completion
			withOptionalAnimation(animation) {
				fullScreenCover = nil
			}
			return
		}
		#endif
		if sheet != nil {
			onCurrentSheetDismiss = completion
			withOptionalAnimation(animation) {
				sheet = nil
			}
		} else if !path.isEmpty {
			withOptionalAnimation(animation) {
				path.removeLast()
			} completion: { completion() }
		} else if let parentRouter {
			parentRouter.dismissScreen(animation: animation, completion: completion)
		} else { assertionFailure("No screen to dismiss") }
	}

	public func dismissModal(animation: Animation? = .default, completion: @escaping () -> Void = {}) {
		guard modal != nil else {
			return assertionFailure("No modal currently presented")
		}
		withOptionalAnimation(animation) {
			modal = nil
			onModalClose = nil
		} completion: { completion() }
	}

	#if !os(macOS)
	public func dismissFullScreenCover(animation: Animation? = .default, completion: @escaping () -> Void = {}) {
		guard let parentRouter, parentRouter.showsFullScreenCover else {
			return assertionFailure("No full screen cover to dismiss")
		}

		parentRouter.dismissScreen(animation: animation, completion: completion)
	}
	#endif

	public func dismissSheet(animation: Animation? = .default, completion: @escaping () -> Void = {}) {
		guard let parentRouter, parentRouter.showsSheet else {
			return assertionFailure("No sheet to dismiss")
		}

		parentRouter.dismissScreen(animation: animation, completion: completion)
	}

	public func dismissAll(
		animation: Animation? = .default,
		animationSequence: DismissAnimationSequence = .sheetsAndCovers,
		completion: @escaping () -> Void = {}
	) {
		#if os(macOS)
		let isThereSomethingToDismiss = showsSheet || !path.isEmpty || parentRouter != nil
		#else
		let isThereSomethingToDismiss = showsSheet || showsFullScreenCover || !path.isEmpty || parentRouter != nil
		#endif
		guard isThereSomethingToDismiss else {
			return assertionFailure("Nothing to dismiss")
		}

		guard animationSequence != .allAtOnce else {
			if let parentRouter {
				parentRouter.dismissAll(
					animation: animation,
					animationSequence: animationSequence,
					completion: completion
				)
			} else {
				withOptionalAnimation(animation) {
					modal = nil
					onModalClose = nil
					sheet = nil
					#if !os(macOS)
					fullScreenCover = nil
					#endif
					path.removeLast(path.count)
				} completion: { completion() }
			}
			return
		}

		dismissChild(animation: animation) {
			if let parentRouter {
				parentRouter.dismissAll(animation: animation, completion: completion)
			} else {
				dismissAllInLocalPath(
					animation: animation,
					animationSequence: animationSequence,
					completion: completion
				)
			}
		}
	}

	// MARK: - Private helpers

	@discardableResult
	private func withOptionalAnimation<Result>(
		_ animation: Animation?,
		body: () throws -> Result,
		completion: @escaping () -> Void = {}
	) rethrows -> Result {
		if let animation {
			return try withAnimation(animation, body, completion: completion)
		} else {
			var transaction = Transaction(animation: nil)
			transaction.disablesAnimations = true
			transaction.addAnimationCompletion(completion)
			return try withTransaction(transaction, body)
		}
	}

	private func dismissChild(animation: Animation?, completion: @escaping () -> Void) {
		#if os(macOS)
		if showsSheet {
			dismissScreen(animation: animation, completion: completion)
			return
		}
		#else
		if showsSheet || showsFullScreenCover {
			dismissScreen(animation: animation, completion: completion)
			return
		}
		#endif

		completion()
	}

	private func dismissAllInLocalPath(
		animation: Animation?,
		animationSequence: DismissAnimationSequence,
		completion: @escaping () -> Void
	) {
		withOptionalAnimation(animation) {
			path.removeLast(path.count)
		} completion: { completion() }
	}
}
