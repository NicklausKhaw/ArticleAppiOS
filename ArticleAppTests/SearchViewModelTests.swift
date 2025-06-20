import XCTest
import RxSwift
import RxTest
@testable import ArticleApp

class SearchViewModelTests: XCTestCase {

    var viewModel: SearchViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        viewModel = nil
        scheduler = nil
        disposeBag = nil
        super.tearDown()
    }

    func testIsSearchButtonEnabled() {
        // 1. Create an observer to record events
        let observer = scheduler.createObserver(Bool.self)

        // 2. Bind the observable to the observer
        viewModel.isSearchButtonEnabled
            .bind(to: observer)
            .disposed(by: disposeBag)

        // 3. Simulate text input events
        scheduler.createColdObservable([
            .next(10, ""),           // Initially empty
            .next(20, "   "),         // Whitespace only
            .next(30, "test"),       // Valid text
            .next(40, "")            // Back to empty
        ])
        .bind(to: viewModel.searchText)
        .disposed(by: disposeBag)

        // 4. Start the scheduler to run the simulation
        scheduler.start()

        // 5. Assert the recorded events
        XCTAssertEqual(observer.events, [
            .next(0, false),   // Initial state
            .next(10, false),  // Empty text
            .next(20, false),  // Whitespace only
            .next(30, true),   // Valid text
            .next(40, false)   // Back to empty
        ])
    }
} 