//
//  ALCClassProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

@protocol ALCClassProcessor <NSObject>

-(BOOL) canProcessClass:(Class) aClass;

-(NSSet<NSBundle *> *) processClass:(Class) aClass withContext:(id<ALCContext>) context;

@end
