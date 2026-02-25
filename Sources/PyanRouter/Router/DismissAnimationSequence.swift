//
//  DismissAnimationSequence.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 28/02/2026.
//

/// Controls how ``Router/dismissAll(animation:animationSequence:completion:)`` unwinds
/// nested sheets and full-screen covers.
public enum DismissAnimationSequence {
	/// Each sheet and cover is dismissed sequentially with its own animation.
	case sheetsAndCovers
	/// All presentations are torn down in a single animation pass.
	case allAtOnce
}
