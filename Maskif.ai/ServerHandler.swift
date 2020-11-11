//
//  ServerHandler.swift
//  Maskif.ai
//
//  Created by Simon Chervenak on 11/10/20.
//

import Foundation
import Starscream
import AVFoundation

let NGROK_URL = "http://7d18ed560826.ngrok.io/"

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

class ServerHandler {
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
  
  func sendCameraFrame(_ buffer: CMSampleBuffer) {
    socket.write(data: imageToBuffer(buffer))
  }
}

extension ServerHandler: WebSocketDelegate {
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case .connected(let headers):
      ServerHandler.connected = true
      print("websocket is connected: \(headers)")
    case .disconnected(let reason, let code):
      ServerHandler.connected = false
      print("websocket is disconnected: \(reason) with code: \(code)")
    case .text(let string):
      print("Received text: \(string)")
    case .binary(let data):
      print("Received data: \(data.count)")
    case .ping(_):
      break
    case .pong(_):
      break
    case .viabilityChanged(_):
      break
    case .reconnectSuggested(_):
      break
    case .cancelled:
      ServerHandler.connected = false
    case .error(let error):
      ServerHandler.connected = false
      print(error)
      connect()
//      handleError(error)
    }
  }
  
  func websocketDidConnect(socket: WebSocketClient) {
    print("connected")
  }
  
  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    print("disconnected")
  }
  
  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    print("got message", text)
  }
  
  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    print("got data")
  }
}
