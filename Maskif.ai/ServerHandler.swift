//
//  ServerHandler.swift
//  Maskif.ai
//
//  Created by Simon Chervenak on 11/10/20.
//

import Foundation
import SocketIO
import AVFoundation
import UIKit

var NGROK_URL = "" // https://7aac9c19543f.ngrok.io

// code translated from https://stackoverflow.com/a/6197348/6342812
// help from https://stackoverflow.com/questions/42997462/convert-cmsamplebuffer-to-uiimage
func imageBufferToData(_ source: CMSampleBuffer) -> Data {
    let ciimage = CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(source)!)
    return UIImage(cgImage: CIContext(options: nil).createCGImage(ciimage, from: ciimage.extent)!).pngData()!
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

class ServerHandler {
    var socket: SocketIOClient!
    var manager: SocketManager!
  
    static let shared: ServerHandler = ServerHandler()
    static var connected = false
    var received = true
    
    var last_sent = Date()
  
  private init() {
//    connect()
  }
  
  func connect(completion: @escaping () -> Void) {
    print("called connect")
    if !ServerHandler.connected && NGROK_URL != "" {
        print("hi")
        manager = SocketManager(socketURL: URL(string: NGROK_URL)!, config: [.compress])
        socket = manager.defaultSocket

        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            ServerHandler.connected = true
            completion()
        }
      
        socket.connect()
    }
  }
  
  func disconnect() {
    if ServerHandler.connected {
      socket.disconnect()
      
      ServerHandler.connected = false
    }
  }
  
  func sendCameraFrame(_ buffer: CMSampleBuffer) {
    let now = Date()
    if ServerHandler.connected { /*  && now - last_sent > 0.5 */
        last_sent = now
//        print("sending", Date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate)
        socket.emit("image", imageBufferToData(buffer))
        received = false
    }
  }
}
