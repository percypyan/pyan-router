//
//  AnyDestination.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 06/02/2026.
//

import SwiftUI

struct AnyDestination: Identifiable {
	let id: UUID = UUID()
	let content: () -> AnyView

	init<Content: View>(@ViewBuilder content: @escaping () -> Content) {
		self.content = { AnyView(content()) }
	}
}

extension AnyDestination: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
		return lhs.id == rhs.id
	}
}
