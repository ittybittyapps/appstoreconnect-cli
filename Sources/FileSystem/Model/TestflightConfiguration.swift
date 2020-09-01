// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

struct TestflightConfiguration {

    var app: Model.App
    var betaTesters: [BetaTester] = []
    var betaGroups: [BetaGroup] = []

}
