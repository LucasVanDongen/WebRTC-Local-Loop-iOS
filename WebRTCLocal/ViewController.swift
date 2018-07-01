//
//  ViewController.swift
//  WebRTCLocalTest
//
//  Created by Lucas van Dongen on 29/06/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import WebRTC

protocol VideoViewHosting {
    var videoView: RTCVideoRenderer { get }
}

class ViewController: UIViewController, VideoViewHosting {

    @IBOutlet private var remoteVideo: UIView!
    @IBOutlet private var videoSizer: UIView! {
        didSet {
            guard let videoView = videoView as? UIView else {
                return assertionFailure("videoView is not a view")
            }

            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoSizer.addSubview(videoView)
            videoSizer.topAnchor.constraint(equalTo: videoView.topAnchor).isActive = true
            videoSizer.leadingAnchor.constraint(equalTo: videoView.leadingAnchor).isActive = true
            videoSizer.bottomAnchor.constraint(equalTo: videoView.bottomAnchor).isActive = true
            videoSizer.trailingAnchor.constraint(equalTo: videoView.trailingAnchor).isActive = true
        }
    }
    @IBOutlet private var localVideo: RTCCameraPreviewView!

    #if __aarch64__//#if RTC_SUPPORTS_METAL
    var videoView: RTCVideoRenderer = RTCMTLVideoView()
    #else
    lazy var videoView: RTCVideoRenderer = {
        let videoView = RTCEAGLVideoView()
        videoView.delegate = self
        return videoView
    }()
    #endif
    private static let senderTrackId = "Lucas1"
    private static let kARDMediaStreamId = "ARDAMS"
    private static let kARDAudioTrackId = "ARDAMSa0"
    private static let kARDVideoTrackId = "ARDAMSv0"
    private static let kARDVideoTrackKind = "video"


    private let factory = RTCPeerConnectionFactory()
    private let configuration = RTCConfiguration()
    private let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                                  optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
    private let audioConstraints = RTCMediaConstraints(mandatoryConstraints: [kRTCMediaConstraintsLevelControl: kRTCMediaConstraintsValueTrue],
                                                       optionalConstraints: nil)
    private lazy var sendingPeerConnectionDelegate = SendingPeerConnectionDelegate(connectingTo: remoteConnection)
    private lazy var receivingPeerConnectionDelegate = ReceivingPeerConnectionDelegate(connectingTo: self.localConnection,
                                                                                       displayingOn: videoView)
    private lazy var videoSource: RTCVideoSource = {
        factory.videoSource()
    }()
    private lazy var capturer: RTCCameraVideoCapturer = { RTCCameraVideoCapturer(delegate: videoSource) }()
    private lazy var videoTrack: RTCVideoTrack = {
        factory.videoTrack(with: videoSource, trackId: type(of: self).senderTrackId)
    }()
    private lazy var localConnection: RTCPeerConnection = {
        factory.peerConnection(with: configuration,
                               constraints: constraints,
                               delegate: nil)
    }()
    private lazy var remoteConnection: RTCPeerConnection = {
        factory.peerConnection(with: configuration,
                               constraints: constraints,
                               delegate: nil)
    }()
    private var capture: VideoCapture!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setup()
    }

    private func setupLocalFeed() {
        localVideo.captureSession = capturer.captureSession
        capture = VideoCapture(with: capturer)
        capture.start()
    }

    private func createMediaSenders() {
        localConnection.delegate = sendingPeerConnectionDelegate
        remoteConnection.delegate = receivingPeerConnectionDelegate
        let source = factory.audioSource(with: audioConstraints)
        let track = factory.audioTrack(with: source,
                                       trackId: type(of: self).kARDAudioTrackId)
        let stream = factory.mediaStream(withStreamId: type(of: self).kARDMediaStreamId)
        stream.addAudioTrack(track)
        stream.addVideoTrack(videoTrack)
        localConnection.add(stream)
    }

    private func setupPeerConnections() {
        localConnection.offer(for: RTCMediaConstraints(mandatoryConstraints: ["offerToReceiveAudio": "true", "offerToReceiveVideo": "true"],
                                                       optionalConstraints: nil),
                              completionHandler: offerCompleted(description:error:))
    }

    private func offerCompleted(description: RTCSessionDescription?,
                                error: Error?) {
        guard let description = description else {
            guard let error = error else {
                return assertionFailure("Neither description nor error were set")
            }

            return assertionFailure("An error occurred while offering the local connection:\n\n\(error)")
        }

        handle(localDescription: description)
    }

    private func setLocalCompleted(error: Error?) {
        if let error = error {
            return assertionFailure("Error setting local description: \(error)")
        }
    }

    private func setRemoteCompleted(error: Error?) {
        if let error = error {
            return assertionFailure("Error setting remote description: \(error)")
        }
    }

    private func answerCompleted(description: RTCSessionDescription?,
                                 error: Error?) {
        guard let description = description else {
            guard let error = error else {
                return assertionFailure("Neither description nor error were set")
            }

            return assertionFailure("An error occurred while creating an answer from the remote connection:\n\n\(error)")
        }

        handle(remoteDescription: description)
    }

    private func handle(localDescription: RTCSessionDescription) {
        print("setting local description of sending peer")
        localConnection.setLocalDescription(localDescription,
                                            completionHandler: setLocalCompleted)
        remoteConnection.setRemoteDescription(localDescription,
                                              completionHandler: setRemoteCompleted)
        print("remote connection aswering")
        remoteConnection.answer(for: constraints,
                                completionHandler: answerCompleted(description:error:))
    }

    private func handle(remoteDescription: RTCSessionDescription) {
        print("setting remote description of receiving peer")
        localConnection.setRemoteDescription(remoteDescription,
                                             completionHandler: setLocalCompleted)
        remoteConnection.setLocalDescription(remoteDescription,
                                             completionHandler: setRemoteCompleted)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocalFeed()
        createMediaSenders()
        setupPeerConnections()
    }
}

#if __aarch64__//#if RTC_SUPPORTS_METAL
#else
extension ViewController: RTCEAGLVideoViewDelegate {
    func videoView(_ videoView: RTCEAGLVideoView,
                   didChangeVideoSize size: CGSize) {
        let multiplier: CGFloat = size.height / size.width
        videoSizer.heightAnchor.constraint(equalTo: videoSizer.widthAnchor, multiplier: multiplier).isActive = true
    }
}
#endif

