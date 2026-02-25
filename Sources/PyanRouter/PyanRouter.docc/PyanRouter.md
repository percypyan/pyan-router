# ``PyanRouter``

A protocol-oriented, type-safe navigation library for SwiftUI.

## Overview

PyanRouter provides a thin abstraction over SwiftUI's `NavigationStack`, sheets,
full-screen covers, and custom modal overlays. Navigation destinations and modals
are declared as enum cases and mapped to views through a builder, giving you
compile-time safety and a single place to wire up dependencies.

The library also ships lightweight protocols for alerts and confirmation dialogs,
plus a ``MockRouter`` for unit testing.

### Key Concepts

- **Screen keys** -- enum cases conforming to ``BuildableScreen`` that list every
  navigable destination. Each case specifies a ``Segue`` (push, sheet, or
  full-screen cover).
- **Modal keys** -- enum cases conforming to ``BuildableModal`` that list every
  presentable modal overlay.
- **Route builder** -- a ``RouteBuilder`` implementation that maps screen and
  modal keys to their concrete views.
- **Router** -- the ``Router`` protocol through which views trigger navigation
  and dismissal. At runtime, ``NavigationRoot`` is the concrete implementation.
- **Dismiss animation sequence** -- ``DismissAnimationSequence`` controls how
  ``Router/dismissAll(animation:animationSequence:completion:)`` unwinds nested
  sheets and covers (one-by-one or all at once).

## Topics

### Essentials

- <doc:GettingStarted>
- ``RouteBuilder``
- ``Router``

### Screens

- ``BuildableScreen``
- ``Segue``

### Modals

- ``BuildableModal``
- ``Modal``
- ``ModalNone``

### Alerts and Dialogs

- ``PyanAlert``
- ``ErrorAlert``
- ``ConfirmationDialog``
- ``BasicConfirmationDialog``

### Navigation

- ``NavigationRoot``
- ``DismissAnimationSequence``

### Testing

- <doc:Testing>
- ``MockRouter``
- ``MockRouterError``
