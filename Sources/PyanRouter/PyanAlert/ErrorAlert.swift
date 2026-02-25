//
//  ErrorAlert.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 27/02/2026.
//

import SwiftUI

/// A ready-made ``PyanAlert`` that displays an error's localized description.
///
/// `ErrorAlert` provides a quick way to surface errors to the user with no
/// custom actions -- only a default "Close" button.
///
/// ```swift
/// alert = ErrorAlert(error: someError)
/// ```
public struct ErrorAlert: PyanAlert {
	private let errorLocalizedDescription: String

	public let title: LocalizedStringKey = "Error"

	public var message: some View {
		Text(errorLocalizedDescription)
	}

	/// Creates an alert from the given error, using its `localizedDescription` as the message.
	public init(error: Error) {
		self.errorLocalizedDescription = error.localizedDescription
	}
}
