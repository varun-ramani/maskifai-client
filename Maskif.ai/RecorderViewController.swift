//
//  RecorderViewController.swift
//  Maskif.ai
//
//  Created by Matthew Shu on 11/9/20.
//

import UIKit

import AVFoundation

// Camera code adapted from @gwinyai at https://stackoverflow.com/a/41698917 and Apple's AVCam: Building a Camera App
// https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/avcam_building_a_camera_app
class RecorderViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    @IBOutlet var cameraPreviewView: UIView!
    @IBOutlet var recordButton: UIButton!

    let captureSession = AVCaptureSession()

    let movieOutput = AVCaptureMovieFileOutput()

    var previewLayer: AVCaptureVideoPreviewLayer!

    var activeInput: AVCaptureDeviceInput!

    var outputURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if setupSession() {
            setupPreview()
            startSession()
        }
        setUpButton()
    }

    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraPreviewView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewView.layer.addSublayer(previewLayer)
    }

    func setUpButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        let notRecordingImage = UIImage(systemName: "record.circle", withConfiguration: largeConfig)
        let isRecordingImage = UIImage(systemName: "record.circle.fill", withConfiguration: largeConfig)
        recordButton.setImage(notRecordingImage, for: .normal)
        recordButton.setImage(isRecordingImage, for: .selected)
        recordButton.tintColor = recordButton.isSelected ? .systemRed : .systemGray
    }
    // MARK: - Setup Camera

    func setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high

        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        return true
    }

    func setupCaptureMode(_ mode: Int) {
        // Video Mode
    }

    // MARK: - Camera Session

    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.stopRunning()
            }
        }
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation

        switch UIDevice.current.orientation {
            case .portrait:
                orientation = AVCaptureVideoOrientation.portrait
            case .landscapeRight:
                orientation = AVCaptureVideoOrientation.landscapeLeft
            case .portraitUpsideDown:
                orientation = AVCaptureVideoOrientation.portraitUpsideDown
            default:
                orientation = AVCaptureVideoOrientation.landscapeRight
        }

        return orientation
    }

    @IBAction func recordButtonTapped(_ sender: Any) {
        startRecording()
        recordButton.isSelected = !recordButton.isSelected
        recordButton.tintColor = recordButton.isSelected ? .systemRed : .systemGray
    }

    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString

        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }

        return nil
    }

    func startRecording() {
        if movieOutput.isRecording == false {
            let connection = movieOutput.connection(with: AVMediaType.video)

            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }

            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }

            let device = activeInput.device

            if device.isSmoothAutoFocusSupported {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        } else {
            stopRecording()
        }
    }

    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {}

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error recording movie: \(error!.localizedDescription)")

        } else {
            print("FINISHED RECORDING VIDEO")

//            let videoRecorded = outputURL! as URL
//            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
}
