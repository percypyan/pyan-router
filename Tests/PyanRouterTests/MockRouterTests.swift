import Testing
import SwiftUI
import PyanRouter

// MARK: - MockRouter Navigation

@MainActor
@Suite("MockRouter Navigation")
struct MockRouterNavigation {

    @Test("hasNavigated returns true after navigating to a screen")
    func hasNavigatedToScreen() {
		let router = ModalTestBuilder.AssociatedMockRouter()

        router.navigate(to: .home)

        #expect(router.hasNavigated(to: .home))
    }

    @Test("hasNavigated returns false for a screen not navigated to")
    func hasNavigatedReturnsFalseForOtherScreen() {
        let router = MockRouter<ModalTestBuilder>()

        router.navigate(to: .home)

        #expect(!router.hasNavigated(to: .detail))
    }

    @Test("hasNavigated with predicate matches correctly")
    func hasNavigatedWithPredicate() {
        let router = MockRouter<ModalTestBuilder>()

        router.navigate(to: .home)

        #expect(router.hasNavigated(where: { $0 == .home }))
        #expect(!router.hasNavigated(where: { $0 == .detail }))
    }

    @Test("navigationCount accumulates correctly")
    func navigationCountAccumulates() {
        let router = MockRouter<ModalTestBuilder>()

        router.navigate(to: .home)
        router.navigate(to: .home)
        router.navigate(to: .detail)

        #expect(router.navigationCount(to: .home) == 2)
        #expect(router.navigationCount(to: .detail) == 1)
		#if !os(macOS)
        #expect(router.navigationCount(to: .coverScreen) == 0)
		#endif
    }

    @Test("navigate calls completion")
    func navigateCallsCompletion() async {
        let router = MockRouter<ModalTestBuilder>()
        var called = false

		// This should be instantanious since completion is called synchronously
		// If this test ever gets stuck, that mean that something is wrong.
		// If the completion ever ends up call asynchronously, some timeout mechanism
		// should be established.
		await withCheckedContinuation { continuation in
			router.navigate(to: .home) {
				called = true
				continuation.resume()
			}
		}

        #expect(called)
    }
}

// MARK: - MockRouter Present

@MainActor
@Suite("MockRouter Present")
struct MockRouterPresent {

    @Test("hasPresented returns true after presenting a modal")
    func hasPresentedModal() {
        let router = MockRouter<ModalTestBuilder>()

        router.present(.info)

        #expect(router.hasPresented(modal: .info))
    }

    @Test("hasPresented returns false for a modal not presented")
    func hasPresentedReturnsFalseForOtherModal() {
        let router = MockRouter<ModalTestBuilder>()

        router.present(.info)

        #expect(!router.hasPresented(modal: .confirm))
    }

    @Test("hasPresented with predicate matches correctly")
    func hasPresentedWithPredicate() {
        let router = MockRouter<ModalTestBuilder>()

        router.present(.info)

        #expect(router.hasPresented(where: { $0 == .info }))
        #expect(!router.hasPresented(where: { $0 == .confirm }))
    }

    @Test("presentedCount accumulates correctly")
    func presentedCountAccumulates() {
        let router = MockRouter<ModalTestBuilder>()

        router.present(.info)
        router.present(.info)
        router.present(.confirm)

        #expect(router.presentedCount(modal: .info) == 2)
        #expect(router.presentedCount(modal: .confirm) == 1)
    }

    @Test("present calls completion")
    func presentCallsCompletion() async {
        let router = MockRouter<ModalTestBuilder>()
        var called = false

		// This should be instantanious since completion is called synchronously
		// If this test ever gets stuck, that mean that something is wrong.
		// If the completion ever ends up call asynchronously, some timeout mechanism
		// should be established.
		await withCheckedContinuation { continuation in
			router.present(.info, completion: {
				called = true
				continuation.resume()
			})
		}

        #expect(called)
    }
}

