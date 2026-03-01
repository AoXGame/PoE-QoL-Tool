# PoE Svintus LIFE

A modern, stable, and AHK-free C# (WPF) application designed to automate repetitive tasks in Path of Exile.

## What is this?
This program replaces obsolete AutoHotkey scripts with a native Windows Desktop application. It utilizes low-level keyboard hooks to ensure hotkeys trigger reliably, and uses native Windows API input simulation to interact with the game, preventing issues like sticky keys or missed inputs.

## Why do you need this?
- Eliminate dependency on AutoHotkey installations
- Prevent conflicts with other scripts and anti-cheat systems
- Enjoy 100% reliable hotkey execution regardless of window focus
- Setup pixel coordinates easily via a modern graphical interface

## Features
### Main Functions

* **Fast Fusing/Jew**
  Spams Left-Click while holding Shift to rapidly apply currency items.

* **Move to Stash**
  Automatically performs Ctrl+Click across your inventory grid, instantly moving items into your open stash.

* **Gem Swap**
  Readily swaps skill gems between your inventory and equipped gear before and after boss fights.

* **Key Spam**
  Continuously spams a specified key (e.g., 'D' for Detonate Dead builds) with adjustable delay.

* **Scour + Alch**
  Automates the process of crafting maps directly in your inventory (Right-click Scour -> Left-click Map -> Right-click Alch -> Left-click Map).

* **Chaos Spam**
  Rapidly rerolls items using Chaos Orbs (Shift + Left-Click continuous spam) based on configured coordinates.

* **Beast Action**
  Automates the tedious process of storing captured beasts into Bestiary Orbs or deleting them from your Bestiary in bulk.

## How to Install?
1. Download the compiled application from the Releases section.
2. Extract the archive to any folder.
3. Run `PoeSvintus.exe`.

## How to Use?
### Configure Coordinates
Unlike older AHK scripts, you no longer need to manually edit configuration files or use a Window Spy tool.

1. Click the "Setup" button next to the desired function in the main interface.
2. The application's status bar will prompt you on where to hover your cursor.
3. Move your mouse over the requested game element (e.g., the top-left stash slot or a specific currency orb).
4. Press the designated setup hotkey (F5, F8, F9, F10, or F11, as indicated by the status bar).
5. The coordinates are automatically saved to your `Config.ini`.

### Assign Hotkeys
1. Click the "Set" button next to any function.
2. Press the keyboard key you wish to bind to that action.
3. The hotkey is immediately saved and ready to use.

## System Requirements
- Windows 10 or Windows 11 (64-bit)
- .NET 10.0 Runtime

## Known Limitations
- The application relies on absolute pixel coordinates. If you change your game resolution, UI scale, or move the game window, you will need to re-run the Setup process for your coordinates.

## License
The program is distributed under the MIT license. You can freely use, modify and distribute it.
