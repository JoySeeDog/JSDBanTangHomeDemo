//
//  UIImage+JQImage.m
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/11/23.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "UIImage+JQImage.h"

@implementation UIImage (JQImage)


+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
