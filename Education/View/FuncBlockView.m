//
//  FuncBlockView.m
//  Education
//
//  Created by Feicun on 15/4/21.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "FuncBlockView.h"

@interface FuncBlockView()

@property (strong, nonatomic) NSColor *blockColor;
@property (nonatomic) BOOL isEditable;//是否可以被编辑

@end

@implementation FuncBlockView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] setFill];
    [[NSColor grayColor] setStroke];
    [NSBezierPath setDefaultLineWidth:1];
    if (self.isSelected) {
        [self.blockColor setFill];
    }
    NSRectFill(dirtyRect);
    [NSBezierPath strokeRect:dirtyRect];
    // Drawing code here.
}

- (id)initWithFrame:(NSRect)frameRect withType:(int)type andEditable:(BOOL)isEditable {
    if (self = [super initWithFrame:frameRect]) {
        //self.isSelected = NO;
        self.isEditable = isEditable;
        self.type = type;
        switch (self.type) {
            case 1:
                self.blockColor = [NSColor greenColor];
                break;
            case 2:
                self.blockColor = [NSColor redColor];
                break;
            case 3:self.blockColor = [NSColor blueColor];
                break;
            case 4:
                self.blockColor = [NSColor yellowColor];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)didSelected:(BOOL)selected {
    self.isSelected = selected;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.isEditable) {
        [self.delegate clickBlock:self];
    }
}

//时间  是否选中

@end
