//
//  DuanSnake.m
//  games
//
//  Created by 段清伦 on 14-1-3.
//  Copyright (c) 2014年 duan.qinglun. All rights reserved.
//

#import "DuanSnake.h"
#import <stdlib.h>

int snake_width = 10;
float snake_speed = 0.5f;

@interface Food : NSObject

typedef struct {
    int x;
    int y;
} FoodPosition;

@property (nonatomic, assign) FoodPosition position;
@property (nonatomic, retain) NSBezierPath *path;

- (void)newPosition:(NSArray *)range;

@end

@implementation Food

NSRect _scene;

FoodPosition FoodMakePosition(int x, int y) {
    FoodPosition p;
    p.x = x;
    p.y = y;
    return p;
}

NSRect NSRectFromPosition(FoodPosition position)
{
    return NSMakeRect(_scene.origin.x + position.x * snake_width, _scene.origin.y + position.y * snake_width, snake_width, snake_width);
}

- (id)initWithScene:(NSRect)scene
{
    self = [super init];
    if (self) {
        _scene = scene;
        self.path = [NSBezierPath bezierPath];
    }
    return self;
}

- (void)render
{
    [self.path removeAllPoints];
    [self.path appendBezierPathWithRect:NSRectFromPosition(self.position)];
}

- (void)newPosition:(NSArray *)range
{
    NSPoint point = NSPointFromString(range[arc4random() % range.count]);
    self.position = FoodMakePosition(point.x, point.y);
}

@end

@interface Snake : NSObject

typedef enum {
    SnakeOrientationUp,
    SnakeOrientationDown,
    SnakeOrientationLeft,
    SnakeOrientationRight,
}SnakeOrientation;

typedef NSPoint SnakeNode;
typedef NSMutableArray SnakeBody;

@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) SnakeOrientation orientation;
@property (nonatomic, retain) SnakeBody *body;
@property (nonatomic, assign) SnakeNode head;
@property (nonatomic, assign) SnakeNode tail;
@property (nonatomic, assign) SnakeNode shadow;

@property (nonatomic, retain) NSMutableArray *nodesWithoutSnake;

@property (nonatomic, retain) NSBezierPath *path;

- (void)run;
- (void)up;
- (void)down;
- (void)left;
- (void)right;

@end

@implementation Snake

NSRect _scene;

NSRect NSRectFromNode(SnakeNode snakeNode)
{
    return NSMakeRect(_scene.origin.x + snakeNode.x * snake_width, _scene.origin.y + snakeNode.y * snake_width, snake_width, snake_width);
}

- (id)initWithScene:(NSRect)scene
{
    self = [super init];
    if (self) {
        _scene = scene;
        self.body = [[NSMutableArray alloc] init];
        self.nodesWithoutSnake = [[NSMutableArray alloc] init];
        self.path = [NSBezierPath bezierPath];
        [self reset];
    }
    return self;
}

- (void)reset
{
    self.orientation = SnakeOrientationLeft;
    [self.body removeAllObjects];
    NSPoint point = NSMakePoint((int)(_scene.size.width/snake_width)/2, (int)(_scene.size.height/snake_width)/2);
    [self.body addObject:NSStringFromPoint(point)];
    [self.body addObject:NSStringFromPoint(NSMakePoint(point.x + 1, point.y))];
    
    [self.nodesWithoutSnake removeAllObjects];
    for (int i = 0; i < (int)_scene.size.width/snake_width; i++) {
        for (int j = 0; j < (int)_scene.size.height/snake_width; j++) {
            [self.nodesWithoutSnake addObject:NSStringFromPoint(NSMakePoint(i, j))];
        }
    }
    [self.nodesWithoutSnake removeObject:NSStringFromPoint(self.head)];
    [self.nodesWithoutSnake removeObject:NSStringFromPoint(self.tail)];
}

- (SnakeNode)head
{
    return NSPointFromString(self.body[0]);
}

- (SnakeNode)tail
{
    return NSPointFromString([self.body lastObject]);
}

- (void)render
{
    [self.path removeAllPoints];
    for (NSString *node in self.body) {
        SnakeNode snakeNode = NSPointFromString(node);
        [self.path appendBezierPathWithRect:NSRectFromNode(snakeNode)];
    }
}

- (void)eat
{
    [self.body addObject:NSStringFromPoint(self.shadow)];
    [self.nodesWithoutSnake removeObject:NSStringFromPoint(self.shadow)];
}

