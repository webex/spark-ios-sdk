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

import Quick
import Nimble
import Alamofire
@testable import SparkSDK

class PeopleSpec: QuickSpec {
    
    private var me = Config.selfUser
    private var other: TestUser!
    
    private func validate(person: Person) {
        expect(person.id).notTo(beNil())
        expect(person.emails).notTo(beNil())
        expect(person.displayName).notTo(beNil())
        expect(person.created).notTo(beNil())
    }
    
    override func spec() {
        beforeSuite {
            self.other = TestUserFactory.sharedInstance.createUser()
            Spark.initWith(accessToken: self.me.token!)
        }
        
        // MARK: - List people
        
        describe("list People") {
            
            it("with emailAddress and displayName and validCount") {
                
                do {
                    let max = 10
                    let peoples = try Spark.people.list(email: self.other.email!, displayName: self.other.name!, max: max)
                    expect(peoples.count).to(equal(1))
                    self.validate(person: peoples[0])
                    expect(peoples[0].avatar).to(beNil())
                    expect(peoples[0].displayName).to(equal(self.other.name!))
                    expect(peoples[0].emails).to(contain(self.other.email!))
                    
                } catch let error as NSError {
                    fail("Failed to list people, \(error.localizedFailureReason)")
                }
            }
            
            it("with only emailAddress") {
                do {
                    let peoples = try Spark.people.list(email: self.other.email!)
                    expect(peoples.count).to(equal(1))
                    self.validate(person: peoples[0])
                    expect(peoples[0].avatar).to(beNil())
                    expect(peoples[0].displayName).to(equal(self.other.name!))
                    expect(peoples[0].emails).to(contain(self.other.email!))
                    
                } catch let error as NSError {
                    fail("Failed to list people, \(error.localizedFailureReason)")
                }
            }
            
            it("with displayName") {
                do {
                    let peoples = try Spark.people.list(email: nil, displayName: self.other.name!)
                    expect(peoples.count).to(equal(1))
                    self.validate(person: peoples[0])
                    expect(peoples[0].avatar).to(beNil())
                    expect(peoples[0].displayName).to(contain(self.other.name!))
                    
                } catch let error as NSError {
                    fail("Failed to list people, \(error.localizedFailureReason)")
                }
            }
            
            it("with displayName and maxCount") {
                do {
                    let peoples = try Spark.people.list(email: nil, displayName: self.other.name!, max: 10)
                    expect(peoples.count).to(equal(1))
                    self.validate(person: peoples[0])
                    expect(peoples[0].avatar).to(beNil())
                    expect(peoples[0].displayName).to(contain(self.other.name!))
                    
                } catch let error as NSError {
                    fail("Failed to list people, \(error.localizedFailureReason)")
                }
            }
            
            it("with email and maxCount") {
                do {
                    let peoples = try Spark.people.list(email: self.other.email!, displayName: nil, max: 10)
                    expect(peoples.count).to(equal(1))
                    self.validate(person: peoples[0])
                    expect(peoples[0].avatar).to(beNil())
                    expect(peoples[0].emails).to(contain(self.other.email!))
                    
                } catch let error as NSError {
                    fail("Failed to list people, \(error.localizedFailureReason)")
                }
            }
            
            it("with only validCount") {
                expect{try Spark.people.list(email: nil, displayName: nil, max: 10)}.to(throwError())
            }
            
            it("with emailAddress and displayName") {
                do {
                    let peoples = try Spark.people.list(email: self.other.email!, displayName: self.other.name!)
                    expect(peoples.count).to(equal(1))
                    self.validate(person: peoples[0])
                    expect(peoples[0].avatar).to(beNil())
                    expect(peoples[0].displayName).to(contain(self.other.name!))
                    
                } catch let error as NSError {
                    fail("Failed to list people, \(error.localizedFailureReason)")
                }
            }
            
            it("with nothing") {
                expect{try Spark.people.list(email: nil, displayName: nil, max: nil)}.to(throwError())
            }
            
            it("with emailAddress and displayName and invalidCount") {
                expect{try Spark.people.list(email: self.other.email!, displayName: self.other.name!, max: -1)}.to(throwError())
            }
            
            it("with emailAddress and invalidCount") {
                expect{try Spark.people.list(email: self.other.email!, displayName: nil, max: -1)}.to(throwError())
            }
            
            it("with displayName and invalidCount") {
                expect{try Spark.people.list(email: nil, displayName: self.other.name!, max: -1)}.to(throwError())
            }
            
            it("with only invalidCount") {
                expect{try Spark.people.list(email: nil, displayName: nil, max: -1)}.to(throwError())
            }
        }
        
        // MARK: - Get people
        
        describe("get") {
            it("me") {
                do {
                    let person = try Spark.people.getMe()
                    self.validate(person: person)
                    expect(person.avatar).to(beNil())
                    expect(person.displayName).to(equal(self.me.name))
                    expect(person.emails).to(contain(self.me.email!))
                    
                } catch let error as NSError {
                    fail("Failed to get people, \(error.localizedFailureReason)")
                }
            }
            
            it("with personId") {
                do {
                    let person = try Spark.people.get(personId: self.me.id!)
                    self.validate(person: person)
                    expect(person.avatar).to(beNil())
                    expect(person.displayName).to(equal(self.me.name))
                    expect(person.emails).to(contain(self.me.email!))
                    
                } catch let error as NSError {
                    fail("Failed to get people, \(error.localizedFailureReason)")
                }
                
            }
            
            it("with emptyId") {
                expect{try Spark.people.get(personId:"")}.to(throwError())
            }
            
            it("with wrongId") {
                expect{try Spark.people.get(personId:"abcd")}.to(throwError())
            }
        }
        
    }
}

