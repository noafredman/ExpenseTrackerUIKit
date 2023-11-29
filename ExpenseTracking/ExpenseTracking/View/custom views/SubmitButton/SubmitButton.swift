//
//  SubmitButton.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

protocol SubmitButtonDelegate {
    func submit()
}

final class SubmitButton: UIButton {
    
    @IBInspectable var title: String {
        set {
            self.button.setTitle(newValue, for: .normal)
        }
        get {
            self.button.title(for: .normal) ?? ""
        }
    }
    
    @IBOutlet weak var button: UIButton!
    
    var delegate: SubmitButtonDelegate?
    
    //  init used if the view is created programmatically
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
        Bundle.main.loadNibNamed("SubmitButton", owner: self, options: nil)
        button.frame = self.bounds
        addSubview(self.button)
        backgroundColor = .clear
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        delegate?.submit()
    }
    
}
