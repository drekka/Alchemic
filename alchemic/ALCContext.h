//
//  ALCContext.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCValueFactory;

@protocol ALCContext <NSObject>

-(void) start;

-(id<ALCValueFactory>) registerClass:(Class) clazz;

@end
