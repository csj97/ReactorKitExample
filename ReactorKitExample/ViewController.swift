//
//  ViewController.swift
//  ReactorKitExample
//
//  Created by openobject on 2024/06/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class ViewController: UIViewController {
  var disposeBag = DisposeBag()
  var reactor: MyReactor?
  
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var numButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.reactor = MyReactor(imageLoaderService: ImageService())
    self.bind(reactor: self.reactor!)
  }
}

extension ViewController: View {
  func bind(reactor: MyReactor) {
    self.numButton.rx.tap.asObservable()
      .map { _ in Reactor.Action.loadImage(url: URL(string: "https://picsum.photos/300/200")!) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  
    reactor.state
      .map { $0.currentNumber }
      .distinctUntilChanged()
      .map { String($0) }
      .bind(to: self.numLabel.rx.text)
      .disposed(by: self.disposeBag)
    
    reactor.state
      .map { $0.image }
      .bind(to: self.imageView.rx.image)
      .disposed(by: self.disposeBag)
    
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: self.loadIndicator.rx.animateAndHide)
      .disposed(by: self.disposeBag)
  }
}

extension Reactive where Base: UIActivityIndicatorView {
  var animateAndHide: Binder<Bool> {
    return Binder(self.base) { activityIndicator, isLoading in
      if isLoading {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
      } else {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
      }
    }
  }
}
