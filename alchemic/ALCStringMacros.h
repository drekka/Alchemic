//
//  ALCStringMacros.h
//  alchemic
//
//  Created by Derek Clarkson on 24/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#define ALCHEMIC_PREFIX _alc_

#define str(template, ...) [NSString stringWithFormat:template, ## __VA_ARGS__ ]

// Used to assemble two strings. We use double macros to ensure any
// embedded macros are resolved.
#define alc_concat(prefix, suffix) _alc_concat(prefix, suffix)
#define _alc_concat(prefix, suffix) prefix ## suffix

// Convert raw macro text to a NSString *
#define alc_toCString(chars) _alc_toCString(chars)
#define _alc_toCString(chars) #chars
#define alc_toNSString(chars) _alc_toNSString(chars)
#define _alc_toNSString(chars) @#chars

#define alc_methodName(name, line) alc_concat(alc_concat(ALCHEMIC_PREFIX, name), line)
