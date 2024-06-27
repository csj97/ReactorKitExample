//
//  MyReactor.swift
//  ReactorKitExample
//
//  Created by openobject on 2024/06/24.
//

import Foundation
import UIKit
import RxSwift
import ReactorKit

class MyReactor: Reactor {
  // View에서 전달 받을 액션
  enum Action {
    case increaseNumber
    case loadImage(url: URL)
  }
  
  // 상태를 변경하는 단위
  // 해야할 작업 단위
  enum Mutation {
    case increaseNumber
    case imageLoaded(image: UIImage)
    case setLoading(isLoading: Bool)
  }
  
  struct MyReactorState {
    var currentNumber: Int = 0
    var image: UIImage?
    var isLoading: Bool = false
  }
  
  let initialState: MyReactorState = MyReactorState()
  private let imageLoaderService: ImageLoaderService
  
  init(imageLoaderService: ImageLoaderService) {
    self.imageLoaderService = imageLoaderService
  }
}

extension MyReactor {
  // Observable 방출
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .increaseNumber:
      return Observable.just(.increaseNumber)
    case .loadImage(let url):
      return Observable.concat([
        Observable.just(.setLoading(isLoading: true)),
        imageLoaderService.loadImage(url: url)
          .map { Mutation.imageLoaded(image: $0) },
        Observable.just(.setLoading(isLoading: false))
      ])
      
    }
  }
  
  // View update
  func reduce(state: MyReactorState, mutation: Mutation) -> MyReactorState {
    var newState = state
    switch mutation {
    case .increaseNumber:
      newState.currentNumber += 1
    case .imageLoaded(let image):
      newState.image = image
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
    }
    
    return newState
  }
}

protocol ImageLoaderService {
    func loadImage(url: URL) -> Observable<UIImage>
}

class ImageService: ImageLoaderService {
  func loadImage(url: URL) -> Observable<UIImage> {
    return Observable.create { observer in
      URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
          observer.onError(error)
          return
        }
        guard let data = data, let image = UIImage(data: data) else { return }
        observer.onNext(image)
        observer.onCompleted()
      }.resume()
      return Disposables.create()
    }
  }
}
