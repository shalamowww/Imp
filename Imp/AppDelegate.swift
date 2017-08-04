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
    
    static let suiteId = "imp.ftw"
    let defaults = UserDefaults.init(suiteName: suiteId)
    let kOwnHeader = "ignore_own_header"
    let kIgnoreFrameworks = "ignore_frameworks_section"
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var ownHeaderCheckbox: NSButton!
    @IBOutlet weak var separatedFrameworksCheckbox: NSButton!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let ownHeaderOnTop = !(defaults?.bool(forKey: kOwnHeader) ?? false)
        self.ownHeaderCheckbox.state = ownHeaderOnTop ? NSOnState : NSOffState
        
        let separateFrameworks = !(defaults?.bool(forKey: kIgnoreFrameworks) ?? false)
        self.separatedFrameworksCheckbox.state = separateFrameworks ? NSOnState : NSOffState
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func checkboxClicked(_ sender: NSButton) {
        if sender == self.ownHeaderCheckbox {
            let ignoreOwnHeader = sender.state == NSOnState ? false : true
            self.defaults?.set(ignoreOwnHeader, forKey: kOwnHeader)
        }
        if sender == self.separatedFrameworksCheckbox {
            let ignoreFrameworks = sender.state == NSOnState ? false : true
            self.defaults?.set(ignoreFrameworks, forKey: kIgnoreFrameworks)
        }
        self.defaults?.synchronize()
    }
}

