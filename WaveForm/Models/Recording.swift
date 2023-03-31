//
//  Recording.swift
//  WaveForm
//
//  Created by Hamish Young on 30/3/2023.
//

import Foundation

struct Recording: Identifiable, Equatable {
    let id: String = UUID().uuidString
    let name: String
    let stamp: Date
    var playing: Bool
    let url: URL
}
