// Copyright 2020 Itty Bitty Apps Pty Ltd

enum AppLookupIdentifier {
     case appId(String)
     case bundleId(String)

     init(_ argument: String) {
         switch Int(argument) == nil {
         case true:
             self = .bundleId(argument)
         case false:
             self = .appId(argument)
         }
     }
 }
