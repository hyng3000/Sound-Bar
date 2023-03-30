//
//  SoundBar.swift
//  WaveForm
//
//  Created by Hamish Young on 28/3/2023.
//

import SwiftUI

struct SoundBar: View {

    var sampleSize: Int
    var value: CGFloat
    
    let soundColor: Color
    
    init(value: CGFloat, sampleSize: Int) {
        self.value = value
        self.sampleSize = sampleSize
        self.soundColor = { switch value {
                        case 0...25: return Color.gray
                        case 26...50: return Color.blue
                        case 51...200: return Color.green
                        default: return Color.red
                    }
                }()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    soundColor
                )
                .frame(
                width:
                    (UIScreen.main.bounds.width - CGFloat(sampleSize)
                    * 10)
                    / CGFloat(sampleSize),
                height: value)
        }
    }
}

struct SoundBar_Previews: PreviewProvider {
    static var previews: some View {
        SoundBar(value: 100.0, sampleSize: 10)
    }
}
