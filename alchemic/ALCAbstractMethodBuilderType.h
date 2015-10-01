//
//  ALCAbstractMethodBuilderType.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCAbstractBuilderType.h"
@class ALCDependency;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMethodBuilderType : ALCAbstractBuilderType

@property (nonatomic, strong, readonly) ALCBuilder *classBuilder;
@property (nonatomic, strong, readonly) NSArray<id> *argumentValues;

hideInitializer(init);

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder;

@end

NS_ASSUME_NONNULL_END

