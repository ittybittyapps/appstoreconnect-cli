// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension String {
  func filenameSafe() -> String {
    let unsafeFilenameCharacters = CharacterSet(charactersIn: " *?:/\\.")
    return self.components(separatedBy: unsafeFilenameCharacters).joined(separator: "_")
  }
}
