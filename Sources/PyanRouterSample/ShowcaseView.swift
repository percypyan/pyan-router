//
//  ShowcaseView.swift
//  PyanRouterSample
//
//  Created by Perceval Archimbaud on 05/02/2026.
//

import SwiftUI
import PyanRouter

enum ShowcaseError: LocalizedError {
	case showcase

	var errorDescription: String? {
		return "Some showcase error"
	}
}

struct ShowcaseView: View {
	let title: String
	let router: any SampleBuilder.AssociatedRouter

	@State private var animated: Bool = true
	@State private var dismissAnimationSequence: DismissAnimationSequence = .sheetsAndCovers

	@State private var alert: (any PyanAlert)? = nil
	@State private var confirmationDialog: (any ConfirmationDialog)? = nil

	private var animation: Animation? { animated ? .default : nil }

    var body: some View {
		List {
			optionSection
			seguesSection
			modalSection
			alertAndDialogSection
			dismissSection
		}
		.navigationTitle(title)
		.presentationDetents([.medium])
		.interactiveDismissDisabled()
    }

	private var optionSection: some View {
		Section {
			Toggle("Animated", isOn: $animated)
			Picker("Dismiss sequence", selection: $dismissAnimationSequence) {
				Text("Covering only").tag(DismissAnimationSequence.sheetsAndCovers)
				Text("All at once").tag(DismissAnimationSequence.allAtOnce)
			}
		} header: {
			Text("Options")
		}
	}

	private var seguesSection: some View {
		Section {
			loggedButton(label: "Push") {
				router.navigate(to: .showcase, animation: animation, completion: $0)
			}
			#if !os(macOS)
			loggedButton(label: "Full screen cover") {
				router.navigate(to: .showcaseCover(title: "Cover showcase"), animation: animation, completion: $0)
			}
			#endif
			loggedButton(label: "Sheet") {
				router.navigate(to: .showcaseSheet(title: "Sheet showcase"), animation: animation, completion: $0)
			}
			loggedButton(label: "Dismiss screen") {
				router.dismissScreen(animation: animation, completion: $0)
			}
			.tint(.red)
		} header: {
			Text("Segues")
		}
	}

	private var modalSection: some View {
		Section {
			loggedButton(label: "Present") {
				router.present(.showcase, animation: animation, completion: $0) {
					print("Modal closed.")
				}
			}
		} header: {
			Text("Modal")
		}
	}

	private var alertAndDialogSection: some View {
		Section {
			Button("Show alert") {
				alert = ShowcaseAlert()
			}
			.alert($alert)
			Button("Show error alert") {
				alert = ErrorAlert(error: ShowcaseError.showcase)
			}
			Button("Show basic confirmation dialog") {
				confirmationDialog = BasicConfirmationDialog(onConfirmation: {})
			}
			.confirmationDialog($confirmationDialog)
		} header: {
			Text("Alert & Dialog")
		}
	}

	private var dismissSection: some View {
		Section {
			loggedButton(label: "Dismiss") {
				router.dismiss(animation: animation, completion: $0)
			}
			#if !os(macOS)
			loggedButton(label: "Dismiss full screen cover") {
				router.dismissFullScreenCover(animation: animation, completion: $0)
			}
			#endif
			loggedButton(label: "Dismiss sheet") {
				router.dismissSheet(animation: animation, completion: $0)
			}
			loggedButton(label: "Dismiss all") {
				router.dismissAll(animation: animation, animationSequence: dismissAnimationSequence, completion: $0)
			}
		} header: {
			Text("Dismisses")
		}
	}

	private func loggedButton(label: String, action: @escaping (@escaping () -> Void) -> Void) -> some View {
		Button(label) {
			let prefix = !animated ? "[NO ANIMATION] " : ""
			let startAt = Date.now
			print("\(prefix)\(label) started...")
			action {
				let duration = Int(Date.now.timeIntervalSince(startAt) * 1_000_000) / 100
				print("\(prefix)\(label) completed in \(duration) ms.")
			}
		}
	}
}

#Preview {
	SampleBuilder()
		.previewScreen(.showcase)
}
