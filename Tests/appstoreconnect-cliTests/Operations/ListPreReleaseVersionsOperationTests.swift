// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Foundation
import Combine
import XCTest

final class ListPreReleaseVersionsOperationTests: XCTestCase {
    typealias Operation = ListPreReleaseVersionsOperation
    typealias Options = Operation.Options

    let successRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(dataResponse)) }) }
    )

    func testReturnsOnePreReleaseVersion() throws {
        let operation = Operation(options: Options(filterAppIds: [], filterVersions: [], filterPlatforms: [], sort: nil))
        let output = try operation.execute(with: successRequestor).await()
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output.first?.preReleaseVersion.attributes?.version, "1.0")
    }

    // TODO: return only included apps in JSON 
    static let dataResponse: PrereleaseVersionResponse = """
        {
          "data" : [ {
            "type" : "preReleaseVersions",
            "id" : "12345678-abcd-abcd-efab-1234567890ab",
            "attributes" : {
              "version" : "1.0",
              "platform" : "IOS"
            },
            "relationships" : {
              "app" : {
                "data" : {
                  "type" : "apps",
                  "id" : "1234567890"
                },
                "links" : {
                  "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/12345678-abcd-abcd-efab-1234567890ab/relationships/app",
                  "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/12345678-abcd-abcd-efab-1234567890ab/app"
                }
              }
            },
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/12345678-abcd-abcd-efab-1234567890ab"
            }
          } ],
          "included" : [ {
            "type" : "apps",
            "id" : "1234567890",
            "attributes" : {
              "name" : "A Test App",
              "bundleId" : "com.example.App",
              "sku" : "EXAMPLEAPP1",
              "primaryLocale" : "en-AU"
            },
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890"
            }
          } ],
          "links" : {
            "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?include=app"
          },
          "meta" : {
            "paging" : {
              "total" : 1,
              "limit" : 50
            }
          }
        }
        """
        .data(using: .utf8)
        .map({ try! jsonDecoder.decode(PrereleaseVersionResponse.self, from: $0) })!
}

