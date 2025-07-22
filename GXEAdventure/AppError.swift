//
//  AppError.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import Foundation

struct AppError: Identifiable, Error, LocalizedError {
    let id: UUID
    let message: String?
    let errorCode: Int

    init(message: String? = nil, errorCode: Int = 1) {
        self.id = UUID()
        self.message = message
        self.errorCode = errorCode
    }

    var errorDescription: String? {
        return message ?? "An unexpected error occurred (Error Code: \(errorCode)). Please try again."
    }
}
