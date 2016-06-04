//
//  AlchemicTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 7/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
//
@import StoryTeller;

#import "Networking.h"
#import "UserInterface.h"
#import "Database.h"
#import "RequestEngine.h"
#import "HTTPServer.h"
#import "ViewController.h"

@interface AlchemicTests : XCTestCase
@end

@implementation AlchemicTests

-(void) testStartUp {
    
    Networking *networking = AcGet(Networking);
    XCTAssertNotNil(networking);
    
    UserInterface *ui = AcGet(UserInterface);
    XCTAssertNotNil(ui);
    
    XCTAssertEqual(networking.ui, ui);
    XCTAssertEqual(ui.networking, networking);
}

-(void) testSingletonViaName {
    Networking *networking = AcGet(Networking, AcName(@"networking"));
    XCTAssertNotNil(networking);
}

-(void) testFactoryClass {
    RequestEngine *rq1 = AcGet(RequestEngine);
    RequestEngine *rq2 = AcGet(RequestEngine);
    XCTAssertNotEqual(rq1, rq2);
}

-(void) testAccessingSimpleFactoryMethod {
    HTTPServer *server = AcGet(HTTPServer);
    XCTAssertNotNil(server);
}

-(void) testAccessingSimpleFactoryMethodViaCustomName {
    HTTPServer *server = AcGet(HTTPServer, AcName(@"HTTPServer"));
    XCTAssertNotNil(server);
}

-(void) testSingletonCreatedUsingInitializer {
    Database *db = AcGet(Database);
    XCTAssertNotNil(db);
    XCTAssertEqual(5, db.aInt);
    XCTAssertNotNil(db.ui);
}

-(void) testViewControllerReference {
    ViewController *vc = [[ViewController alloc] init];
    AcSet(vc);
    XCTAssertNotNil(vc.ui);
}

@end
