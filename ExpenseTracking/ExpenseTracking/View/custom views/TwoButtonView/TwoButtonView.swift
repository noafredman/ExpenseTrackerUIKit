//
//  TwoButtonView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman on 18/08/2023.
//

import UIKit

protocol TwoButtonViewInCellDelegate {
    func leftButtonClicked(indexPath: IndexPath)
    func rightButtonClicked(indexPath: IndexPath)
}

class TwoButtonView: UIView {
    @IBOutlet var mainView: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var selectedIndexPath: IndexPath?
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    //  init used if the view is created through IB
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("TwoButtonView", owner: self, options: nil)
        mainView.frame = self.bounds
        addSubview(self.mainView)
        
        leftButton.addTarget(self, action: #selector(leftButtonClicked), for: .touchDown)
        rightButton.addTarget(self, action: #selector(rightButtonClicked), for: .touchDown)
    }
    
    @objc func leftButtonClicked() throws {
        guard let delegate else {
            // can call regular delegate method if needed
            return
        }
        guard let selectedIndexPath else {
            throw NSError()
        }
        delegate.leftButtonClicked(indexPath: selectedIndexPath)
    }
    
    @objc func rightButtonClicked() throws {
        guard let delegate else {
            // can call regular delegate method if needed
            return
        }
        guard let selectedIndexPath else {
            throw NSError()
        }
        delegate.rightButtonClicked(indexPath: selectedIndexPath)
    }
}
