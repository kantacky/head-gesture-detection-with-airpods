//
//  HeadGestureView.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import SwiftUI

struct HeadGestureView: View {
    @State private var presenter = HeadGesturePresenter()

    var body: some View {
        VStack {
            Text(presenter.state.currentPose?.description ?? "No current pose")

            Button("Reset Starting Pose") {
                presenter.dispatch(.onResetStartingPoseButton)
            }
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
