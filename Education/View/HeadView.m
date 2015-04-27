//
//  HeadView.m
//  Education
//
//  Created by Feicun on 15/4/20.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "HeadView.h"

@interface HeadView()

@property (strong, nonatomic) NSArray *weekSymbols;

@property (strong, nonatomic) NSButton *todayBtn;
@property (strong, nonatomic) NSButton *previousBtn;
@property (strong, nonatomic) NSButton *nextBtn;

//@property (strong, nonatomic) NSTextField *dateTF;
@end

@implementation HeadView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    
    double width = self.frame.size.width / 7;
    for (int i = 0; i < self.weekSymbols.count; i++) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:17], NSFontAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
        NSAttributedString * weekText = [[NSAttributedString alloc] initWithString:[self.weekSymbols objectAtIndex:i] attributes:attributes];
        double pointX = width * (i + 1) - 2 * 17 - 12;
        [weekText drawAtPoint:NSMakePoint(pointX, self.bounds.size.height * 0.1)];
    }
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:33], NSFontAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
    NSAttributedString *date = [[NSAttributedString alloc] initWithString:self.dateText attributes:attributes];
    [date drawAtPoint:NSMakePoint(12, 2 * 17)];
    // Drawing code here.
}

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self initWithMonth];
    }
    return self;
}

- (void)setDateText:(NSString *)dateText {
    _dateText = dateText;
    [self setNeedsDisplay:YES];
}

- (void)initWithMonth {
    NSCalendar *calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    self.weekSymbols = [calendar shortWeekdaySymbols];
    //self.dateText = @"2015年12月";//[NSString stringWithFormat:@"%i年%i月", year, month];
    
    self.todayBtn = [[NSButton alloc] initWithFrame:NSMakeRect(500, 50, 50, 25)];
    self.todayBtn.title = @"今天";
    [self.todayBtn setButtonType:NSMomentaryPushInButton];
    //响应点击事件 需要设置 action 和 target
    [self.todayBtn setAction:@selector(showToday:)];
    [self.todayBtn setTarget:self];
    self.todayBtn.bezelStyle = NSRoundRectBezelStyle;
    [self addSubview:self.todayBtn];
    
    self.previousBtn = [[NSButton alloc] initWithFrame:NSMakeRect(475, 50, 25, 25)];
    self.previousBtn.image = [NSImage imageNamed:@"previous.png"];
    self.previousBtn.imagePosition = NSImageOnly;
    [self.previousBtn setButtonType:NSMomentaryPushInButton];
    [[self.previousBtn cell] setImageScaling:NSImageScaleProportionallyDown];
    [self.previousBtn setAction:@selector(showPrevious:)];
    [self.previousBtn setTarget:self];
    self.previousBtn.bezelStyle = NSRoundRectBezelStyle;
    [self addSubview:self.previousBtn];
    
    self.nextBtn = [[NSButton alloc] initWithFrame:NSMakeRect(550, 50, 25, 25)];
    self.nextBtn.image = [NSImage imageNamed:@"next.png"];
    self.nextBtn.imagePosition = NSImageOnly;
    [self.nextBtn setButtonType:NSMomentaryPushInButton];
    [[self.nextBtn cell] setImageScaling:NSImageScaleProportionallyDown];
    [self.nextBtn setButtonType:NSMomentaryPushInButton];
    [self.nextBtn setAction:@selector(showNext:)];
    [self.nextBtn setTarget:self];
    self.nextBtn.bezelStyle = NSRoundRectBezelStyle;
    [self addSubview:self.nextBtn];
}

- (void)showToday:(id)sender {
    [self.delegate clickToday];
}

- (void)showPrevious:(id)sender {
    [self.delegate clickPrevious];
}

- (void)showNext:(id)sender {
    [self.delegate clickNext];
}

@end
