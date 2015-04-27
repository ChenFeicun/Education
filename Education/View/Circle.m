//
//  Circle.m
//  Education
//
//  Created by Feicun on 15/4/20.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "Circle.h"

@interface Circle()

@property (strong, nonatomic) NSColor *circleColor;

@end

@implementation Circle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    [self addCircleToFontWithContext:context];
    if (self.circleText) {
        NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(0, (self.frame.size.height - 16) / 2, self.frame.size.width - 3, 16)];
        field.font = [NSFont systemFontOfSize:16];
        field.textColor = [NSColor whiteColor];
        field.backgroundColor = [NSColor clearColor];
        field.editable = NO;
        field.selectable = NO;
        field.bordered = NO;
        field.stringValue = self.circleText;
        field.alignment = NSCenterTextAlignment;
        [self addSubview:field];
    }
}

- (void)addCircleToFontWithContext:(NSGraphicsContext *)context {
    [context saveGraphicsState];
    [NSBezierPath setDefaultLineWidth:self.bounds.size.height * 0.05];
    NSBezierPath* thePath = [NSBezierPath bezierPath];
    
    [self.circleColor setFill];
    [thePath appendBezierPathWithOvalInRect:CGRectMake(0, 0, self.bounds.size.width * 0.8, self.bounds.size.height * 0.8)];
    [thePath fill];
    [context restoreGraphicsState];
}

- (id)initWithFrame:(NSRect)frameRect andColor:(NSColor *)color {
    if (self = [super initWithFrame:frameRect]) {
        self.circleColor = color;
    }
    return self;
}

@end
