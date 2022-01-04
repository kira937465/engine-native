/***************************************************************************
 Copyright (c) 2018-2021 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated engine source code (the "Software"), a limited,
 worldwide, royalty-free, non-assignable, revocable and non-exclusive license
 to use Cocos Creator solely to develop games on your target platforms. You shall
 not use Cocos Creator software for developing other software or tools that's
 used for developing games. You are not granted to publish, distribute,
 sublicense, and/or sell copies of Cocos Creator.

 The software or tools in this License Agreement are licensed, not sold.
 Xiamen Yaji Software Co., Ltd. reserves all rights not expressly granted to you.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/
#include "JsbBridgeWrapper.h"
#include <iostream>
#include <string>
#include "JsbBridge.h"
#include "Application.h"

@implementation JsbBridgeWrapper {
    JsbBridge* jb;
    NSMutableDictionary<NSString*, NSMutableArray<eventCallback>*>* cbDictionnary;
}

static JsbBridgeWrapper* instance = nil;
static ICallback         cb       = ^void(NSString* _event, NSString* _arg) {
    [[JsbBridgeWrapper sharedInstance] triggerEvent:_event arg:_arg];
};
+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone*)zone {
    return [JsbBridgeWrapper sharedInstance];
}

- (id)copyWithZone:(struct _NSZone*)zone {
    return [JsbBridgeWrapper sharedInstance];
}

- (void)addCallback:(NSString*)event callback:(eventCallback)callback {
    if (![cbDictionnary objectForKey:event]) {
        [cbDictionnary setValue:[NSMutableArray<eventCallback> new] forKey:event];
    }
    NSMutableArray* arr = [cbDictionnary objectForKey:event];
    if (![arr containsObject:callback]) {
        [arr addObject:callback];
    }
    [callback release];
}

- (void)triggerEvent:(NSString*)event arg:(NSString*)arg {
    NSMutableArray<eventCallback>* arr = [cbDictionnary objectForKey:event];
    if (!arr) {
        return;
    }
    for (eventCallback cb : arr) {
        cb(arg);
    }
}
- (void)removeEvent:(NSString*)event {
    if (![cbDictionnary objectForKey:event]) {
        return;
    }
    [cbDictionnary removeObjectForKey:event];
}

- (bool)removeCallback:(NSString*)event callback:(eventCallback)callback {
    NSMutableArray<eventCallback>* arr = [cbDictionnary objectForKey:event];
    if (!arr) {
        return false;
    }
    [arr removeObject:callback];
    return true;
}

- (void)dispatchScriptEvent:(NSString*)event arg:(NSString*)arg {
    [jb sendToScript:event arg1:arg];
}

- (void)dispatchScriptEvent:(NSString*)event {
    [jb sendToScript:event];
}
- (id)init {
    self          = [super init];
    cbDictionnary = [NSMutableDictionary new];
    jb = [JsbBridge sharedInstance];
    [jb setCallback:cb];
    return self;
}
- (void)dealloc {
    for (NSMutableArray* arr : cbDictionnary) {
        [arr release];
    }
    [cbDictionnary release];
    [super dealloc];
}
@end
