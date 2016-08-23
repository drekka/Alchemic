//
//  ALCUserDefaultsTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;
@import StoryTeller;

@interface TestDefaults : ALCUserDefaults;
@property (nonatomic, strong) NSString *name_preference;
@property (nonatomic, assign) float slider_preference;
@end

@implementation TestDefaults
@end

@interface ALCUserDefaultsTests : XCTestCase
@end

@implementation ALCUserDefaultsTests {
    id _mockBundle;
    ALCUserDefaults *_defaults;
}

-(void)setUp {

    // Hack the bundle loading to load the test bundle so we can get to the plist.
    _mockBundle = OCMClassMock([NSBundle class]);
    OCMStub(ClassMethod([_mockBundle mainBundle])).andReturn([NSBundle bundleForClass:[self class]]);

    // Clear any current defaults.
    NSString *domain = (NSString *) kCFPreferencesCurrentApplication;
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domain];

    _defaults = [[ALCUserDefaults alloc] init];
    [_defaults alchemicDidInjectDependencies];
}

-(void)tearDown {
    [_mockBundle stopMocking];
    _defaults = nil;
}

#pragma mark - Basic access

-(void) testReadingString {
    XCTAssertEqualObjects(@"abc", [_defaults valueForKey:@"name_preference"]);
}

-(void) testUpdatingString {
    [_defaults setValue:@"def" forKey:@"name_preference"];
    XCTAssertEqualObjects(@"def", [_defaults valueForKey:@"name_preference"]);
}

#pragma mark - Subscripting

-(void) testReadingStringViaSubscripts {
    XCTAssertEqualObjects(@"abc", _defaults[@"name_preference"]);
}

-(void) testUpdatingStringViaSubscripts {
    _defaults[@"name_preference"] = @"def";
    XCTAssertEqualObjects(@"def", _defaults[@"name_preference"]);
}

#pragma mark - Class extension

-(void) testClassExtensionReadingProperties {
    
    TestDefaults *customDefaults;
    customDefaults = [[TestDefaults alloc] init];
    [customDefaults alchemicDidInjectDependencies];

    XCTAssertEqualObjects(@"abc", customDefaults.name_preference);
}

-(void) testClassExtensionSettingProperty {
    
    TestDefaults *customDefaults;
    customDefaults = [[TestDefaults alloc] init];
    [customDefaults alchemicDidInjectDependencies];
    
    customDefaults.name_preference = @"def";

    XCTAssertEqualObjects(@"def", customDefaults.name_preference);
}

-(void) testClassExtensionSettingPropertyViaSubscript {
    
    TestDefaults *customDefaults;
    customDefaults = [[TestDefaults alloc] init];
    [customDefaults alchemicDidInjectDependencies];
    
    customDefaults[@"name_preference"] = @"def";
    
    XCTAssertEqualObjects(@"def", customDefaults.name_preference);
}

-(void) testWhenNoSttingsBundle {
    [_mockBundle stopMocking];
    _defaults = [[ALCUserDefaults alloc] init];
    [_defaults alchemicDidInjectDependencies];

    // Nothing should happen.
}


@end
