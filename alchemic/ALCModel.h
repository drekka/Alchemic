//
//  ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCModelSearchCriteria;
@protocol ALCValueFactory;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCModel <NSObject>

@property (nonatomic, readonly, strong) NSSet<id<ALCValueFactory>> *valueFactories;

-(void) addValueFactory:(id<ALCValueFactory>) valueFactory withName:(NSString *) name;

-(NSArray<id<ALCValueFactory>> *) valueFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria;

-(void) valueFactory:(id<ALCValueFactory>) valueFactory changedName:(NSString *) oldName newName:(NSString *) newName;

@end

NS_ASSUME_NONNULL_END