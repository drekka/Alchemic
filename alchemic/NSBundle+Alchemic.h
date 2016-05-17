//
//  NSBundle+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCClassProcessor;
@protocol ALCContext;

@interface NSBundle (Alchemic)

-(NSSet<NSBundle *> *) scanWithProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context;

@end
