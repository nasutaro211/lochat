//
//  CameraViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift
import AVFoundation

class CameraViewController: BaseJoinedViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    var input:AVCaptureDeviceInput!
    var output:AVCaptureVideoDataOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    var imageView:UIImageView!
    var frameImageView:UIImageView!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var rotate:CGFloat = 0//上が上の時→0, 右が上の時→90, 左が上の時→270
    var audioPlayer: AVAudioPlayer!//シャッター音用
    var usableFrame: [Frame] = []
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()

        // 画面タップでピントをあわせる
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.tappedScreen(gestureRecognizer:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CameraViewController.pinchedGesture(gestureRecgnizer:)))
        // デリゲートをセット
        tapGesture.delegate = self
        // Viewにタップ、ピンチのジェスチャーを追加
        self.view.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(pinchGesture)

    }
    
    
    

    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupDisplay()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //カメラがなかったらアラート
        if camera == nil || input == nil{
            let alert = UIAlertController(title: "カメラへのアクセスが許可されていません", message: "設定 → プライバシー → カメラ からアクセスを許可してください", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    // メモリ解放
    override func viewDidDisappear(_ animated: Bool) {
        session.stopRunning()
        for output in session.outputs {session.removeOutput((output as? AVCaptureOutput)!)}
        for input in session.inputs {session.removeInput((input as? AVCaptureInput)!)}
        session = nil
        camera = nil
    }
    
    
    
    // sampleBufferからUIImageを作成 CMSampleBuffer → CVPixelBuffer → CIImage → CGImage → UIImage
    func captureImage(sampleBuffer:CMSampleBuffer) -> UIImage{
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage = self.convert(cmage: ciimage)
        return image
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage{
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    // タップイベント.
    @objc func tapedShutterButton() {
        let realm = try! Realm()
        
        takeStillPicture()
        self.imageView.alpha = 0.25
        UIView.animate(withDuration: 0.1, delay: 0.15, options: .curveEaseOut, animations: {
            self.imageView.alpha = 1
        }, completion: nil)
    }

    
    
    let focusView = UIView()
    @objc func tappedScreen(gestureRecognizer: UITapGestureRecognizer) {
        let tapCGPoint = gestureRecognizer.location(ofTouch: 0, in: gestureRecognizer.view)
        focusView.frame.size = CGSize(width: 120, height: 120)
        focusView.center = tapCGPoint
        focusView.backgroundColor = UIColor.white.withAlphaComponent(0)
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 2
        focusView.alpha = 1
        imageView.addSubview(focusView)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.focusView.frame.size = CGSize(width: 80, height: 80)
            self.focusView.center = tapCGPoint
        }, completion: { Void in
            UIView.animate(withDuration: 0.5, animations: {
                self.focusView.alpha = 0
            })
        })
        self.focusWithMode(focusMode: AVCaptureDevice.FocusMode.continuousAutoFocus, exposeWithMode: AVCaptureDevice.ExposureMode.autoExpose, atDevicePoint: tapCGPoint, motiorSubjectAreaChange: true)
    }
    
    
    
    var oldZoomScale: CGFloat = 1.0
    @objc func pinchedGesture(gestureRecgnizer: UIPinchGestureRecognizer) {
        do {
            try camera.lockForConfiguration()
            // ズームの最大値
            let maxZoomScale: CGFloat = 6.0
            // ズームの最小値
            let minZoomScale: CGFloat = 1.0
            // 現在のカメラのズーム度
            var currentZoomScale: CGFloat = camera.videoZoomFactor
            // ピンチの度合い
            let pinchZoomScale: CGFloat = gestureRecgnizer.scale
            // ピンチアウトの時、前回のズームに今回のズーム-1を指定
            // 例: 前回3.0, 今回1.2のとき、currentZoomScale=3.2
            if pinchZoomScale > 1.0 {
                currentZoomScale = oldZoomScale+pinchZoomScale-1
            } else {
                currentZoomScale = oldZoomScale-(1-pinchZoomScale)*oldZoomScale
            }
            // 最小値より小さく、最大値より大きくならないようにする
            if currentZoomScale < minZoomScale {
                currentZoomScale = minZoomScale
            }
            else if currentZoomScale > maxZoomScale {
                currentZoomScale = maxZoomScale
            }
            // 画面から指が離れたとき、stateがEndedになる。
            if gestureRecgnizer.state == .ended {
                oldZoomScale = currentZoomScale
            }
            camera.videoZoomFactor = currentZoomScale
            camera.unlockForConfiguration()
        } catch {
            // handle error
            return
        }
    }
    
    

    


    
    @objc func didOrientationChange(){
        let deviceOrientation: UIDeviceOrientation  = UIDevice.current.orientation
        rotate = updateRotate(deviceOrientation: deviceOrientation)
    }
    
    func updateRotate(deviceOrientation: UIDeviceOrientation) -> CGFloat{
        switch deviceOrientation {
        case UIDeviceOrientation.portrait:
            return 0
        case UIDeviceOrientation.landscapeLeft://下が左
            return 90
        case UIDeviceOrientation.landscapeRight://下が右
            return 270
        default:
            return rotate
        }
    }
    


    


    
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self //delegateが位置情報に関する変更などを担っている
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse{
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let now = Date()
        updateFrames(latitude: Float(latitude!), longitude: Float(longitude!))

    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
    }
    
    func updateFrames(latitude: Float, longitude: Float){
        var newUsableFrame: [Frame] = []
        let frames = Frame.returnMatchedFrames(lat: latitude, long: longitude)
//        print(frames)
        if !frames.isEmpty{
            frames.forEach { (frame) in
                newUsableFrame.append(frame)
            }
        }

        usableFrame = newUsableFrame
        //TODO: フロントをアップデートする機能もつける
        
    }
}





extension CameraViewController{
    
    func setupDisplay(){
        // カメラからの映像を映すimageViewの作成
        if let iv = imageView {
            //以前のimageViewがあれば剥がしておく(imageViewが残っていないか確認最初は入ってない)
            iv.removeFromSuperview()
        }
        if let fiv = frameImageView{
            fiv.removeFromSuperview()
        }
        imageView = UIImageView()
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
        frameImageView = UIImageView(image: UIImage(named: "spicts_frame001"))
        view.addSubview(frameImageView)
        frameImageView.snp.makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.left.equalTo(imageView)
            make.right.equalTo(imageView)
            make.bottom.equalTo(imageView)
        }
        frameImageView.contentMode = .scaleAspectFill
        //縦横比ちゃんとする
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        //TODO: サイズを治す
        imageView.snp.makeConstraints({(make)in
            make.width.equalTo(view).multipliedBy(0.9)
            make.centerX.equalTo(view)
            make.height.equalTo(imageView.snp.width)
            make.centerY.equalTo(view).offset(-70)
        })
        self.view.layoutIfNeeded()
    }
    
    
    func setupCamera(){
        // AVCaptureSession: キャプチャに関する入力と出力の管理
        session = AVCaptureSession()
        // sessionPreset: キャプチャ・クオリティの設定
        session.sessionPreset = .photo//
        // AVCaptureDevice: カメラやマイクなどのデバイスを設定
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            // 背面カメラを取得
            if caputureDevice.position == AVCaptureDevice.Position.back {
                camera = caputureDevice as? AVCaptureDevice
                print("true")
                break
            }
        }
        if camera == nil{
            //カメラが取れなかった時の処理
            self.view.backgroundColor = UIColor.white
            return;
        }
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
            return//TODO: カメラのアクセス許可をしていないとこの上のtryが失敗して, inputがnilとなり下でエラーになる
        }
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // AVCaptureVideoDataOutput:動画フレームデータを出力に設定
        output = AVCaptureVideoDataOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // ピクセルフォーマットを 32bit BGR + A とする
        output.videoSettings = nil
        //            [kCVPixelBufferPixelFormatTypeKey as AnyHashable as!
        //                String : Int(kCVPixelFormatType_32BGRA)]
        // フレームをキャプチャするためのサブスレッド用のシリアルキューを用意
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        //画面が90度回転してしまう対策
        let connection  = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        output.alwaysDiscardsLateVideoFrames = true
        
        
        session.startRunning()
        
        // deviceをロックして設定
        do {
            try camera.lockForConfiguration()
            // フレームレート
            camera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    
    
    
    // 新しいキャプチャの追加で呼ばれる
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        // キャプチャしたsampleBufferからUIImageを作成
        let image:UIImage = self.captureImage(sampleBuffer: sampleBuffer)
        // カメラの画像を画面に表示
        DispatchQueue.main.async() {
            self.imageView.image = image
        }
    }
    
    func takeStillPicture(){
        let realm = try! Realm()
        if var _:AVCaptureConnection? = output.connection(with: AVMediaType.video){
            // アルバムに追加
            let bottomImage = imageView.croppingImage()
            let topImage = frameImageView.croppingImage()
            var size = imageView.frame.size
            UIGraphicsBeginImageContext(size)
            let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            bottomImage.draw(in: areaSize)
            topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
            var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil)
            let imageManager = ImageManager()
            imageManager.send_to_flask(originImage: bottomImage, framedImage: newImage)
        }
    }
    
    func orientation()-> UIImage.Orientation{
        switch rotate {
        case 0:
            return UIImage.Orientation.up
        case 90:
            return UIImage.Orientation.left
        case 180:
            return UIImage.Orientation.down
        case 270:
            return UIImage.Orientation.right
        default:
            fatalError("rotate is something wrong")
            return UIImage.Orientation.up
        }
    }
    
    func focusWithMode(focusMode : AVCaptureDevice.FocusMode, exposeWithMode expusureMode :AVCaptureDevice.ExposureMode, atDevicePoint point:CGPoint, motiorSubjectAreaChange monitorSubjectAreaChange:Bool) {
        guard input != nil else {
            let alert = UIAlertController(title: "カメラへのアクセスが許可されていません", message: "設定 → プライバシー → カメラ からアクセスを許可してください", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            return
        }
        DispatchQueue(label: "session queue").async {
            let device : AVCaptureDevice = self.input.device
            
            do {
                try device.lockForConfiguration()
                if(device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode)){
                    device.focusPointOfInterest = point
                    device.focusMode = focusMode
                }
                if(device.isExposurePointOfInterestSupported && device.isExposureModeSupported(expusureMode)){
                    device.exposurePointOfInterest = point
                    device.exposureMode = expusureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
                
            } catch let error as NSError {
                print(error.debugDescription)
            }
            
        }
}
}





