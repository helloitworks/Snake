//
//  main.m
//  Snake
//
//  Created by 段清伦 on 14-1-24.
//  Copyright (c) 2014年 段清伦. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [[NSApplication sharedApplication] setDelegate:delegate];
        [NSApp run];
    }
    return EXIT_SUCCESS;
}
