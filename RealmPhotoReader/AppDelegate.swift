//
//  AppDelegate.swift
//  RealmPhotoReader
//
//  Created by 陳劭任 on 2018/9/27.
//  Copyright © 2018 陳劭任. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        NSApplication.shared.terminate(self)
        
        return true
        
    }

}

