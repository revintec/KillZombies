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
    if(!self.dict[name])return;
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
    id opt=(id)kCFBooleanTrue;
    self.dict[@"Xcode"]=opt;
    self.dict[@"TextEdit"]=opt;
    self.dict[@"Automator"]=opt;
    self.dict[@"Script Editor"]=opt;
    self.dict[@"Sublime Text"]=opt;
    
    self.dict[@"Terminal"]=opt;
    self.dict[@"Activity Monitor"]=opt;
    self.dict[@"QuickTime Player"]=opt;
    self.dict[@"MPlayer OSX Extended"]=opt;
    
    self.dict[@"Preview"]=opt;
    self.dict[@"Pages"]=opt;
    self.dict[@"Numbers"]=opt;
    self.dict[@"Keynote"]=opt;
    
    self.dict[@"VMware Fusion"]=opt;
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
