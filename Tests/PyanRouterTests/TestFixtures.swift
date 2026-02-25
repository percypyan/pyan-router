//
//  TestScreen.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 28/02/2026.
//

import Testing
import SwiftUI
import PyanRouter

// MARK: - Test Fixtures

enum TestScreen: @MainActor BuildableScreen {
    case home
    case detail
	#if !os(macOS)
    case coverScreen
	#endif
    case sheetScreen

    var segue: Segue {
        switch self {
		#if !os(macOS)
        case .coverScreen: return .fullScreenCover
		#endif
        case .sheetScreen: return .sheet
        default: return .push
        }
    }
}
enum TestModal: @MainActor BuildableModal {
    case info
    case confirm
}

@MainActor
struct TestModalImpl: Modal {
    var content: some View { EmptyView() }
}

@MainActor
struct ModalTestBuilder: @MainActor RouteBuilder {
    typealias ModalKey = TestModal

    let rootScreen: TestScreen = .home

    func build(screen: TestScreen, with router: any AssociatedRouter) -> any View {
        EmptyView()
    }

    func build(modal: TestModal) -> any Modal {
        TestModalImpl()
    }
}
