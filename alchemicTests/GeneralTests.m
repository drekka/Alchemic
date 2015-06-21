//
//  GeneralTests.m
//  alchemic
//
//  Created by Derek Clarkson on 15/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ObjA<ObjectType> : NSObject @end
@implementation  ObjA @end

@interface ObjB : ObjA @end
@implementation  ObjB @end

@interface GeneralTests : XCTestCase
@end

@implementation GeneralTests

-(void) testGeneric {
    NSMutableSet<ObjA *> *set = [[NSMutableSet alloc] init];
    ObjA *a = [[ObjA alloc] init];
    ObjB *b = [[ObjB alloc] init];
    [set addObject:a];
    [set addObject:b];
}

-(void) testGenericKindOf {
    NSMutableSet<__kindof ObjA *> *set = [[NSMutableSet alloc] init];
    ObjA *a = [[ObjA alloc] init];
    ObjB *b = [[ObjB alloc] init];
    [set addObject:a];
    [set addObject:b];
}

@end
