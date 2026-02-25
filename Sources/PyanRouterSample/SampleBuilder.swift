//
//  SampleBuilder.swift
//  PyanRouterSample
//
//  Created by Perceval Archimbaud on 24/02/2026.
//

import SwiftUI
import PyanRouter

// MARK: - Screen enum

// A Screen enumation that list all possible destinations
enum SampleScreen: @MainActor BuildableScreen {
	case showcase
	case showcaseSheet(title: String = "Sheet")

	#if !os(macOS)
	case showcaseCover(title: String = "Cover")
	#endif

	var segue: Segue {
		return switch self {
		case .showcaseSheet: .sheet
		#if !os(macOS)
		case .showcaseCover: .fullScreenCover
		#endif
		default: .push
		}
	}
}

// MARK: - Modal enum

// A Modal enumation that list all presentable modals
enum SampleModal: @MainActor BuildableModal {
	case showcase
}

// MARK: - RouteBuilder protocol

// A RouteBuilder that is in charge of building screens and modal from enum cases.
// That is here that you will gather and inject dependencies for your screens and modal.
// You also define here a root screen.
@MainActor
struct SampleBuilder: @MainActor RouteBuilder {
	// Defines the root screen for this builder
	let rootScreen: SampleScreen = .showcase

	func build(screen: SampleScreen, with router: any AssociatedRouter) -> any View {
		return switch screen {
		case .showcase:
			ShowcaseView(title: "Showcase", router: router)
		case .showcaseSheet(let title):
			ShowcaseView(title: title, router: router)
		#if !os(macOS)
		case .showcaseCover(let title):
			ShowcaseView(title: title, router: router)
		#endif
		}
	}

	func build(modal: SampleModal) -> any Modal {
		return switch modal {
		case .showcase:
			ShowcaseModal()
		}
	}
}
