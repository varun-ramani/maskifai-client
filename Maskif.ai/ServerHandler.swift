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

let NGROK_URL = "https://611e8d9395c1.ngrok.io"

// code translated from https://stackoverflow.com/a/6197348/6342812
// help from https://stackoverflow.com/questions/42997462/convert-cmsamplebuffer-to-uiimage
func imageBufferToData(_ source: CMSampleBuffer) -> Data {
    let ciimage = CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(source)!)
    return UIImage(cgImage: CIContext(options: nil).createCGImage(ciimage, from: ciimage.extent)!).pngData()!
}

class ServerHandler {
    let manager = SocketManager(socketURL: URL(string: NGROK_URL)!, config: [.compress])
    var socket: SocketIOClient!
  
    static let shared: ServerHandler = ServerHandler()
    static var connected = false
    var received = true
  
  private init() {
//    connect()
  }
  
  func connect() {
    if !ServerHandler.connected {
      socket = manager.defaultSocket

      socket.on(clientEvent: .connect) {data, ack in
          print("socket connected")
          ServerHandler.connected = true
      }
      
      socket.on("faces") {data, ack in
          self.received = true
          guard let json_str = data[0] as? String else { return }
          do {
              let json = try JSONSerialization.jsonObject(with: json_str.data(using: .utf8)!)
          
              print("received", Date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate, json)
          } catch {
              print("JSon error", error)
          }
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
    if ServerHandler.connected && received {
        print("sending", Date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate)
        socket.emit("image", imageBufferToData(buffer))
        received = false
    }
  }
}
