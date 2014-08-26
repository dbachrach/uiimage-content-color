//  UIImage+MDContentColor.m
//
//  Created by Mladen Djordjevic on 6/4/14.
//  Copyright (c) 2014 Topnotch Apps. All rights reserved.

#import "UIImage+MDContentColor.h"

static const CGFloat kMDRedMultiplier = 299.0f;
static const CGFloat kMDGreenMultiplier = 587.0f;
static const CGFloat kMDBlueMultiplier = 114.0f;
static const CGFloat kMDDarnessDivider = 1000.0f;
static const CGFloat kMDDefaultDarknessTheshold = .5f;

@implementation UIImage (MDContentColor)

- (UIColor *)md_averageColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

- (MDContentColor)md_imageContentColor
{
    return [self md_imageContentColorWithDarknessThreshold:kMDDefaultDarknessTheshold];
}

- (MDContentColor)md_imageContentColorWithDarknessThreshold:(CGFloat)threshold
{
    return [UIImage md_contentColorForUIColor:[self md_averageColor] darknessThreshold:threshold];
}

+ (MDContentColor)md_contentColorForUIColor:(UIColor *)color
{
    return [self md_contentColorForUIColor:color darknessThreshold:kMDDefaultDarknessTheshold];
}

+ (MDContentColor)md_contentColorForUIColor:(UIColor *)color darknessThreshold:(CGFloat)threshold
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat darknessScore = ((components[0] * 255.0f * kMDRedMultiplier) + (components[1] * 255.0f * kMDGreenMultiplier) + (components[2] * 255.0f * kMDBlueMultiplier)) / kMDDarnessDivider;
    if (darknessScore >= (threshold * 255.0f)) {
        return MDContentColorLight;
    }
    return MDContentColorDark;
}

@end
