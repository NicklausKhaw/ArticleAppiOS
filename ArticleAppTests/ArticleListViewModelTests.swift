import XCTest
import RxSwift
@testable import ArticleApp

class ArticleListViewModelTests: XCTestCase {

    var viewModel: ArticleListViewModel!
    var mockNetworkService: MockNetworkService!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = ArticleListViewModel(networkService: mockNetworkService)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        disposeBag = nil
        super.tearDown()
    }

    func testFetchMostPopularArticles_Success() {
        // Given
        let expectation = self.expectation(description: "Popular articles are fetched successfully")
        let mockArticles = [Article(id: 1, title: "Test Article", abstract: "", url: "", publishedDate: "", section: "", subsection: nil, byline: nil, media: nil)]
        mockNetworkService.mostPopularResult = .success(mockArticles)

        // Then
        viewModel.articles
            .filter { !$0.isEmpty } // Ignore intermediate empty states
            .subscribe(onNext: { articles in
                XCTAssertEqual(articles.count, 1)
                XCTAssertEqual(articles.first?.title, "Test Article")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        viewModel.configureForMostPopular(type: .mostViewed)

        waitForExpectations(timeout: 1.0)
    }

    func testFetchMostPopularArticles_Failure() {
        // Given
        let expectation = self.expectation(description: "Error message is received")
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockNetworkService.mostPopularResult = .failure(error)

        // Then
        viewModel.errorMessage
            .compactMap { $0 }
            .subscribe(onNext: { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        viewModel.configureForMostPopular(type: .mostViewed)

        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(viewModel.articles.value.isEmpty)
    }

    func testSearchArticles_Success() {
        // Given
        let expectation = self.expectation(description: "Search results are fetched successfully")
        let mockDocs = [
            ArticleSearchDoc(
                webUrl: "", snippet: "Test Snippet", leadParagraph: nil, abstract: nil, printPage: nil,
                source: nil, multimedia: nil, headline: Headline(main: "Test Headline"), keywords: nil,
                pubDate: "", documentType: "", newsDesk: nil, sectionName: nil, subsectionName: nil,
                byline: nil, typeOfMaterial: nil, id: "1", wordCount: nil, uri: nil
            )
        ]
        mockNetworkService.searchResult = .success(mockDocs)

        // Then
        viewModel.searchArticles
            .filter { !$0.isEmpty } // Ignore intermediate empty states
            .subscribe(onNext: { articles in
                XCTAssertEqual(articles.count, 1)
                XCTAssertEqual(articles.first?.headline.main, "Test Headline")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        viewModel.configureForSearch(query: "test")
        
        waitForExpectations(timeout: 1.0)
    }

    func testChangePeriod_RefetchesData() {
        // Given
        let initialExpectation = self.expectation(description: "Initial data is fetched")
        let updatedExpectation = self.expectation(description: "Updated data is fetched after period change")
        
        var callCount = 0
        viewModel.articles
            .filter { !$0.isEmpty } // Ignore intermediate empty states
            .subscribe(onNext: { articles in
                callCount += 1
                if callCount == 1 {
                    XCTAssertEqual(articles.first?.title, "7-Day Article")
                    initialExpectation.fulfill()
                } else if callCount == 2 {
                    XCTAssertEqual(articles.first?.title, "1-Day Article")
                    XCTAssertEqual(self.viewModel.selectedPeriod.value, 1)
                    updatedExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        // When (initial fetch)
        let initialArticles = [Article(id: 1, title: "7-Day Article", abstract: "", url: "", publishedDate: "", section: "", subsection: nil, byline: nil, media: nil)]
        mockNetworkService.mostPopularResult = .success(initialArticles)
        viewModel.configureForMostPopular(type: .mostViewed)
        wait(for: [initialExpectation], timeout: 1.0)
        
        // When (period change)
        let newArticles = [Article(id: 2, title: "1-Day Article", abstract: "", url: "", publishedDate: "", section: "", subsection: nil, byline: nil, media: nil)]
        mockNetworkService.mostPopularResult = .success(newArticles)
        viewModel.changePeriod(to: 1)

        // Then
        wait(for: [updatedExpectation], timeout: 1.0)
    }
} 
