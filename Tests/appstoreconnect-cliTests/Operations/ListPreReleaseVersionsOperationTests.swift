// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Foundation
import Combine
import XCTest

final class ListPreReleaseVersionsOperationTests: XCTestCase {
    typealias Dependencies = ListPreReleaseVersionsOperation.Dependencies

    func testReturnsNoVersions() throws {
        let value = try ListPreReleaseVersionsOperation(options: .init())
            .execute(with: .makeDependency(Fixture.noDataResponse))
            .await()

        XCTAssertTrue(value.isEmpty)
    }

    func testReturnsOnePreReleaseVersion() throws {
        let value = try ListPreReleaseVersionsOperation(options: .init())
            .execute(with: .makeDependency(Fixture.dataResponse))
            .await()

        XCTAssertEqual(value.count, 1)
    }
}

private enum Fixture {
    static let noAppDataResponse = """
    {
      "data" : [ ],
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/apps"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)!

    static let noDataResponse = """
    {
      "data" : [ ],
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?include=app"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)!

    static let dataResponse = """
    {
      "data" : [ {
        "type" : "preReleaseVersions",
        "id" : "12345678-abcd-abcd-efab-1234567890ab",
        "attributes" : {
          "version" : "1.0",
          "platform" : "IOS"
        },
        "relationships" : {
          "builds" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/12345678-abcd-abcd-efab-1234567890ab/relationships/builds",
              "related" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions/12345678-abcd-abcd-efab-1234567890ab/builds"
            }
          },
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
        "relationships" : {
          "betaTesters" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/relationships/betaTesters",
              "related" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/betaTesters"
            }
          },
          "betaGroups" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/relationships/betaGroups",
              "related" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/betaGroups"
            }
          },
          "preReleaseVersions" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/relationships/preReleaseVersions",
              "related" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/preReleaseVersions"
            }
          },
          "betaAppLocalizations" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/relationships/betaAppLocalizations",
              "related" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/betaAppLocalizations"
            }
          },
          "builds" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/relationships/builds",
              "related" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/builds"
            }
          },
          "betaLicenseAgreement" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/relationships/betaLicenseAgreement",
              "related" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/betaLicenseAgreement"
            }
          },
          "betaAppReviewDetail" : {
            "links" : {
              "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/relationships/betaAppReviewDetail",
              "related" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890/betaAppReviewDetail"
            }
          }
        },
        "links" : {
          "self" : "https://api.appstoreconnect.apple.com/v1/apps/1234567890"
        }
      } ],
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?include=app&filter%5Bapp%5D=1234567890"
      },
      "meta" : {
        "paging" : {
          "total" : 1,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)!
}

private extension ListPreReleaseVersionsOperation.Dependencies {
    static let jsonDecoder = JSONDecoder()

    static func makeDependency(_ data: Data) -> Self {
        Self(
            preReleaseVersions: { _ in
                Future<PreReleaseVersionsResponse, Error> { promise in
                    let result = try! jsonDecoder.decode(PreReleaseVersionsResponse.self, from: data)
                    promise(.success(result))
                }
            },
            apps: { _ in
                fatalError("Shouldn't execute in test")
            }
        )
    }
}
