//
//  FeatureHintOverlay.swift
//  153PexfarkarzeNifla
//

import SwiftUI

struct FeatureHintOverlay: ViewModifier {
    @ObservedObject var data: DesignDataManager
    let hintID: FeatureHintID

    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                visible = !data.isHintDismissed(hintID)
            }
            .overlay {
                if visible {
                    ZStack {
                        Color.appBackground.opacity(0.92)
                            .ignoresSafeArea()
                        VStack(alignment: .leading, spacing: 14) {
                            Text(hintID.title)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                                .appLabelStyle()
                            Text(hintID.message)
                                .font(.body)
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Button(action: dismiss) {
                                Text("Got it")
                                    .appLabelStyle()
                                    .foregroundStyle(Color.appTextOnVibrant)
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 44)
                                    .appPrimaryActionBackground(cornerRadius: 14)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(20)
                        .appSurfaceCard(cornerRadius: 20)
                        .padding(.horizontal, 20)
                    }
                    .transition(AnyTransition.opacity.combined(with: AnyTransition.scale(scale: 0.96)))
                    .animation(AppAnimations.spring, value: visible)
                }
            }
    }

    private func dismiss() {
        data.dismissHint(hintID)
        withAnimation(AppAnimations.easeInOutShort) {
            visible = false
        }
    }
}

extension View {
    func featureHintOverlay(_ hintID: FeatureHintID, data: DesignDataManager) -> some View {
        modifier(FeatureHintOverlay(data: data, hintID: hintID))
    }
}
