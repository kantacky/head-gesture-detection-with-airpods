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
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(0..<10) { index in
                        Text(index.description)
                            .containerRelativeFrame(.horizontal)
                            .frame(maxHeight: .infinity)
                            .background(.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $presenter.state.scrollPosition)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 24)
            .frame(height: 120)

            RealityView { content in
                await presenter.dispatch(.makeRealityView)
                content.add(presenter.state.cubeLeft)
                content.add(presenter.state.cubeRight)
            }

            HeadGestureChartView(motionLogs: presenter.state.motionLogs)
                .padding()

            Button(presenter.state.isLogging ? "Stop Logging" : "Start Logging") {
                presenter.dispatch(.onLoggingButtonTapped)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .padding()

            Button("Reset Starting Pose") {
                presenter.dispatch(.onResetStartingPoseButtonTapped)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .padding()
        }
        .onAppear {
            presenter.dispatch(.onAppear)
        }
        .onDisappear {
            presenter.dispatch(.onDisappear)
        }
    }
}

#Preview {
    HeadGestureScreen()
}
