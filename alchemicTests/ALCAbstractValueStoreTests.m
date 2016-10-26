//
//  ALCAbstractValueStoreTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

#pragma mark - Test classes

@interface DummyValue : NSObject
@property (nonatomic, assign) int number;
@end

@implementation DummyValue
@end

@interface DummyValueStore : ALCAbstractValueStore
@property (nonatomic, strong) DummyValue *abc;
@end

@implementation DummyValueStore {
    id obj;
}

-(void) setBackingStoreValue:(nullable id)value forKey:(NSString *)key {
    obj = value;
}

-(nullable id) backingStoreValueForKey:(id) key {
    return obj;
}

-(id) abcFromBackingStoreValue:(id) value {
    NSNumber *bsv = (NSNumber *) value;
    DummyValue *kvc = (DummyValue *) value;
    kvc.number = bsv.intValue;
    return kvc;
}

-(id) backingStoreValueFromAbc:(id) value {
    DummyValue *kvc = (DummyValue *) value;
    return @(kvc.number);
}

@end

#pragma mark - Tests

@interface ALCAbstractValueStoreTests : XCTestCase
@end

@implementation ALCAbstractValueStoreTests

-(void) testToFromTransformersUsingSubscripts {
    DummyValueStore *dsv = [[DummyValueStore alloc] init];
    DummyValue *value = [[DummyValue alloc] init];
    value.number = 5;
    dsv[@"abc"] = value;
    DummyValue *result = dsv[@"abc"];
    XCTAssertNotEqual(value, result);
    XCTAssertEqual(5, result.number);
}

-(void) testToFromTransformersUsingKVC {
    DummyValueStore *dsv = [[DummyValueStore alloc] init];
    DummyValue *value = [[DummyValue alloc] init];
    value.number = 5;
    [dsv setValue:value forKey:@"abc"];
    DummyValue *result = [dsv valueForKey:@"abc"];
    XCTAssertNotEqual(value, result);
    XCTAssertEqual(5, result.number);
}

-(void) testToFromTransformersUsingProperty {
    DummyValueStore *dsv = [[DummyValueStore alloc] init];
    DummyValue *value = [[DummyValue alloc] init];
    value.number = 5;
    dsv.abc = value;
    DummyValue *result = dsv.abc;
    XCTAssertNotEqual(value, result);
    XCTAssertEqual(5, result.number);
}

@end
