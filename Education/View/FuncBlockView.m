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

- (id)initWithFrame:(NSRect)frameRect withType:(NSString *)type andEditable:(BOOL)isEditable {
    if (self = [super initWithFrame:frameRect]) {
        //self.isSelected = NO;
        self.isEditable = isEditable;
        self.type = type;
        if ([type isEqualToString:@"听"]) {
            self.blockColor = [NSColor greenColor];
        } else if ([type isEqualToString:@"说"]) {
            self.blockColor = [NSColor redColor];
        } else if ([type isEqualToString:@"读"]) {
            self.blockColor = [NSColor blueColor];
        } else if ([type isEqualToString:@"写"]) {
            self.blockColor = [NSColor yellowColor];
        }
    }
    return self;
}

- (void)didSelected:(BOOL)selected {
    self.isSelected = selected;
    [self setNeedsDisplay:YES];
}

//- (void)setEditable:(BOOL)editable {
//    self.isEditable = editable;
//}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.isEditable) {
        [self.delegate clickBlock:self];
    }
}

//时间  是否选中

@end
