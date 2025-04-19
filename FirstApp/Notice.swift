//
//  Notice.swift
//  FirstApp
//
//  Created by Arsalan Lodhi on 4/17/25.
//

import Foundation

struct Notice: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let date: String
    let content: String
}
