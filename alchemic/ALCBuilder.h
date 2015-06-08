//
//  ALCObjectBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 24/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@class ALCDependency;
@class ALCType;

@protocol ALCBuilder <NSObject>

@property (nonatomic, assign) BOOL primary;

@property (nonatomic, assign) BOOL factory;

@property (nonatomic, assign) BOOL singleton;

@property (nonatomic, strong, readonly) id value;

@property (nonatomic, strong, readonly) ALCType *valueType;

-(void) addDependency:(ALCDependency *) dependency;

#pragma mark - Resolving

-(void) resolve;

@end
