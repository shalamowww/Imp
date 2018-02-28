# Imp 😈
Imp is a tiny yet useful Xcode extension, which allows you to sort import declarations and remove duplicates. Sorting import statements is a good quality coding practice and Imp is here to help you.

**Tame the Imp by binding a key in Xcode preferences**

## Supported languages
Objective-C, Swift

## Features

- [x] Basic import sorting
- [x] The class header on top, separated by new line
- [x] Split frameworks and headers imports
- [x] Remove duplicates
- [x] Sorting selected lines
- [ ] Cut empty lines among imports
- [ ] More flexible settings

If you have an idea for a new feature, please file an issue and tell me more.

## Installation

### Demo way
Clone and Run the project with Xcode 8+ (make sure the App and the Extension are signed with your developer account)

### Right way
1. Open ``Imp.xcodeproj``
2. Sign both the Application and the Extension using your own developer account
3. Product > Archive
4. Right click archive > Show in Finder
5. Right click archive > Show Package Contents
6. Open Products, Applications
7. Drag ``Imp.app`` to your Applications folder
8. Run ``Imp.app`` and close it (the app need to be run at least once)
9. Go to System Preferences -> Extensions and check if ``Imp Tools`` is enabled in Xcode Source Editor section (or ``Imp`` in All section)
10. ``Imp Tools`` should now be available from Xcode's Editor menu
11. Bind a key for ``Sort imports`` command
12. Find a Large Class with many messy imports
13. Hit the key and enjoy the magic!

## Settings
Just run ``Imp`` from your Applications folder. No need in restarting Xcode to apply the changes!

## How to uninstall
1. Disable the extension in System Preferences
2. Delete the App from Applications folder
3. Feel sorry

## Known limitations (objC)
Imp doesn’t like messy code and may think that the first @implementation (or @interface, in case no implementation found) he founds is the class you are working with. Xcode doesn’t provide any information on the current file, so little fella has to guess it. It will affect the header which will (or will not) be popped to top with “own header on top” setting.

## Thank you
For any questions or feedbacks, feel free to contact me directly via Telegram: @alexxxander
