//
//  Circle.h
//  Education
//
//  Created by Feicun on 15/4/20.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Circle : NSView

@property (strong, nonatomic) NSString *circleText;
- (id)initWithFrame:(NSRect)frameRect andColor:(NSColor *)color;

@end
