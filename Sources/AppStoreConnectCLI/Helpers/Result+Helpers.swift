// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension Result {
    func render(format: OutputFormat) {
        Renderers.ResultRenderer(format: format).render(self)
    }
}
