//
//  Extensions.swift
//  HapticTouchFinal
//
//  Created by Aries Aviles on 11/15/21.
//
import SwiftUI

extension Color {
    static let offWhite = Color(red: 240 / 255, green: 240 / 255, blue: 245 / 255)
    static let darkerOffWhite = Color(red: 210 / 255, green: 210 / 255, blue: 215 / 255)
    static let darkerButton = Color(red: 200 / 255, green: 200 / 255, blue: 205 / 255)
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension View {
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
    }
}
