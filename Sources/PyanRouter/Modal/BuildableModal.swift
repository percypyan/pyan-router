//
//  BuildableModal.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 27/02/2026.
//

import SwiftUI

/// A protocol that modal enum cases must conform to.
///
/// Each case in your modal enum represents a distinct modal overlay that can
/// be presented via ``Router/present(_:animation:completion:onClose:)``.
///
/// ```swift
/// enum MyModal: BuildableModal {
///     case confirmation
///     case share
/// }
/// ```
@MainActor
public protocol BuildableModal: Hashable, Identifiable {}

@MainActor
public extension BuildableModal {
	var id: Int { self.hashValue }
}
