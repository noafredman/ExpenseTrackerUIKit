//
//  ExpenseView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

final class ExpenseView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineSeperatorView: UIView!
    
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
        Bundle.main.loadNibNamed("ExpenseView", owner: self, options: nil)
        contentView.frame = self.bounds
        addSubview(self.contentView)
        backgroundColor = .clear
    }
}