private extension UIImageView{
    //ImageViewに写っている部分のUIImageを返してくれるメソッド
    func croppingImage() -> UIImage {
        let cgImage = image!.cgImage!
        var rect:CGRect?
        //set rect
        switch self.contentMode {
        case .scaleAspectFill:
            if (CGFloat(cgImage.height)/CGFloat(cgImage.width) > frame.height/frame.width){
                //横にぴっちりして縦は空いている時
                rect = CGRect(x: 0, y: (CGFloat(cgImage.height)-CGFloat(cgImage.width)*self.frame.height/self.frame.width)/2, width: CGFloat(cgImage.width), height: CGFloat(cgImage.width)*self.frame.height/self.frame.width)
            }else{
                //縦にぴっちりして横は空いている時
                rect = CGRect(x: (CGFloat(cgImage.width)-CGFloat(cgImage.height)*self.frame.width/self.frame.height)/2, y: 0, width: CGFloat(cgImage.height)*self.frame.width/self.frame.height, height: CGFloat(cgImage.height))
            }
            break
        default:
            break
        }
        guard rect != nil else {
            fatalError("Didnt set rect")
        }
        let croppedCGImage = cgImage.cropping(to: rect!)!
        return UIImage(cgImage: croppedCGImage, scale: image!.scale, orientation: image!.imageOrientation)
    }
}
