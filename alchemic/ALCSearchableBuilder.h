//
//  ALCSearchableBuilder.h
//  Alchemic
//
//  Created by Derek Clarkson on 27/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilder.h"

/**
 Defines builders which can be searched and saved into the model.
 */
@protocol ALCSearchableBuilder <ALCBuilder>

@property (nonatomic, strong, readonly, nonnull) Class valueClass;

@end
