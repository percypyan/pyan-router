//
//  Segue.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 06/02/2026.
//

/// The presentation style used when navigating to a ``BuildableScreen``.
public enum Segue {
	/// Pushes the screen onto the navigation stack.
	case push
	#if !os(macOS)
	/// Presents the screen as a full-screen cover.
	case fullScreenCover
	#endif
	/// Presents the screen as a sheet.
	case sheet
}
