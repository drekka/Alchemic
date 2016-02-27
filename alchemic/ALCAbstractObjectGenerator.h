//
//  ALCAbstractObjectGenerator.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCObjectGenerator.h"

@protocol ALCModel;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectGenerator : NSObject<ALCObjectGenerator>

@property (nonatomic, assign, readonly) BOOL resolved;

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithClass:(Class) objectClass NS_DESIGNATED_INITIALIZER;

-(void) resolveDependenciesWithStack:(NSMutableArray<NSString *> *) resolvingStack
                               model:(id<ALCModel>) model;

@end

NS_ASSUME_NONNULL_END

