//
//  SourceEditorCommand.swift
//  Imp Tools
//
//  Created by Alexander Shalamov on 8/3/17.
//  Copyright © 2017 Alexander Shalamov. All rights reserved.
//

import Foundation
import XcodeKit


fileprivate struct Commands {
  static let sortImports = "imports"
  static let sortSelectedLines = "lines"
}


class SourceEditorCommand: NSObject, XCSourceEditorCommand {
  
  let settings = UserDefaults.init(suiteName: Constants.settings.suiteId)!
  let importCommandSwift = "import"
  let importCommandObjc = "#import"
  var isSwiftFile = true
  
  func perform(with invocation: XCSourceEditorCommandInvocation,
               completionHandler: @escaping (Error?) -> Void ) -> Void {

    if invocation.buffer.lines.count == 0 {
      completionHandler(nil)
      return
    }
    
    let text = invocation.buffer.lines
    
    switch invocation.commandIdentifier {
      case Commands.sortImports:
        self.sortImports(in: text)
      case Commands.sortSelectedLines:
        let selections = invocation.buffer.selections.flatMap { $0 as? XCSourceTextRange }
        self.sort(selectedLines: selections, in: text)
      default:
        break
    }
    
    completionHandler(nil)
  }
  
}

// MARK: Sort Imports
extension SourceEditorCommand {
  
  fileprivate func sortImports(in text: NSMutableArray) {
    
    let importIndexes = text.indexesOfObjects(passingTest:) { (object, index, stop) -> Bool in
      let line = object as! String
      if line.hasPrefix(importCommandSwift) {
        return true
      } else if line.hasPrefix(importCommandObjc) {
        self.isSwiftFile = false
        return true
      } else {
        return false
      }
    }
    
    if importIndexes.isEmpty {
      return
    }
    
    var importLines = text.objects(at: importIndexes).map { return $0 as! String }
    text.removeObjects(at: importIndexes)
    
    if self.shouldRemoveDuplicates() {
      let linesWithoutDuplicates = NSSet.init(array: importLines)
      importLines = linesWithoutDuplicates.allObjects as! [String]
    }
    
    var sortedLines = importLines.sorted { return $0 < $1 }
    
    // Own header to top logic
    if !self.isSwiftFile && self.shouldPutOwnHeaderOnTop() {
      if let className = self.getFileClass(in: text.copy() as! NSArray) {
        let classExtractionRegex = "(?<=.\").*(?=\\.h\")"
        for (index, line) in sortedLines.enumerated() {
          let matches = line.matches(for: classExtractionRegex)
          if matches.count > 0 {
            let extractedClass = matches.first!
            if className == extractedClass {
              let header = sortedLines[index]
              sortedLines.remove(at: index)
              sortedLines.insert(header, at: 0)
              sortedLines.insert("\n", at: 1)
              break
            }
          }
        }
      }
    }
    
    if self.shouldSeparateFrameworks() {
      for (index, line) in sortedLines.enumerated() {
        if line.hasPrefix(importCommandObjc) && line.contains("<") {
          sortedLines.insert("\n", at: index)
          break
        }
      }
    }
    
    let firstImportIndex = importIndexes.first!
    let importsRange = Range(uncheckedBounds: (lower: firstImportIndex, upper: firstImportIndex + sortedLines.count))
    
    var sortedIndexSet = IndexSet()
    sortedIndexSet.insert(integersIn: importsRange)
    
    text.insert(sortedLines, at: sortedIndexSet)
  }
  
  // MARK: Auxiliary methods
  private func shouldPutOwnHeaderOnTop() -> Bool {
    return !self.settings.bool(forKey: Constants.settings.ignoreOwnHeader)
  }
  
  private func shouldSeparateFrameworks() -> Bool {
    return !self.settings.bool(forKey: Constants.settings.ignoreFrameworks)
  }
  
  private func shouldRemoveDuplicates() -> Bool {
    return !self.settings.bool(forKey: Constants.settings.ignoreDuplicates)
  }
  
  private func getFileClass(in text: NSArray) -> String? {
    
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

// MARK: Sort Selected Lines
extension SourceEditorCommand {
  
  fileprivate func sort(selectedLines selections: [XCSourceTextRange], in text: NSMutableArray) {
    
    for selection in selections {
      if selections.count == 1 && selection.start.line == selection.end.line && selection.start.column != selection.end.column {
        // bwahaha! while dealing with hellish creatures expect surprises: sorting symbols in line
        let startIndex = selection.start.column
        let endIndex = selection.end.column
        let selectedRange = NSRange(location: startIndex, length: endIndex - startIndex)
        guard
          let line = text[selection.start.line] as? String,
          let range = Range(selectedRange, in: line) else {
            break
        }
        let selectedString = line.substring(with: range)
        let sortedString = line.replacingCharacters(in: range, with: String(selectedString.sorted()))
        text[selection.end.line] = sortedString
      }
      let indexes = IndexSet(integersIn: selection.start.line ..< selection.end.line)
      let lines = text.objects(at: indexes).flatMap { $0 as? String }
      text.replaceObjects(at: indexes, with: lines.sorted())
    }
  }
}

