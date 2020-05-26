// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Foundation

extension Certificate {
    static let createdSuccessResponse = """
    {
      "data" : {
        "type" : "certificates",
        "id" : "1234ABCD",
        "attributes" : {
          "serialNumber" : "6E06FFECD4B8D8C8",
          "certificateContent" : "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ",
          "displayName" : "Hello",
          "name" : "Mac Installer Distribution: Hello",
          "csrContent" : null,
          "platform" : "MAC_OS",
          "expirationDate" : "2021-04-22T08:02:15.000+0000",
          "certificateType" : "MAC_INSTALLER_DISTRIBUTION"
        },
        "links" : {
          "self" : "https://api.appstoreconnect.apple.com/v1/certificates/1234ABCD"
        }
      },
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/certificates"
      }
    }
    """.data(using: .utf8)

    static let noCertificateResponse = """
    {
      "data" : [ ],
      "links": {
        "self": "https://api.appstoreconnect.apple.com/v1/certificates"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)

    static let readCertificateResponse = """
    {
      "data" : [{
        "type" : "certificates",
        "id" : "1234ABCD",
        "attributes" : {
          "serialNumber" : "6E06FFECD4B8D8C8",
          "certificateContent" : "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ",
          "displayName" : "Hello",
          "name" : "Mac Installer Distribution: Hello",
          "csrContent" : null,
          "platform" : "MAC_OS",
          "expirationDate" : "2021-04-22T08:02:15.000+0000",
          "certificateType" : "MAC_INSTALLER_DISTRIBUTION"
        },
        "links" : {
          "self" : "https://api.appstoreconnect.apple.com/v1/certificates/1234ABCD"
        }
      }
     ],
      "links": {
        "self": "https://api.appstoreconnect.apple.com/v1/certificates"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)

    static let notUniqueResponse = """
    {
      "data" : [
        {
            "type" : "certificates",
            "id" : "1234ABCD",
            "attributes" : {
              "serialNumber" : "6E06FFECD4B8D8C8",
              "certificateContent" : "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ",
              "displayName" : "Hello",
              "name" : "Mac Installer Distribution: Hello",
              "csrContent" : null,
              "platform" : "MAC_OS",
              "expirationDate" : "2021-04-22T08:02:15.000+0000",
              "certificateType" : "MAC_INSTALLER_DISTRIBUTION"
            },
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/certificates/1234ABCD"
            }
        },
        {
            "type" : "certificates",
            "id" : "1234ABCD",
            "attributes" : {
              "serialNumber" : "6E06FFECD4B8D8C8",
              "certificateContent" : "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ",
              "displayName" : "Hello",
              "name" : "Mac Installer Distribution: Hello",
              "csrContent" : null,
              "platform" : "MAC_OS",
              "expirationDate" : "2021-04-22T08:02:15.000+0000",
              "certificateType" : "MAC_INSTALLER_DISTRIBUTION"
            },
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/certificates/1234ABCD"
            }
        }
     ],
      "links": {
        "self": "https://api.appstoreconnect.apple.com/v1/certificates"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)
}
