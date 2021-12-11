//
//  FlooringInfo.swift
//
//  Created by Aries Aviles on 9/25/21.
//

import SwiftUI
import SceneKit
import Neumorphic
import ExyteGrid

struct FlooringInfo: View {
    var flooringInfo: Flooring
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var settings : FloorSettings

    var btnBack : some View { Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                Image("ic_back") // set image here
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    Text("Go back")
                }
            }
        }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    Spacer().frame(width: 40)
                    VStack(alignment: .leading) {
                        Text("\(settings.name)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("\(settings.color)")
                    }
                    Spacer()
                }.padding(.bottom).padding(.top, 100)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.offWhite)
                        .frame(width: 340, height: 500)
                        .softOuterShadow()
                    
                    switch flooringInfo.name {
//                        ========== CARPET
                    case "Subtle Aura":
                        SubtleAView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Vintage Revival":
                        VintageRView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Inspired Design":
                        InspiredDView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Calm Serenity":
                        CalmSView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
//                     ============ WOOD
                    case "Expressions":
                        ExpressionView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Landmark Walnut":
                        LandmarkWView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Empire Oak Herringbone":
                        EmpireOakView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
//                     ============ VINYL
                    case "Paragon Mix Plus":
                        ParagonView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Bascilica Plus":
                        BascilicaView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Market Square":
                        MarketSquareView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
//                     ============ TILE
                    case "Revival Maria":
                        RevivalView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Islander 3x6 Wall":
                        IslanderView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    case "Grand Strands Wall":
                        GrandStrandsView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    default:
                        SubtleAView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                    }

//                    SubtleAView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
//                    VintageRView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
//                    InspiredDView().frame(width: 300, height: 400).offset(y: -30).softOuterShadow()
                }.frame(alignment: .center)
                
//                HStack(spacing: 20) {
//                    Spacer().frame(width:10)
//                    Image(flooringInfo.imageURLs[1])
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                    Image(flooringInfo.imageURLs[2])
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                    Spacer().frame(width:10)
//                }.padding(.top)
            
    //            RoundedRectangle(cornerRadius: 25)
    //                .fill(Color.offWhite)
    //                .frame(width: 300, height: 400, alignment: .center)
    //                .softOuterShadow()
                
                
                // BUTTOSNS
                
                VStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color.offWhite)
                                .frame(width: 130, height: 45)
                            .softOuterShadow()
                            Text("+ ADD TO MY SHAW").font(Font.system(size:10))
                        }
                        
                        Spacer().frame(width: 20)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color.offWhite)
                                .frame(width: 130, height: 45)
                            .softOuterShadow()
                            Text("+ SAMPLES WAIT LIST").font(Font.system(size:10))
                        }
                        
                    }.padding(.top)
                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 50)
//                            .fill(Color.black.opacity(0.85))
//                            .frame(width: 285, height: 50)
//                        .softOuterShadow()
//                        Text("WANT TO COLOR MATCH?").font(Font.system(size:14)).foregroundColor(.white)
//                    }.padding(.top)
                }
                
                
                VStack {
                    Text("Refined + effortless, the Caress Collection is styled for you. Featuring Anso® Nylon with R2X® built-in stain & soil protection, LifeGuard® Spill-Proof Backing™ and a 20-year warranty, Caress offers the best in style and design.")
                        .lineLimit(Int.max)
                        .padding(.leading).padding(.trailing)
                    
                }
                .padding()
                
                Spacer()
            }
            .background( Color.offWhite.ignoresSafeArea())
            .offset(y: -150)
        }.navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        .onAppear {
            settings.configureSettings(flooring: flooringInfo)
        }

    }
    
}



struct FlooringInfo_Previews: PreviewProvider {
    static var previews: some View {
//        @ObservedObject var settings = FloorSettings()
        FlooringInfo(flooringInfo: MOCK_FLOORING[0], settings: FloorSettings())
    }
}

