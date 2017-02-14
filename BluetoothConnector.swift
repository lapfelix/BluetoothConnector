import IOBluetooth

let hardcodedAddress : String? = nil//"12-34-56-78-90-ab"

func printHelp() {
    print("Usage:\nBluetoothConnector 00-00-00-00-00-00");
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