class XCPeopleSpec: XCTestCase {
    
    private var spark: Spark!
    private let PeopleCountMin = 0
    private let PeopleCountMax = 100
    private let PeopleCountValid = 10
    private let PeopleCountInvalid = -1
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
        spark = Spark(authenticationStrategy: SimpleAuthStrategy(accessToken: Config.selfUser.token!))
        other = TestUserFactory.sharedInstance.createUser() //do we need to change this?
    }
    
    /* TODO: Fix these tests?
     1. Why are we using XCTAssertLessThanOrEqual with PeopleCountValid? (e.g. testListPeopleWithEmailAddressAndDisplayNameAndValidCount)
     2. Why are we checking that the people[0].displayName contains otherName? (e.g. testListPeopleWithDisplayName)
    */
    
    func testListPeopleWithEmailAddressAndDisplayNameAndValidCount() {
        if let people = listPeople(email: otherEmail, displayName: otherName, max: PeopleCountValid), let displayName = people[0].displayName, let emails = people[0].emails {
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertLessThanOrEqual(people.count, PeopleCountValid)
            XCTAssertGreaterThan(people.count, PeopleCountMin)
            XCTAssertEqual(displayName, otherName)
            XCTAssertTrue(emails.contains(otherEmail))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithEmailAddress() {
        if let people = listPeople(email: otherEmail, displayName: nil, max: nil), let displayName = people[0].displayName, let emails = people[0].emails {
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertLessThanOrEqual(people.count, PeopleCountMax)
            XCTAssertGreaterThan(people.count, PeopleCountMin)
            XCTAssertEqual(displayName, otherName)
            XCTAssertTrue(emails.contains(otherEmail))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithDisplayName() {
        if let people = listPeople(email: nil, displayName: otherName, max: nil), let displayName = people[0].displayName {
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertLessThanOrEqual(people.count, PeopleCountMax)
            XCTAssertGreaterThan(people.count, PeopleCountMin)
            XCTAssertTrue(displayName.contains(otherName))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithDisplayNameAndMaxCount() {
        if let people = listPeople(email: nil, displayName: otherName, max: PeopleCountMax), let displayName = people[0].displayName {
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertLessThanOrEqual(people.count, PeopleCountMax)
            XCTAssertGreaterThan(people.count, PeopleCountMin)
            XCTAssertTrue(displayName.contains(otherName))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithDisplayNameAndMinCount() {
        if let people = listPeople(email: nil, displayName: otherName, max: PeopleCountMin) {
            XCTAssertEqual(people.count, PeopleCountMin)
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithEmailAndMaxCount() {
        if let people = listPeople(email: otherEmail, displayName: nil, max: PeopleCountMax), let emails = people[0].emails {
            validate(person: people[0])
            XCTAssertNil(people[0].avatar)
            XCTAssertLessThanOrEqual(people.count, PeopleCountMax)
            XCTAssertGreaterThan(people.count, PeopleCountMin)
            XCTAssertTrue(emails.contains(otherEmail))
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithEmailAndMinCount() {
        if let people = listPeople(email: otherEmail, displayName: nil, max: PeopleCountMin) {
            XCTAssertEqual(people.count, PeopleCountMin)
        } else {
            XCTFail("Failed to list people")
        }
    }
    
    func testListPeopleWithOnlyValidCount() {
        let people = listPeople(email: nil, displayName: nil, max: PeopleCountValid)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndDisplayName() {
        if let people = listPeople(email: otherEmail, displayName: otherName, max: nil), let displayName = people[0].displayName {
            validate(person: people[0])
            XCTAssertLessThanOrEqual(people.count, PeopleCountMax)
            XCTAssertGreaterThan(people.count, PeopleCountMin)
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
        let people = listPeople(email: otherEmail, displayName: otherName, max: PeopleCountInvalid)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithEmailAndInvalidCount() {
        let people = listPeople(email: otherEmail, displayName: nil, max: PeopleCountInvalid)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithDisplayNameAndInvalidCount() {
        let people = listPeople(email: nil, displayName: otherName, max: PeopleCountInvalid)
        XCTAssertNil(people, "Unexpected successful request")
    }
    
    func testListPeopleWithOnlyInvalidCount() {
        let people = listPeople(email: nil, displayName: nil, max: PeopleCountInvalid)
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
