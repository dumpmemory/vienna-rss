//
//  BrowserContextMenuDelegate.swift
//  Vienna
//
//  Copyright 2020 Tassilo Karge
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

protocol BrowserContextMenuDelegate: AnyObject {
    func contextMenuItemsFor(purpose: WKWebViewContextMenuContext, existingMenuItems: [NSMenuItem]) -> [NSMenuItem]
    func processMenuItem(_ menuItem: NSMenuItem)
}

enum WKWebViewContextMenuContext {
    case page(url: URL)
    case link(_ url: URL)
    case media(_ media: URL)
    case mediaLink(media: URL, link: URL)
    case text(_ text: String)
}

// Some Apple private menu-item identifiers in WKMenuItemIdentifiersPrivate.h
extension NSUserInterfaceItemIdentifier {
    static let WKMenuItemCopy = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierCopy")
    static let WKMenuItemDownloadImage = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierDownloadImage")
    static let WKMenuItemDownloadLinkedFile = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierDownloadLinkedFile")
    static let WKMenuItemDownloadMedia = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierDownloadMedia")
    static let WKMenuItemGoBack = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierGoBack")
    static let WKMenuItemGoForward = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierGoForward")
    static let WKMenuItemOpenLinkInBackground = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierOpenLinkInBackground")
    static let WKMenuItemOpenLinkInNewWindow = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierOpenLinkInNewWindow")
    static let WKMenuItemOpenLink = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierOpenLink")
    static let WKMenuItemOpenLinkInSystemBrowser = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierOpenLinkInSystemBrowser")
    static let WKMenuItemOpenMediaInNewWindow = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierOpenMediaInNewWindow")
    static let WKMenuItemOpenImageInNewWindow = NSUserInterfaceItemIdentifier("WKMenuItemIdentifierOpenImageInNewWindow")
}
