//
//  DBLabel.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBLabel.h"

@implementation DBLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    if(_verticalAlignment == UIControlContentVerticalAlignmentTop ||
       _verticalAlignment == UIControlContentVerticalAlignmentBottom)
    {
        //	If one line, we can just use the lineHeight, faster than querying sizeThatFits
        const CGFloat height = ((self.numberOfLines == 1) ? ceilf(self.font.lineHeight) : [self sizeThatFits:self.frame.size].height);
        
        if(height < self.frame.size.height)
            rect.origin.y = ((self.frame.size.height - height) / 2.0f) * ((_verticalAlignment == UIControlContentVerticalAlignmentTop) ? -1.0f : 1.0f);
    }
    
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}
- (void) setVerticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment
{
    _verticalAlignment = verticalAlignment;
    
    [self setNeedsDisplay];
}



@end
