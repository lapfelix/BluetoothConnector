<img width=450 alt="screen shot 2019-02-16 at 11 30 23 am" src="https://user-images.githubusercontent.com/4634735/52902443-cf2f6000-31de-11e9-844e-c5459b31ed87.png">

# BluetoothConnector <img src="https://app.bitrise.io/app/e673c0a1d059026a/status.svg?token=KfzTO6gwCraFRsJdxzpnew&branch=master"> [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Flapfelix%2FBluetoothConnector%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/lapfelix/BluetoothConnector)
Simple macOS CLI to connect/disconnect a Bluetooth device. I made it to easily connect my BeatsX earbuds (I thought the W1 chip would make the switch from my iPhone to my Mac seamless, but we're not there yet, apparently). There's probably a program that already does this but I didn't find it.

You can download a compiled version here: https://github.com/lapfelix/BluetoothConnector/releases

If you have issues running the compiled binary (`permission denied` error), try running this command in Terminal:
`chmod +x /path/to/BluetoothConnector`

# Installation

### [Homebrew](https://brew.sh)
```
brew install bluetoothconnector
```

### [Mint](https://github.com/yonaskolb/Mint)
```
mint install lapfelix/BluetoothConnector
```

### Manually
```
swift package update
swift build -c release
mv .build/release/BluetoothConnector /usr/local/bin/BluetoothConnector
```

# Usage
#### Running
Replace `00-00-00-00-00-00` with your device's MAC address. You can get it by alt-clicking the Bluetooth menu icon or by running BluetoothConnector without any arguments

##### To toggle the connection (connect/disconnect) and be notified about it
```
BluetoothConnector 00-00-00-00-00-00 --notify
```

##### To connect and be notified about it
```
BluetoothConnector --connect 00-00-00-00-00-00 --notify
BluetoothConnector -c 00-00-00-00-00-00 --notify
```

##### To disconnect
```
BluetoothConnector --disconnect 00-00-00-00-00-00
BluetoothConnector -d 00-00-00-00-00-00
```

##### Notification Center
<img width=300 alt="screen shot 2019-01-27 at 4 51 16 pm" src="https://dsc.cloud/felix/Screen-Shot-2019-01-27-at-5.04.23-PM.png">

You can have BluetoothConnector send a notification to say what it did (connect or disconnect), if the action succeeded or get an error description if something goes wrong

```
BluetoothConnector 00-00-00-00-00-00 --notify
```

To reduce Notification Center pollution, I'd recommend turning off "Show in Notification Center" for the Script Editor app in the Notifications system preferences:

<img width="480" alt="screen shot 2019-01-27 at 4 51 16 pm" src="https://user-images.githubusercontent.com/4634735/51807529-f0430780-2255-11e9-9bc3-94205ea033ae.png">

#### With Automator to bind a shortcut to it (this is how I'm using it)
I included an Automator workflow service that calls BluetoothConnector from `/usr/local/bin` to make it easier to run BluetoothConnector with a keyboard workflow (this is how I'm using it).

To this, you will need a copy of this repo, a `brew` install is not enough.

1. Clone the repo.
2. In the root directory there is a file named "Connect Bluetooth Device.workflow", click on it, accept the install prompt.
3. In settings, `Keyboard > Shortcuts > Services > General` and bind the Bluetooth Connect to whatever you'd like.
4. Set the MAC address, the workflow can be found in `/Users/\[username]/Library/Services, open it and set your MAC address.
5. Create a link: in terminal, head over to `usr/local/bin` and create a link to your `brew` install.
   1. Something like: `sudo ln -s /opt/homebrew/Cellar/bluetoothconnector/2.1.0/bin/BluetoothConnector`

Test out the keyboard shortcut!
You will need to grant permissions the first time you run the workflow.
