//
//  clipHelper.swift
//  clip
//
//  Created by Aries Aviles on 11/18/21.
//

import Foundation

final class clipHelper: ObservableObject {
    @Published var source: String = ""
    @Published var idx: Int = 0
    
    func handle(activity: NSUserActivity) {
        if let webpage = activity.webpageURL {
            source = webpage.lastPathComponent
        }
        
        switch source {
        case "darkcarpet":
            idx = 0
        case "wood":
            idx = 1
        case "fluffycarpet":
            idx = 2
        case "resilient":
            idx = 3
        case "stone":
            idx = 4
        default:
            idx = 0
        }
    }
}
