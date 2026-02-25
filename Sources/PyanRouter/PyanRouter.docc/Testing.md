# Testing with MockRouter

Verify navigation logic in unit tests without running the UI.

## Overview

``MockRouter`` is a test double that conforms to ``Router`` and records every
method call. It is available under `#if DEBUG` and lets you assert which
screens were navigated to, which modals were presented, and which dismiss
methods were called.

### Create a MockRouter

Instantiate `MockRouter` with the same builder type your production code uses:

```swift
let router = MockRouter<MyBuilder>()
```

You can also use the ``RouteBuilder/AssociatedMockRouter`` type alias:

```swift
let router = MyBuilder.AssociatedMockRouter()
```

### Assert navigation

After exercising the code under test, query the mock:

```swift
// Did we navigate to the detail screen?
#expect(router.hasNavigated(to: .detail(id: "42")))

// How many times did we navigate to home?
#expect(router.navigationCount(to: .home) == 1)

// Predicate-based matching for associated values
#expect(router.hasNavigated(where: { screen in
    if case .detail = screen { return true }
    return false
}))
```

### Assert modal presentation

```swift
#expect(router.hasPresented(modal: .confirmation))
#expect(router.presentedCount(modal: .confirmation) == 1)
```

Predicate-based overloads are also available:

```swift
#expect(router.hasPresented(where: { $0 == .confirmation }))
#expect(router.presentedCount(where: { $0 == .confirmation }) == 1)
```

### Assert dismissals

Use ``MockRouter/DismissType`` to check specific dismiss methods.

```swift
#expect(router.hasDismissed(type: .screen))
#expect(router.hasDismissed(type: .fullScreenCover))
#expect(router.dismissedCount(type: .all) == 0)
```

### Simulate modal closing

When production code passes an `onClose` callback to
``Router/present(_:animation:completion:onClose:)``,
you can trigger it from your test:

```swift
router.present(.confirmation, onClose: { didClose = true })
try router.simulateLastModalClosing()
#expect(didClose)
```

Callbacks are invoked in LIFO order -- the most recently presented modal's
callback fires first.
