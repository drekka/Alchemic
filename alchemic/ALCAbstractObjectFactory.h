//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"
#import "ALCDefs.h"

@class ALCInstantiation;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectFactory : NSObject<ALCObjectFactory>

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithClass:(Class) objectClass NS_DESIGNATED_INITIALIZER;

-(void) configureWithOptions:(NSArray *) options unknownOptionHandler:(void (^)(id option)) unknownOptionHandler;

-(ALCObjectCompletion) setObject:(id) object;

-(id) createObject;

-(ALCObjectCompletion) objectCompletion;

@end

NS_ASSUME_NONNULL_END