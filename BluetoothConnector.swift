import IOBluetooth

let hardcodedAddress : String? = nil//"12-34-56-78-90-ab"

func printHelp() {
    print("Usage:\nBluetoothConnector [-c|--connect|-d|--disconnect] [00-00-00-00-00-00]\n\nGet the MAC address from the list below (if your device is missing, pair it with your computer first):\n");
    IOBluetoothDevice.pairedDevices().forEach({(device) in
        guard let device = device as? IOBluetoothDevice,
        let addressString = device.addressString,
        let deviceName = device.name
        else { return }
        let connectedString = device.isConnected() ? "connected" : "disconnected"
        print("\(addressString) - \(deviceName) (\(connectedString))")
    })
}

var macAddr : String? = nil
var action : String? = nil

for argument in CommandLine.arguments[1...] {
    switch argument {
        case "-c", "--connect":
            action = "connect"

        case "-d", "--disconnect":
            action = "disconnect"

        default:
            if argument.hasPrefix("-") || macAddr != nil {
                printHelp()
                exit(-3)
            }
            macAddr = argument
    }
}


if (macAddr == nil) {
    printHelp()
    exit(-3)
}

let deviceAddress = hardcodedAddress ?? macAddr!
guard let bluetoothDevice = IOBluetoothDevice(addressString: deviceAddress) else {
    print("Device not found: \(deviceAddress)")
    exit(-2)
}

if !bluetoothDevice.isPaired() {
    print("Not paired to device")
    exit(-4)
}

if bluetoothDevice.isConnected() {
    if (action == "disconnect" || action == nil) {
        bluetoothDevice.closeConnection()
    }
}
else {
    if (action == "connect" || action == nil) {
        bluetoothDevice.openConnection()
    }
}
