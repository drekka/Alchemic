//
//  NSObject+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
@protocol ALCResolvable;

@interface NSObject (Alchemic)

-(void) injectVariable:(Ivar) variable withResolvable:(id<ALCResolvable>) resolvable;

@end
