# PyanRouter

A protocol-oriented, type-safe navigation library for SwiftUI.

## Overview

PyanRouter provides a thin abstraction over SwiftUI's `NavigationStack`, sheets, full-screen covers, and custom modal overlays. Navigation destinations and modals are declared as enum cases and mapped to views through a builder, giving you compile-time safety and a single place to wire up dependencies.

## Requirements

### Platform

- iOS 17.0+
- macOS 14.0+
- tvOS 17.0+
- watchOS 10.0+
- visionOS 1.0+

### Toolchain

- Swift 6.2+

## Installation

Add PyanRouter as a local package dependency in Xcode, or reference it in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/percypyan/PyanRouter.git", .upToNextMajor("0.1.0"))
]
```

## Quick Start

**1. Define screen keys**

```swift
enum MyScreen: BuildableScreen {
    case home
    case detail(id: String)
    case settings

    var segue: Segue {
        switch self {
        case .settings: .sheet
        default: .push
        }
    }
}
```

**2. Implement a RouteBuilder**

```swift
struct MyBuilder: RouteBuilder {
    let rootScreen: MyScreen = .home

    func build(screen: MyScreen, with router: any AssociatedRouter) -> any View {
        switch screen {
        case .home: HomeView(router: router)
        case .detail(let id): DetailView(id: id, router: router)
        case .settings: SettingsView(router: router)
        }
    }
}
```

**3. Display the root view**

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyBuilder().root()
        }
    }
}
```

**4. Navigate**

```swift
router.navigate(to: .detail(id: "42"))
router.present(.confirmation)
router.dismissAll()
```

## Testing

Use `MockRouter` to verify navigation logic in unit tests without running the UI:

```swift
let router = MyBuilder.AssociatedMockRouter()
// exercise code under test...
#expect(router.hasNavigated(to: .detail(id: "42")))
```

## AI disclaimer

The code of this package is **entirely human-written**.
However, AI has been used to _generate unit tests suites and documentation_. Every generated bit of code or
documentation has been **reviewed and approved by a human developer**.

## License

The repository use an MIT licence.

See [LICENSE](LICENSE.md) file for details.
