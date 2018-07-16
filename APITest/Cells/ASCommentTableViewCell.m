//
//  ASCommentTableViewCell.m
//  APITest
//
//  Created by SA on 7/15/18.
//  Copyright © 2018 Sergei Agishev. All rights reserved.
//

#import "ASCommentTableViewCell.h"

@implementation ASCommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.fromPhoto.layer.cornerRadius = 30 / 2.0;
    self.fromPhoto.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
