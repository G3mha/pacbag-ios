import XCTest
@testable import PacBag

/// Feeds the parser trimmed copies of real Wikipedia API answers for "Kyoto, Japan".
final class WikipediaPhotoTests: XCTestCase {
    private let search = Data("""
    {"query":{"pages":[{"pageid":37652,"title":"Kyoto","thumbnail":{"source":"https://upload.wikimedia.org/kyoto.jpg","width":1200,"height":793},"pageimage":"Kiyomizu-dera,_Kyoto,_November_2016_-02.jpg"}]}}
    """.utf8)

    func testFindsTheLeadImageOfAMatchingArticle() {
        let image = WikipediaPhoto.leadImage(from: search, for: "Kyoto, Japan")
        XCTAssertEqual(image?.fileName, "Kiyomizu-dera,_Kyoto,_November_2016_-02.jpg")
        XCTAssertEqual(image?.url, URL(string: "https://upload.wikimedia.org/kyoto.jpg"))
    }

    func testIgnoresAnArticleAboutSomethingElse() {
        XCTAssertNil(WikipediaPhoto.leadImage(from: search, for: "Grandma's house"))
    }

    func testMatchesADestinationEndingInAFlag() {
        XCTAssertNotNil(WikipediaPhoto.leadImage(from: search, for: "Kyoto 🇯🇵"))
    }

    func testMatchesIgnoringCaseAndAccents() {
        XCTAssertNotNil(WikipediaPhoto.leadImage(from: search, for: "kyóto"))
    }

    func testAnArticleWithoutAnImageHasNoPhoto() {
        let data = Data(#"{"query":{"pages":[{"title":"Kyoto"}]}}"#.utf8)
        XCTAssertNil(WikipediaPhoto.leadImage(from: data, for: "Kyoto"))
    }

    func testCreditsTheArtistAndLicense() throws {
        let info = Data("""
        {"query":{"pages":[{"title":"File:Kiyomizu-dera, Kyoto, November 2016 -02.jpg","imageinfo":[{"descriptionurl":"https://commons.wikimedia.org/wiki/File:Kiyomizu-dera,_Kyoto,_November_2016_-02.jpg","extmetadata":{"Artist":{"value":"<a href=\\"//commons.wikimedia.org/wiki/User:Martin_Falbisoner\\">Martin Falbisoner</a>"},"LicenseShortName":{"value":"CC BY-SA 4.0"}}}]}]}}
        """.utf8)
        let photo = try XCTUnwrap(WikipediaPhoto.placePhoto(imageURL: URL(string: "https://upload.wikimedia.org/kyoto.jpg")!, fileInfo: info))
        XCTAssertEqual(photo.credit, "Photo: Martin Falbisoner, CC BY-SA 4.0, Wikimedia Commons")
        XCTAssertEqual(photo.sourceURL.host(), "commons.wikimedia.org")
    }

    func testCreditsCommonsWhenTheFileNamesNoArtist() throws {
        let info = Data(#"{"query":{"pages":[{"imageinfo":[{"descriptionurl":"https://commons.wikimedia.org/wiki/File:X.jpg"}]}]}}"#.utf8)
        let photo = try XCTUnwrap(WikipediaPhoto.placePhoto(imageURL: URL(string: "https://upload.wikimedia.org/x.jpg")!, fileInfo: info))
        XCTAssertEqual(photo.credit, "Photo: Wikimedia Commons")
    }
}
