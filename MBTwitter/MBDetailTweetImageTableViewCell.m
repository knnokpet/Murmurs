//
//  MBDetailTweetImageTableViewCell.m
//  MBTwitter
//
//  Created by Masayuki Ikeda on 2015/01/29.
//  Copyright (c) 2015年 Masayuki Ikeda. All rights reserved.
//

#import "MBDetailTweetImageTableViewCell.h"

static CGFloat defaultHeight = 240;
static CGFloat topBottomMargin = 10;

@interface MBDetailTweetImageTableViewCell()

@property (nonatomic, readonly) UIImageView *mediaImageView;

@end

@implementation MBDetailTweetImageTableViewCell
+ (CGFloat)heightWithImage:(UIImage *)image constraintSize:(CGSize)constraintSize
{
    CGFloat height = defaultHeight;
    if (!image) {
        return height;
    }
    
    
    BOOL isWider = (image.size.width > image.size.height) ? YES : NO;
    if (isWider) {
        CGFloat heightScale = 1.0;
        if (image.size.width > constraintSize.width) {
            heightScale = constraintSize.width / image.size.width;
            height = ceilf(image.size.height * heightScale);
        } else {
            CGFloat widthScale = constraintSize.width / image.size.width;
            height = ceilf(image.size.height * widthScale);
        }
        
        
    } else {
        if (image.size.height < defaultHeight) {
            CGFloat widthScale = constraintSize.width / image.size.width;
            height = ceilf(image.size.height * widthScale);
            
        } else {
            if (image.size.width > constraintSize.width) {
                CGFloat widthScale = constraintSize.width / image.size.width;
                height = ceilf(image.size.height * widthScale);
                
            } else {
                CGFloat widthScale = constraintSize.width / image.size.width;
                height = ceilf(image.size.height * widthScale);
            }
        }
    }
    
    return height + (topBottomMargin * 2);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
        [self configureView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)commonInit
{
    self.userInteractionEnabled = NO;
}

- (void)configureView
{
    _mediaImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.mediaImageView];
}

#pragma mark
#pragma mark - Setter & Getter

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMediaImage:(UIImage *)mediaImage
{
    _mediaImage = mediaImage;
    self.mediaImageView.image = mediaImage;
    [self compositeMediaImageViewSize];
    [self setNeedsLayout];
}

#pragma mark 
#pragma mark Instance Methods
- (void)compositeMediaImageViewSize
{
    CGSize mediaImageViewSize = CGSizeZero;
    
    if (!self.mediaImageView.image) {
        self.mediaImageView.frame = CGRectMake(0, 0, self.bounds.size.width, defaultHeight);
        return;
        
    }
    
    UIImage *mediaImage = self.mediaImageView.image;
    BOOL isWider = (mediaImage.size.width > mediaImage.size.height) ? YES : NO;
    if (isWider) {
        CGFloat heightScale = 1.0;
        if (mediaImage.size.width > self.bounds.size.width) {
            heightScale = self.bounds.size.width / mediaImage.size.width;
            mediaImageViewSize = CGSizeMake(self.bounds.size.width, ceilf(mediaImage.size.height * heightScale));
            
        } else {
            CGFloat widthScale = self.bounds.size.width / mediaImage.size.width;
            mediaImageViewSize = CGSizeMake(ceilf(mediaImage.size.width * widthScale), ceilf(mediaImage.size.height * widthScale));
        }
        
    } else {
        if (mediaImage.size.height < defaultHeight) {
            CGFloat widthScale = self.bounds.size.width / mediaImage.size.width;
            mediaImageViewSize = CGSizeMake(ceilf(mediaImage.size.width * widthScale), ceilf(mediaImage.size.height * widthScale));
            
        } else {
            if (mediaImage.size.width > self.bounds.size.width) {
                CGFloat widthScale = self.bounds.size.width / mediaImage.size.width;
                mediaImageViewSize = CGSizeMake(self.bounds.size.width, ceilf(mediaImage.size.height * widthScale));
                
            } else {
                CGFloat widthScale = self.bounds.size.width / mediaImage.size.width;
                mediaImageViewSize = CGSizeMake(ceilf(mediaImage.size.width * widthScale), ceilf(mediaImage.size.height * widthScale));
                
            }
        }
    }
    self.mediaImageView.frame = CGRectMake( ceilf(self.bounds.size.width / 2 - mediaImageViewSize.width / 2), topBottomMargin, mediaImageViewSize.width, mediaImageViewSize.height);
    
}

#pragma mark 
#pragma mark - View
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect imageViewFrame = self.mediaImageView.frame;
    imageViewFrame.origin.x = ceilf(bounds.size.width / 2 - imageViewFrame.size.width / 2);
    self.mediaImageView.frame = imageViewFrame;
}

@end
