//
//  MFCustomError.swift
//  Minifire
//
//  Created by 디해 on 1/8/25.
//

import Foundation

public protocol MFErrorDecoder {
    associatedtype MFCustomError: Error

    func decodeError(from data: Data, response: HTTPURLResponse) throws -> MFCustomError
}