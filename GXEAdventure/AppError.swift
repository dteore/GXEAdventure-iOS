//
//  AppError.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import Foundation

struct AppError: Identifiable, Error {
    let id = UUID()
    let message: String
}
