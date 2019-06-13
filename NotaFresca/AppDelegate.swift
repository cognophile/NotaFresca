//
//  AppDelegate.swift
//  NotaFresca
//
//  Created by Alex Boggis on 13/06/2019.
//  Copyright © 2019 cognophile. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var storyboard : NSStoryboard?
    var app : AppWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle.main)
        app = storyboard?.instantiateController(withIdentifier: "AppWindowController") as? AppWindowController
        
        app?.contentViewController = storyboard?.instantiateController(withIdentifier: "CoreViewController") as! NSSplitViewController
        app?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}