//
//  ContentView.swift
//  clip
//
//  Created by Aries Aviles on 12/11/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = clipHelper()
    
    var body: some View {
        FlooringInfoClip(idx: viewModel.idx)
            .userActivity(NSUserActivityTypeBrowsingWeb) { activity in
                viewModel.handle(activity: activity)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
