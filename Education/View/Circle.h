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
@property (strong, nonatomic) NSString *circleType;

- (id)initWithFrame:(NSRect)frameRect andType:(NSString *)type andColor:(NSColor *)color;

@end
