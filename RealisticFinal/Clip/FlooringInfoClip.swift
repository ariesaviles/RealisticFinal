//
//  FlooringInfoClip.swift
//  clip
//
//  Created by Aries Aviles on 11/18/21.
//


import SwiftUI
import SceneKit
import Neumorphic
import RealisticFinal

struct FlooringInfoClip: View {
    var idx: Int
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    Spacer().frame(width: 40)
                    VStack(alignment: .leading) {
                        Text(MOCK_FLOORING[idx].name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(MOCK_FLOORING[idx].colorName)
                    }
                    Spacer()
                }.padding(.bottom).padding(.top, 100)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.offWhite)
                        .frame(width: 340, height: 500)
                        .softOuterShadow()
                    switch idx {
                    case 0:
                        darkCarpetView().frame(width: 300, height: 400).offset(y: -30)
                            .softOuterShadow()
                    case 1:
                        ParagonView().frame(width: 300, height: 400).offset(y: -30)
                            .softOuterShadow()
                    case 2:
                        CalmSView().frame(width: 300, height: 400).offset(y: -30)
                            .softOuterShadow()
                    case 3:
                        ExpressionView().frame(width: 300, height: 400).offset(y: -30)
                            .softOuterShadow()
                    case 4:
                        StoneView().frame(width: 300, height: 400).offset(y: -30)
                            .softOuterShadow()
                    default:
                        darkCarpetView().frame(width: 300, height: 400).offset(y: -30)
                            .softOuterShadow()
                    }
                    
                }.frame(alignment: .center)

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
                
//                Spacer()
            }
            .background( Color.offWhite.ignoresSafeArea())
            .offset(y: -100)
            .padding(.top)
        }.background( Color.offWhite.ignoresSafeArea())


    }
}

struct FlooringInfoClip_Previews: PreviewProvider {
    static var previews: some View {
        FlooringInfoClip(idx: 0)
    }
}

