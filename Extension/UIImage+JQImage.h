//
//  UIImage+JQImage.h
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/11/23.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JQImage)

/**
 根据颜色和尺寸生成图片

 @param color 颜色
 @param size 输出图片大小
 @return 图片大小
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
