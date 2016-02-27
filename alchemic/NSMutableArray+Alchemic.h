//
//  NSMutableArray+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 27/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCResolvable;
@protocol ALCModel;
@protocol ALCObjectGenerator;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (Alchemic)

-(void) resolve:(id<ALCObjectGenerator>) objectGenerator
          model:(id<ALCModel>) model;

-(void) resolve:(id<ALCResolvable>) resolvable
 resolvableName:(NSString *) resolvableName
          model:(id<ALCModel>) model;

@end

NS_ASSUME_NONNULL_END
