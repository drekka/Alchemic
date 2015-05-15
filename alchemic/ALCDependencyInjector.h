//
//  ALCDependencyInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCVariableDependencyResolver;

@protocol ALCObjectResolver <NSObject>

-(BOOL) injectObject:(id) object dependency:(ALCVariableDependencyResolver *) dependency;

@end
