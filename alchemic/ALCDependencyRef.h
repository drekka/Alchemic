//
//  ALCDependencyRef.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@protocol ALCResolvable;

@interface ALCDependencyRef : NSObject
@property (nonatomic, assign) Ivar ivar;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id<ALCResolvable> dependency;
@end
