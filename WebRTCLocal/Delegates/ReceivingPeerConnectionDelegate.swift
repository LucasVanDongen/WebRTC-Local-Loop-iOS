//
//  ReceivingPeerConnectionDelegate.swift
//  WebRTCLocalTest
//
//  Created by Lucas van Dongen on 01/07/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import WebRTC

class ReceivingPeerConnectionDelegate: BasePeerConnectionDelegate {
    private let renderer: RTCVideoRenderer
    private var stream: RTCMediaStream?
    init(connectingTo theOtherPeerConnection: RTCPeerConnection,
                  displayingOn renderer: RTCVideoRenderer) {
        self.renderer = renderer
        super.init(connectingTo: theOtherPeerConnection)
    }

    override func peerConnection(_ peerConnection: RTCPeerConnection,
                                 didAdd stream: RTCMediaStream) {
        guard let videoTrack = stream.videoTracks.first else {
            return assertionFailure("Should contain at least one video track!")
        }

        if let previousStream = self.stream {
            print("removed renderer from previous stream")
            previousStream.videoTracks.first?.remove(renderer)
        }

        self.stream = stream
        print("adding videotrack to renderer")
        videoTrack.add(renderer)
    }
}
