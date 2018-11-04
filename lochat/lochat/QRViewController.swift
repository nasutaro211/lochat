//
//  QRViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import RealmSwift

class QRViewController: UIViewController {
    var dismissButton = UIButton()
    var joiningEvent:Event?
    
    //カメラ周り
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        setLayouts()
        setUIsConfig()
        setCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @objc func myDissmiss(){
        self.dismiss(animated: true, completion: nil)
    }
}


extension QRViewController:AVCaptureMetadataOutputObjectsDelegate {
    func setCamera(){
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        joiningEvent = Event(eventURL: code)
        let realm = try! Realm()
        try! realm.write {
            realm.add(joiningEvent!)
        }
        segueToCameraView()
    }
    
    func segueToCameraView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabJoiningViewController = storyboard.instantiateViewController(withIdentifier: "TabJoiningViewController") as! UITabBarController
        tabJoiningViewController.selectedIndex = 1
        self.present(tabJoiningViewController, animated: true, completion: nil)
    }
    
    func afterFailedToOpen(){
        let alert = UIAlertController(title: "おっと君は開けないよ", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

//UIセット用
extension QRViewController{
    func addViews(){
        self.view.addSubview(dismissButton)
    }

    func setLayouts(){
        dismissButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-15)
        }
    }
    
    func setUIsConfig(){
        dismissButton.setImage(UIImage(named: "peke"), for: .normal)
        dismissButton.addTarget(self, action: #selector(self.myDissmiss), for: .touchUpInside)
    }
}
