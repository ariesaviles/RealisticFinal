//
//  FlooringLists.swift
//
//  Created by Aries Aviles on 9/23/21.
//

import SwiftUI

struct FlooringLists: View {
    @ObservedObject var settings = FloorSettings()
    
    var body: some View {
        CustomNavigationView(destination: FirstView(), isRoot: true, isLast: false, color: Color.offWhite, label: "Carpet") {
            List(CARPET_FLOORING) { flooring in
                NavigationLink(destination: FlooringInfo(flooringInfo: flooring, settings: settings)) {
                    FlooringRow(flooring: flooring)
                }
            }
            .background(Color.offWhite.ignoresSafeArea())
            .onAppear {
                    // Set the default to clear
                UITableView.appearance().backgroundColor = .clear
            }
            
        }
    }
}

struct FirstView : View {
    @ObservedObject var settings = FloorSettings()
    
    var body: some View {
        CustomNavigationView(destination: SecondView(), isRoot: false, isLast: false, color: Color.offWhite, label: "Hardwood") {
            List(HARDWOOD_FLOORING) { flooring in
                NavigationLink(destination: FlooringInfo(flooringInfo: flooring, settings: settings)) {
                    FlooringRow(flooring: flooring)
                }
            }
            .background(Color.offWhite.ignoresSafeArea())
            .onAppear {
                    // Set the default to clear
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}

struct SecondView : View {
    @ObservedObject var settings = FloorSettings()
    
    var body: some View {
        CustomNavigationView(destination: LastView(), isRoot: false, isLast: false, color: Color.offWhite, label: "Resilient") {
            List(VINYL_FLOORING) { flooring in
                NavigationLink(destination: FlooringInfo(flooringInfo: flooring, settings: settings)) {
                    FlooringRow(flooring: flooring)
                }
            }
            .background(Color.offWhite.ignoresSafeArea())
            .onAppear {
                    // Set the default to clear
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}

struct LastView : View {
    @ObservedObject var settings = FloorSettings()
    
    var body: some View {
        CustomNavigationView(destination: EmptyView(), isRoot: false, isLast: true, color: Color.offWhite, label: "Tile&Stone") {
            List(TILE_FLOORING) { flooring in
                NavigationLink(destination: FlooringInfo(flooringInfo: flooring, settings: settings)) {
                    FlooringRow(flooring: flooring)
                }
            }
            .background(Color.offWhite.ignoresSafeArea())
            .onAppear {
                    // Set the default to clear
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}

struct CustomNavigationView<Content: View, Destination : View>: View {
    let destination : Destination
    let isRoot : Bool
    let isLast : Bool
    let color : Color
    let label : String
    let content: Content
    @State var active = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State private var didTapLeft: Bool = false
    @State private var didTapRight: Bool = false
    
    init(destination: Destination, isRoot : Bool, isLast : Bool,color : Color, label : String, @ViewBuilder content: () -> Content) {
        self.destination = destination
        self.isRoot = isRoot
        self.isLast = isLast
        self.color = color
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                Color.offWhite
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.offWhite)
                            .frame(height: 250)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.darkerOffWhite)
                            .frame(width: 300, height: 5, alignment: .center)
                            .offset(x: 0, y: CGFloat(55))
                            .shadow(color: Color.white.opacity(0.5), radius: 2, x: 2, y: -2)
                            .shadow(color: Color.white.opacity(0.5), radius: 2, x: 2, y: 2)
                        
                        HStack {
                            Spacer().frame(width: 20)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.offWhite)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                                Image(systemName: "arrow.left")
                                    .frame(width: 30)
                                    .foregroundColor(.black)
                            }
                            .onTapGesture(count: 1, perform: {
                                self.mode.wrappedValue.dismiss()
                            })
                            .opacity(isRoot ? 0 : 1)
                            .padding(.top, 30)
                            
                            Spacer()
                            
                            VStack {
                                Text(self.label)
                                    .font(.system(size: 25.0))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(width: 130, height: 10)
                                    .padding(.top, 40)
                                
                            }
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.offWhite)
                                    .frame(width: 30, height: 30)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                                Image(systemName: "arrow.right")
                                    .frame(width: 30)
                            }.onTapGesture(count: 1, perform: {
                                self.active.toggle()
                            })
                            
                            .opacity(isLast ? 0 : 1)
                            .padding(.top, 30)
                                
                            
                            Spacer().frame(width: 20)
                            
                            NavigationLink(
                                destination: destination.navigationBarHidden(true)
                                    .navigationBarHidden(true),
                                isActive: self.$active,
                                label: {
                                    //no label
                                })
                        }
                        .padding([.leading,.trailing,.top], 8)
                        .frame(width: geometry.size.width)
                        .font(.system(size: 22))
                        .background(Color.clear)

                    }
                    .frame(width: geometry.size.width, height: 90)
                    .edgesIgnoringSafeArea(.top)

//                    Spacer()
                    
                    self.content
                        .offset(y: -40)
                        .frame(height: 700)
                        .padding(.top, 20)
                        .padding(.leading)
                        .padding(.trailing)
                        .cornerRadius(20)
                        .foregroundColor(.black)
                        .ignoresSafeArea()
                        
                }.background(Color.offWhite.ignoresSafeArea())
            }.navigationBarHidden(true)
        }
    }
}

struct FlooringLists_Previews: PreviewProvider {
    static var previews: some View {
        FlooringLists()
    }
}




