# PoE Svintus LIFE

A comprehensive AutoHotkey automation tool for Path of Exile with a modern GUI interface. Features multiple quality-of-life improvements including bestiary management, gem swapping, currency automation, and more.

## Features

### Bestiary Management
- **Auto Store/Delete**: Automatically store or delete beasts from your bestiary
- **Smart Filtering**: Customizable regex filters for good/rare/bad beasts
- **Statistics Tracking**: Real-time tracking of deleted and stored beasts
- **Dual Modes**: Switch between storing valuable beasts and deleting unwanted ones

### Gem Swap System
- **2/3 Gem Modes**: Support for swapping 2 or 3 gems at once
- **Position Memory**: Saves inventory and socket positions
- **Auto Inventory**: Automatically opens and closes inventory during swap
- **Fast Execution**: Optimized delays for smooth gem swapping

### Currency Automation
- **Scour + Alch**: Automated map rolling with Orb of Scouring and Orb of Alchemy
- **Chaos Orb Spam**: Fast chaos orb rolling for maps
- **Regex Detection**: Stops automatically when desired mod is found (yellow border detection)
- **Loop Mode**: Continuous rolling until stopped or regex match found

### Weapon Swap
- **Custom Hotkey**: Assign any key for weapon swap combo
- **Skill Integration**: Automatically uses skill after weapon swap
- **Triple Send**: Ensures reliable swap-back even in laggy combat
- **Configurable Delays**: Adjust timing for different builds

### Key Spam
- **Single/Dual Key**: Spam one or two keys simultaneously
- **Spam/Hold Modes**: Choose between rapid spam or continuous hold
- **Adjustable Speed**: Delay slider from 50-200ms
- **Custom Keys**: Assign any keyboard keys

### Stash Management
- **Fast Stash Transfer**: Quickly move items to stash with Ctrl+Click
- **Smart Grid**: Automatically calculates all stash positions
- **One-Time Setup**: Only need to set top-left corner position

### Divine Rate Calculator
- **API Integration**: Fetches current Divine Orb rates from poe.ninja
- **Quick Change Calculator**: Calculate change for trades instantly
- **Manual Override**: Set custom rates if needed

## Installation

