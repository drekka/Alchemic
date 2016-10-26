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
@property (nonatomic, strong) id backingStoreValue;
@end

@implementation DummyValueStore

-(void) setBackingStoreValue:(nullable id)value forKey:(NSString *)key {
    _backingStoreValue = value;
}

-(nullable id) backingStoreValueForKey:(id) key {
    return _backingStoreValue;
}

-(id) abcFromBackingStoreValue:(id) value {
    NSNumber *bsValue = (NSNumber *) value;
    DummyValue *dummyValue = [[DummyValue alloc] init];
    dummyValue.number = bsValue.intValue;
    return dummyValue;
}

-(id) backingStoreValueFromAbc:(id) value {
    DummyValue *dummyValue = (DummyValue *) value;
    return @(dummyValue.number);
}

@end

@interface DummyValueStoreWithProperty : DummyValueStore
@property (nonatomic, strong) DummyValue *abc;
@end

@implementation DummyValueStoreWithProperty
@end

#pragma mark - Tests

@interface ALCAbstractValueStoreTests : XCTestCase
@end

@implementation ALCAbstractValueStoreTests {
    DummyValueStore *_store;
    DummyValueStoreWithProperty *_storeWithProperty;
    DummyValue *_value;
}

-(void)setUp {
    _store = [[DummyValueStore alloc] init];
    [_store alchemicDidInjectDependencies];

    _storeWithProperty = [[DummyValueStoreWithProperty alloc] init];
    [_storeWithProperty alchemicDidInjectDependencies];

    _value = [[DummyValue alloc] init];
    _value.number = 5;
}

-(void) testToFromTransformersUsingSubscripts {
    _store[@"abc"] = _value;
    XCTAssertEqual(5, ((NSNumber *)_store.backingStoreValue).intValue);
    DummyValue *result = _store[@"abc"];
    XCTAssertNotEqual(_value, result);
    XCTAssertEqual(5, result.number);
}

-(void) testToFromTransformersUsingKVC {
    [_store setValue:_value forKey:@"abc"];
    XCTAssertEqual(5, ((NSNumber *)_store.backingStoreValue).intValue);
    DummyValue *result = [_store valueForKey:@"abc"];
    XCTAssertNotEqual(_value, result);
    XCTAssertEqual(5, result.number);
}

-(void) testToFromTransformersUsingProperty {
    _storeWithProperty.abc = _value;
    XCTAssertEqual(5, ((NSNumber *)_storeWithProperty.backingStoreValue).intValue);
    DummyValue *result = _storeWithProperty.abc;
    XCTAssertEqual(_value, result);
    XCTAssertEqual(5, result.number);
}

@end
