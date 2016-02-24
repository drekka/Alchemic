//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCObjectFactory.h"

@protocol ALCResolvable;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectFactory : NSObject<ALCObjectFactory>

// Object factories must be settable.
@property (nonatomic, strong) id object;

-(void) resolveDependenciesWithStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack
                               model:(id<ALCModel>) model;

-(void) resolve:(id<ALCResolvable>) resolvable
      withStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack
    description:(NSString *) description
          model:(id<ALCModel>) model;

-(id) instantiateObject;

@end

NS_ASSUME_NONNULL_END