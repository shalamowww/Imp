//
//  SettingsViewController.swift
//  Imp
//
//  Created by Alexander on 9/17/17.
//  Copyright © 2017 Alexander Shalamov. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    let settings = UserDefaults.init(suiteName: Constants.settings.suiteId)!
    
    @IBOutlet weak var ownHeaderCheckbox: NSButton!
    @IBOutlet weak var separatedFrameworksCheckbox: NSButton!
    @IBOutlet weak var removeDuplicatesCheckbox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let putsOwnHeaderOnTop = !self.settings.bool(forKey: Constants.settings.ignoreOwnHeader)
        self.ownHeaderCheckbox.state = putsOwnHeaderOnTop ? NSOnState : NSOffState
        
        let separatesFrameworks = !self.settings.bool(forKey: Constants.settings.ignoreFrameworks)
        self.separatedFrameworksCheckbox.state = separatesFrameworks ? NSOnState : NSOffState
        
        let removesDuplicates = !self.settings.bool(forKey: Constants.settings.ignoreDuplicates)
        self.removeDuplicatesCheckbox.state = removesDuplicates ? NSOnState : NSOffState
    }
    
    @IBAction func checkboxClicked(_ sender: NSButton) {
        if sender == self.ownHeaderCheckbox {
            let shouldIgnoreOwnHeader = sender.state == NSOnState ? false : true
            self.settings.set(shouldIgnoreOwnHeader, forKey: Constants.settings.ignoreOwnHeader)
        }
        if sender == self.separatedFrameworksCheckbox {
            let shouldIgnoreFrameworks = sender.state == NSOnState ? false : true
            self.settings.set(shouldIgnoreFrameworks, forKey: Constants.settings.ignoreFrameworks)
        }
        if sender == self.removeDuplicatesCheckbox {
            let shouldIgnoreDuplicates = sender.state == NSOnState ? false : true
            self.settings.set(shouldIgnoreDuplicates, forKey: Constants.settings.ignoreDuplicates)
        }
        self.settings.synchronize()
    }
    
}
