//
//  ALCAbstractDependencyInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCDependencyInjector.h"

@interface ALCAbstractDependencyInjector : NSObject<ALCDependencyInjector>

-(BOOL) injectObject:(id) object variable:(Ivar) variable withValue:(id) value;

@end
