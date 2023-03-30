//
//  SoundBarsDisplay.swift
//  WaveForm
//
//  Created by Hamish Young on 31/3/2023.
//

import SwiftUI

struct SoundBarsDisplay: View {

    let samples: [Float]
    @StateObject var vm: HomeViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.primary)
                .frame(width: 350, height: 350)
                .overlay(
                HStack(spacing: 4) {
                ForEach(samples, id: \.self) { level in
                        SoundBar(value: vm.normalizeLevel(level: level), sampleSize: 10)
                }
            })
        }
    }
}

struct SoundBarsDisplay_Previews: PreviewProvider {
    static var previews: some View {
        SoundBarsDisplay(samples: [Float](), vm: HomeViewModel())
    }
}
