//
//  Features.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

@import StoryTeller;

@import Alchemic;
@import Alchemic.Private;

@interface FakeUserDefaults : ALCUserDefaults
@end
@implementation FakeUserDefaults
@end

@interface Features : XCTestCase

@end

@implementation Features {
    id<ALCContext> _context;
}

-(void) setUp {
    _context = [[ALCContextImpl alloc] init];
}

-(void) testDisableUserDefaultsLeaveModelUntouched {

    [_context addResolveAspect:[[ALCUserDefaultsAspect alloc] init]];
    [ALCUserDefaultsAspect setEnabled:NO];

    [_context start];
    
    // Get the user defaults.
    XCTAssertThrowsSpecific(([_context objectWithClass:[ALCUserDefaults class], AcName(@"userDefaults"), nil]), AlchemicNoDependenciesFoundException);
}


-(void) testEnableUserDefaultsAddsDefaultsFactory {
    [_context addResolveAspect:[[ALCUserDefaultsAspect alloc] init]];
    [ALCUserDefaultsAspect setEnabled:YES];
    [_context start];
    
    // Get the user defaults.
    id obj = [_context objectWithClass:[ALCUserDefaults class], AcName(@"userDefaults"), nil];
    XCTAssertNotNil(obj);
    XCTAssertTrue([obj isKindOfClass:[ALCUserDefaults class]]);
}

-(void) testEnableUserDefaultsLeavesCustomDefaultsInPlace {

    [_context addResolveAspect:[[ALCUserDefaultsAspect alloc] init]];
    [ALCUserDefaultsAspect setEnabled:YES];
    
    [_context registerObjectFactoryForClass:[FakeUserDefaults class]];
    
    [_context start];
    
    // Get the user defaults.
    id obj = [_context objectWithClass:[ALCUserDefaults class], AcClass(ALCUserDefaults), nil];
    XCTAssertNotNil(obj);
    XCTAssertTrue([obj isKindOfClass:[FakeUserDefaults class]]);
}

@end
