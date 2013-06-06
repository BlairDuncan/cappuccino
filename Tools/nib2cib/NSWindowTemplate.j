/*
 * NSWindowTemplate.j
 * nib2cib
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <AppKit/CPPanel.j>
@import <AppKit/_CPCibWindowTemplate.j>

@global CP_NSMapClassName

var NSBorderlessWindowMask              = 0x00,
    NSTitledWindowMask                  = 0x01,
    NSClosableWindowMask                = 0x02,
    NSMiniaturizableWindowMask          = 0x04,
    NSResizableWindowMask               = 0x08,
    NSUtilityWindowMask                 = 0x10,
    NSDocModalWindowMask                = 0x40,
    NSTexturedBackgroundWindowMask      = 0x100,
    NSHUDBackgroundWindowMask           = 0x2000,

    NSPositionFlexibleRight             = 1 << 19,
    NSPositionFlexibleLeft              = 1 << 20,
    NSPositionFlexibleBottom            = 1 << 21,
    NSPositionFlexibleTop               = 1 << 22,

    NSAutorecalculatesKeyViewLoopWTFlag = 0x800;

@implementation _CPCibWindowTemplate (NSCoding)

- (id)NS_initWithCoder:(CPCoder)aCoder
{
    self = [super init];

    if (self)
    {
        if ([aCoder containsValueForKey:@"NSMinSize"])
            _minSize = [aCoder decodeSizeForKey:@"NSMinSize"];

        if ([aCoder containsValueForKey:@"NSMaxSize"])
            _maxSize = [aCoder decodeSizeForKey:@"NSMaxSize"];

        _screenRect = [aCoder decodeRectForKey:@"NSScreenRect"]; // screen created on
        _viewClass = [aCoder decodeObjectForKey:@"NSViewClass"]; // references the toolbar if present (anything else?)
        _wtFlags = [aCoder decodeIntForKey:@"NSWTFlags"];
        _windowAutorecalculatesKeyViewLoop = !!(_wtFlags & NSAutorecalculatesKeyViewLoopWTFlag);

        // @TODO: this seems to not be used anywhere, maybe we should safely remove this
        // from Antoine the 18 Jan 2013
        // _windowBacking = [aCoder decodeIntForKey:@"NSWindowBacking"];

        // Convert NSWindows to CPWindows.
        _windowClass = CP_NSMapClassName([aCoder decodeObjectForKey:@"NSWindowClass"]);

        _windowRect = [aCoder decodeRectForKey:@"NSWindowRect"];
        _windowStyleMask = [aCoder decodeIntForKey:@"NSWindowStyleMask"];
        _windowTitle = [aCoder decodeObjectForKey:@"NSWindowTitle"];
        _windowView = [aCoder decodeObjectForKey:@"NSWindowView"];
        _windowFrameAutosaveName = [aCoder decodeObjectForKey:@"NSFrameAutosaveName"];

        // Flip Y coordinate
        _windowRect.origin.y = _screenRect.size.height - _windowRect.origin.y - _windowRect.size.height;

        if (_windowStyleMask === NSBorderlessWindowMask)
            _windowStyleMask = CPBorderlessWindowMask;

        else
            _windowStyleMask =  (_windowStyleMask & NSTitledWindowMask ? CPTitledWindowMask : 0) |
                                (_windowStyleMask & NSClosableWindowMask ? CPClosableWindowMask : 0) |
                                (_windowStyleMask & NSMiniaturizableWindowMask ? CPMiniaturizableWindowMask : 0) |
                                (_windowStyleMask & NSResizableWindowMask ? CPResizableWindowMask : 0) |
                                (_windowStyleMask & NSTexturedBackgroundWindowMask ? NSTexturedBackgroundWindowMask : 0) |
                                (_windowStyleMask & NSDocModalWindowMask ? CPDocModalWindowMask : 0) |
                                (_windowStyleMask & NSHUDBackgroundWindowMask ? CPHUDBackgroundWindowMask : 0);

        _windowIsFullPlatformWindow = [aCoder decodeObjectForKey:@"NSFrameAutosaveName"] === @"CPBorderlessBridgeWindowMask";

        /*if (![_windowClass isEqualToString:@"NSPanel"])
           _windowRect.origin.y -= [NSMainMenuView menuHeight];   // compensation for the additional menu bar
        */
   }

   return self;
}

@end

@implementation NSWindowTemplate : _CPCibWindowTemplate
{
}

- (id)initWithCoder:(CPCoder)aCoder
{
    return [self NS_initWithCoder:aCoder];
}

- (Class)classForKeyedArchiver
{
    return [_CPCibWindowTemplate class];
}

@end
