//
//  ALCContext.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCObjectFactory;

@protocol ALCContext <NSObject>

-(void) start;

-(id<ALCObjectFactory>) registerClass:(Class) clazz;

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory changedName:(NSString *) oldName newName:(NSString *) newName;

@end
