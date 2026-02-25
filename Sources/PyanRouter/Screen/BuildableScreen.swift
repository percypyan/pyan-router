//
//  BuildableScreen.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 25/02/2026.
//

import SwiftUI

/// A protocol that screen enum cases must conform to.
///
/// Each case in your screen enum represents a distinct destination. The
/// ``segue`` property controls how the screen is presented (push, sheet, or
/// full-screen cover). The default segue is ``Segue/push``.
///
/// ```swift
/// enum MyScreen: BuildableScreen {
///     case home
///     case settings
///     case profile // presented as a sheet
///
///     var segue: Segue {
///         switch self {
///         case .profile: .sheet
///         default: .push
///         }
///     }
/// }
/// ```
@MainActor
public protocol BuildableScreen: Hashable, Identifiable {
	/// The presentation style used when navigating to this screen.
	var segue: Segue { get }
}

@MainActor
public extension BuildableScreen {
	var id: Int { self.hashValue }
	/// Defaults to ``Segue/push``.
	var segue: Segue { .push }
}
