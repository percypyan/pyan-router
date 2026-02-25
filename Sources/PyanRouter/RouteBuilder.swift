//
//  RouteBuilder.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 06/02/2026.
//

import SwiftUI

/// A type that maps screen and modal keys to their concrete view implementations.
///
/// Implement this protocol to define the screens and modals available in a
/// navigation router. The builder acts as a factory: given a ``BuildableScreen``
/// or ``BuildableModal`` key, it returns the corresponding view.
///
/// ```swift
/// struct MyBuilder: RouteBuilder {
///     let rootScreen: MyScreen = .home
///
///     func build(screen: MyScreen, with router: any AssociatedRouter) -> any View {
///         switch screen {
///         case .home: HomeView(router: router)
///         case .detail: DetailView(router: router)
///         }
///     }
/// }
/// ```
///
/// If your module has no modals, omit the `ModalKey` associated type and it
/// defaults to ``ModalNone``.
@MainActor
public protocol RouteBuilder {
	/// The enum type listing all navigable screens.
	associatedtype ScreenKey: BuildableScreen

	/// The enum type listing all presentable modals.
	/// Defaults to ``ModalNone`` when no modals are needed.
	associatedtype ModalKey: BuildableModal = ModalNone

	/// A convenience alias for the router protocol associated with this builder.
	typealias AssociatedRouter = Router<Self>

	/// The screen that should be use as root when `root()` method is called.
	var rootScreen: ScreenKey { get }

	/// Returns the root screen.
	func root() -> AnyView

	/// Builds the view for the given screen key.
	///
	/// - Parameters:
	///   - screen: The screen key to build.
	///   - router: The router to pass to the created view for further navigation.
	/// - Returns: The view representing the screen.
	func build(screen: ScreenKey, with router: any AssociatedRouter) -> any View

	/// Builds the modal for the given modal key.
	///
	/// - Parameter modal: The modal key to build.
	/// - Returns: A ``Modal`` instance describing the overlay content and transitions.
	func build(modal: ModalKey) -> any Modal
}

@MainActor
public extension RouteBuilder {
	func root() -> AnyView {
		AnyView(NavigationRoot(builder: self) { AnyView(build(screen: rootScreen, with: $0)) })
	}
}

@MainActor
public extension RouteBuilder where ModalKey == ModalNone {
	func build(modal: ModalKey) -> any Modal {
		fatalError("This router does not implement any modal.")
	}
}
