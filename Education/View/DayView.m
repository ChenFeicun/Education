//
//  BlockView.m
//  Education
//
//  Created by Feicun on 15/4/15.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "DayView.h"
#import "Circle.h"

@interface DayView()

@property (strong, nonatomic) NSTextField *dayTF;

@property (strong, nonatomic) Circle *listenView;
@property (strong, nonatomic) Circle *speakView;
@property (strong, nonatomic) Circle *readView;
@property (strong, nonatomic) Circle *writeView;

@end

@implementation DayView

- (void)setDayText:(NSString *)dayText{
    _dayText = dayText;
    self.dayTF.stringValue = _dayText;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] setFill];
    [[NSColor grayColor] setStroke];
    [NSBezierPath setDefaultLineWidth:self.bounds.size.height*0.02];
    NSRectFill(dirtyRect);
    [NSBezierPath strokeRect:dirtyRect];
}

- (id)initWithFrame:(NSRect)frameRect andDayText:(NSString *)dayText andMonth:(int)month andYear:(int)year {
    if (self = [super initWithFrame:frameRect]) {
        self.dayText = dayText;
        self.month = month;
        self.year = year;
        [self initLabel];
    }
    return self;
}

- (void)mouseUp:(NSEvent *)theEvent {
    self.alphaValue = 1;
    NSPoint point = [theEvent locationInWindow];//[self convertPoint:[theEvent locationInWindow] toView:self];
    NSPoint curPoint = NSMakePoint(point.x - self.frame.origin.x, point.y - self.frame.origin.y);
    if (CGRectContainsPoint(self.bounds, curPoint)) {
        [self.delegate clickDay:self];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    self.alphaValue = 0.3;
    //[self setNeedsDisplay:YES];
}

- (void)initLabel {
    self.layer.borderColor = [NSColor grayColor].CGColor;
    self.layer.borderWidth = 2;
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    float kPadding = 2;
    float kSize = (width - kPadding * 5) / 4;
    
    self.dayTF = [[NSTextField alloc] initWithFrame:NSMakeRect(0, height / 3 * 2 - 7, width - 10, height / 3)];
    self.dayTF.font = [NSFont systemFontOfSize:15];
    self.dayTF.backgroundColor = [NSColor clearColor];
    self.dayTF.editable = NO;
    self.dayTF.selectable = NO;
    self.dayTF.bordered = NO;
    self.dayTF.stringValue = self.dayText;
    self.dayTF.alignment = NSRightTextAlignment;
    [self addSubview:self.dayTF];
    
    self.listenView = [[Circle alloc] initWithFrame:NSMakeRect(kPadding, 5, kSize, kSize) andType:@"听" andColor:[NSColor greenColor]];
    self.listenView.hidden = YES;
    [self addSubview:self.listenView];
    
    self.speakView = [[Circle alloc] initWithFrame:NSMakeRect(kSize + kPadding * 2, 5, kSize, kSize) andType:@"说" andColor:[NSColor redColor]];
    self.speakView.hidden = YES;
    [self addSubview:self.speakView];
    
    self.readView = [[Circle alloc] initWithFrame:NSMakeRect(kSize * 2 + kPadding * 3, 5, kSize, kSize) andType:@"读" andColor:[NSColor blueColor]];
    self.readView.hidden = YES;
    [self addSubview:self.readView];
    
    self.writeView = [[Circle alloc] initWithFrame:NSMakeRect(kSize * 3 + kPadding * 4, 5, kSize, kSize) andType:@"写" andColor:[NSColor yellowColor]];
    self.writeView.hidden = YES;
    [self addSubview:self.writeView];
}
// 与系统日期一致的今天 特殊标记
- (void)addCircleToCurDate:(int)day {
    self.dayTF.stringValue = @"日";
    self.dayTF.frame = NSMakeRect(0, self.dayTF.frame.origin.y, self.dayTF.frame.size.width + 7, self.dayTF.frame.size.height);
    Circle *circle = [[Circle alloc] initWithFrame:NSMakeRect(self.frame.size.width * 0.68, self.frame.size.height / 3 * 2, 30, 30) andType:@"" andColor:[NSColor redColor]];
    circle.circleText = [NSString stringWithFormat:@"%i", day];
    [self addSubview:circle];
}

- (void)showWithLessonType:(NSMutableArray *)lessonTypes {
    NSMutableArray *circleArr = [[NSMutableArray alloc] init];
    [circleArr addObject:self.listenView];
    [circleArr addObject:self.speakView];
    [circleArr addObject:self.readView];
    [circleArr addObject:self.writeView];
    for (int i = 0; i < lessonTypes.count; i++) {
        for (int j = 0; j < circleArr.count; j++) {
            NSLog(@"%@", ((Circle *)circleArr[j]).circleType);
            if ([lessonTypes[i] isEqualToString:((Circle *)circleArr[j]).circleType]) {
                ((Circle *)circleArr[j]).hidden = NO;
            }
        }
    }
}

- (void)showWithType:(NSString *)type {
    if ([type isEqualToString:@"听"]) {
        self.listenView.hidden = NO;
    } else if ([type isEqualToString:@"说"]) {
        self.speakView.hidden = NO;
    } else if ([type isEqualToString:@"读"]) {
        self.readView.hidden = NO;
    } else if ([type isEqualToString:@"写"]) {
        self.writeView.hidden = NO;
    }
}

@end
