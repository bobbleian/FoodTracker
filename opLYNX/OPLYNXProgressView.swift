//
//  OPLYNXProgressView.swift
//  opLYNX
//
//  Created by Ian Campbell on 2017-12-11.
//  Copyright © 2017 CIS. All rights reserved.
//

import Foundation

protocol OPLYNXProgressView {
    func updateProgress(title: String?, description: String?)
    func endProgress()
}
