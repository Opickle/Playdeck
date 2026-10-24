# Playdeck

A Windows desktop launcher for games, videos, music and apps. Playdeck keeps a personal library on your PC and opens items with their native applications.

## Run from source

1. Install Node.js 22 or newer and pnpm 11.
2. Run `pnpm install`.
3. Run `pnpm start`.

## Build the Windows installer

Run `pnpm dist`. This creates a standard per-user NSIS setup program at `release/Playdeck-Setup-1.0.2.exe`. The wizard lets people choose an install location and desktop shortcut, creates Start Menu and uninstall entries, and keeps library data if the app is removed. The installer does not require administrator access.

GitHub Actions also builds the installer after each push to `main`. Download the `Playdeck-Setup` artifact from the latest **Build Windows installer** workflow run.

## Add items

Use **Add to library**, choose Game, Video, Music or App, then browse to a file. For games and apps, choose the executable or a Windows shortcut. Media opens in the default player configured in Windows. Playdeck never copies, moves or deletes source files. Removing a card only removes its library entry.

On first launch, choose a display name, optional profile picture and accent colour. The setup guide explains how to add each kind of item. You can change profile and colour later in Settings. Library data is stored in the current user's Electron application-data directory.

Playdeck supports Xbox-style controllers: use the D-pad or left stick to move focus, A to select or launch, B to go back, X for item options or add, Y for settings, and LB/RB to switch shelves. The Xbox Guide button toggles fullscreen when the controller and Windows expose that button to the app. F11 is also available. A short animated splash plays at startup.

