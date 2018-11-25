import IOBluetooth
import SimpleCLI

func printHelp() {
    print(cliParser.helpString(CommandLine.arguments))
    print("\nGet the MAC address from the list below (if your device is missing, pair it with your computer first):");
    IOBluetoothDevice.pairedDevices().forEach({(device) in
        guard let device = device as? IOBluetoothDevice,
        let addressString = device.addressString,
        let deviceName = device.name
        else { return }
        print("\(addressString) - \(deviceName)")
    })
}

let cliParser = SimpleCLI(configuration: [
    Argument(longName: "connect", shortName: "c", type: .keyOnly, defaultValue: "false"),
    Argument(longName: "disconnect", shortName: "d", type: .keyOnly, defaultValue: "false"),
    Argument(longName: "address", type: .valueOnly, obligatory: true, inputName: "00-00-00-00-00-00"),
    ])
let dictionary = cliParser.parseArgs(CommandLine.arguments)

guard let deviceAddress = dictionary["address"] else {
    printHelp()
    exit(-3)
}

guard let bluetoothDevice = IOBluetoothDevice(addressString: deviceAddress) else {
    print("Device not found")
    exit(-2)
}

if !bluetoothDevice.isPaired() {
    print("Not paired to device")
    exit(-4)
}

var connectOnly = false
if let connectString = dictionary["connect"] {
    connectOnly = Bool(connectString) ?? false
}

var disconnectOnly = false
if let disconnectString = dictionary["disconnect"] {
    disconnectOnly = Bool(disconnectString) ?? false
}

var error : IOReturn = -1
var action = "Toggle"
if !connectOnly && bluetoothDevice.isConnected() {
    action = "Disconnection"
    error = bluetoothDevice.closeConnection()
}
else if (!disconnectOnly) {
    action = "Connection"
    error = bluetoothDevice.openConnection()
}

if error > 0 {
    print("Error: \(action) failed")
    exit(-1)
}
