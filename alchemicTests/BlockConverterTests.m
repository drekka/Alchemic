//
//  BlockConverterTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 25/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import ObjectiveC;
@import CoreGraphics;
@import Foundation;

@interface BlockConverterTests : XCTestCase

@end

@implementation BlockConverterTests {
    int _aInt;
    CGSize _aCGSize;
    NSString *_aString;
}

#pragma mark - Runtime tests

-(void) testStructEncoding {
    const char *enc = @encode(CGSize);
    NSLog(@"Type encoding: %s", enc);
    Ivar ivar = class_getInstanceVariable([self class], "_aCGSize");
    enc = ivar_getTypeEncoding(ivar);
    NSLog(@"Ivar encoding: %s", enc);
    Method method = class_getInstanceMethod([self class], @selector(doWithSize:));
    char *enc1 = method_copyArgumentType(method, 2);
    NSLog(@"Method arg encoding: %s", enc1);
    free(enc1);
    char *enc2 = method_copyReturnType(method);
    NSLog(@"Method return encoding: %s", enc2);
    free(enc2);
}

-(CGSize) doWithSize:(CGSize) size {return CGSizeZero;}

-(void) testObjectEncoding {
    const char *enc = @encode(NSString *);
    NSLog(@"Type encoding: %s", enc);
    Ivar ivar = class_getInstanceVariable([self class], "_aString");
    enc = ivar_getTypeEncoding(ivar);
    NSLog(@"Ivar encoding: %s", enc);
    Method method = class_getInstanceMethod([self class], @selector(doWithString:));
    char *enc1 = method_copyArgumentType(method, 2);
    NSLog(@"Method arg encoding: %s", enc1);
    free(enc1);
    char *enc2 = method_copyReturnType(method);
    NSLog(@"Method return encoding: %s", enc2);
    free(enc2);
}

-(NSString *) doWithString:(NSString *) string {return nil;}

#pragma mark - Converter tests

-(void) testBlockConvert {
    NSNumber *number = @(5);
    Ivar ivar = class_getInstanceVariable([self class], "_aInt");
    [self convertToIntBlock](number, [self injectIntIntoIVarBlock:ivar]);
    XCTAssertEqual(5, _aInt);
}

#pragma mark - Experimental code

// Converts NSNumber in an id to an int in a void *
-(void (^)(id origValue, void (^injectBlock)(id obj, void *value))) convertToIntBlock {
    return ^(id origValue, void (^injectBlock)(id obj, void *value)) {
        NSNumber *nbr = origValue;
        int intNbr = nbr.intValue;
        injectBlock(self, &intNbr);
    };
}

// Gets an int from a void * and sets a variable.
-(void (^)(id obj, void *value)) injectIntIntoIVarBlock:(Ivar) ivar {

    return ^(id obj, void *value) {

        // Convert back to an int.
        int intValue = * (int *) value;
        
        // Set the variable.
        CFTypeRef objRef = CFBridgingRetain(obj);
        int *ivarPtr = (int *) ((uint8_t *) objRef + ivar_getOffset(ivar));
        *ivarPtr = intValue;
        CFBridgingRelease(objRef);
        
    };
}

-(void) testVoidPtrToObj {
    int five = 5;
    void *ptr = &five;
    NSNumber *number = @(*ptr);
}


@end
