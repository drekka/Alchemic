//
//  ALCConstantValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCResolvable.h"

@interface ALCConstantValue : NSObject<ALCResolvable>

-(instancetype) initWithValue:(id) value;

@end
