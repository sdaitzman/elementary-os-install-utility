//
//  main.m
//  Elementary OS Install utility
//
//  Created by Sam Daitzman on 8/16/14.
//  Copyright (c) 2014 Sam Daitzman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
