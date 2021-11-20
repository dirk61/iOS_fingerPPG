//
//  ContentView.swift
//  Trois-cam
//
//  Created by Joss Manger on 1/19/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import SwiftUI
import AVFoundation
import UIKit
import CoreLocation
import Photos
import CoreMotion
import SensorKit


let RTime = 90

var exp = ""
let ID2 = "01"
let ID = "fingerPPG/"
let metaID = "01/Meta"

let fingerName = "/PPG.mov"

let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String


var fingerURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + fingerName)


var frontdispatch: DispatchQueue = DispatchQueue(label: "Front")
var backdispatch: DispatchQueue = DispatchQueue(label: "Back")

struct MultiView: View{
    @State private var timeRemaining = RTime
    @State private var start = false
    @State private var selectedMode = "Auto"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let cameraSource = CameraController()
    
    @State var selectedIndex:Int? = nil
    
    var body: some View {
        VStack{
            
            Text("Selected:\(ExperimentStr)")
            Text("Selected:\(selectedMode)")
            HStack(spacing:0){
                
                ForEach(Array([Color.green].enumerated()),id: \.offset){   (index,value) in
                    CameraView(color: value, session: self.cameraSource.captureSession, index: index,selectedIndex:self.selectedIndex).frame(width: 216, height: 288, alignment: .center)
                    
                }
                
            }
            
            Button(action: {toggleTorch(on: true);},label:{Text("Flash")})
            Text("Time:\(timeRemaining)").padding()

        
            Button(action:{start = true;mkdirectory(ID);fingerURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + DateString() + ".mov");print(fingerURL);cameraSource.startRecord2();
                    },label:{Text("Start Survey")})
            //            Toggle("Start Survey", isOn: $start)
            
//            Spacer()
        }.padding().onReceive(timer){time in
            if self.timeRemaining > 0 && self.start{
                self.timeRemaining -= 1
                
                //                var dataqueue = DispatchQueue(label: "data" + String(self.timeRemaining))
                //                dataqueue.async {
                ////                    writeDepth(data: cameraSource.getdpth())
                //                    trueDepthCsvWriter?.writeField("1")
                //                    trueDepthCsvWriter?.finishLine()
                //                }
                
            }
            
            else if self.timeRemaining == 0{
                
                cameraSource.stopRecord2()
                
               
                self.timeRemaining -= 1

                start = false
                self.timeRemaining = RTime
                toggleTorch(on: false)
            }
        }
        
    }
}

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    
    if device.hasTorch {
        do {
            try device.lockForConfiguration()
            
            if on == true {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}

func manualISO()
{
    
    guard let device = AVCaptureDevice.default(.builtInTrueDepthCamera,for: .video, position: .front) else { return }
    
    
    do {
        try device.lockForConfiguration()
        device.exposureMode = .custom
//        device.exposureMode = .locked

        device.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: 50), iso: 100, completionHandler: nil)
        device.whiteBalanceMode = .locked
        
//        device.focusMode = .locked
        let fps60 = CMTimeMake(value: 1, timescale: 60)
        device.activeVideoMinFrameDuration = fps60;
        device.activeVideoMaxFrameDuration = fps60;
        
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
}

func lockfocus(){
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    
    do {
        try device.lockForConfiguration()
//        device.exposureMode = .locked
//        device.exposureMode = .custom
//        device.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: 50), iso: 100, completionHandler: nil)
//        device.whiteBalanceMode = .locked
        device.focusMode = .locked
        let fps60 = CMTimeMake(value: 1, timescale: 30)
        device.activeVideoMinFrameDuration = fps60;
        device.activeVideoMaxFrameDuration = fps60;
      
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
}

func manualISOBack()
{
    
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    
    
    do {
        try device.lockForConfiguration()
        device.exposureMode = .locked
//        device.exposureMode = .custom
//        device.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: 50), iso: 100, completionHandler: nil)
//        device.whiteBalanceMode = .locked
        device.focusMode = .locked
        let fps60 = CMTimeMake(value: 1, timescale: 30)
        device.activeVideoMinFrameDuration = fps60;
        device.activeVideoMaxFrameDuration = fps60;
      
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
}


func autoISOBack()
{
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    
    
    do {
        try device.lockForConfiguration()
        
        device.exposureMode = .continuousAutoExposure
        device.whiteBalanceMode = .continuousAutoWhiteBalance
        device.focusMode = .continuousAutoFocus
        
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
    
}

func printCameraSettings(){
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
//    do {
//        try device.lockForConfiguration()
//
//        device.exposureMode = .autoExpose
//        device.whiteBalanceMode = .continuousAutoWhiteBalance
//        device.focusMode = .autoFocus
//        device.unlockForConfiguration()
//    } catch {
//        print("Torch could not be used")
//    }
    
    print("expmode", device.exposureMode.rawValue)
    print("wbmode", device.whiteBalanceMode.rawValue)
    print("afmode", device.focusMode.rawValue)
    print("iso", device.iso)
    print("exp", device.exposureDuration)
    if #available(iOS 15.0, *) {
        print("", device.minimumFocusDistance)
    } else {
        // Fallback on earlier versions
    }
    print("focuspointof interest", device.focusPointOfInterest)
}

func collectAmbientLight(){
    if #available(iOS 14.0, *) {
        let ambient = SRSensor(rawValue: "ambientLightSensor")
        SRSensorReader.requestAuthorization(sensors: [.ambientLightSensor]) { error in
            print(error!)
        }
        let reader = SRSensorReader(sensor: ambient)
        print(reader.authorizationStatus)
        
        reader.startRecording()
        
    } else {
        // Fallback on earlier versions
    }
    
}



func mkdirectory(_ back:String){
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let docURL = URL(string: documentsDirectory)!
    let dataPath = docURL.appendingPathComponent(back)
    if !FileManager.default.fileExists(atPath: dataPath.path) {
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}

func DateString() -> String{
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "YY_MM_dd_mm_ss"
    
    return formatter.string(from: date)
}
