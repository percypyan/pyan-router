# Getting Started with PyanRouter

Set up type-safe navigation in a SwiftUI module.

## Overview

This guide walks you through the three steps needed to add PyanRouter-based
navigation to a feature module: defining screen keys, defining modal keys
(optional), and implementing a route builder.

### Define your screen keys

Create an enum conforming to ``BuildableScreen``. Each case represents a
navigable destination. Override ``BuildableScreen/segue`` to control how a
screen is presented -- the default is ``Segue/push``.

```swift
enum MyScreen: BuildableScreen {
    case home
    case detail(id: String)
    case settings // presented as a sheet

    var segue: Segue {
        switch self {
        case .settings: .sheet
        default: .push
        }
    }
}
```

### Define your modal keys (optional)

If your module presents custom modal overlays, create an enum conforming to
``BuildableModal``.

```swift
enum MyModal: BuildableModal {
    case confirmation
    case share(item: URL)
}
```

Then implement each modal by conforming to the ``Modal`` protocol. You can
customise the `transition`, `backgroundTransition`, `animation`, and
`background` color (all have sensible defaults):

```swift
struct ConfirmationModal: Modal {
    let transition: AnyTransition = .move(edge: .bottom)
    let animation: Animation = .bouncy

    var content: some View {
        Text("Are you sure?")
            .padding()
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
    }
}
```

### Implement a RouteBuilder

The ``RouteBuilder`` maps keys to views. It also declares the root screen.
If your module has no modals you can omit the `ModalKey` associated type and
`build(modal:)` -- both default to ``ModalNone``.

```swift
struct MyBuilder: RouteBuilder {
    let rootScreen: MyScreen = .home

    func build(screen: MyScreen, with router: any AssociatedRouter) -> any View {
        switch screen {
        case .home:
            HomeView(router: router)
        case .detail(let id):
            DetailView(id: id, router: router)
        case .settings:
            SettingsView(router: router)
        }
    }

    func build(modal: MyModal) -> any Modal {
        switch modal {
        case .confirmation:
            ConfirmationModal()
        case .share(let item):
            ShareModal(item: item)
        }
    }
}
```

### Display the root view

Call ``RouteBuilder/root()`` to obtain a `NavigationRoot` view configured with
your builder's root screen:

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

### Navigate from your views

Views receive a router via their initializer. Use it to push screens, present
modals, or dismiss:

```swift
struct HomeView: View {
    let router: any MyBuilder.AssociatedRouter

    var body: some View {
        Button("Open Detail") {
            router.navigate(to: .detail(id: "42"))
        }
        Button("Show Confirmation") {
            router.present(.confirmation)
        }
    }
}
```

### Dismiss screens and modals

The router provides granular dismiss methods:

```swift
router.dismissScreen()           // pops or dismisses the topmost screen
router.dismissFullScreenCover()  // dismisses the current full-screen cover
router.dismissSheet()            // dismisses the current sheet
router.dismissModal()            // dismisses the current modal overlay
router.dismissAll()              // unwinds the entire navigation stack
```

``Router/dismissAll(animation:animationSequence:completion:)`` accepts a
``DismissAnimationSequence`` to control how nested sheets and covers are
dismissed:

- ``DismissAnimationSequence/sheetsAndCovers`` (default) -- each sheet and
  cover is dismissed with its own animation sequentially.
- ``DismissAnimationSequence/allAtOnce`` -- everything is torn down in a single
  animation pass.

Every method also accepts an optional `animation` and `completion` closure.

### Chain navigation after a dismiss

Dismiss completion closures receive the *resulting router* -- the router that
becomes the active navigation context once the dismissal finishes. You can use
it to immediately start a new navigation action:

```swift
router.dismissSheet { router in
    router.navigate(to: .detail(id: "42"))
}
```

This is useful when you need to dismiss the current presentation and navigate
somewhere else in a single gesture. Because the resulting router points to the
correct navigation context (for example the parent router after dismissing a
sheet), you do not need to keep a manual reference to it.

### Use alerts and confirmation dialogs

PyanRouter provides lightweight wrappers for SwiftUI alerts and confirmation
dialogs. Store a ``PyanAlert`` or ``ConfirmationDialog`` in a `@State` binding
and attach the corresponding view modifier:

```swift
@State private var alert: (any PyanAlert)? = nil

MyView()
    .alert($alert)
```

Use ``ErrorAlert`` for a quick error display, or ``BasicConfirmationDialog`` for
a simple continue/cancel prompt.

### Preview screens and modals

In `#Preview` blocks, the builder provides convenience methods:

```swift
#Preview {
    MyBuilder().previewScreen(.home)
}

#Preview("Confirmation Modal") {
    MyBuilder().previewModal(.confirmation)
}
```
