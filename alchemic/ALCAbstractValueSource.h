//
//  ALCAbstractValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCValueSource.h"

@interface ALCAbstractValueSource : NSObject<ALCValueSource>

-(NSSet<id> *) values;

@end
