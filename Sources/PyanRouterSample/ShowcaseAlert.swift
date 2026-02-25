//
//  ShowcaseAlert.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 27/02/2026.
//

import SwiftUI
import PyanRouter

struct ShowcaseAlert: PyanAlert {	
	let title: LocalizedStringKey = "Showcase Alert"

	var message: some View {
		Text("This alert is showcasing the alert option of this module")
	}

	// Since we did not defined any actions, a default closing option will be added.
}
