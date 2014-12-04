//
//  AppDelegate.m
//  KillZombies
//
//  Created by revin on Dec.3,2014.
//  Copyright (c) 2014 revin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property NSMutableDictionary*dict;
@end

@implementation AppDelegate
-(void)someotherAppGotDeactivated:(NSNotification*)notification{
    NSDictionary*_n=[notification userInfo];if(_n==nil)return;
    NSRunningApplication*ra=[_n objectForKey:NSWorkspaceApplicationKey];if(ra==nil)return;
    NSString*name=[ra localizedName];
    if(![self.dict objectForKey:name])return;
    AXUIElementRef xa=AXUIElementCreateApplication([ra processIdentifier]);
    // BUG FIX: don't use AXUIElementCopyAttributeValue(xa,kAXWindowsAttribute,&windows)
    // because it won't get windows on other desktop, so will terminate apps by mistake!
    AXError error;CFTypeRef dontCare;
    error=AXUIElementCopyAttributeValue(xa,kAXMainWindowAttribute,&dontCare);
    if(!error)return;else if(kAXErrorNoValue!=error){AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);return;}
    error=AXUIElementCopyAttributeValue(xa,kAXFocusedWindowAttribute,&dontCare);
    if(!error)return;else if(kAXErrorNoValue!=error){AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);return;}
    error=AXUIElementCopyAttributeValue(xa,kAXExtrasMenuBarAttribute,&dontCare);
    if(!error)return;else if(kAXErrorNoValue!=error){AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);return;}
    [ra terminate];
}
-(void)applicationWillBecomeActive:(NSNotification*)notification{
    self.dict=[NSMutableDictionary dictionary];
    [self.dict setObject:self forKey:@"Xcode"];
    [self.dict setObject:self forKey:@"TextEdit"];
    [self.dict setObject:self forKey:@"Automator"];
    [self.dict setObject:self forKey:@"Script Editor"];
    [self.dict setObject:self forKey:@"Sublime Text"];
    
    [self.dict setObject:self forKey:@"Terminal"];
    [self.dict setObject:self forKey:@"Activity Monitor"];
    [self.dict setObject:self forKey:@"QuickTime Player"];
    [self.dict setObject:self forKey:@"MPlayer OSX Extended"];
    
    [self.dict setObject:self forKey:@"Preview"];
    [self.dict setObject:self forKey:@"Pages"];
    [self.dict setObject:self forKey:@"Numbers"];
    [self.dict setObject:self forKey:@"Keynote"];
    
    [self.dict setObject:self forKey:@"VMware Fusion"];
    
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToForegroundApplication);
}
-(IBAction)buttonTapped:(NSButton*)sender
{
    [NSApp terminate:self];
}
-(void)applicationDidResignActive:(NSNotification*)notification{
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToUIElementApplication);
}
-(void)applicationDidFinishLaunching:(NSNotification*)notification{
    if(!AXIsProcessTrusted()){
        [self.window close];
        NSAlert*alert=[[NSAlert alloc]init];
        [alert addButtonWithTitle:@"Quit"];
        [alert setMessageText:@"Can't acquire Accessibility Permissions"];
        [alert setInformativeText:@"Click Quit to quit"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [NSApp terminate:self];
    }else{
        NSNotificationCenter*ncc=[[NSWorkspace sharedWorkspace]notificationCenter];
        [ncc addObserver:self selector:@selector(someotherAppGotDeactivated:) name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    }
}
-(void)applicationWillTerminate:(NSNotification*)notification{
    // Insert code here to tear down your application
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication{
    return false;
}
@end
