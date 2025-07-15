//
//  ErrorWrapper.swift
//  GXEAdventure
//
//  Created by Gemini on 2025-07-15.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import Foundation

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: Error
}
