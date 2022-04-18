import IOBluetooth
import ArgumentParser

func utilityName() -> String {
  return URL(fileURLWithPath: CommandLine.arguments.first ?? "¯\\_(ツ)_/¯").lastPathComponent
}

func getDeviceListHelpString() -> String {
    var helpString = "\nMAC Address missing. Get the MAC address from the list below (if your device is missing, pair it with your computer first):"
    IOBluetoothDevice.pairedDevices().forEach({(device) in
        guard let device = device as? IOBluetoothDevice,
        let addressString = device.addressString,
        let deviceName = device.name
        else { return }
        helpString += "\n\(addressString) - \(deviceName)"
    })
    helpString += "\n"
    return helpString
}

func printAndNotify(title: String, body: String, notify: Bool) {
    if (notify) {
        Process.launchedProcess(launchPath: "/usr/bin/osascript", arguments: ["-e", "display notification \"\(body)\" with title \"\(title)\""])
    }

    print(body)
}

func turnOnBluetoothIfNeeded(notify: Bool) {
    guard let bluetoothHost = IOBluetoothHostController.default(),
    bluetoothHost.powerState != kBluetoothHCIPowerStateON else { return }

    // Definitely not App Store safe
    if let iobluetoothClass = NSClassFromString("IOBluetoothPreferences") as? NSObject.Type {
        let obj = iobluetoothClass.init()
        let selector = NSSelectorFromString("setPoweredOn:")
        if (obj.responds(to: selector)) {
            obj.perform(selector, with: 1)
        }
    }

    var timeWaited : UInt32 = 0
    let interval : UInt32 = 200000 // in microseconds
    while (bluetoothHost.powerState != kBluetoothHCIPowerStateON) {
        usleep(interval)
        timeWaited += interval
        if (timeWaited > 5000000) {
            printAndNotify(title: utilityName(), body: "Failed to turn on Bluetooth", notify: notify)
            exit(-2)
        }
    }
}

enum ActionType {
    case Connection
    case Disconnect
}

func execute(macAddress: String, connectOnly: Bool, disconnectOnly: Bool, notify: Bool, statusOnly: Bool) {
    guard let bluetoothDevice = IOBluetoothDevice(addressString: macAddress) else {
        printAndNotify(title: utilityName(), body: "Device not found", notify: notify)
        exit(-2)
    }

    if !bluetoothDevice.isPaired() {
        printAndNotify(title: utilityName(), body: "Not paired to device", notify: notify)
        exit(-4)
    }

    let alreadyConnected = bluetoothDevice.isConnected()
    let shouldConnect = (connectOnly
                        || (!connectOnly && !disconnectOnly && !alreadyConnected))

    if statusOnly {
        if alreadyConnected {
            print("Connected")
        }
        else {
            print("Disconnected")
        }
        exit(0)
    }

    var error : IOReturn = -1
    var action : ActionType
    if shouldConnect {
        action = .Connection
        turnOnBluetoothIfNeeded(notify: notify)
        error = bluetoothDevice.openConnection()
    }
    else {
        action = .Disconnect
        error = bluetoothDevice.closeConnection()
    }

    let title = bluetoothDevice.name ?? utilityName()
    if error > 0 {
        printAndNotify(title: title, body: "\(action) failed", notify: notify)
        exit(-1)
    } else if notify {
        if action == .Connection && alreadyConnected {
            printAndNotify(title: title, body: "Already connected", notify: notify)
        }
        else if action == .Disconnect && !alreadyConnected {
            printAndNotify(title: title, body: "Already disconnected", notify: notify)
        }
        else {
            switch action {
                case .Connection:
                    printAndNotify(title: title, body: "Connected", notify: notify)

                case .Disconnect:
                    printAndNotify(title: title, body: "Disconnected", notify: notify)
            }
        }
    }
}

struct BluetoothConnector: ParsableCommand {
    @Flag(name: .shortAndLong, help: "Connect a device")
    var connect = false

    @Flag(name: .shortAndLong, help: "Disconnect a device")
    var disconnect = false

    @Flag(name: .shortAndLong, help: "Get the status of a device")
    var status = false

    @Flag(name: .shortAndLong, help: "Post a Notification Center notification")
    var notify = false

    @Argument(help: ArgumentHelp(
        "The MAC address of the device. Format: 00-00-00-00-00-00 or 000000000000",
        valueName: "MAC address"))
    var macAddress: String?

    static var configuration = CommandConfiguration(
        commandName: utilityName(),
        abstract: "Connect/disconnects Bluetooth devices.",
        discussion: "Default behavior is to toggle between connecting and disconnecting.")

    mutating func validate() throws {
        guard connect != true || disconnect != true else {
            throw ValidationError("Can't connect and disconnect at once.")
        }

        if status {
            guard connect == false else {
                throw ValidationError("Can't connect with status flag enabled.")
            }

            guard disconnect == false else {
                throw ValidationError("Can't disconnect with status flag enabled.")
            }
        }

        if let address = macAddress {
            if address.replacingOccurrences(of: "-", with: "").count != 12 {
                throw ValidationError("Invalid MAC address: \(address).")
            }
        }
        else {
            throw ValidationError(getDeviceListHelpString())
        }
    }

    func run() throws {
        execute(macAddress: macAddress!, connectOnly: connect, disconnectOnly: disconnect, notify: notify, statusOnly: status)
    }
}

BluetoothConnector.main()
