//
//  ExceptionCatcher.h
//  AlchemicSwift
//
//  Created by Derek Clarkson on 25/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ExceptionCatcher:NSObject

+(BOOL) catchException:(void (^)(void)) tryBlock
                 error:(__autoreleasing NSError **) error;

@end
