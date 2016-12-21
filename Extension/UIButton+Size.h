//
//  UIButton+Size.h
//  bantang
//
//  Created by MS on 15-12-28.
//  Copyright (c) 2015年 ms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Size)
/**
 *  通过字体来设置button的frame
 *
 *  @param width    宽
 *  @param fontSize 字体大小
 *  @param str      title
 *
 *  @return <#return value description#>
 */
+(CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str;




@end
