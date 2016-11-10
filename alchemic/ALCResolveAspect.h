//
//  ALCPreResolveFilter.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCModel;

/**
 Classes which implement this aspect will automatically be called before and after Alchemic resolves the model.
 */
@protocol ALCResolveAspect <NSObject>

@property (class, atomic, assign) BOOL enabled;

@optional

-(void) modelWillResolve:(id<ALCModel>) model;

-(void) modelDidResolve:(id<ALCModel>) model;

@end
