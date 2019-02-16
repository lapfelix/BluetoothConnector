<img width=450 alt="screen shot 2019-02-16 at 11 30 23 am" src="https://user-images.githubusercontent.com/4634735/52902443-cf2f6000-31de-11e9-844e-c5459b31ed87.png">

# BluetoothConnector
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

Then open the Automator workflow and you should get a prompt to install it (don't forget to change the MAC address).
To bind a shortcut to the Automator service, launch System Preferences and Go to `Keyboard > Shortcuts > Services`, find your service and add a shortcut to it.
