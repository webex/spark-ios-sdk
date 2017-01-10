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
    
    private var spark: Spark!
    private var me = Config.selfUser
    private var other: TestUser!
    private var otherName: String! {
        if let otherName = other.name {
            return otherName
        } else {
            XCTFail("Don't have an otherName")
            return nil
        }
    }
    private var otherEmail: EmailAddress! {
        if let otherEmail = other.email {
            return otherEmail
        } else {
            XCTFail("Don't have an otherName")
            return nil
        }
    }
    private func validate(person: Person) {
        XCTAssertNotNil(person.id)
        XCTAssertNotNil(person.emails)
        XCTAssertNotNil(person.displayName)
        XCTAssertNotNil(person.created)
    }
    
    override func setUp() {
        if let token = Config.selfUser.token {
            spark = Spark(authenticationStrategy: SimpleAuthStrategy(accessToken: token))
        } else {
            spark = Spark(authenticationStrategy: JWTAuthStrategy())
        }
        other = TestUserFactory.sharedInstance.createUser() //do we need to change this?
    }
    
    /* TODO: Fix these tests?
     1. Why are we using XCTAssertLessThanOrEqual with PeopleCountValid? (e.g. testListPeopleWithEmailAddressAndDisplayNameAndValidCount)
     2. Why are we checking that the people[0].displayName contains otherName? (e.g. testListPeopleWithDisplayName)
    */
    
    func testListPeopleWithEmailAddressAndDisplayNameAndValidCount() {
        if let people = listPeople(email: otherEmail, displayName: otherName, max: 10), let displayName = people[0].displayName, let emails = people[0].emails {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertEqual(displayName, otherName)
            XCTAssertTrue(emails.contains(otherEmail))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithOnlyEmailAddress() {
        if let people = listPeople(email: otherEmail, displayName: nil, max: nil), let displayName = people[0].displayName, let emails = people[0].emails {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertEqual(displayName, otherName)
            XCTAssertTrue(emails.contains(otherEmail))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithDisplayName() {
        if let people = listPeople(email: nil, displayName: otherName, max: nil), let displayName = people[0].displayName {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertTrue(displayName.contains(otherName))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithDisplayNameAndMaxCount() {
        if let people = listPeople(email: nil, displayName: otherName, max: 10), let displayName = people[0].displayName {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertTrue(displayName.contains(otherName))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithEmailAndMaxCount() {
        if let people = listPeople(email: otherEmail, displayName: nil, max: 10), let emails = people[0].emails {
            validate(person: people[0])
            XCTAssertEqual(people.count, 1)
            XCTAssertNil(people[0].avatar)
            XCTAssertTrue(emails.contains(otherEmail))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithOnlyValidCount() {
        let people = listPeople(email: nil, displayName: nil, max: 10)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndDisplayName() {
        if let people = listPeople(email: otherEmail, displayName: otherName, max: nil), let displayName = people[0].displayName {
            XCTAssertEqual(people.count, 1)
            validate(person: people[0])
            XCTAssertTrue(displayName.contains(otherName))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithNothing() {
        let people = listPeople(email: nil, displayName: nil, max: nil)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndDisplayNameAndInvalidCount() {
        let people = listPeople(email: otherEmail, displayName: otherName, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndInvalidCount() {
        let people = listPeople(email: otherEmail, displayName: nil, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithDisplayNameAndInvalidCount() {
        let people = listPeople(email: nil, displayName: otherName, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithOnlyInvalidCount() {
        let people = listPeople(email: nil, displayName: nil, max: -1)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testGetMe() {
        if let person = getMe(), let emails = person.emails, let myEmail = me.email {
            validate(person: person)
            XCTAssertNil(person.avatar)
            XCTAssertEqual(person.displayName, me.name)
            XCTAssert(emails.contains(myEmail))
        } else {
            XCTFail("Failed to get me")
        }
    }
    
    func testGetWithPersonId() {
        if let myId = me.id, let person = get(personId: myId), let emails = person.emails, let myEmail = me.email {
            validate(person: person)
            XCTAssertNil(person.avatar)
            XCTAssertEqual(person.displayName, me.name)
            XCTAssert(emails.contains(myEmail))
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
            self.spark.people.list(email: email, displayName: displayName, max: max, completionHandler: completionHandler)
        }
        return Utils().getResponse(request: request)
    }
    
    private func getMe() -> Person? {
        let request = { (completionHandler: @escaping (ServiceResponse<Person>) -> Void) in
            self.spark.people.getMe(completionHandler: completionHandler)
        }
        return Utils().getResponse(request: request)
    }
    
    private func get(personId: String) -> Person? {
        let request = { (completionHandler: @escaping (ServiceResponse<Person>) -> Void) in
            self.spark.people.get(personId: personId, completionHandler: completionHandler)
        }
        return Utils().getResponse(request: request)
    }
}
