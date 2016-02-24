//
//  ExploringTheRuntime.m
//  Alchemic
//
//  Created by Derek Clarkson on 19/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
@import XCTest;

@protocol ALCValue
-(void) setOnInvocation:(NSInvocation *) inv index:(int) idx;
@end

#define ALCConstantHeader(name, type) \
@interface ALCValue ## name : NSObject<ALCValue> \
-(instancetype) initWithValue:(type) value; \
@end

#define ALCConstantImplementation(name, type) \
@implementation ALCValue ## name { \
type _value; \
} \
-(instancetype) initWithValue:(type) value { \
self = [super init];if (self) {_value = value;}return self; \
} \
-(void) setOnInvocation:(NSInvocation *) inv index:(int) idx { \
[inv setArgument:&_value atIndex:2 + idx]; \
} \
@end

ALCConstantHeader(Int, int)
ALCConstantImplementation(Int, int)
ALCConstantHeader(String, NSString *)
ALCConstantImplementation(String, NSString *)

@interface ExploringTheRuntime : XCTestCase
@property (nonatomic, assign) int x;
@property (nonatomic, assign) NSString *y;
@end

@implementation ExploringTheRuntime {
    NSArray<NSString *> *_arrayOfStrings;
}

-(void) setX:(int)x andY:(NSString *) y {
    _x = x;
    _y = y;
}

-(void) testEncoding {
    const char *encoding = ivar_getTypeEncoding(class_getInstanceVariable([self class], "_arrayOfStrings"));
    XCTAssertEqual(0, strcmp("@\"NSArray\"", encoding));
}

#pragma mark - Void *

-(void) testUsingVoidPointers {
    int var = 5;
    void *pToVar = &var;
    int varCopy = * (int *) pToVar;
    XCTAssertEqual(5, varCopy);
    var = 6;
    XCTAssertEqual(6, * (int *) pToVar);
    XCTAssertEqual(5, varCopy);
    NSLog(@"encoding %s", @encode(typeof(*pToVar)));
}

#pragma mark - Directly accessing variables

-(void) testDirectlyAccessingVariables {
    int z = 15;
    Ivar ivar = class_getInstanceVariable([self class], "_x");
    CFTypeRef selfRef = CFBridgingRetain(self);
    int *ivarPtr = (int *)((uint8_t *)selfRef + ivar_getOffset(ivar));
    *ivarPtr = z;
    CFBridgingRelease(selfRef);
    XCTAssertEqual(15, self.x);
}

#pragma mark - Using NSValue

-(void) testTwoArgs {

    // Won't work when attempting to use liternals or computed results.
    // Have to go through previously set local variables like this.
    int x = 5;
    NSValue *arg1 = [self valueFromPointer:&x];
    NSString *y = @"abc";
    NSValue *arg2 = [self valueFromPointer:&y];
    [self executeSelector:@selector(setX:andY:) values:@[arg1, arg2]];
    XCTAssertEqual(5, self.x);
    XCTAssertEqualObjects(@"abc", self.y);
}

-(NSValue *) valueFromPointer:(const void *) valuePointer {
    return [NSValue value:valuePointer withObjCType:@encode(typeof(valuePointer))];
}

-(void) executeSelector:(SEL) selector values:(NSArray<NSValue *> *) values {

    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = selector;

    [values enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        typeof(value.objCType) originalValue;
        [value getValue:&originalValue];
        [inv setArgument:&originalValue atIndex:2 + (int) idx];
    }];

    [inv invokeWithTarget:self];
    
}

#pragma mark - Using custom value classes created by above maros.

-(void) testTwoArgsUsingValues {

    // ALCValue handles the types internally via custom implementations. Which means it can take listerals and comuputed results.

    id<ALCValue> arg1 = [[ALCValueInt alloc] initWithValue:5];
    id<ALCValue> arg2 = [[ALCValueString alloc] initWithValue:[NSString stringWithFormat:@"%@%@%@", @"a", @"b", @"c"]];
    [self executeSelector:@selector(setX:andY:) withValues:@[arg1, arg2]];
    XCTAssertEqual(5, self.x);
    XCTAssertEqualObjects(@"abc", self.y);
}

-(void) executeSelector:(SEL) selector withValues:(NSArray<id<ALCValue>> *) values {

    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    inv.selector = selector;

    [values enumerateObjectsUsingBlock:^(id<ALCValue> value, NSUInteger idx, BOOL *stop) {
        [value setOnInvocation:inv index:(int) idx];
    }];

    [inv invokeWithTarget:self];
    
}

@end
