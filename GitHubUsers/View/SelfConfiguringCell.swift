//
//  SelfConfiguringCell.swift
//  CollectionViewDemo
//
//  Created by Alex Nagy on 18/01/2020.
//  Copyright © 2020 Alex Nagy. All rights reserved.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
}
