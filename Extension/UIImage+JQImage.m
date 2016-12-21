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


- (UIImage *)transformWidth:(CGFloat)width height:(CGFloat)height{
    
    CGImageRef imageRef = self.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4*width, CGImageGetColorSpace(imageRef), (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *resultImage = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    return resultImage;
}

-(UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    if (imageSize.width > imageSize.height) {
        size = CGSizeMake(size.height, size.width);
    }
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (NSData *)compressImageBelow:(NSInteger)length{
    
    NSData *data11 = UIImageJPEGRepresentation(self, 1);
    double i = 15;
    while (data11.length > length) {
        i = i  * 2.0 / 3.0;
        data11 = UIImageJPEGRepresentation(self, i / 10.0);
        NSLog(@"%ld",data11.length);
        if (i < 1) {
            i = 0;
            data11 = UIImageJPEGRepresentation(self, i);
            break;
        }
    }
    return data11;
}

- (UIImage *)squareImage{
    CGImageRef squrareImageRef;
    if (self.size.width < self.size.height) {
        squrareImageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake(0, 0, self.size.width, self.size.width));
    }
    else{
        squrareImageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake( (self.size.width - self.size.height)/2.0, 0, self.size.height, self.size.height));
    }
    UIImage *squrareImage = [UIImage imageWithCGImage:squrareImageRef];
    CGImageRelease(squrareImageRef);
    
    return squrareImage;
}




@end
