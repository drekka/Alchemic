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

@property (nonatomic, assign) BOOL createOnStartup;

@property (nonatomic, assign, getter=isPrimary) BOOL primary;

@property (nonatomic, assign, getter=isFactory) BOOL factory;

@property (nonatomic, strong) id value;

#pragma mark - Querying the builder

@property (nonatomic, strong, readonly) ALCType *valueType;

@property (nonatomic, assign, readonly) BOOL shouldCreateOnStartup;

#pragma mark - Adding dependencies

-(void) addDependency:(ALCDependency *) dependency;

#pragma mark - Resolving

-(void) resolve;

/**
 Used during the instantiation of singletons on startup. Otherwise never used.
 Different to accessing the value in that it does not trigger dependency injection.
 */
-(id) instantiate;

@end
