//
//  CustomHorizontalStackView.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-08-28.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

class CustomHorizontalStackView: UIStackView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: Initialization
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBackgroundView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        addBackgroundView()
    }
 */
    
    private func addBackgroundView() {
        let backGroundView = UIView()
        backGroundView.backgroundColor = .brown
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backGroundView)
        backGroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backGroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backGroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }

}
