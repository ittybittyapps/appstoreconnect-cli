// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import XCTest

final class ReadPreReleaseVersionOperationTests: XCTestCase {
    typealias Operation = ReadPreReleaseVersionOperation
    typealias Options = Operation.Options
    typealias OperationError = ReadPreReleaseVersionOperation.Error

    let successResponseRequestor = OneEndpointTestRequestor(response: { _ in
        Future({ $0(.success(onePreRealeseVersionResponse)) }) }
    )

    let noResponseRequestor = OneEndpointTestRequestor(response: { _ in
        Future { $0(.success(noPreReleaseVersionResponse)) }}
    )

    let notUniqueRequestor = OneEndpointTestRequestor(response: { _ in
        Future { $0(.success(notUniqueResponse)) }}
    )

    func testOnePreReleaseVersion() throws {
        let operation = Operation(options: Options(filterAppId: "1504341572", filterVersion: "1.0"))
        let output = try operation.execute(with: successResponseRequestor).await()
        XCTAssertEqual(output.preReleaseVersion.attributes?.version, "1.0")
    }

    func testNoPreReleaseVersion() {
        let operation = Operation(options: Options(filterAppId: "1504341572", filterVersion: "0.0"))

        XCTAssertThrowsError(try operation.execute(with: noResponseRequestor).await()) { error in
            XCTAssertEqual(error as! OperationError, OperationError.noVersionExists)
        }
    }

    func testNotUniquePreReleaseVersion() {
        let operation = Operation(options: Options(filterAppId: "1504341572", filterVersion: "1.0"))

        XCTAssertThrowsError(try operation.execute(with: notUniqueRequestor).await()) { error in
            XCTAssertEqual(error as! OperationError, OperationError.versionNotUnique)
        }
    }

    static let onePreRealeseVersionResponse: PreReleaseVersionsResponse = """
        {
          "data" : [ {
            "type" : "preReleaseVersions",
            "id" : "bc4bba16-2af1-4517-8de7-21790799ca72",
            "attributes" : {
              "version" : "1.0",
              "platform" : "IOS"
            },
            "relationships" : {
              "builds" : {
                "links" : {
                  "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/relationships/builds",
                  "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/builds"
                }
              },
              "app" : {
                "links" : {
                  "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/relationships/app",
                  "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/app"
                }
              }
            },
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72"
            }
          } ],
          "links" : {
            "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?filter%5Bapp%5D=1504341572"
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
        .map({ try! jsonDecoder.decode(PreReleaseVersionsResponse.self, from: $0) })! // swiftlint:disable:this force_try

    static let notUniqueResponse: PreReleaseVersionsResponse  = """
    {
      "data" : [ {
        "type" : "preReleaseVersions",
        "id" : "bc4bba16-2af1-4517-8de7-21790799ca72",
        "attributes" : {
          "version" : "1.0",
          "platform" : "IOS"
        },
        "relationships" : {
          "builds" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/relationships/builds",
              "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/builds"
            }
          },
          "app" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/relationships/app",
              "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/app"
            }
          }
        },
        "links" : {
          "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72"
        }
      } ,
        {
          "type" : "preReleaseVersions",
          "id" : "bc4bba16-2af1-4517-8de7-21790799ca72",
          "attributes" : {
            "version" : "1.1",
            "platform" : "IOS"
          },
          "relationships" : {
            "builds" : {
              "links" : {
                "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/relationships/builds",
                "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/builds"
              }
            },
            "app" : {
              "links" : {
                "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/relationships/app",
                "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72/app"
              }
            }
          },
          "links" : {
            "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72"
          }
        } ],
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?filter%5Bapp%5D=1504341572"
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
        .map({ try! jsonDecoder.decode(PreReleaseVersionsResponse.self, from: $0) })! // swiftlint:disable:this force_try

    static let noPreReleaseVersionResponse: PreReleaseVersionsResponse = """
    {
      "data" : [ ],
      "links": {
        "self": "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/bc4bba16-2af1-4517-8de7-21790799ca72"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """
        .data(using: .utf8)
        .map({ try! jsonDecoder.decode(PreReleaseVersionsResponse.self, from: $0) })! // swiftlint:disable:this force_try
}
