//
//  ModalNone.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 25/02/2026.
//

/// A placeholder type used as the default ``RouteBuilder/ModalKey`` when a module has no modals.
///
/// Because the enum has no cases, presenting a modal on a builder using
/// `ModalNone` will trigger a fatal error at runtime.
@MainActor
public enum ModalNone: @MainActor BuildableModal {}
