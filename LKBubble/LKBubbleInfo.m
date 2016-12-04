//
//  LKBubbleInfo.m
//  LemonKit
//
//  Created by 1em0nsOft on 16/9/12.
//  Copyright © 2016年 1em0nsOft. All rights reserved.
//

#import "LKBubbleInfo.h"

@implementation LKBubbleInfo

- (instancetype)init{
    self = [super init];
    if (self) {
        self.bubbleSize = CGSizeMake(180, 120);
        self.cornerRadius = 8;
        self.layoutStyle = BUBBLE_LAYOUT_STYLE_ICON_TOP_TITLE_BOTTOM;
        self.iconAnimation = nil;
        self.onProgressChanged = nil;
        self->_iconArray = nil;
        self->_title = @"LKBubble";
        self.frameAnimationTime = 0.1;
        self.proportionOfIcon = 0.675;
        self.proportionOfSpace = 0.1;
        self.proportionOfPadding = CGPointMake(0.1, 0.1);
        self.locationStyle = BUBBLE_LOCATION_STYLE_CENTER;
        self.proportionOfDeviation = 0;
        self.isShowMaskView = YES;
        self->_maskColor = [UIColor colorWithRed: 0.1 green: 0.1 blue:0.1 alpha:0.2];
        self->_backgroundColor = [UIColor colorWithRed: 0  green: 0 blue: 0 alpha: 0.8];
        self->_iconColor = [UIColor whiteColor];
        self->_titleColor = [UIColor whiteColor];
        self.titleFontSize = 13;
        
        // 生成随机的key
        self->_key = arc4random();
    }
    return self;
}

- (instancetype)initWithTitle: (NSString *)title icon: (UIImage *)icon{
    self = [self init];
    if (self) {
        self->_title = title;
        self->_iconArray = @[icon];
    }
    return self;
}

- (CGSize)measureStringSize:(NSString *)text WithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setLineBreakMode:lineBreakMode];
	NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName : paragraphStyle };
	CGSize tempSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:attributes context:nil].size;
	return CGSizeMake(ceilf(tempSize.width), ceilf(tempSize.height));
}

- (CGRect)calBubbleViewFrame{
    CGFloat y;
    switch (self.locationStyle) {
        case BUBBLE_LOCATION_STYLE_TOP:
            y = 0;
            break;
        case BUBBLE_LOCATION_STYLE_CENTER:
            y = ([UIScreen mainScreen].bounds.size.height - self.bubbleSize.height) / 2;
            break;
        default:
            y = [UIScreen mainScreen].bounds.size.height - self.bubbleSize.height;
            break;
    }
    y += (self.locationStyle != BUBBLE_LOCATION_STYLE_BOTTOM ? 1 : -1) * (self.proportionOfDeviation * [UIScreen mainScreen].bounds.size.height);
    return CGRectMake(([UIScreen mainScreen].bounds.size.width - self.bubbleSize.width) / 2, y, self.bubbleSize.width, self.bubbleSize.height);
}

