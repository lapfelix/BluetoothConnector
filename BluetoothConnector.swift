import IOBluetooth

let hardcodedAddress : String? = nil//"12-34-56-78-90-ab"

func printHelp() {
    print("Usage:\nBluetoothConnector 00-00-00-00-00-00\n\nGet the MAC address from the list below (if your device is missing, pair it with your computer first):");
    IOBluetoothDevice.pairedDevices().forEach({(device) in
        guard let device = device as? IOBluetoothDevice,
        let addressString = device.addressString,
        let deviceName = device.name
        else { return }
        print("\(addressString) - \(deviceName)")
    })
}

if (CommandLine.arguments.count == 2 || hardcodedAddress != nil) {
    let deviceAddress : String? = hardcodedAddress == nil ? CommandLine.arguments[1] : nil
    guard let bluetoothDevice = IOBluetoothDevice(addressString: hardcodedAddress ?? deviceAddress) else {
        print("Device not found")
        exit(-2)
    }
    
    if !bluetoothDevice.isPaired() {
        print("Not paired to device")
        exit(-4)
    }
    
    if bluetoothDevice.isConnected() {
        bluetoothDevice.closeConnection()
    }
    else {
        bluetoothDevice.openConnection()
    }
}
else {
    printHelp()
    exit(-3)
}
