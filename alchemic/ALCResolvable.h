//
//  ALCResolvable.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCModel;

@protocol ALCResolvable <NSObject>

@property (nonatomic, assign, readonly) bool ready;

@property (nonatomic, assign, readonly) Class objectClass;

@property (nonatomic, strong, readonly) NSString *resolvingDescription;

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                   model:(id<ALCModel>)model;

@end

NS_ASSUME_NONNULL_END