1. Install [AutoHotkey v1.1+](https://www.autohotkey.com/)
2. Download `SvintusLife.ahk` and `Config.ini`
3. Run `SvintusLife.ahk`
4. Configure your settings through the GUI

## Quick Start Guide

### First Time Setup

1. **Launch the script** - A GUI window will appear
2. **Adjust transparency** - Use the Alpha slider at the bottom
3. **Set Divine rate** - Click "Refresh" to fetch current rates from poe.ninja

**Note**: Most features have built-in **"Help"** buttons in the GUI that provide detailed setup instructions and usage tips. Click these buttons for feature-specific guidance.

### Setting Up Features

Each feature requires initial position setup. For detailed instructions, use the **"Help"** buttons available in the GUI for each feature.

#### Bestiary Setup
1. Click **"Setup"** button in Bestiary section
2. Hover over **"release X"** button → Press **F5**
3. Hover over **center of first beast** → Press **F5**

#### Gem Swap Setup
1. Click **"Setup"** button in GemSwap section
2. Follow on-screen instructions
3. Press **F9** for each position:
   - Gem 1 in inventory
   - Gem 1 socket
   - Gem 2 in inventory
   - Gem 2 socket
   - (Gem 3 positions if using 3-gem mode)

#### Stash Setup
1. Click **"Setup"** button next to F2
2. Hover over **top-left corner** of first stash slot
3. Press **F8**

#### Scour + Alch / Chaos Setup
1. Click **"Main"** setup button
2. Press **F12** for each position:
   - Scour orb in inventory
   - Alchemist orb in inventory
   - Map position (where to click)
   - Chaos orb in inventory
3. Click **"Area"** button to set regex detection zone
4. Click and drag to select the area around map mods

## Hotkeys

### Main Functions
| Key | Function |
|-----|----------|
| **F1** | Start/Stop Beast Store/Delete |
| **F2** | Move items to stash |
| **F3** (Hold) | Fast clicking for Fusing/Jeweller |
| **F4** | Execute gem swap |
| **F5** | Save position during setup |
| **F6** | Change beast filter (Good/Rare/Bad) |
| **Ctrl+F6** | Switch Beast mode (Store/Delete) |
| **F7** | Toggle key spam |
| **F8** | Save stash position |
| **F9** | Save gem position during setup |
| **F10** | Scour+Alch / Chaos Orb (based on mode) |
| **F12** | Save currency position during setup |

### GUI Controls
- **Minimize Button (-)**: Hide to system tray
- **Close Button (X)**: Exit program
- **Tray Icon**: Right-click to show/hide GUI

## Configuration

Settings are automatically saved to `Config.ini` including:
- All position coordinates
- Divine Orb rates
- Beast filter strings
- Key spam settings
- Weapon swap configuration
- GUI transparency

### Beast Filter Strings

Edit regex patterns in the **"Regex"** button:
- **Good Beasts**: Valuable beasts to keep
- **Rare Beasts**: Uncommon but useful beasts
- **Bad Beasts**: Common beasts to delete

Default filters are pre-configured for common valuable beasts.

## Advanced Features

### Chaos/Scour Mode Toggle
- **Mode 1**: Scour + Alch (for white maps)
- **Mode 2**: Chaos Orb spam (for rare maps)
- Toggle with **"Mode"** button

### Loop Mode (Scour+Alch)
- Enable **"Loop: ON"** for continuous rolling
- Automatically stops when regex match is found
- Press **F10** again to stop manually

### Weapon Swap Configuration
1. Set activation hotkey with **"Key"** button
2. Click **"Setup"** to configure:
   - Swap button before skill (default: X)
   - Swap button after skill (default: X)
   - Delay after swap (default: 120ms)
   - Delay after skill (default: 300ms)
3. Enable with checkbox

### Statistics Window
- Click **"Stats"** button to open detailed statistics
- Shows separate counters for good/bad beasts
- **Reset** button to clear session stats
- Independent transparency control

## Tips & Tricks

1. **Bestiary Efficiency**: Use F6 to cycle filters without stopping the process
2. **Gem Swap Speed**: Lower delays in Config.ini for faster swaps (may be less reliable)
3. **Map Rolling**: Set up regex area to include all visible mods for best detection
4. **Key Spam**: Use Hold mode for movement skills, Spam mode for attacks
5. **Transparency**: Set different transparency for main window and stats window

## Troubleshooting

**Script not working in-game:**
- Make sure Path of Exile window is active
- Some features check for "Path of Exile" window title

**Positions not accurate:**
- Re-run setup for that feature
- Ensure game resolution hasn't changed
- Check that UI scale is consistent

**Regex detection not working:**
- Verify the detection area includes the mod text
- Make sure yellow border is visible when hovering over map
- Adjust area size with "Area" setup button

**Gem swap fails:**
- Verify all positions are set correctly
- Increase delays in Config.ini if swaps are too fast
- Make sure inventory is accessible (not in hideout decorating mode)

## Requirements

- Windows 7/8/10/11
- AutoHotkey v1.1 or higher
- Path of Exile (windowed or fullscreen windowed recommended)
- Screen resolution: Any (positions are saved per setup)

## Safety & Fair Play

This tool uses standard AutoHotkey mouse and keyboard automation. It does not:
- Read game memory
- Inject code
- Modify game files
- Provide unfair advantages in combat

Use at your own discretion and follow Path of Exile's Terms of Service.

## Credits

- Mouse movement uses `mouse_event` API for absolute positioning
- Divine rates fetched from poe.ninja API
- GUI design inspired by modern dark themes

## License

This project is provided as-is for personal use.

---

**Note**: Always ensure you're following the game's Terms of Service when using automation tools. This script is designed for quality-of-life improvements and does not provide gameplay advantages.