- (void)run
{
    SnakeNode newHead;
    switch (self.orientation) {
        case SnakeOrientationUp:
        {
            newHead = NSMakePoint(self.head.x, self.head.y + 1);
        }
            break;
            
        case SnakeOrientationDown:
        {
            newHead = NSMakePoint(self.head.x, self.head.y - 1);
        }
            break;
            
        case SnakeOrientationLeft:
        {
            newHead = NSMakePoint(self.head.x - 1, self.head.y);
        }
            break;
            
        case SnakeOrientationRight:
        {
            newHead = NSMakePoint(self.head.x + 1, self.head.y);
        }
            break;
            
        default:
            break;
    }
    
    [self.body insertObject:NSStringFromPoint(newHead) atIndex:0];
    self.shadow = self.tail;
    [self.body removeLastObject];
    
    [self.nodesWithoutSnake removeObject:NSStringFromPoint(newHead)];
    [self.nodesWithoutSnake addObject:NSStringFromPoint(self.shadow)];
}

- (void)up
{
    if (self.orientation == SnakeOrientationLeft || self.orientation == SnakeOrientationRight) {
        self.orientation = SnakeOrientationUp;
    }
}

- (void)down
{
    if (self.orientation == SnakeOrientationLeft || self.orientation == SnakeOrientationRight) {
        self.orientation = SnakeOrientationDown;
    }
}

- (void)left
{
    if (self.orientation == SnakeOrientationUp || self.orientation == SnakeOrientationDown) {
        self.orientation = SnakeOrientationLeft;
    }
}

- (void)right
{
    if (self.orientation == SnakeOrientationUp || self.orientation == SnakeOrientationDown) {
        self.orientation = SnakeOrientationRight;
    }
}

@end

@implementation DuanSnake
{
    Snake *snake;
    Food *food;
    NSRect scene;
    NSTimer *timer;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scene = NSMakeRect(0, 0, frame.size.width, frame.size.height);
        snake = [[Snake alloc] initWithScene:scene];
        food = [[Food alloc] initWithScene:scene];
        
        [food newPosition:snake.nodesWithoutSnake];
        [self resume];
    }
    return self;
}

- (void)restart
{
    [[NSApplication sharedApplication] stopModal];
    [self pause];
    [snake reset];
    [food newPosition:snake.nodesWithoutSnake];
    [self resume];
}

- (void)over
{
    [[NSApplication sharedApplication] stopModal];
    [self pause];
}

- (BOOL)collisionCheck
{
    if (!NSContainsRect(scene, NSRectFromNode(snake.head))) {
        [self gameOver];
        return YES;
    }
    for (int i = 1; i < snake.body.count; i++) {
        NSString *node = snake.body[i];
        SnakeNode snakeNode = NSPointFromString(node);
        if (snakeNode.x == snake.head.x && snakeNode.y == snake.head.y) {
            [self gameOver];
            return YES;
        }
    }
    return NO;
}

- (void)eatIfCan
{
    if ((int)snake.head.x == food.position.x && (int)snake.head.y == food.position.y) {
        [snake eat];
        if (snake.nodesWithoutSnake.count == 0) {
            [self victory];
        } else {
            [food newPosition:snake.nodesWithoutSnake];
        }
    }
}

- (void)run
{
    [snake run];
    [self eatIfCan];
    if (![self collisionCheck]) {
        [self setNeedsDisplay:YES];
    }
}

- (void)resume
{
    [self run];
    timer = [NSTimer scheduledTimerWithTimeInterval:snake_speed target:self selector:@selector(run) userInfo:nil repeats:YES];
}

- (void)pause
{
    [timer invalidate];
}

- (void)gameOver
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Game Over"];
    [alert addButtonWithTitle:@"重来"];
    [alert addButtonWithTitle:@"结束"];
    [alert.buttons[0] setTarget:self];
    [alert.buttons[0] setAction:@selector(restart)];
    [alert.buttons[0] setKeyEquivalent:@"\033"];
    [alert.buttons[1] setTarget:self];
    [alert.buttons[1] setAction:@selector(over)];
    [alert.buttons[1] setKeyEquivalent:@"\r"];
    [alert runModal];
}

- (void)victory
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Victory!!!"];
    [alert runModal];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

    [[NSColor greenColor] set];
    NSRectFill(scene);
    
    [[NSColor blackColor] set];
    [snake render];
    [snake.path fill];
    
    [[NSColor redColor] set];
    [food render];
    [food.path fill];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) { // arrow keys have this mask
        NSString *theArrow = [theEvent charactersIgnoringModifiers];
        unichar keyChar = 0;
        if ( [theArrow length] == 0 )
            return;            // reject dead keys
        if ( [theArrow length] == 1 ) {
            [self pause];
            keyChar = [theArrow characterAtIndex:0];
            switch (keyChar) {
                case NSLeftArrowFunctionKey:
                    [snake left];
                    break;
                case NSRightArrowFunctionKey:
                    [snake right];
                    break;
                case NSUpArrowFunctionKey:
                    [snake up];
                    break;
                case NSDownArrowFunctionKey:
                    [snake down];
                    break;
                default:
                    break;
            }
            [self resume];
            return;
        }
    }
    [super keyDown:theEvent];
}

@end
