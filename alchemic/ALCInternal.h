//
//  AlchemicInternal.h
//  alchemic
//
//  Created by Derek Clarkson on 14/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#define ALCHEMIC_METHOD_PREFIX _alchemic_

// Used to assemble two strings. We use double macros to ensure any
// embedded macros are resolved.
#define _alchemic_concat(prefix, suffix) _alchemic_concat_strings(prefix, suffix)
#define _alchemic_concat_strings(prefix, suffix) prefix ## suffix

// Convert raw macro text to a char *
#define toCharPointer(text) _toCharPointer(text)
#define _toCharPointer(text) #text

#define dataToNSString(data) [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
#define stringToData(string) [string dataUsingEncoding:NSUTF8StringEncoding]


