# maskifai-client

Client for the server repo here: https://github.com/varun-ramani/maskifai-server

# Motivation
As businesses around the world begin to reopen, many of them have issued mandatory
mask mandates to protect the safety of their employees and customers. Unfortunately, where there
are rules, there are people who decide not to follow them. As of today, there have been countless incidents
of people arguing with business owners over the importance of wearing a mask. This is not only disrespectful and
a waste of time for these business owners, but it is also dangerous given the pandemic.
How can we solve this issue? 

# What we built
Introducing Maskif.ai, the AI-powered smart lock. Maskif.ai uses computer vision to detect 
people who are not wearing a mask and then subsequently locks the door to keep them out. Maskif.ai
is compatible with Google Home, and thus can be used with a multitude of smart devices. Here is a 
video which includes a demo and some more information about what Maskif.ai does: https://www.youtube.com/watch?v=EG8_0GUnhqg&feature=youtu.be

# How it works
We leverage the [AVFoundation](https://developer.apple.com/av-foundation/) framework from Apple to obtain the video from the user, and then use the [socket.io](https://socket.io/docs/v2/internals/index.html) protocol to communicate with the server using a singleton websocket. Press the button to start/stop recording.

# Using Maskifai
- Clone this repo using `git clone https://github.com/varun-ramani/maskifai-client.git`
- Open `Maskif.ai.xcodeproj` in Xcode 12.0+
- Make sure the Swift Package Manager is up and running (this requires [this project](https://github.com/socketio/socket.io-client-swift))
- Connect your iphone
- When prompted, type in the server URL
# Devpost
Check out our devpost at: https://devpost.com/software/maskif-ai.
This project was created as part of YHack 2020