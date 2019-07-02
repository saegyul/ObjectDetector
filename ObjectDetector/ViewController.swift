//
//  ViewController.swift
//  ObjectDetector
//
//  Created by Youngsang Yun on 7/1/19.
//  Copyright © 2019 Youngsang Yun. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!

    var tempCnt = 0
    
    @IBOutlet weak var videoPreview: UIImageView!
    @IBOutlet weak var detectedObj: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        beginCapturing()
    }

    func beginCapturing() {
        captureSession.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return  }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
            
        captureSession.addInput(captureInput)
       
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame
  /*
        self.videoPreview.layer.addSublayer(AVCaptureVideoPreviewLayer(session: captureSession))
        self.videoPreview.frame = self.videoPreview.layer.frame
        */
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.yyun.objectDetector"))
        captureSession.addOutput(dataOutput)
        
//        let requests = VNCoreMLRequest(model: <#T##VNCoreMLModel#>, completionHandler: <#T##VNRequestCompletionHandler?##VNRequestCompletionHandler?##(VNRequest, Error?) -> Void#>)
//        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: <#T##[VNImageOption : Any]#>).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
//
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//       print("cnt is \(tempCnt) ")
//        if (tempCnt % 100 == 0) {
//            let date = Date()
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            let datestr = dateFormatter.string(from: date)
//            print("image is captured \(datestr)")
//
//            //self.detectedObj.text = Date().description
//            detectedObj.text = datestr
//
//        }
       tempCnt += 1
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("CP1")
            return  }
//        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {

            print("CP2")
            return }
        
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            //
//            print(finishedReq.results ?? "Unknown Result" )
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else { return }
            print (firstObservation.identifier,firstObservation.confidence  )
//            self.detectedObj.text = firstObservation.identifier
//            self.accuracy.text = String(firstObservation.confidence) + "%"
            DispatchQueue.main.async {
                self.detectedObj.text = firstObservation.identifier
                self.accuracy.text = "\(round(firstObservation.confidence*100)) %"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}

