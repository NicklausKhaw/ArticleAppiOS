import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    // MARK: - Published Properties (converted to RxSwift)
    let searchText = BehaviorRelay<String>(value: "")
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = BehaviorRelay<String?>(value: nil)
    
    private let networkService = NetworkService.shared
    private let disposeBag = DisposeBag()
    
    var isSearchButtonEnabled: Observable<Bool> {
        return searchText.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    func clearSearch() {
        searchText.accept("")
        errorMessage.accept(nil)
    }
} 