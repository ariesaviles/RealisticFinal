//
//  GridView.swift
//
//  Created by Aries Aviles on 11/2/21.
//

import SwiftUI
import ExyteGrid

struct VCardLabel: View {
    var text: String
    
   var body: some View {
       Text(text)
           .foregroundColor(.white)
           .font(.system(size: 25))
           .font(.headline).bold()
   }
}

struct VCardView: View {
    var idx: Int
    
   var body: some View {
       ZStack {
           
           Image("floor\(idx)")
               .resizable()
               .aspectRatio(contentMode: .fit)
               .cornerRadius(10)
               .frame(minWidth: 100, minHeight: 50)
               .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
               .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
           if (idx == 0) {
               VCardLabel(text: "Carpet")
               
           } else if (idx == 1) {
               VCardLabel(text: "Wood")
           } else if (idx == 2) {
               VCardLabel(text: "Resilient")
           } else if (idx == 3) {
               VCardLabel(text: "Tile & Stone")
           }

       }
   }
}

struct GridView: View {
    @EnvironmentObject var chosenFloor: FloorSettings
    @State private var isModal = false
    
    var body: some View {
//        let gridItems = [
//            GridItem(.fixed(150), spacing: 10, alignment: .leading),
//            GridItem(.fixed(150), spacing: 10, alignment: .leading),
//            GridItem(.fixed(150), spacing: 10, alignment: .leading)
//        ]
        
        HStack (alignment: .top) {
            Spacer()
            Image("shaw-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 130)
                .padding(.top, -20)
                .padding(.bottom, -5)
            Spacer()
        }
        .background(Color.offWhite.ignoresSafeArea())
        
        Grid(tracks: 2, spacing: [10, 10]) {
            ForEach(0..<4) { idx in
                if (idx == 0 || idx == 3) {
                    VCardView(idx: idx)
                        .gridSpan(column: 2)
                        .onTapGesture {
                            self.isModal = true
                        }
                        .sheet(isPresented: $isModal, content: {
                            if (idx == 0) {
                                FlooringLists()
                            } else {
                                LastView()
                            }
                        }) // sheet
                } else {
                    VCardView(idx: idx)
                        .onTapGesture {
                            self.isModal = true
                        }
                        .sheet(isPresented: $isModal, content: {
                            if (idx == 1) {
                                FirstView()
                            } else {
                                SecondView()
                            }
                        }) // sheet
                }
                
            }

        }
        .gridContentMode(.scroll)
        .gridPacking(.dense)
        .gridFlow(.rows)
        .background(Color.offWhite.ignoresSafeArea())
        .padding(.top, -10)
    } // end of body
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}
