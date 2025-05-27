//
//  MFRequest.swift
//  TDNetwork
//
//  Created by 디해 on 1/8/25.
//

import Foundation

public typealias Queries = [String: Any]
public typealias Parameters = [String: Any]

public class MFRequest {
    let id: UUID
    
    private let url: MFURLConvertible
    
    private var method: MFHTTPMethod = .get
    
    private var queries: Queries? = nil
    
    private var parameters: Parameters? = nil
    
    private var headers: MFHeaders? = nil
    
    private(set) var error: MFError? = nil
    
    private(set) var validation: ((URLResponse) throws -> Void)?
    
    public var request: URLRequest? {
        try? asURLRequest()
    }

    public init(id: UUID = UUID(), url: MFURLConvertible) {
        self.id = id
        self.url = url
    }
    
    @discardableResult
    public func get() -> Self {
        self.method = .get
        return self
    }
    
    @discardableResult
    public func post() -> Self {
        self.method = .post
        return self
    }
    
    @discardableResult
    public func put() -> Self {
        self.method = .put
        return self
    }
    
    @discardableResult
    public func delete() -> Self {
        self.method = .delete
        return self
    }
    
    @discardableResult
    public func setMethod(_ method: MFHTTPMethod) -> Self {
        self.method = method
        return self
    }
    
    @discardableResult
    public func addQueries(_ queries: Parameters) -> Self {
        self.queries = (self.queries?.merging(queries) { (_, new) in new }) ?? queries
        return self
    }
    
    @discardableResult
    public func addParameters(_ parameters: Parameters) -> Self {
        self.parameters = (self.parameters?.merging(parameters) { (_, new) in new }) ?? parameters
        return self
    }
    
    @discardableResult
    public func addParameters<T: Encodable>(_ encodable: T) -> Self {
        do {
            let dictionary = try encodable.asDictionary()
            self.parameters = dictionary
            return self
        } catch {
            self.error = error as? MFError
            return self
        }
    }
    
    @discardableResult
    public func addHeaders(_ headers: MFHeaders) -> Self {
        self.headers = (self.headers?.merge(with: headers)) ?? headers
        return self
    }
    
    @discardableResult
    public func validate(statusCode acceptableStatusCodes: Range<Int> = 200..<300) -> Self {
        self.validation = { response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MFError.invalidResponse(response)
            }
            guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
                throw MFError.invalidStatusCode(httpResponse.statusCode)
            }
        }
        return self
    }
    
    func asURLRequest() throws -> URLRequest {
        let request = try URLRequest(
            url: url,
            method: method,
            queries: queries,
            parameters: parameters,
            headers: headers
        )
        return request
    }
}