// MARK: - MockRouter Dismiss

@MainActor
@Suite("MockRouter Dismiss")
struct MockRouterDismiss {

    @Test("Each dismiss method records the correct type")
    func dismissRecordsCorrectType() {
        let router = MockRouter<ModalTestBuilder>()

		#expect(!router.hasDismissed(type: .screen))
        router.dismissScreen()
        #expect(router.hasDismissed(type: .screen))

		#if !os(macOS)
		#expect(!router.hasDismissed(type: .fullScreenCover))
        router.dismissFullScreenCover()
        #expect(router.hasDismissed(type: .fullScreenCover))
		#endif

		#expect(!router.hasDismissed(type: .sheet))
        router.dismissSheet()
        #expect(router.hasDismissed(type: .sheet))

		#expect(!router.hasDismissed(type: .modal))
        router.dismissModal()
        #expect(router.hasDismissed(type: .modal))

		#expect(!router.hasDismissed(type: .all))
        router.dismissAll()
        #expect(router.hasDismissed(type: .all))
    }

    @Test("dismissedCount accumulates correctly")
    func dismissedCountAccumulates() {
        let router = MockRouter<ModalTestBuilder>()

        router.dismissScreen()
        router.dismissScreen()
        router.dismissSheet()

        #expect(router.dismissedCount(type: .screen) == 2)
        #expect(router.dismissedCount(type: .sheet) == 1)
    }

    @Test("Different dismiss types do not cross-contaminate")
    func dismissTypesDoNotCrossContaminate() {
        let router = MockRouter<ModalTestBuilder>()

        router.dismissSheet()

        #expect(!router.hasDismissed(type: .screen))
        #expect(!router.hasDismissed(type: .fullScreenCover))
        #expect(!router.hasDismissed(type: .modal))
        #expect(!router.hasDismissed(type: .all))
    }

    @Test("Dismiss calls completion")
    func dismissCallsCompletion() async {
        let router = MockRouter<ModalTestBuilder>()
        var called = false

		// This should be instantanious since completion is called synchronously
		// If this test ever gets stuck, that mean that something is wrong.
		// If the completion ever ends up call asynchronously, some timeout mechanism
		// should be established.
		await withCheckedContinuation { continuation in
			router.dismissScreen(
				animation: .default
			) {
				called = true
				continuation.resume()
			}
		}

        #expect(called)
    }
}

// MARK: - MockRouter simulateLastModalClosing

@MainActor
@Suite("MockRouter simulateLastModalClosing")
struct MockRouterSimulateLastModalClosing {

    @Test("Invokes onClose callback")
    func invokesOnCloseCallback() throws {
        let router = MockRouter<ModalTestBuilder>()
        var closed = false

        router.present(.info, onClose: { closed = true })

        try router.simulateLastModalClosing()
        #expect(closed)
    }

    @Test("Invokes callbacks in LIFO order")
    func invokesCallbacksInLifoOrder() throws {
        let router = MockRouter<ModalTestBuilder>()
        var order: [Int] = []

        router.present(.info, onClose: { order.append(1) })
        router.present(.confirm, onClose: { order.append(2) })

        try router.simulateLastModalClosing()
        try router.simulateLastModalClosing()

        #expect(order == [2, 1])
    }

    @Test("Throws noModalPresented when no callbacks exist")
    func throwsWhenNoCallbacks() {
        let router = MockRouter<ModalTestBuilder>()

        #expect(throws: MockRouterError.noModalPresented) {
            try router.simulateLastModalClosing()
        }
    }
}

// MARK: - MockRouter Initial State

@MainActor
@Suite("MockRouter Initial State")
struct MockRouterInitialState {

    @Test("Fresh instance has default state")
    func freshInstanceHasDefaultState() {
        let router = MockRouter<ModalTestBuilder>()

        #expect(!router.showsFullScreenCover)
        #expect(!router.showsSheet)
    }
}

