//
//  ViewController.swift
//  SafeEject
//
//  Created by Tanner W. Stokes on 7/1/17.
//  Copyright © 2017 Tanner W. Stokes. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    
    @IBOutlet weak var statusLabel: NSTextField!
    var timer = Timer()
    let diskHandler = DiskHandler()
    
    @IBAction func ejectPressed(_ sender: NSButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.diskHandler?.ejectAllVolumes()
                debugPrint("All drives were ejected successfully")
                self.refreshVolumeStatus()
            } catch {
                // this should be more specific, e.g. what volume
                debugPrint("Failed to eject all volumes!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register our volume refresh observer
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.fireVolumeTimer), name: NSNotification.Name("com.tannr.volumeRefresh"), object: nil)
        
        diskHandler?.registerVolumeMounted({ disk, keys, context in
            debugPrint("Volume mounted")
            NotificationCenter.default.post(name: Notification.Name("com.tannr.volumeRefresh"), object: DiskStatus.arrive)
        })
        
        diskHandler?.registerDiskDisappeared({ disk, context in
            debugPrint("Disk disappeared")
            NotificationCenter.default.post(name: Notification.Name("com.tannr.volumeRefresh"), object: DiskStatus.leave)
        })
        
        // set our initial UI state
        refreshVolumeStatus()
    }
    
    func refreshVolumeStatus() {
        if let volumeCount = diskHandler?.getMountedVolumes().count, volumeCount == 0 {
            updateUiState(safe: true)
        } else {
            updateUiState(safe: false)
        }
    }
    
    func updateUiState(safe: Bool) {
        if safe {
            statusLabel.stringValue = "Safe to eject."
        } else {
            statusLabel.stringValue = "Unsafe to eject."
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func fireVolumeTimer(_ notification: Notification) {
        debugPrint("Firing off volume timer!")
        
        if let status = notification.object as? DiskStatus {
            debugPrint("Status: \(status)")
            
            switch status {
            case .arrive:
                // when any arrival event occurred, it's an unsafe state
                updateUiState(safe: false)
            case .leave:
                // because the timer can be called multiple times in a row, invalidate it each time
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: status.waitTime, target: self, selector: #selector(refreshVolumeStatus), userInfo: nil, repeats: false)
            }
        }
    }
}

