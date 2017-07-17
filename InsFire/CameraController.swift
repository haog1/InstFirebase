//
//  CameraController.swift
//  InsFire
//
//  Created by TG on 13/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupCaptureButtons()
    }
    
    fileprivate func setupCaptureButtons() {
        view.addSubview(captureButton)
        view.addSubview(dismissButton)
        
        captureButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    
    }
    
    let output = AVCapturePhotoOutput()

    
    func handleCapturePhoto() {
        
        let settings  = AVCapturePhotoSettings()
        
        output.capturePhoto(with: settings, delegate: self)
        
    }

    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        print("finish processing photo sample buffer")
        
    }
    
    
    
    fileprivate func setupCaptureSession() {

        let captureSession = AVCaptureSession()

        
        // 1. setup input
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

        } catch let err {
            print("Could not setup camera input: ", err)
        }

        // 2. setup output
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // 3. setup output preview
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }

        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
}




