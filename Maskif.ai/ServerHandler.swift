//
//  ServerHandler.swift
//  Maskif.ai
//
//  Created by Simon Chervenak on 11/10/20.
//

import Foundation
import Starscream
import AVFoundation

let NGROK_URL = "https://7d18ed560826.ngrok.io"

// code translated from https://stackoverflow.com/a/6197348/6342812
func imageToBuffer(_ source: CMSampleBuffer) -> Data {
    let imageBuffer = CMSampleBufferGetImageBuffer(source)!

    CVPixelBufferLockBaseAddress(imageBuffer, [])
  
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
    let width = CVPixelBufferGetWidth(imageBuffer)
    let height = CVPixelBufferGetHeight(imageBuffer)
    let src_buff = CVPixelBufferGetBaseAddress(imageBuffer)
  
    CVPixelBufferUnlockBaseAddress(imageBuffer as CVPixelBuffer, [])

    return Data(bytes: src_buff!, count: bytesPerRow * height)
}

class ServerHandler: WebSocketDelegate {
  var socket: WebSocket!
  
  static let shared: ServerHandler = ServerHandler()
  static var connected = false
  
  private init() {
    connect()
  }
  
  func connect() {
    if !ServerHandler.connected {
      var request = URLRequest(url: URL(string: NGROK_URL)!)
      request.timeoutInterval = 5
      socket = WebSocket(request: request)
      socket.delegate = self
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
  
  // todo: socket.disconnect
  
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    print("hm")
  }
  
  func sendCameraFrame(_ buffer: CMSampleBuffer) {
    socket.write(data: imageToBuffer(buffer))
  }
}
