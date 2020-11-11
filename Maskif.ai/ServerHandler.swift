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

let NGROK_URL = "https://7d18ed560826.ngrok.io/"

// code translated from https://stackoverflow.com/a/6197348/6342812
// help from https://stackoverflow.com/questions/42997462/convert-cmsamplebuffer-to-uiimage
func imageBufferToData(_ source: CMSampleBuffer) -> Data {
    let ciimage = CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(source)!)
    return UIImage(cgImage: CIContext(options: nil).createCGImage(ciimage, from: ciimage.extent)!).pngData()!
}

class ServerHandler {
  let manager = SocketManager(socketURL: URL(string: NGROK_URL)!, config: [.log(true), .compress])
  var socket: SocketIOClient!
  
  static let shared: ServerHandler = ServerHandler()
  static var connected = false
  
  private init() {
    connect()
  }
  
  func connect() {
    if !ServerHandler.connected {
      socket = manager.defaultSocket

      socket.on(clientEvent: .connect) {data, ack in
          print("socket connected")
      }
      
      socket.onAny { (event) in
        print("The event is: \(event.event)")
      }
      
      socket.connect()
      
      ServerHandler.connected = true
    }
  }
  
  func disconnect() {
    if ServerHandler.connected {
      socket.disconnect()
      
      ServerHandler.connected = false
    }
  }
  
  func sendCameraFrame(_ buffer: CMSampleBuffer) {
    socket.emit("image", imageBufferToData(buffer))
  }
}
