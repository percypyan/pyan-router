//
//  AnyModal.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 25/02/2026.
//

import SwiftUI

struct AnyModal: Modal {
	let content: AnyView
	let background: Color

	let transition: AnyTransition
	let backgroundTransition: AnyTransition

	let animation: Animation

	init<Content: View>(
		background: Color = .black.opacity(0.6),
		transition: AnyTransition = .opacity,
		animation: Animation = .default,
		backgroundTransition: AnyTransition = .opacity.animation(.linear),
		content: @escaping () -> Content
	) {
		self.content = AnyView(content())
		self.background = background
		self.transition = transition
		self.animation = animation
		self.backgroundTransition = backgroundTransition
	}
}
