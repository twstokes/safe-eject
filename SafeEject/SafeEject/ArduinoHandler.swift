//
//  ArduinoHandler.swift
//  SafeEject
//
//  Created by Tanner W. Stokes on 7/2/17.
//  Copyright © 2017 Tanner W. Stokes. All rights reserved.
//

import Cocoa
import ORSSerial

class ArduinoHandler: NSObject, ORSSerialPortDelegate {
    var ejectCallback: () -> Void = {}

    fileprivate(set) internal var serialPort: ORSSerialPort? {
        willSet {
            if let port = serialPort {
                port.close()
                port.delegate = nil
            }
        }
        didSet {
            if let port = serialPort {
                port.baudRate = 9600
                port.delegate = self
                port.open()
            }
        }
    }

    func open(path: String) {
        serialPort = ORSSerialPort(path: path)
    }

    func sendData(data: Data) {
        serialPort?.send(data)
    }

    func close() {
        serialPort = nil
    }

    func registerEjectCallback(callback: @escaping () -> Void) {
        ejectCallback = callback
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        debugPrint("Data received")
        ejectCallback()
    }

    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort = nil
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        debugPrint("The serial port encountered an error.")
    }

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        debugPrint("The serial port was opened.")
    }

    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        debugPrint("The serial port was closed.")
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        debugPrint("A response was recieved.")
    }
}
