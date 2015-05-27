//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 6/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCType;

/**
 Base protocol for things that can resolve to a value.
 */
@protocol ALCResolvable <NSObject>

#pragma mark - Resolving

-(void) resolve;

@property (nonatomic, strong, readonly) id value;

@property (nonatomic, strong, readonly) ALCType *valueType;

@end
