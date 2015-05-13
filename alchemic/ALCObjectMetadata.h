//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 6/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCObjectMetadata <NSObject>

@property (nonatomic, assign, readonly) Class objectClass;
@property (nonatomic, strong) id object;
@property (nonatomic, assign) BOOL primary;

#pragma mark - Lifecycle

-(void) resolveDependencies;

-(void) instantiateObject;


@end
