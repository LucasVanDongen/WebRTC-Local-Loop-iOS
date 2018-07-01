//
//  BasePeerConnectionDelegate.swift
//  WebRTCLocalTest
//
//  Created by Lucas van Dongen on 01/07/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import WebRTC

class BasePeerConnectionDelegate: NSObject {

    let otherPeerConnection: RTCPeerConnection
    init(connectingTo theOtherPeerConnection: RTCPeerConnection) {
        otherPeerConnection = theOtherPeerConnection
    }

    func onIceCandidate(peerConnection: RTCPeerConnection,
                        candidate: RTCIceCandidate) {
        otherPeerConnection.add(candidate)
    }
}

extension BasePeerConnectionDelegate: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange stateChanged: RTCSignalingState) {

    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didAdd stream: RTCMediaStream) {

    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove stream: RTCMediaStream) {

    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {

    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceConnectionState) {

    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceGatheringState) {
        print("SendingPeerConnection changed state to: \(newState)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didGenerate candidate: RTCIceCandidate) {
        otherPeerConnection.add(candidate)
        let candidateLocationDescription = candidate.serverUrl.map { "ICE candidate from \($0)" } ?? "local ICE candidate"
        print("SendingPeerConnection added \(candidateLocationDescription): \(candidate.sdp)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove candidates: [RTCIceCandidate]) {

    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didOpen dataChannel: RTCDataChannel) {

    }
}
