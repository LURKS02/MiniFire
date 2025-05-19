import XCTest
import Minifire

final class MinifireTests: XCTestCase {
    let baseURL = "https://jsonplaceholder.typicode.com"
    
    func test_리퀘스트() {
        let expectation = self.expectation(description: "요청 완료")
        
        let request = MFRequest(url: "\(baseURL)/posts")
        
        Task {
            let response = try await MF.request(request)
            let data = response.value
            let statusCode = response.httpResponse?.statusCode
            
            XCTAssertNotNil(data, "응답이 도착해야 합니다.")
            XCTAssertEqual(statusCode, 200, "Http 상태 코드가 200이어야 합니다.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_파라미터가_있는_리퀘스트() {
        let expectation = self.expectation(description: "요청 완료")
        
        let parameters: [String: Any] = [
            "title": "foo",
            "body": "bar",
            "userId": 1
        ]
        
        let request = MFRequest(url: "\(baseURL)/posts")
            .post()
            .addParameters(parameters)
            .addHeaders([
                .contentType("application/json")
            ])
        
        Task {
            let response = try await MF.request(request)
            let data = response.value
            let statusCode = response.httpResponse?.statusCode
            
            XCTAssertNotNil(data, "응답이 도착해야 합니다.")
            XCTAssertEqual(statusCode, 201, "Http 상태 코드가 201이어야 합니다.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_Encodable한_파라미터가_있는_리퀘스트() {
        let expectation = self.expectation(description: "요청 완료")
        
        struct Post: Encodable {
            let title: String
            let body: String
            let userId: Int
        }
        
        let post: Post = .init(title: "foo", body: "bar", userId: 1)
        
        let request = MFRequest(url: "\(baseURL)/posts")
            .post()
            .addParameters(post)
            .addHeaders([
                .contentType("application/json")
            ])
        
        Task {
            let response = try await MF.request(request)
            let data = response.value
            let statusCode = response.httpResponse?.statusCode
            
            XCTAssertNotNil(data, "응답이 도착해야 합니다.")
            XCTAssertEqual(statusCode, 201, "Http 상태 코드가 201이어야 합니다.")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_Decodable_리스폰스() {
        let expectation = self.expectation(description: "요청 완료")
        
        struct Post: Decodable {
            let userId: Int
            let id: Int
            let title: String
            let body: String
        }
        
        let request = MFRequest(url: "\(baseURL)/posts/1")
        
        Task {
            let response = try await MF.requestDecodable(of: Post.self, request)
            let decodableValue = response.value
            let statusCode = response.httpResponse?.statusCode
            
            XCTAssertNotNil(decodableValue, "응답이 도착해야 합니다.")
            XCTAssertEqual(statusCode, 200, "Http 상태 코드가 200이어야 합니다.")
            print("디코딩된 객체: ", decodableValue)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_String_리스폰스() {
        let expectation = self.expectation(description: "요청 완료")
        
        let request = MFRequest(url: "\(baseURL)/posts/1")
        
        Task {
            let response = try await MF.requestString(request)
            let stringValue = response.value
            let statusCode = response.httpResponse?.statusCode
            
            XCTAssertNotNil(stringValue, "응답이 도착해야 합니다.")
            XCTAssertEqual(statusCode, 200, "Http 상태 코드가 200이어야 합니다.")
            print("응답 문자열: ", stringValue)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_JSON_리스폰스() {
        let expectation = self.expectation(description: "요청 완료")
        
        let request = MFRequest(url: "\(baseURL)/posts/1")
        
        Task {
            let response = try await MF.requestString(request)
            let jsonValue = response.value
            let statusCode = response.httpResponse?.statusCode
            
            XCTAssertNotNil(jsonValue, "응답이 도착해야 합니다.")
            XCTAssertEqual(statusCode, 200, "Http 상태 코드가 200이어야 합니다.")
            print("응답 JSON: ", jsonValue)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_유효하지_않은_URL() {
        let expectation = self.expectation(description: "요청 완료")
        
        let request = MFRequest(url: "")
        
        Task {
            do {
                _ = try await MF.request(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.invalidURL = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_유효하지_않은_Content_Type() {
        let expectation = self.expectation(description: "요청 완료")
        
        let parameters: [String: Any] = [
            "title": "foo",
            "body": "bar",
            "userId": 1
        ]
        
        let request = MFRequest(url: "\(baseURL)/posts")
            .post()
            .addParameters(parameters)
            .addHeaders([
                .contentType("temp")
            ])
        
        Task {
            do {
                _ = try await MF.request(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.invalidContentType = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_Encodable_파라미터_인코딩_실패() {
        let expectation = self.expectation(description: "요청 완료")
        
        let parameters: String = "Invalid data"
        
        let request = MFRequest(url: "\(baseURL)/posts")
            .post()
            .addParameters(parameters)
            .addHeaders([
                .contentType("application/json")
            ])
        
        Task {
            do {
                _ = try await MF.request(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.parameterEncodingFailure = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_String_데이터_인코딩_실패() {
        let expectation = self.expectation(description: "요청 완료")
        
        let request = MFRequest(url: "https://httpbin.org/stream-bytes/32")
        
        Task {
            do {
                _ = try await MF.requestString(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.requestStringEncodingFailure = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_JSON_데이터_디코딩_실패() {
        let expectation = self.expectation(description: "요청 완료")
        
        let request = MFRequest(url: "https://httpbin.org/stream-bytes/32")
        
        Task {
            do {
                _ = try await MF.requestJSON(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.requestJSONDecodingFailure = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_Decodable_데이터_디코딩_실패() {
        let expectation = self.expectation(description: "요청 완료")
        
        struct Post: Decodable {
            let userId: Int
            let id: Int
            let title: String
            let name: String
        }
        
        let request = MFRequest(url: "\(baseURL)/posts/1")
        
        Task {
            do {
                _ = try await MF.requestDecodable(of: Post.self, request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.requestDecodableDecodingFailure = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_JSON_직렬화_실패() {
        let expectation = self.expectation(description: "요청 완료")

        let parameters: [String: Any] = [
            "title": "foo",
            "body": "bar",
            "data": Data()
        ]
        
        let request = MFRequest(url: "\(baseURL)/posts")
            .post()
            .addParameters(parameters)
        
        Task {
            do {
                _ = try await MF.request(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.jsonSerializationFailure = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_url_encoded_인코딩_실패() {
        let expectation = self.expectation(description: "요청 완료")

        let parameters: [String: Any] = [
            "title": "foo",
            "body": "bar",
            "data": Data()
        ]
        
        let request = MFRequest(url: "\(baseURL)/posts")
            .post()
            .addParameters(parameters)
            .addHeaders([
                .contentType("application/x-www-form-urlencoded")
            ])
        
        Task {
            do {
                _ = try await MF.request(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.urlEncodingFailure = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_에러_유효하지_않은_쿼리() {
        let expectation = self.expectation(description: "요청 완료")
        
        let queries: [String: Any] = [
            "title": "foo",
            "body": "bar",
            "data": Data()
        ]
        
        let request = MFRequest(url: "\(baseURL)/posts")
            .addQueries(queries)
        
        Task {
            do {
                _ = try await MF.request(request)
                XCTFail("반드시 에러를 던져야 합니다.")
            } catch let error as MFError {
                if case MFError.invalidQueryValue = error {
                    XCTAssertTrue(true, "예상한 에러가 발생했습니다.")
                    print(error)
                } else {
                    XCTFail("예상치 못한 에러가 발생했습니다: \(error)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
