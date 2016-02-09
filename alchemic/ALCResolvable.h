//
//  ALCResolvable.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCModel;

@protocol ALCResolvable <NSObject>

@property (nonatomic, strong, readonly) id object;

@property (nonatomic, assign, readonly) Class objectClass;

@property (nonatomic, assign, readonly) bool resolved;

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>) model;

@end
