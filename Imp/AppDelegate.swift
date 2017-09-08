//
//  AppDelegate.swift
//  Imp
//
//  Created by Alexander Shalamov on 8/3/17.
//  Copyright © 2017 Alexander Shalamov. All rights reserved.
//

import Cocoa

// TODO: REFACTOR ASAP
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let settings = UserDefaults.init(suiteName: Constants.settings.suiteId)!
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var ownHeaderCheckbox: NSButton!
    @IBOutlet weak var separatedFrameworksCheckbox: NSButton!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let ownHeaderOnTop = !self.settings.bool(forKey: Constants.settings.ignoreOwnHeader)
        self.ownHeaderCheckbox.state = ownHeaderOnTop ? NSOnState : NSOffState
        
        let separateFrameworks = !self.settings.bool(forKey: Constants.settings.ignoreFrameworks)
        self.separatedFrameworksCheckbox.state = separateFrameworks ? NSOnState : NSOffState
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func checkboxClicked(_ sender: NSButton) {
        if sender == self.ownHeaderCheckbox {
            let ignoreOwnHeader = sender.state == NSOnState ? false : true
            self.settings.set(ignoreOwnHeader, forKey: Constants.settings.ignoreOwnHeader)
        }
        if sender == self.separatedFrameworksCheckbox {
            let ignoreFrameworks = sender.state == NSOnState ? false : true
            self.settings.set(ignoreFrameworks, forKey: Constants.settings.ignoreFrameworks)
        }
        self.settings.synchronize()
    }
}

