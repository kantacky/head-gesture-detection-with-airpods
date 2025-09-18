//
//  HeadGestureScreen.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import RealityKit
import SwiftUI

struct HeadGestureScreen: View {
    @State private var presenter = HeadGesturePresenter()

    var body: some View {
        VStack(spacing: 16) {
            carousel

            cubes

            loggingButton

            resetStartingPoseButton

            Divider()

            Text("Motion: \(presenter.state.motion?.debugDescription ?? "Empty")")

            Divider()

            Text("Gesture: \(presenter.state.currentGesture.label)")
        }
        .onAppear {
            presenter.dispatch(.onAppear)
        }
        .onDisappear {
            presenter.dispatch(.onDisappear)
        }
        .padding(.vertical, 16)
    }

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(0..<10) { index in
                    Text(index.description)
                        .containerRelativeFrame(.horizontal)
                        .frame(maxHeight: .infinity)
                        .background(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $presenter.state.scrollPosition)
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 24)
        .frame(height: 120)
    }

    private var cubes: some View {
        RealityView { content in
            await presenter.dispatch(.makeRealityView)
            content.add(presenter.state.cubeLeft)
            content.add(presenter.state.cubeRight)
        }
    }

    private var loggingButton: some View {
        Button(presenter.state.isLogging ? "Stop Logging" : "Start Logging") {
            presenter.dispatch(.onLoggingButtonTapped)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
    }

    private var resetStartingPoseButton: some View {
        Button("Reset Starting Pose") {
            presenter.dispatch(.onResetStartingPoseButtonTapped)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
    }
}

#Preview {
    HeadGestureScreen()
}
