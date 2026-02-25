//
//  ShowcaseModal.swift
//  PyanRouterSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanRouter

struct ShowcaseModal: Modal {
	let transition: AnyTransition = .move(edge: .leading)
	let animation: Animation = .bouncy

	var content: some View {
		VStack {
			Text("Showcase Modal")
				.font(.headline)
				.padding()
				.foregroundStyle(.black)
				.background(.white)
				.clipShape(.rect(cornerRadius: 16))
		}
	}
}

#Preview {
	SampleBuilder()
		.previewModal(.showcase)
}
