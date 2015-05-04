//
//  TimeBlock.m
//  Education
//
//  Created by Feicun on 15/4/29.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "TimeBlock.h"

@interface TimeBlock()

@property (strong, nonatomic) NSMutableDictionary *minutesDict;//(分6段 YES代表有课)

@end

@implementation TimeBlock

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    for (int i = 0; i < 6; i++) {
        BOOL hasLesson = [[self.minutesDict objectForKey:[NSString stringWithFormat:@"%i", i]] boolValue];
        if (hasLesson) {
            [[NSColor grayColor] setFill];
            NSRectFill(((NSTextField *)[self viewWithTag:i]).frame);
        }
    }
    // Drawing code here.
}

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.minutesDict = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < 6; i++) {
            NSTextField *minuteView = [[NSTextField alloc] initWithFrame:NSMakeRect(self.frame.size.width / 6 * i - i, 0, self.frame.size.width / 6, self.frame.size.height)];
            
            minuteView.backgroundColor = [NSColor clearColor];
            minuteView.editable = NO;
            minuteView.selectable = NO;
            minuteView.bordered = YES;
            minuteView.tag = i;
            
            [self addSubview:minuteView];
            [self.minutesDict setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%i", i]];
        }
    }
    return self;
}

- (void)minutesOfHourSelected:(int)start ToEnd:(int)end {
    for (int i = start; i <= end; i++) {
        [self.minutesDict setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i", i]];
    }
    [self setNeedsDisplay:YES];
}

@end
