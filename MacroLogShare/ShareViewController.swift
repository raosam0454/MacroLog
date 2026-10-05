//
//  ShareViewController.swift
//  MacroLogShare
//
//  Created by Sumangala Rao on 3/10/2026.
//

import UIKit
import Social
import UniformTypeIdentifiers

/// The Share Extension. It appears in the system share sheet for web links and
/// text, lets the woman add an optional note, and on Post it saves what was
/// shared into the App Group inbox for the app to pick up. It always completes
/// its request, so the sheet dismisses cleanly whatever happens.
class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        true
    }

    override func didSelectPost() {
        let note = contentText ?? ""

        extractSharedString { [weak self] shared in
            let pieces = [shared, note].filter { !$0.isEmpty }
            let text = pieces.isEmpty ? "Shared item" : pieces.joined(separator: " — ")

            SharedInboxStore.append(SharedItem(text: text))
            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        []
    }

    /// Pulls the first web URL or text out of what was shared. Always calls back,
    /// with an empty string if nothing usable was found, so Post never hangs.
    private func extractSharedString(completion: @escaping (String) -> Void) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else {
            completion("")
            return
        }

        let urlType = UTType.url.identifier
        let textType = UTType.plainText.identifier

        if provider.hasItemConformingToTypeIdentifier(urlType) {
            provider.loadItem(forTypeIdentifier: urlType, options: nil) { data, _ in
                let value = (data as? URL)?.absoluteString ?? (data as? String) ?? ""
                DispatchQueue.main.async { completion(value) }
            }
        } else if provider.hasItemConformingToTypeIdentifier(textType) {
            provider.loadItem(forTypeIdentifier: textType, options: nil) { data, _ in
                let value = (data as? String) ?? (data as? URL)?.absoluteString ?? ""
                DispatchQueue.main.async { completion(value) }
            }
        } else {
            DispatchQueue.main.async { completion("") }
        }
    }
}
