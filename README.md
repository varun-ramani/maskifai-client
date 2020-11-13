# maskifai-client

Client for the server repo here: https://github.com/varun-ramani/maskifai-server

## Design

We leverage the [AVFoundation](https://developer.apple.com/av-foundation/) framework from Apple to obtain the video from the user, and then use the [socket.io](https://socket.io/docs/v2/internals/index.html) protocol to communicate with the server using a singleton websocket. Press the button to start/stop recording.