//
//  WaveformViewModel.swift
//  WaveForm
//
//  Created by Hamish Young on 28/3/2023.
//

import Foundation

class WaveformViewModel : ObservableObject {

        func normalizeLevel(level: Float) -> CGFloat {
            let level = max(0.2, CGFloat(level) + 50) / 2
            return CGFloat(level * (300 / 25))
    }


}
