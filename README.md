## Pro Tools full screen App Window
Removes borders from application window <br>

#### Functionality

- Keyboard shortcut to toggle ugly borders
- Mouse middle-click to toggle menu visibility.
- Keep main window borders visible and remove just the mix/edit window's blue vista border
- Auto-fullscreen
- Settings stored in PTFS_App.ini

#### Default shortcuts
- `Ctrl + F12`: Toggle fullscreen mode<br>
- `Mouse Middle-Click`: Toggle menu visibility when fullscreen<br>

#### PTFS_App.ini Options
- `PT_Monitor (number)` Monitor to make Pro Tools full screen on. Default: MonitorGetPrimary()
- `Custom_Width (0|1)` Custom PT window width in pixels. Default: 0 (Use primary monitor width) ; 1: use `WindowWidth`
- `WindowWidth (number)` Pro Tools window width used when `CustomWidth=1`
- `Show_Project_Name (0|1)`: Show project name when window in focus. Default: 1
- `Keep_Main_Window (0|1)`: Keep main window border and menu. Default: 0
- `Thin_Border (0|1) ` 0: remove all borders from edit and mix windows; 1: wil use WM_BORDER as window style; Default: 0
- `Auto_Fullscreen (0|1)` Keeps Pro Tools in fullscreen mode, until the keyboard shortcut is pressed; Default: 0

#### Notes
- When `ThinBorder=0` and menu is visible, moving regions in timeline is glitchy on certain resolutions. Either hide the menu with middle-mouse click, or switch to `ThinBorder=1` <br>
- Use `Keep_Main_Window=1` to be able to drag and resize the main window.

#### Todo
- nothing planned for now
- maybe a GUI for settings...
