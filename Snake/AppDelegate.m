//
//  AppDelegate.m
//  Snake
//
//  Created by 段清伦 on 14-1-24.
//  Copyright (c) 2014年 段清伦. All rights reserved.
//

#import "AppDelegate.h"
#import "DuanSnake.h"

@implementation AppDelegate

- (id)init
{
    if (self = [super init]) {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        [NSApp activateIgnoringOtherApps:YES];
    }
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [NSApp setMainMenu:[NSMenu new]];
    
    NSMenuItem *appMenuItem = [NSMenuItem new];
    [[NSApp mainMenu] addItem:appMenuItem];
    
    NSMenu *appMenu = [NSMenu new];
    [appMenuItem setSubmenu:appMenu];
    
    NSString *appName = [[NSProcessInfo processInfo] processName];
    NSString *quitTitle = [@"Quit " stringByAppendingString:appName];
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle action:@selector(terminate:) keyEquivalent:@"q"];
    [appMenu addItem:quitMenuItem];
    
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 300) styleMask:NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask backing:NSBackingStoreBuffered defer:NO];
    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:[[NSProcessInfo processInfo] processName]];
    [window makeKeyAndOrderFront:self];
    [window makeMainWindow];
    self.window = window;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DuanSnake *view = [[DuanSnake alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
    [self.window.contentView addSubview:view];
}

@end
