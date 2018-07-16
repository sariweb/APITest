//
//  ASPostViewCell.m
//  APITest
//
//  Created by SA on 7/14/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASPostViewCell.h"

static CGFloat phone8PLUSWindowWidth = 375;

@implementation ASPostViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.fromPhoto.layer.cornerRadius = 50 / 2;
    self.fromPhoto.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Height calculations

+ (CGFloat)heightForText:(NSString *)text withFontSize:(CGFloat)fontSize {
    
    CGFloat xOffsetLeft = 10.0;
    CGFloat xOffsetRight = 10.0;
    
    if (fontSize < 17.0) {      
        xOffsetLeft = 50.0;
    }
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes =
    [NSDictionary dictionaryWithObjectsAndKeys:
     font, NSFontAttributeName,
     paragraph, NSParagraphStyleAttributeName, nil];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(phone8PLUSWindowWidth - (xOffsetLeft + xOffsetRight), CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics
                                  attributes:attributes
                                     context:nil];
    
    return CGRectGetHeight(rect);
}

+ (CGFloat)heightForCellWithText:(NSString *)text withFontSize:(CGFloat)fontSize andImagesRatios:(NSArray *)imagesRatios {
    
    static CGFloat xOffset = 10.0;
    static CGFloat yTopOffset = 70.0;
    static CGFloat yBottomOffset = 40.0;
    static CGFloat imageZeroYOffset = 10.0;
    
    CGFloat textHeight = [ASPostViewCell heightForText:text withFontSize:fontSize];
    
    CGFloat imagesTotalHeight = 0.0;
    
    for (int i = 0; i < [imagesRatios count]; i++) {
        
        if (i > 2) {
            break;
        }
        
        CGFloat imageRatio = [[imagesRatios objectAtIndex:i] floatValue];
        CGFloat imageHeight = (phone8PLUSWindowWidth - 2 * xOffset) / imageRatio;
        
        imagesTotalHeight += imageHeight + imageZeroYOffset;
    }
    
    return textHeight + yTopOffset + yBottomOffset + imagesTotalHeight;
}

@end