- (void)calIconView:(UIImageView *)iconView andTitleView:(UILabel *)titleView {
	CGSize bubbleContentSize = CGSizeMake(self.bubbleSize.width * (1 - self.proportionOfPadding.x * 2),
										  self.bubbleSize.height * (1 - self.proportionOfPadding.y * 2));
	CGFloat iconWidth = self.layoutStyle == BUBBLE_LAYOUT_STYLE_ICON_TOP_TITLE_BOTTOM || self.layoutStyle == BUBBLE_LAYOUT_STYLE_ICON_ONLY || self.layoutStyle == BUBBLE_LAYOUT_STYLE_ICON_BOTTOM_TITLE_TOP ?
	bubbleContentSize.height * self.proportionOfIcon :
	bubbleContentSize.height * self.proportionOfIcon;
	
	CGFloat baseX = self.bubbleSize.width * self.proportionOfPadding.x;
	CGFloat baseY = self.bubbleSize.height * self.proportionOfPadding.y;
	
	//计算文本高度，可能是单行也可能是多行
	CGSize calTitleRect = [self.title sizeWithAttributes: @{NSFontAttributeName : [UIFont systemFontOfSize: self.titleFontSize]}];
	CGFloat titleWidth = self.layoutStyle == BUBBLE_LAYOUT_STYLE_ICON_TOP_TITLE_BOTTOM || self.layoutStyle == BUBBLE_LAYOUT_STYLE_ICON_BOTTOM_TITLE_TOP || self.layoutStyle == BUBBLE_LAYOUT_STYLE_TITLE_ONLY ?
	bubbleContentSize.width:
	bubbleContentSize.width * (1 - self.proportionOfSpace) - iconWidth;
	if (titleWidth > calTitleRect.width) {
		titleWidth = calTitleRect.width;
	}
	CGSize titleSize = [self measureStringSize:self.title
									  WithFont:[UIFont systemFontOfSize:_titleFontSize]
							 constrainedToSize:CGSizeMake(titleWidth, MAXFLOAT)
								 lineBreakMode:NSLineBreakByWordWrapping];
	CGFloat titleHeight = titleSize.height;
	if (titleHeight > bubbleContentSize.height) {
		titleHeight = bubbleContentSize.height;
	}
	//初始化frame
	CGRect iconFrame = CGRectMake(baseX, baseY+ (bubbleContentSize.height - iconWidth) / 2, iconWidth, iconWidth);
	CGRect titleFrame = CGRectMake(baseX, baseY + (bubbleContentSize.height - titleHeight) / 2, titleWidth, titleHeight);
	switch (self.layoutStyle) {
		case BUBBLE_LAYOUT_STYLE_ICON_TOP_TITLE_BOTTOM: {
			//图标+文本高度
			CGFloat contentHeight = iconWidth + bubbleContentSize.height * self.proportionOfSpace + titleHeight;
			//垂直居中，图标坐标
			iconFrame.origin.x = baseX + (bubbleContentSize.width - iconWidth) / 2;
			iconFrame.origin.y = baseY + (bubbleContentSize.height - contentHeight) / 2;
			//由图标Y坐标求出文本Y坐标
			titleFrame.origin.y = iconFrame.origin.y + iconWidth + bubbleContentSize.height * self.proportionOfSpace;
			titleFrame.origin.x = baseX + (bubbleContentSize.width - titleWidth) / 2;
		}
			break;
		case BUBBLE_LAYOUT_STYLE_ICON_BOTTOM_TITLE_TOP: {
			//图标+文本高度
			CGFloat contentHeight = iconWidth + bubbleContentSize.height * self.proportionOfSpace + titleHeight;
			//垂直居中，文本Y坐标
			titleFrame.origin.y = baseY + (bubbleContentSize.height - contentHeight) / 2;
			titleFrame.origin.x = baseX + (bubbleContentSize.width - titleWidth) / 2;
			//由文本坐标求出图标坐标
			iconFrame.origin.x = baseX + (bubbleContentSize.width - iconWidth) / 2;
			iconFrame.origin.y = titleFrame.origin.y + titleFrame.size.height + bubbleContentSize.height * self.proportionOfSpace;
		}
			break;
		case BUBBLE_LAYOUT_STYLE_ICON_LEFT_TITLE_RIGHT: {
			//图标+文本宽度
			CGFloat contentWidth = iconWidth + bubbleContentSize.width * self.proportionOfSpace + titleWidth;
			//水平居中，图标X坐标
			iconFrame.origin.x = baseX + (bubbleContentSize.width - contentWidth) / 2;
			//由图标X坐标求出文本X坐标
			titleFrame.origin.x = iconFrame.origin.x + iconWidth + bubbleContentSize.width * self.proportionOfSpace;
		}
			break;
		case BUBBLE_LAYOUT_STYLE_ICON_RIGHT_TITLE_LEFT: {
			//图标+文本宽度
			CGFloat contentWidth = iconWidth + bubbleContentSize.width * self.proportionOfSpace + titleWidth;
			//水平居中，文本X坐标
			titleFrame.origin.x = baseX + (bubbleContentSize.width - contentWidth) / 2;
			//由文本坐标求出图标坐标
			iconFrame.origin.x = titleFrame.origin.x + titleFrame.size.width + bubbleContentSize.width * self.proportionOfSpace;
		}
			break;
		case BUBBLE_LAYOUT_STYLE_ICON_ONLY:
			titleFrame = CGRectMake(0, 0, 0, 0);
			iconFrame.origin.x = (bubbleContentSize.width - iconWidth) / 2;
			break;
		case BUBBLE_LAYOUT_STYLE_TITLE_ONLY:
			titleFrame.origin.y = (bubbleContentSize.height - titleHeight) / 2;
			iconFrame = CGRectMake(0, 0, 0, 0);
			break;
		default:
			break;
	}
	iconView.frame = iconFrame;
	titleView.frame = titleFrame;
}

@end
