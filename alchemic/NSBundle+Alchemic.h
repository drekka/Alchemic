//
//  NSBundle+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCRuntimeScanner;

@interface NSBundle (Alchemic)

-(NSSet<NSBundle *> *) scanWithScanners:(NSArray<ALCRuntimeScanner *> *) scanners;

@end
