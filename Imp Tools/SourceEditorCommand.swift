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
            return line.hasPrefix("import") || line.hasPrefix("#import")
        }
        
        if importIndexes.isEmpty {
            return
        }
        
        let importLines = text.objects(at: importIndexes)
        let sortedLines = importLines.sorted { (obj1, obj2) -> Bool in
            let line1 = obj1 as! String, line2 = obj2 as! String
            return line1 < line2
        }
        
        text.removeObjects(at: importIndexes)
        
        let firstImportIndex = importIndexes.first
        let importsRange = Range(uncheckedBounds: (lower: firstImportIndex!, upper: firstImportIndex! + importIndexes.count))
        
        var sortedIndexSet = IndexSet()
        sortedIndexSet.insert(integersIn: importsRange)
        
        text.insert(sortedLines, at: sortedIndexSet)
    }
    
}
