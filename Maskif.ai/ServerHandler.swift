//
//  ServerHandler.swift
//  Maskif.ai
//
//  Created by Simon Chervenak on 11/10/20.
//

import Foundation
import Starscream

let NGROK_URL = ""

class ServerHandler: WebSocketDelegate {
  var socket: WebSocket!
  
  init() {
    var request = URLRequest(url: URL(string: NGROK_URL)!)
    request.timeoutInterval = 5
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
  }
  
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    <#code#>
  }
}
