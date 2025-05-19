//
//  MiyaTests.swift
//  Minifire
//
//  Created by 디해 on 1/23/25.
//

import XCTest
import Minifire


struct Post: Codable {
    let title: String
    let body: String
    let userId: Int
}

enum JSONPlaceHolderAPI {
    case getPost(id: Int)
    case createPost(post: Post)
}

extension JSONPlaceHolderAPI: MFTarget {
    var baseURL: URL {
        URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getPost(let id):
            return "/posts/\(id)"
        case .createPost:
            return "/posts"
        }
    }
    
    var method: Minifire.MFHTTPMethod {
        switch self {
        case .getPost:
            return .get
        case .createPost:
            return .post
        }
    }
    
    var queries: Minifire.Parameters? {
        return nil
    }
    
    var task: Minifire.MFTask {
        switch self {
        case .getPost:
            return .requestPlain
        case .createPost(let post):
            return .requestJSONEncodable(post)
        }
    }
    
    var headers: Minifire.MFHeaders? {
        switch self {
        case .getPost:
            return nil
        case .createPost:
            let headers: MFHeaders = [
                .contentType("application/json")
            ]
            return headers
        }
    }
}

final class MiyaTests: XCTestCase {
    let baseURL = "https://jsonplaceholder.typicode.com"
    
    func test_GET_리퀘스트() {
        let expectation = self.expectation(description: "요청 완료")
        
        let provider = MFProvider<JSONPlaceHolderAPI>()
        
        Task {
            let post = try await provider.requestDecodable(of: Post.self, .getPost(id: 1)).value
            
            XCTAssertNotNil(post, "응답이 도착해야 합니다.")
            print("응답 post: ", post)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_POST_리퀘스트() {
        let expectation = self.expectation(description: "요청 완료")
        
        let provider = MFProvider<JSONPlaceHolderAPI>()
        
        let post = Post(title: "테스트", body: "테스트", userId: 1)
        
        Task {
            let response = try await provider.request(.createPost(post: post))
            
            XCTAssertNotNil(response.value, "응답이 도착해야 합니다.")
            XCTAssertEqual(response.httpResponse?.statusCode, 201, "Http 상태 코드가 201이어야 합니다.")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
