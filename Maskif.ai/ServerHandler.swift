//
//  ServerHandler.swift
//  Maskif.ai
//
//  Created by Simon Chervenak on 11/10/20.
//

import Foundation
import Starscream
import AVFoundation

let NGROK_URL = ""

// code translated from https://stackoverflow.com/a/6197348/6342812
func imageToBuffer(_ source: CMSampleBuffer) -> Data {
    let imageBuffer = CMSampleBufferGetImageBuffer(source)!

    CVPixelBufferLockBaseAddress(imageBuffer, [])
  
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
    let width = CVPixelBufferGetWidth(imageBuffer)
    let height = CVPixelBufferGetHeight(imageBuffer)
    var src_buff = CVPixelBufferGetBaseAddress(imageBuffer)

    CVPixelBufferUnlockBaseAddress(imageBuffer as CVPixelBuffer, [])

    return Data(bytes: &src_buff, count: bytesPerRow * height)
}

class ServerHandler: WebSocketDelegate {
  var socket: WebSocket!
  
  static let shared: ServerHandler = ServerHandler()
  
  private init() {
    var request = URLRequest(url: URL(string: NGROK_URL)!)
    request.timeoutInterval = 5
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
  }
  
  // todo: socket.disconnect
  
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    print("hm")
  }
  
  func sendCameraFrame(_ buffer: CMSampleBuffer) {
    socket.write(data: imageToBuffer(buffer))
  }
}
