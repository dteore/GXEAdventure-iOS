//
//  SafariView.swift
//  AdventureApp
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2023 YourCompany. All rights reserved.
//

import SwiftUI
import SafariServices // Import SafariServices for SFSafariViewController

// This struct is a UIViewControllerRepresentable wrapper for SFSafariViewController.
// It allows us to present a Safari web view within our SwiftUI application.
struct SafariView: UIViewControllerRepresentable {
    let url: URL // The URL to load in the Safari View Controller

    // Creates and configures your UIViewController.
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Initialize SFSafariViewController with the given URL.
        let safariVC = SFSafariViewController(url: url)
        // Optionally, you can set a delegate if you need to handle dismissal or other events.
        // safariVC.delegate = context.coordinator // Uncomment if a coordinator is needed
        return safariVC
    }

    // Updates the state of the specified UIViewController with new information from SwiftUI.
    // In this simple case, if the URL changes, a new SFSafariViewController would typically be presented,
    // so this method might not be heavily used for simple URL changes.
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed for a static URL presentation.
    }

    // If you need a Coordinator for SFSafariViewControllerDelegate methods, you would define it here.
    /*
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView

        init(_ parent: SafariView) {
            self.parent = parent
        }

        // Example delegate method: called when the user taps 'Done' or dismisses the view controller
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            // Handle dismissal, e.g., update a binding to dismiss the sheet in SwiftUI
            // parent.isPresented = false // If you had a binding for presentation
        }
    }
    */
}

