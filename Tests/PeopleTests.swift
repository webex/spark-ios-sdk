// Copyright 2016-2017 Cisco Systems Inc
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
    
    func testListPeopleWithEmailAddressAndDisplayNameAndValidCount() {
        let peopleList = listPeople(email: other.email, displayName: other.name, max: 10)
        XCTAssertNotNil(peopleList)
        if let people = peopleList {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertEqual(people[0].displayName, other.name)
            XCTAssertNotNil(people[0].emails)
            XCTAssertTrue(people[0].emails!.contains(other.email))
        }
    }
    
    func testListPeopleWithOnlyEmailAddress() {
            let peopleList = listPeople(email: other.email, displayName: nil, max: nil)
            XCTAssertNotNil(peopleList)
            if let people = peopleList {
                XCTAssertEqual(people.count, 1)
                validate(person: people[0])
                XCTAssertNil(people[0].avatar)
                XCTAssertEqual(people[0].displayName, other.name)
                XCTAssertNotNil(people[0].emails)
                XCTAssertTrue(people[0].emails!.contains(other.email))
            }
    }
    
    func testListPeopleWithDisplayName() {
        let peopleList = listPeople(email: nil, displayName: other.name, max: nil)
        XCTAssertNotNil(peopleList)
        if let people = peopleList {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertNotNil(people[0].displayName)
            XCTAssertTrue(people[0].displayName!.contains(other.name))
        }
    }
    
    func testListPeopleWithDisplayNameAndMaxCount() {
        let peopleList = listPeople(email: nil, displayName: other.name, max: 10)
        XCTAssertNotNil(peopleList)
        if let people = peopleList {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertNotNil(people[0].displayName)
            XCTAssertTrue(people[0].displayName!.contains(other.name))
        }
    }
    
    func testListPeopleWithEmailAndMaxCount() {
        let peopleList = listPeople(email: other.email, displayName: nil, max: 10)
        XCTAssertNotNil(peopleList)
        if let people = peopleList {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertNotNil(people[0].emails)
            XCTAssertTrue(people[0].emails!.contains(other.email))
        }
    }
    
    func testListPeopleWithOnlyValidCount() {
        let people = listPeople(email: nil, displayName: nil, max: 10)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndDisplayName() {
        let peopleList = listPeople(email: other.email, displayName: other.name, max: nil)
        XCTAssertNotNil(peopleList)
        if let people = peopleList {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            
            XCTAssertNotNil(people[0].displayName)
            XCTAssertTrue(people[0].displayName!.contains(other.name))
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
        let person = getMe()
        XCTAssertNotNil(person)
        if let me = person {
            validate(person: me)
            XCTAssertNil(me.avatar)
            XCTAssertEqual(me.displayName, fixture.selfUser.name)
            XCTAssertNotNil(me.emails)
            XCTAssert(me.emails!.contains(fixture.selfUser.email))
        }
    }
    
    func testGetWithPersonId() {
        let getPerson = get(personId: fixture.selfUser.personId)
        XCTAssertNotNil(getPerson)
        if let person = getPerson {
            validate(person: person)
            XCTAssertNil(person.avatar)
            XCTAssertEqual(person.displayName, fixture.selfUser.name)
            XCTAssertNotNil(person.emails)
            XCTAssert(person.emails!.contains(fixture.selfUser.email))
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
