//
//  ALCFactoryTypeFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCObjectFactoryTypeTemplate.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeTemplate

@synthesize object = _object;

-(ALCFactoryType) factoryType {
    return ALCFactoryTypeFactory;
}

-(BOOL) ready {
    return YES;
}

-(void) setObject:(id) value {}

-(NSString *)description {
    return @"Template";
}

@end

NS_ASSUME_NONNULL_END

