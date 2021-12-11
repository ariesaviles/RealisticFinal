//
//  FloorSettings.swift
//  HapticTouchFinal
//
//  Created by Aries Aviles on 11/15/21.
//

import SwiftUI

class FloorSettings: ObservableObject {
    @Published var name = "Landmark Walnut"
    @Published var color = "Washington"
    @Published var imgName = "landmarkwalnut-full"
    @Published var type = "jpeg"
    @Published var colliName = "CollisionSmall"
    @Published var ahapName = "Texture-solid"
    
    func configureSettings(flooring: Flooring) {
        name = flooring.name
        color = flooring.colorName
        imgName = flooring.imageURLs[0]
        type = flooring.flooringType
        colliName = flooring.collision
        ahapName = flooring.ahap
    }
}
