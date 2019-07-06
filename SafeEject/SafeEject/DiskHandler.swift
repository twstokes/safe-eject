//
//  DiskHandler.swift
//  SafeEject
//
//  Created by Tanner W. Stokes on 7/2/17.
//  Copyright © 2017 Tanner W. Stokes. All rights reserved.
//

import Cocoa
import DiskArbitration

class DiskHandler {
    let daSession: DASession
    // what disk types to match
    let matches: CFDictionary = [kDADiskDescriptionMediaRemovableKey as String: true as CFBoolean] as CFDictionary

    init?() {
        if let newSession = DASessionCreate(nil) {
            daSession = newSession
        } else {
            return nil
        }

        DASessionScheduleWithRunLoop(daSession, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }

    func registerVolumeMounted(_ callBack: @escaping DADiskDescriptionChangedCallback) {
        DARegisterDiskDescriptionChangedCallback(daSession, matches, nil, callBack, nil)
    }

    func registerDiskDisappeared(_ callBack: @escaping DADiskDisappearedCallback) {
        DARegisterDiskDisappearedCallback(daSession, matches, callBack, nil)
    }

    @discardableResult func getMountedVolumes() -> [URL] {
        var volumes = [URL]()

        // get volumes that are ejectable
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey, .volumeIsEjectableKey]

        // get the paths of the volumes, skip hidden ones
        let paths = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [.skipHiddenVolumes])

        if let urls = paths {
            for url in urls {
                let components = url.pathComponents
                if components.count > 1 && components[1] == "Volumes" {
                    volumes.append(url)
                }
            }
        }

        return volumes
    }

    func ejectAllVolumes() throws {
        let volumes = self.getMountedVolumes()

        for volume in volumes {
            try NSWorkspace().unmountAndEjectDevice(at: volume)
        }
    }
}

enum DiskStatus {
    case arrive
    case leave

    public var waitTime: TimeInterval {
        switch self {
        case.arrive:
            return 0
        case.leave:
            return 1
        }
    }
}
