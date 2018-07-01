//
//  VideoCapture.swift
//  WebRTCLocalTest
//
//  Created by Lucas van Dongen on 01/07/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import WebRTC

class VideoCapture {
    private let capturer: RTCCameraVideoCapturer
    init(with capturer: RTCCameraVideoCapturer) {
        self.capturer = capturer
    }

    func start() {
        guard let device = RTCCameraVideoCapturer.captureDevices().first(where: { (device) -> Bool in
            device.position == .front
        }) else {
            return assertionFailure("This device has no front camera")
        }

        guard let format = RTCCameraVideoCapturer.supportedFormats(for: device).first else {
            return assertionFailure("No available formats")
        }

        let frameRate: Float64 = format.videoSupportedFrameRateRanges.reduce(0.0, { (result, range) -> Float64 in
            return range.maxFrameRate > result ? range.maxFrameRate : result
        })

        guard frameRate > 0.0 else {
            return assertionFailure("FPS should be larger than 0.0")
        }

        capturer.startCapture(with: device, format: format, fps: Int(frameRate))
    }

    func stop() {
        
    }
}
