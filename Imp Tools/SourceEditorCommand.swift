//
//  SourceEditorCommand.swift
//  Imp Tools
//
//  Created by Alexander Shalamov on 8/3/17.
//  Copyright © 2017 Alexander Shalamov. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    let settings = UserDefaults.init(suiteName: Constants.settings.suiteId)!

    var isSwiftFile = true
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        if invocation.buffer.lines.count == 0 {
            completionHandler(nil)
            return
        }
        
        let text = invocation.buffer.lines
        self.sortImports(in: text)
        
        completionHandler(nil)
    }
    
}

extension SourceEditorCommand {

    fileprivate func sortImports(in text: NSMutableArray) {
        
        let importIndexes = text.indexesOfObjects(passingTest:) { (object, index, stop) -> Bool in
            let line = object as! String
            if line.hasPrefix("import") {
                return true
            } else if line.hasPrefix("#import") {
                self.isSwiftFile = false
                return true
            } else {
                return false
            }
        }
        
        if importIndexes.isEmpty {
            return
        }
        
        let importLines = text.objects(at: importIndexes)
        let sortedLines = importLines.sorted { (obj1, obj2) -> Bool in
            let line1 = obj1 as! String, line2 = obj2 as! String
            return line1 < line2
        }
        
        let finalLines = NSMutableArray(array: sortedLines)
        text.removeObjects(at: importIndexes)
        
        // Own header to top logic
        if !self.isSwiftFile && self.shouldPutOwnHeaderOnTop() {
            if let className = self.getFileClass(in: text.copy() as! NSArray) {
                let classExtractionRegex = "(?<=.\").*(?=\\.h\")"
                for (index, line) in sortedLines.enumerated() {
                    let string = line as! String
                    let matches = string.matches(for: classExtractionRegex)
                    if matches.count > 0 {
                        let extractedClass = matches.first!
                        if className == extractedClass {
                            self.pushOwnHeaderTop(headerIndex: index, in: finalLines)
                            break
                        }
                    }
                }
            }
        }
        
        if self.shouldSeparateFrameworks() {
            for (index, line) in finalLines.enumerated() {
                let string = line as! String
                if string.hasPrefix("#import") && string.contains("<") {
                    finalLines.insert("\n", at: index)
                    break
                }
            }
        }
        
        let firstImportIndex = importIndexes.first!
        let importsRange = Range(uncheckedBounds: (lower: firstImportIndex, upper: firstImportIndex + finalLines.count))
        
        var sortedIndexSet = IndexSet()
        sortedIndexSet.insert(integersIn: importsRange)
        
        text.insert(finalLines.copy() as! [Any], at: sortedIndexSet)
    }
    
    fileprivate func shouldPutOwnHeaderOnTop() -> Bool {
        return !self.settings.bool(forKey: Constants.settings.ignoreOwnHeader)
    }
    
    fileprivate func shouldSeparateFrameworks() -> Bool {
        return !self.settings.bool(forKey: Constants.settings.ignoreFrameworks)
    }
    
    fileprivate func pushOwnHeaderTop(headerIndex: Int, in lines: NSMutableArray) {
        let header = lines[headerIndex]
        lines.removeObject(at: headerIndex)
        lines.insert(header, at: 0)
        lines.insert("\n", at: 1)
    }
    
    fileprivate func getFileClass(in text: NSArray) -> String? {
        
        var implementations = [String]()
        var interfaces = [String]()
        let interfaceDeclaration = "@interface"
        let implementationDeclaration = "@implementation"
        
        text.enumerateObjects({ (obj, idx, stop) in
            let line = obj as! String
            if line.contains(implementationDeclaration) {
                implementations.append(line.matches(for: "(?<=\\"+implementationDeclaration+"\\s)\\w+").first!)
            } else if line.contains(interfaceDeclaration) {
                interfaces.append(line.matches(for: "(?<=\\"+interfaceDeclaration+"\\s)\\w+").first!)
            }
        })
        
        // TODO: somehow distinguish the class if a file has several interfaces/implementations (xcode doesnt provide a file name)
        
        if implementations.count > 0 {
            return implementations.first
        }
        
        if interfaces.count > 0 {
            return interfaces.first
        }
        
        return nil
    }
    
}
