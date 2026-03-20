//
//  MockRouter.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 27/02/2026.
//

#if DEBUG

import SwiftUI

public extension RouteBuilder {
	/// A convenience alias for `MockRouter<Self>`.
	typealias AssociatedMockRouter = MockRouter<Self>
}

/// Errors thrown by ``MockRouter``.
public enum MockRouterError: Error {
	/// No modal has been presented, so there is no `onClose` callback to invoke.
	case noModalPresented
}

/// A test double that records every ``Router`` method call without performing real navigation.
///
/// Use `MockRouter` in unit tests to verify that your presenters and view models
/// call the correct navigation methods.
///
/// ```swift
/// let router = MockRouter<MyBuilder>()
/// presenter.didTapProfile()
/// #expect(router.hasNavigated(to: .profile))
/// ```
///
/// Dismiss completions receive `self` as the resulting router, so dismiss-then-navigate
/// chains execute synchronously and can be verified in a single test:
///
/// ```swift
/// router.dismissSheet { router in
///     router.navigate(to: .home)
/// }
/// #expect(router.hasDismissed(type: .sheet))
/// #expect(router.hasNavigated(to: .home))
/// ```
@MainActor
public final class MockRouter<Builder: RouteBuilder>: Router {
	#if !os(macOS)
	public private(set) var showsFullScreenCover: Bool = false
	#endif

	public private(set) var showsSheet: Bool = false
	public var builder: Builder { fatalError("MockRouter does not provide a real builder") }

	private(set) var calls: [MethodCall] = []
	private(set) var modalsOnCloseCallbacks: [(() -> Void)?] = []

	public init() {}

	private func navigateCallWhere(_ whereScreen: @escaping (Builder.ScreenKey) -> Bool) -> ((MethodCall) -> Bool) {
		return { call in
			if case .navigate(let callScreen, _) = call, whereScreen(callScreen) {
				return true
			}
			return false
		}
	}

	private func presentCallWhere(_ whereModal: @escaping (Builder.ModalKey) -> Bool) -> ((MethodCall) -> Bool) {
		return { call in
			if case .present(let callModal, _, _) = call, whereModal(callModal) {
				return true
			}
			return false
		}
	}

	private func dismissCallWhere(type: DismissType) -> ((MethodCall) -> Bool) {
		return { call in
			if case .dismiss(let callType, _, _) = call, callType == type {
				return true
			}
			return false
		}
	}

	// MARK: - Test utilities

	/// Simulates the user dismissing the most recently presented modal by invoking its `onClose` callback.
	///
	/// Callbacks are invoked in LIFO order (last presented, first closed).
	///
	/// - Throws: ``MockRouterError/noModalPresented`` if no modals have been presented.
	public func simulateLastModalClosing() throws {
		guard let onClose = modalsOnCloseCallbacks.popLast() else {
			throw MockRouterError.noModalPresented
		}
		onClose?()
	}

	/// Returns `true` if any recorded navigation matches the given predicate.
	public func hasNavigated(where whereScreen: @escaping (Builder.ScreenKey) -> Bool) -> Bool {
		return calls.contains(where: navigateCallWhere(whereScreen))
	}

	/// Returns `true` if the router has navigated to the given screen at least once.
	public func hasNavigated(to screen: Builder.ScreenKey) -> Bool {
		return hasNavigated(where: { $0 == screen })
	}

	/// Returns the number of recorded navigations matching the given predicate.
	public func navigationCount(where whereScreen: @escaping (Builder.ScreenKey) -> Bool) -> Int {
		return calls.count(where: navigateCallWhere(whereScreen))
	}

	/// Returns the number of times the router has navigated to the given screen.
	public func navigationCount(to screen: Builder.ScreenKey) -> Int {
		return navigationCount(where: { $0 == screen })
	}

	/// Returns `true` if any recorded presentation matches the given predicate.
	public func hasPresented(where whereModal: @escaping (Builder.ModalKey) -> Bool) -> Bool {
		return calls.contains(where: presentCallWhere(whereModal))
	}

	/// Returns `true` if the router has presented the given modal at least once.
	public func hasPresented(modal: Builder.ModalKey) -> Bool {
		return hasPresented(where: { $0 == modal })
	}

	/// Returns the number of recorded presentations matching the given predicate.
	public func presentedCount(where whereModal: @escaping (Builder.ModalKey) -> Bool) -> Int {
		return calls.count(where: presentCallWhere(whereModal))
	}

	/// Returns the number of times the router has presented the given modal.
	public func presentedCount(modal: Builder.ModalKey) -> Int {
		return presentedCount(where: { $0 == modal })
	}

	/// Returns `true` if the router has recorded a dismiss of the given type.
	public func hasDismissed(type: DismissType) -> Bool {
		calls.contains(where: dismissCallWhere(type: type))
	}

	/// Returns the number of times the router has recorded a dismiss of the given type.
	public func dismissedCount(type: DismissType) -> Int {
		calls.count(where: dismissCallWhere(type: type))
	}

	// MARK: - Router protocol conformance

	public func navigate(to screen: Builder.ScreenKey, animation: Animation?, completion: @escaping () -> Void) {
		calls.append(.navigate(to: screen, animation: animation))
		completion()
	}

	public func present(
		_ modal: Builder.ModalKey,
		animation: Animation?,
		completion: @escaping () -> Void,
		onClose: (() -> Void)?
	) {
		calls.append(.present(modal: modal, animation: animation, hasOnClose: onClose != nil))
		modalsOnCloseCallbacks.append(onClose)
		completion()
	}

	public func dismiss(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void) {
		if !modalsOnCloseCallbacks.isEmpty {
			dismissModal(animation: animation, completion: { completion(self) })
		} else {
			dismissScreen(animation: animation, completion: completion)
		}
	}

	public func dismissScreen(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void) {
		calls.append(.dismiss(type: .screen, animation: animation, animationSequence: nil))
		completion(self)
	}

	#if !os(macOS)
	public func dismissFullScreenCover(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void) {
		calls.append(.dismiss(type: .fullScreenCover, animation: animation, animationSequence: nil))
		completion(self)
	}
	#endif

	public func dismissSheet(animation: Animation?, completion: @escaping (any Router<Builder>) -> Void) {
		calls.append(.dismiss(type: .sheet, animation: animation, animationSequence: nil))
		completion(self)
	}

	public func dismissModal(animation: Animation?, completion: @escaping () -> Void) {
		calls.append(.dismiss(type: .modal, animation: animation, animationSequence: nil))
		try! simulateLastModalClosing()
		completion()
	}

	public func dismissAll(
		animation: Animation?,
		animationSequence: DismissAnimationSequence,
		completion: @escaping (any Router<Builder>) -> Void
	) {
		calls.append(.dismiss(type: .all, animation: animation, animationSequence: animationSequence))
		completion(self)
	}
}
public extension MockRouter {
	/// The kind of dismissal that was recorded.
	enum DismissType {
		case screen
		case fullScreenCover
		case sheet
		case modal
		case all
	}

	/// A recorded method call on the mock router.
	enum MethodCall {
		/// A navigation to a screen.
		case navigate(to: Builder.ScreenKey, animation: Animation?)
		/// A modal presentation.
		case present(modal: Builder.ModalKey, animation: Animation?, hasOnClose: Bool)
		/// A dismiss operation.
		case dismiss(type: DismissType, animation: Animation?, animationSequence: DismissAnimationSequence?)
	}
}

#endif
