//
//  ALCVariableDependencyMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCAbstractMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCVariableDependencyMacroProcessor : ALCAbstractMacroProcessor

@property (nonatomic, assign, readonly) Ivar variable;

-(instancetype) initWithParentClass:(Class) parentClass variable:(NSString *) variable NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
