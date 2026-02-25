//
//  RouteBuilder+Previews.swift
//  PyanRouter
//
//  Created by Perceval Archimbaud on 25/02/2026.
//

import SwiftUI

#if DEBUG

@MainActor
public extension RouteBuilder {
	/// Returns a view suitable for Xcode Previews that builds and displays the given screen.
	///
	/// ```swift
	/// #Preview {
	///     MyBuilder().previewScreen(.home)
	/// }
	/// ```
	func previewScreen(_ screen: ScreenKey) -> some View {
		NavigationRoot(builder: self) {
			AnyView(build(screen: screen, with: $0))
		}
	}

	/// Returns a view suitable for Xcode Previews that presents the given modal.
	///
	/// The modal is automatically presented on appear. A draggable "Show Modal"
	/// button is overlaid so you can re-present the modal after dismissing it.
	///
	/// - Parameters:
	///   - modal: The modal key to preview.
	///   - screen: An optional screen to display behind the modal.
	///   - showButtonAlignment: The alignment of the re-show button. Pass `nil` to hide it.
	func previewModal(
		_ modal: ModalKey,
		over screen: ScreenKey? = nil,
		showButtonAlignment: Alignment? = .center
	) -> some View {
		NavigationRoot(builder: self) { router in
			ZStack {
				if let screen {
					AnyView(build(screen: screen, with: router))
				} else {
					Rectangle()
						.fill(.background)
						.ignoresSafeArea()
				}
				if let showButtonAlignment {
					PreviewModalButton(alignment: showButtonAlignment) {
						router.present(modal)
					}
				}
			}
			.onAppear { router.present(modal) }
		}
	}
}

struct PreviewModalButton: View {
	let alignment: Alignment
	let action: () -> Void

	@State private var offset: CGSize = .zero
	@State private var gestureOffset: CGSize = .zero
	@State private var isDragging: Bool = false

	private var totalOffset: CGSize {
		CGSize(
			width: offset.width + gestureOffset.width,
			height: offset.height + gestureOffset.height
		)
	}

	var body: some View {
		Button(action: action) {
			HStack {
				Image(systemName: "eye.square")
				Text(verbatim: "Show Modal")
			}
			.padding()
			.foregroundStyle(Color.white)
			.background(Color.accentColor)
			.clipShape(.buttonBorder)
			.font(.headline)
		}
		.disabled(isDragging)
		.buttonStyle(.plain)
		.shadow(radius: 10)
		.offset(totalOffset)
		.simultaneousGesture(
			DragGesture()
				.onChanged {
					isDragging = true
					gestureOffset = $0.translation
				}
				.onEnded { _ in
					offset = totalOffset
					gestureOffset = .zero
					isDragging = false
				}
		)
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
	}
}

#endif
