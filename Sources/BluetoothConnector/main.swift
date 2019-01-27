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

func printAndNotify(_ content: String, notify: Bool) {
    if (notify) {
        Process.launchedProcess(launchPath: "/usr/bin/osascript", arguments: ["-e", "display notification \"\(content)\" with title \"BluetoothConnector\""])
    }

    print(content)
}

let cliParser = SimpleCLI(configuration: [
    Argument(longName: "connect", shortName: "c", type: .keyOnly, defaultValue: "false"),
    Argument(longName: "disconnect", shortName: "d", type: .keyOnly, defaultValue: "false"),
    Argument(longName: "address", type: .valueOnly, obligatory: true, inputName: "00-00-00-00-00-00"),
    Argument(longName: "notify", shortName: "n", type: .keyOnly, defaultValue: "false"),
    ])
let dictionary = cliParser.parseArgs(CommandLine.arguments)

guard let deviceAddress = dictionary["address"] else {
    printHelp()
    exit(0)
}

var notify = false
if let notifyString = dictionary["notify"] {
    notify = Bool(notifyString) ?? false
}

guard let bluetoothDevice = IOBluetoothDevice(addressString: deviceAddress) else {
    printAndNotify("Device not found", notify: notify)
    exit(-2)
}

if !bluetoothDevice.isPaired() {
    printAndNotify("Not paired to device", notify: notify)
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

enum ActionType {
    case Connection
    case Disconnect
}

var action : ActionType

let alreadyConnected = bluetoothDevice.isConnected()
let shouldConnect = (connectOnly
                     || (!connectOnly && !disconnectOnly && !alreadyConnected))

if shouldConnect {
    action = .Connection
    error = bluetoothDevice.openConnection()
}
else {
    action = .Disconnect
    error = bluetoothDevice.closeConnection()
}

if error > 0 {
    printAndNotify("Error: \(action) failed", notify: notify)
    exit(-1)
} else if notify {
    if action == .Connection && alreadyConnected {
        printAndNotify("Already connected", notify: notify)
    }
    else if action == .Disconnect && !alreadyConnected {
        printAndNotify("Already disconnected", notify: notify)
    }
    else {
        switch action {
            case .Connection: 
                printAndNotify("Successfully connected", notify: notify)
            
            case .Disconnect: 
                printAndNotify("Successfully disconnected", notify: notify)
        }
    }
}
