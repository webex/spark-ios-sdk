// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import SparkSDK

class XCPeopleSpec: XCTestCase {
    
    private let fixture: SparkTestFixture! = SparkTestFixture.sharedInstance
    private var other: TestUser!
    private var people: PersonClient!
    
    private func validate(person: Person) {
        XCTAssertNotNil(person.id)
        XCTAssertNotNil(person.emails)
        XCTAssertNotNil(person.displayName)
        XCTAssertNotNil(person.created)
    }
    
    override func setUp() {
        continueAfterFailure = false
        XCTAssertNotNil(fixture)
        other = fixture.createUser()
        people = fixture.spark.people
    }
    
    /* TODO: Fix these tests?
     1. Why are we using XCTAssertLessThanOrEqual with PeopleCountValid? (e.g. testListPeopleWithEmailAddressAndDisplayNameAndValidCount)
     2. Why are we checking that the people[0].displayName contains other.name? (e.g. testListPeopleWithDisplayName)
    */
    
    func testListPeopleWithEmailAddressAndDisplayNameAndValidCount() {
        if let people = listPeople(email: other.email, displayName: other.name, max: 10), let displayName = people[0].displayName, let emails = people[0].emails {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertEqual(displayName, other.name)
            XCTAssertTrue(emails.contains(other.email))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithOnlyEmailAddress() {
        if let people = listPeople(email: other.email, displayName: nil, max: nil), let displayName = people[0].displayName, let emails = people[0].emails {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertEqual(displayName, other.name)
            XCTAssertTrue(emails.contains(other.email))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithDisplayName() {
        if let people = listPeople(email: nil, displayName: other.name, max: nil), let displayName = people[0].displayName {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertTrue(displayName.contains(other.name))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithDisplayNameAndMaxCount() {
        if let people = listPeople(email: nil, displayName: other.name, max: 10), let displayName = people[0].displayName {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertTrue(displayName.contains(other.name))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithEmailAndMaxCount() {
        if let people = listPeople(email: other.email, displayName: nil, max: 10), let emails = people[0].emails {
            validate(person: people[0])
            XCTAssertEqual(people.count, 1)
            XCTAssertNil(people[0].avatar)
            XCTAssertTrue(emails.contains(other.email))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithOnlyValidCount() {
        let people = listPeople(email: nil, displayName: nil, max: 10)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndDisplayName() {
        if let people = listPeople(email: other.email, displayName: other.name, max: nil), let displayName = people[0].displayName {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertTrue(displayName.contains(other.name))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithNothing() {
        let people = listPeople(email: nil, displayName: nil, max: nil)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndDisplayNameAndInvalidCount() {
        let people = listPeople(email: other.email, displayName: other.name, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndInvalidCount() {
        let people = listPeople(email: other.email, displayName: nil, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithDisplayNameAndInvalidCount() {
        let people = listPeople(email: nil, displayName: other.name, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithOnlyInvalidCount() {
        let people = listPeople(email: nil, displayName: nil, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testGetMe() {
        if let person = getMe(), let emails = person.emails {
            validate(person: person)
            XCTAssertNil(person.avatar)
            XCTAssertEqual(person.displayName, fixture.selfUser.name)
            XCTAssert(emails.contains(fixture.selfUser.email))
        } else {
            XCTFail("Failed to get me")
        }
    }
    
    func testGetWithPersonId() {
        if let person = get(personId: fixture.selfUser.personId), let emails = person.emails {
            validate(person: person)
            XCTAssertNil(person.avatar)
            XCTAssertEqual(person.displayName, fixture.selfUser.name)
            XCTAssert(emails.contains(fixture.selfUser.email))
        } else {
            XCTFail("Failed to get me")
        }
    }
    
    func testWithEmptyId() {
        let person = get(personId: "")
        XCTAssertNil(person, "Unexpected successful request")
    }
    
    func testWithWrongId() {
        let person = get(personId: "abcd")
        XCTAssertNil(person, "Unexpected successful request")
    }
    
    private func listPeople(email: EmailAddress?, displayName: String?, max: Int?) -> [Person]? {
        let request = { (completionHandler: @escaping (ServiceResponse<[Person]>) -> Void) in
            self.people.list(email: email, displayName: displayName, max: max, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func getMe() -> Person? {
        let request = { (completionHandler: @escaping (ServiceResponse<Person>) -> Void) in
            self.people.getMe(completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
    
    private func get(personId: String) -> Person? {
        let request = { (completionHandler: @escaping (ServiceResponse<Person>) -> Void) in
            self.people.get(personId: personId, completionHandler: completionHandler)
        }
        return fixture.getResponse(testCase: self, request: request)
    }
}
