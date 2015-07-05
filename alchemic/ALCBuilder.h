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

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, assign) BOOL createOnStartup;

@property (nonatomic, assign) BOOL primary;

@property (nonatomic, assign) BOOL factory;

@property (nonatomic, strong) id value;

#pragma mark - Querying the builder

@property (nonatomic, strong, readonly) Class valueClass;

#pragma mark - Resolving

-(void) resolve;

/**
 Used during the instantiation of singletons on startup. Otherwise never used.
 Different to accessing the value in that it does not trigger dependency injection.
 */
-(id) instantiate;

@end
