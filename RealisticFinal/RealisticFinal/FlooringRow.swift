//
//  FlooringRow.swift
//
//  Created by Aries Aviles on 9/23/21.
//

import SwiftUI

struct FlooringRow: View {
    var flooring: Flooring
    
    var body: some View {
        HStack {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.offWhite)
                    .frame(width: 105, height: 100)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                Image(flooring.imageURLs[0])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                    .shadow(color: Color.white.opacity(0.7), radius: 5, x: -5, y: -5)
            }
                    
            Spacer()
                .frame(width: CGFloat(30.0))

            // Titles
            VStack(alignment: .leading) {
                Text(flooring.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .font(.system(size: 20.0))
                Text(flooring.colorName)
                    .font(.system(size: 15.0))
            }
            
             // Spacer
            Spacer()
        }.padding(.top).padding(.bottom)
    }
}

struct FlooringRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FlooringRow(flooring: MOCK_FLOORING[0])
                .previewLayout(.fixed(width: 300, height: 80))
            FlooringRow(flooring: MOCK_FLOORING[1])
                .previewLayout(.fixed(width: 300, height: 80))
            FlooringRow(flooring: MOCK_FLOORING[2])
                .previewLayout(.fixed(width: 300, height: 80))
        }
        
    }
}

