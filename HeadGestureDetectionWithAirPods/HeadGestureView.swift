//
//  HeadGestureView.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import RealityKit
import SwiftUI

struct HeadGestureView: View {
    @State private var presenter = HeadGesturePresenter()

    var body: some View {
        VStack {
            RealityView { content in
                await presenter.dispatch(.makeRealityView)
                content.add(presenter.state.cubeLeft)
                content.add(presenter.state.cubeRight)
            }

            Button("Reset Starting Pose") {
                presenter.dispatch(.onResetStartingPoseButton)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .padding()
        .onAppear {
            presenter.dispatch(.onAppear)
        }
        .onDisappear {
            presenter.dispatch(.onDisappear)
        }
    }
}

#Preview {
    HeadGestureView()
}
