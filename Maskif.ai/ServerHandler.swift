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
func imageBufferToData(_ source: CMSampleBuffer) -> Data {
    let imageBuffer = CMSampleBufferGetImageBuffer(source)!
    let ciimage = CIImage(cvPixelBuffer: imageBuffer)
    let context: CIContext = CIContext(options: nil)
    let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
    let image = UIImage(cgImage: cgImage)
    return image.pngData()!

//    CVPixelBufferLockBaseAddress(imageBuffer, [])
//
//    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
//    let width = CVPixelBufferGetWidth(imageBuffer)
//    let height = CVPixelBufferGetHeight(imageBuffer)
//    let src_buff = CVPixelBufferGetBaseAddress(imageBuffer)
//
//    let data = Data(bytes: src_buff!, count: bytesPerRow * height)
//
//    CVPixelBufferUnlockBaseAddress(imageBuffer as CVPixelBuffer, [])
//
//    return data
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
