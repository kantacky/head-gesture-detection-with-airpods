//
//  HeadphoneMotionView.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import SwiftUI

struct HeadphoneMotionView: View {
    @State private var manager = HeadphoneMotionManager()

    var body: some View {
        VStack {
            Text(manager.currentPose?.description ?? "No starting pose")

            Button("Reset Starting Pose") {
                manager.resetStartingPose()
            }
        }
        .padding()
        .onAppear {
            manager.startTracking()
        }
        .onDisappear {
            manager.stopTracking()
        }
    }
}

#Preview {
    HeadphoneMotionView()
}
