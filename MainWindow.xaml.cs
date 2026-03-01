using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

using System.Linq;
using System.Windows.Interop;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Resources;
using System.Reflection;
using System.Media;

namespace PoeSvintus
{
    public partial class MainWindow : Window
    {
        private bool _isGemSwapMode3 = false;
        private bool _isBeastDeleteMode = false;
        private TextBlock? _currentAwaitingHotkey = null;
        private IniFile? _ini;
        private Rect _searchArea = Rect.Empty;
        private StatsWindow? _statsWin;
        private int _beastDelGood = 0;
        private int _beastDelBad = 0;
        private int _beastStrGood = 0;
        private int _beastStrBad = 0;
        private System.Windows.Media.MediaPlayer? _startupPlayer;
        private string? _tempAudioPath;
        private bool _isStashRunning = false;
        private bool _isKeySpamRunning = false;
        private bool _isFusingRunning = false;
        private bool _isBeastRunning = false;
        private System.Threading.CancellationTokenSource? _stashCts;
        private System.Threading.CancellationTokenSource? _keySpamCts;
        private System.Threading.CancellationTokenSource? _fusingCts;
        private System.Threading.CancellationTokenSource? _beastCts;

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool UnhookWindowsHookEx(IntPtr hhk);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr GetModuleHandle(string lpModuleName);

        private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
        private LowLevelKeyboardProc? _proc;
        private IntPtr _hookID = IntPtr.Zero;
        private const int WH_KEYBOARD_LL = 13;
        private const int WM_KEYDOWN = 0x0100;
        private const int WM_SYSKEYDOWN = 0x0104;

        [DllImport("user32.dll")]
        static extern bool SetCursorPos(int x, int y);
        [DllImport("user32.dll")]
        static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);
        [DllImport("user32.dll")]
        static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
        [DllImport("user32.dll")]
        static extern bool GetCursorPos(out POINT lpPoint);

        [StructLayout(LayoutKind.Sequential)]
        struct INPUT {
            public uint type;
            public InputUnion u;
        }

        [StructLayout(LayoutKind.Explicit)]
        struct InputUnion {
            [FieldOffset(0)] public MOUSEINPUT mi;
            [FieldOffset(0)] public KEYBDINPUT ki;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct MOUSEINPUT {
            public int dx, dy;
            public uint mouseData, dwFlags, time;
            public IntPtr dwExtraInfo;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct KEYBDINPUT {
            public ushort wVk, wScan;
            public uint dwFlags, time;
            public IntPtr dwExtraInfo;
        }

        private const uint INPUT_MOUSE = 0;
        private const uint INPUT_KEYBOARD = 1;
        private const uint KEYEVENTF_EXTENDEDKEY = 0x0001;
        private const uint KEYEVENTF_KEYUP = 0x0002;
        private const uint MOUSEEVENTF_MOVE = 0x0001;
        private const uint MOUSEEVENTF_ABSOLUTE = 0x8000;
        private const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
        private const uint MOUSEEVENTF_LEFTUP = 0x0004;
        private const uint MOUSEEVENTF_RIGHTDOWN = 0x0008;
        private const uint MOUSEEVENTF_RIGHTUP = 0x0010;
        private const byte VK_CONTROL = 0x11;

        [StructLayout(LayoutKind.Sequential)]
        public struct POINT { public int X; public int Y; }

        private int _stashSetupState = -1;
        private int _beastSetupState = -1;
        private int _gemSwapSetupState = -1;
        private int _scourSetupState = -1;
        private int _chaosSetupState = -1;
        private readonly string[] _scourSteps = { "ScourX/ScourY", "AlchX/AlchY", "MapX/MapY" };

        public MainWindow()
        {
            InitializeComponent();
            _ini = new IniFile(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Config.ini"));
            this.Loaded += MainWindow_Loaded;

            LoadSettings();
            _ = LoadLeagues();
            _statsWin = new StatsWindow();

            this.Closed += (s, e) => { 
                if (_hookID != IntPtr.Zero) UnhookWindowsHookEx(_hookID);
                _statsWin?.Close(); 
                try { if (!string.IsNullOrEmpty(_tempAudioPath) && File.Exists(_tempAudioPath)) File.Delete(_tempAudioPath); } catch {}
                Application.Current.Shutdown(); 
            };

            InitializeAudio();
            PlayStartupSound();
        }

        private void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            _proc = HookCallback;
            _hookID = SetHook(_proc);
            if (_hookID == IntPtr.Zero) {
                int err = Marshal.GetLastWin32Error();
                StatusFunction.Text = "HOOK ERR 0x" + err.ToString("X");
            } else {
                StatusFunction.Text = "Ready";
            }
        }

        private void InitializeAudio()
        {
            try
            {
                StreamResourceInfo res = Application.GetResourceStream(new Uri("pack://application:,,,/startup.wav"));
                if (res != null)
                {
                    _tempAudioPath = Path.Combine(Path.GetTempPath(), "poe_svintus_startup.wav");
                    using (var fileStream = File.Create(_tempAudioPath))
                    {
                        res.Stream.CopyTo(fileStream);
                    }

                    _startupPlayer = new System.Windows.Media.MediaPlayer();
                    _startupPlayer.Open(new Uri(_tempAudioPath));
                    _startupPlayer.Volume = VolumeSlider.Value;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Audio Init error: " + ex.Message);
            }
        }

        private void PlayStartupSound()
        {
            try
            {
                if (_startupPlayer != null)
                {
                    _startupPlayer.Position = TimeSpan.Zero;
                    _startupPlayer.Play();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Audio Play error: " + ex.Message);
            }
        }

        private async Task LoadLeagues()
        {
            try
            {
                using var client = new HttpClient();
                client.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 PoeSvintus");
                var response = await client.GetStringAsync("https://api.pathofexile.com/leagues?type=main&compact=1");
                var leagues = JsonSerializer.Deserialize<List<LeagueInfo>>(response);
                
                if (leagues != null)
                {
                    LeagueCombo.ItemsSource = leagues.Select(l => l.name).ToList();
                    string savedLeague = _ini?.Read("Settings", "League", "Standard") ?? "Standard";
                    if (LeagueCombo.Items.Contains(savedLeague))
                        LeagueCombo.SelectedItem = savedLeague;
                    else
                        LeagueCombo.SelectedIndex = 0;
                }
            }
            catch (Exception ex)
            {
                StatusFunction.Text = "League Load Error: " + ex.Message;
                LeagueCombo.Items.Add("Standard");
                LeagueCombo.Items.Add("Hardcore");
                LeagueCombo.SelectedIndex = 0;
            }
        }

        public class LeagueInfo
        {
            public string? id { get; set; }
            public string? name { get; set; }
        }

        private void LoadSettings()
        {
            if (_ini == null) return;
            Key_Fusing.Text = _ini.Read("Hotkeys", "Fusing", "None");
            Key_Stash.Text = _ini.Read("Hotkeys", "Stash", "None");
            Key_GemSwap.Text = _ini.Read("Hotkeys", "GemSwap", "None");
            Key_KeySpam.Text = _ini.Read("Hotkeys", "KeySpam", "None");
            Key_Chaos.Text = _ini.Read("Hotkeys", "Chaos", "None");
            Key_Scour.Text = _ini.Read("Hotkeys", "Scour", "None");
            Key_Beast.Text = _ini.Read("Hotkeys", "Beast", "None");
            DivineRateEdit.Text = _ini.Read("Settings", "DivineRate", "155");
            
            double detDelay;
            if (double.TryParse(_ini.Read("Settings", "DetonateDelay", "100"), out detDelay))
                DetonateSlider.Value = detDelay;
            
            double alpha;
            if (double.TryParse(_ini.Read("Settings", "Alpha", "200"), out alpha))
            {
                AlphaSlider.Value = alpha;
                this.Opacity = alpha / 255.0;
            }
            try {
                double x = double.Parse(_ini.Read("Area", "X", "0"));
                double y = double.Parse(_ini.Read("Area", "Y", "0"));
                double w = double.Parse(_ini.Read("Area", "W", "0"));
                double h = double.Parse(_ini.Read("Area", "H", "0"));
                if (w > 0 && h > 0) {
                    _searchArea = new Rect(x, y, w, h);
                    AreaCoordsText.Text = $"Area: {(int)x},{(int)y} {(int)w}x{(int)h}";
                }
            } catch {}

            double vol;
            if (double.TryParse(_ini.Read("Settings", "StartVolume", "0.5"), out vol))
                VolumeSlider.Value = vol;
        }

        protected override void OnSourceInitialized(EventArgs e)
        {
            base.OnSourceInitialized(e);
        }

        private IntPtr SetHook(LowLevelKeyboardProc proc)
        {
            return SetWindowsHookEx(WH_KEYBOARD_LL, proc, GetModuleHandle(null), 0);
        }

        private IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
        {
            if (nCode >= 0 && (wParam == (IntPtr)WM_KEYDOWN || wParam == (IntPtr)WM_SYSKEYDOWN))
            {
                int vkCode = Marshal.ReadInt32(lParam);
                Key key = KeyInterop.KeyFromVirtualKey(vkCode);
                string pressedKey = key.ToString();

                Application.Current.Dispatcher.Invoke(() =>
                {
                    if (_currentAwaitingHotkey != null)
                    {
                        bool isEscape = (key == Key.Escape);
                        string keyName = isEscape ? "None" : pressedKey;
                        _currentAwaitingHotkey.Text = keyName;
                        _currentAwaitingHotkey.Foreground = (SolidColorBrush)FindResource("AccentYellow");
                        StatusFunction.Text = isEscape ? "Hotkey Cleared" : "Saved: " + keyName;
                        StatusFunction.Foreground = (SolidColorBrush)FindResource("DarkTextPrimary");
                        string funcName = _currentAwaitingHotkey.Name.Replace("Key_", "");
                        _ini?.Write("Hotkeys", funcName, keyName);
                        _currentAwaitingHotkey = null;
                        return;
                    }
                    if (key == Key.F8 && _stashSetupState == 0)
                    {
                        SavePosition("Stash", "StartX", "StartY");
                        _stashSetupState = -1;
                        StatusFunction.Text = "Stash setup complete!";
                        return;
                    }
                    if (key == Key.F5 && _beastSetupState >= 0)
                    {
                        if (_beastSetupState == 0) { SavePosition("DeletePos", "posX", "posY"); _beastSetupState = 1; BeastStatusText.Text = "Setup: Beast pickup (F5)"; }
                        else if (_beastSetupState == 1) { SavePosition("BeastPos", "posX", "posY"); _beastSetupState = -1; BeastStatusText.Text = "Setup complete!"; }
                        return;
                    }
                    if (key == Key.F9 && _gemSwapSetupState >= 0)
                    {
                        string[] steps = _isGemSwapMode3
                            ? new[] { "Gem1Inv", "Gem1Socket", "Gem2Inv", "Gem2Socket", "Gem3Inv", "Gem3Socket" }
                            : new[] { "Gem1Inv", "Gem1Socket", "Gem2Inv", "Gem2Socket" };
                        if (_gemSwapSetupState < steps.Length)
                        {
                            SavePosition("GemSwap", steps[_gemSwapSetupState] + "X", steps[_gemSwapSetupState] + "Y");
                            _gemSwapSetupState++;
                            GemSwapStatusText.Text = _gemSwapSetupState < steps.Length
                                ? $"Setup: {steps[_gemSwapSetupState]} (F9)"
                                : "Setup complete!";
                            if (_gemSwapSetupState >= steps.Length) _gemSwapSetupState = -1;
                        }
                        return;
                    }

                    if (key == Key.F10 && _scourSetupState >= 0)
                    {
                        string[] keyPairs = { "ScourX", "AlchX", "MapX" };
                        string[] keyPairsY = { "ScourY", "AlchY", "MapY" };
                        string[] labels = { "ALCH (press F10)", "MAP position (press F10)", "Setup complete!" };
                        GetCursorPos(out POINT p);
                        _ini?.Write("ScourAlch", keyPairs[_scourSetupState], p.X.ToString());
                        _ini?.Write("ScourAlch", keyPairsY[_scourSetupState], p.Y.ToString());
                        _scourSetupState++;
                        StatusFunction.Text = _scourSetupState < 3 
                            ? $"Saved! Now hover over {labels[_scourSetupState - 1]}" 
                            : "Scour+Alch setup complete!";
                        if (_scourSetupState >= 3) _scourSetupState = -1;
                        return;
                    }

                    if (key == Key.F11 && _chaosSetupState >= 0)
                    {
                        string[] keyPairs = { "ChaosX", "MapX" };
                        string[] keyPairsY = { "ChaosY", "MapY" };
                        string[] labels = { "MAP position (press F11)", "Setup complete!" };
                        GetCursorPos(out POINT p);
                        _ini?.Write("ChaosSpam", keyPairs[_chaosSetupState], p.X.ToString());
                        _ini?.Write("ChaosSpam", keyPairsY[_chaosSetupState], p.Y.ToString());
                        _chaosSetupState++;
                        StatusFunction.Text = _chaosSetupState < 2 
                            ? $"Saved! Now hover over {labels[_chaosSetupState - 1]}" 
                            : "Chaos Spam setup complete!";
                        if (_chaosSetupState >= 2) _chaosSetupState = -1;
                        return;
                    }
                    CheckAndTriggerHotkey(pressedKey);
                });
            }
            return CallNextHookEx(_hookID, nCode, wParam, lParam);
        }

        private void CheckAndTriggerHotkey(string pressedKey)
        {
            if (_currentAwaitingHotkey != null) return;

            string stashKey = _ini?.Read("Hotkeys", "Stash",   "None") ?? "None";
            string fusingKey = _ini?.Read("Hotkeys", "Fusing",  "None") ?? "None";
            string gemKey   = _ini?.Read("Hotkeys", "GemSwap", "None") ?? "None";
            string spamKey  = _ini?.Read("Hotkeys", "KeySpam", "None") ?? "None";
            string beastKey = _ini?.Read("Hotkeys", "Beast",   "None") ?? "None";
            string scourKey = _ini?.Read("Hotkeys", "Scour",   "None") ?? "None";
            string chaosKey = _ini?.Read("Hotkeys", "Chaos",   "None") ?? "None";

            if (string.Equals(pressedKey, stashKey, StringComparison.OrdinalIgnoreCase)) ToggleStash();
            else if (string.Equals(pressedKey, fusingKey, StringComparison.OrdinalIgnoreCase)) ToggleFusing();
            else if (string.Equals(pressedKey, gemKey,   StringComparison.OrdinalIgnoreCase)) PerformGemSwap();
            else if (string.Equals(pressedKey, spamKey,  StringComparison.OrdinalIgnoreCase)) ToggleKeySpam();
            else if (string.Equals(pressedKey, beastKey, StringComparison.OrdinalIgnoreCase)) ToggleBeastAction();
            else if (string.Equals(pressedKey, scourKey, StringComparison.OrdinalIgnoreCase)) PerformScourAlch();
            else if (string.Equals(pressedKey, chaosKey, StringComparison.OrdinalIgnoreCase)) ToggleChaosSpam();
        }

        protected override void OnClosed(EventArgs e)
        {
            UnhookWindowsHookEx(_hookID);
            base.OnClosed(e);
        }

        private void ToggleStash()
        {
            if (_isStashRunning)
            {
                _stashCts?.Cancel();
                _isStashRunning = false;
                StatusFunction.Text = "Stash Stopped";
            }
            else
            {
                _isStashRunning = true;
                _stashCts = new System.Threading.CancellationTokenSource();
                PerformMoveToStash(_stashCts.Token);
            }
        }
        private void MoveCursor(int x, int y)
        {
            int screenW = (int)SystemParameters.PrimaryScreenWidth;
            int screenH = (int)SystemParameters.PrimaryScreenHeight;
            
            var input = new INPUT {
                type = INPUT_MOUSE,
                u = new InputUnion {
                    mi = new MOUSEINPUT {
                        dx = (int)(x * 65535.0 / screenW),
                        dy = (int)(y * 65535.0 / screenH),
                        dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE
                    }
                }
            };
            SendInput(1, new[] { input }, Marshal.SizeOf(typeof(INPUT)));
        }

        private void SimulateClick(bool right = false)
        {
            uint down = right ? MOUSEEVENTF_RIGHTDOWN : MOUSEEVENTF_LEFTDOWN;
            uint up   = right ? MOUSEEVENTF_RIGHTUP   : MOUSEEVENTF_LEFTUP;
            var inputs = new INPUT[] {
                new INPUT { type = INPUT_MOUSE, u = new InputUnion { mi = new MOUSEINPUT { dwFlags = down } } },
                new INPUT { type = INPUT_MOUSE, u = new InputUnion { mi = new MOUSEINPUT { dwFlags = up } } },
            };
            SendInput(2, inputs, Marshal.SizeOf(typeof(INPUT)));
        }

        private void SimulateCtrlClick()
        {
            var ctrlDown = new INPUT { type = INPUT_KEYBOARD, u = new InputUnion { ki = new KEYBDINPUT { wVk = VK_CONTROL } } };
            var lDown    = new INPUT { type = INPUT_MOUSE,    u = new InputUnion { mi = new MOUSEINPUT { dwFlags = MOUSEEVENTF_LEFTDOWN } } };
            var lUp      = new INPUT { type = INPUT_MOUSE,    u = new InputUnion { mi = new MOUSEINPUT { dwFlags = MOUSEEVENTF_LEFTUP } } };
            var ctrlUp   = new INPUT { type = INPUT_KEYBOARD, u = new InputUnion { ki = new KEYBDINPUT { wVk = VK_CONTROL, dwFlags = KEYEVENTF_KEYUP } } };
            SendInput(4, new[] { ctrlDown, lDown, lUp, ctrlUp }, Marshal.SizeOf(typeof(INPUT)));
        }

        private async void PerformMoveToStash(System.Threading.CancellationToken token)
        {
            PlayStartupSound();

            if (_ini == null) return;
            
            if (!int.TryParse(_ini.Read("Stash", "StartX", "0"), out int startX) || 
                !int.TryParse(_ini.Read("Stash", "StartY", "0"), out int startY) ||
                (startX == 0 && startY == 0))
            {
                StatusFunction.Text = "ERR: Setup Stash position first!";
                _isStashRunning = false;
                return;
            }

            StatusFunction.Text = "STASHING...";
            StatusFunction.Foreground = System.Windows.Media.Brushes.Orange;

            int rows = 5;
            int cols = 12;
            int cw = 53;
            int ch = 53;

            try {
                for (int r = 0; r < rows; r++)
                {
                    for (int c = 0; c < cols; c++)
                    {
                        if (token.IsCancellationRequested) break;
                        if (c == 11 && r <= 4) continue;

                        int x = startX + c * cw;
                        int y = startY + r * ch;

                        MoveCursor(x, y);
                        await Task.Delay(10, token);
                        SimulateCtrlClick();
                        await Task.Delay(10, token);
                    }
                    if (token.IsCancellationRequested) break;
                }
            }
            catch (OperationCanceledException) {}
            finally {
                _isStashRunning = false;
                StatusFunction.Text = "Finished";
                StatusFunction.Foreground = (SolidColorBrush)FindResource("DarkTextPrimary");
            }
        }

        private void ToggleFusing()
        {
            if (_isFusingRunning)
            {
                _fusingCts?.Cancel();
                _isFusingRunning = false;
                StatusFunction.Text = "Fusing Stopped";
            }
            else
            {
                _isFusingRunning = true;
                _fusingCts = new System.Threading.CancellationTokenSource();
                PerformFusing(_fusingCts.Token);
            }
        }

        private async void PerformFusing(System.Threading.CancellationToken token)
        {
            StatusFunction.Text = "Fusing...";
            try {
                while (!token.IsCancellationRequested)
                {
                    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
                    await Task.Delay(10, token);
                    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero);
                    await Task.Delay(50, token);
                }
            }
            catch (OperationCanceledException) {}
            finally {
                _isFusingRunning = false;
            }
        }

        private async void PerformGemSwap()
        {
            StatusFunction.Text = "Gem Swapping...";
            keybd_event(0x49, 0, 0, UIntPtr.Zero); 
            await Task.Delay(200);

            string[] gems = _isGemSwapMode3 ? new[] { "1", "2", "3" } : new[] { "1", "2" };
            foreach (var g in gems)
            {
                await SwapSingleGem(g);
            }

            keybd_event(0x44, 0, 0, UIntPtr.Zero);
            keybd_event(0x49, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
            StatusFunction.Text = "Gem Swap Finished";
        }

        private async Task SwapSingleGem(string num)
        {
            if (_ini == null) return;
            if (!int.TryParse(_ini.Read("GemSwap", $"Gem{num}InvX", "0"), out int ix) ||
                !int.TryParse(_ini.Read("GemSwap", $"Gem{num}InvY", "0"), out int iy) ||
                !int.TryParse(_ini.Read("GemSwap", $"Gem{num}SocketX", "0"), out int sx) ||
                !int.TryParse(_ini.Read("GemSwap", $"Gem{num}SocketY", "0"), out int sy)
                || (ix == 0 || sx == 0)) return;

            int d = 50;
            MoveCursor(ix, iy); await Task.Delay(d); SimulateClick(); await Task.Delay(d);
            MoveCursor(sx, sy); await Task.Delay(d); SimulateClick(); await Task.Delay(d);
            MoveCursor(ix, iy); await Task.Delay(d); SimulateClick(); await Task.Delay(d);
        }

        private void ToggleKeySpam()
        {
            if (_isKeySpamRunning)
            {
                _keySpamCts?.Cancel();
                _isKeySpamRunning = false;
                StatusFunction.Text = "Key Spam Stopped";
            }
            else
            {
                _isKeySpamRunning = true;
                _keySpamCts = new System.Threading.CancellationTokenSource();
                PerformKeySpam(_keySpamCts.Token);
            }
        }

        private async void PerformKeySpam(System.Threading.CancellationToken token)
        {
            StatusFunction.Text = "Spamming 'D'...";
            int delay = (int)DetonateSlider.Value;
            try {
                while (!token.IsCancellationRequested)
                {
                    keybd_event(0x44, 0, 0, UIntPtr.Zero);
                    await Task.Delay(10, token);
                    keybd_event(0x44, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
                    await Task.Delay(delay, token);
                }
            }
            catch (OperationCanceledException) {}
            finally {
                _isKeySpamRunning = false;
            }
        }

        private async void PerformScourAlch()
        {
            if (_ini == null) return;

            if (!int.TryParse(_ini.Read("ScourAlch", "ScourX", "0"), out int scourX) ||
                !int.TryParse(_ini.Read("ScourAlch", "ScourY", "0"), out int scourY) ||
                !int.TryParse(_ini.Read("ScourAlch", "AlchX",  "0"), out int alchX)  ||
                !int.TryParse(_ini.Read("ScourAlch", "AlchY",  "0"), out int alchY)  ||
                !int.TryParse(_ini.Read("ScourAlch", "MapX",   "0"), out int mapX)   ||
                !int.TryParse(_ini.Read("ScourAlch", "MapY",   "0"), out int mapY)   ||
                (scourX == 0 || alchX == 0 || mapX == 0))
            {
                StatusFunction.Text = "Scour+Alch: Setup required!";
                return;
            }

            StatusFunction.Text = "Scour + Alch...";
            int minDelay = 30;
            int clickDelay = 50;
            int dropDelay = 100;
            MoveCursor(scourX, scourY); await Task.Delay(minDelay);
            SimulateClick(right: true);
            await Task.Delay(clickDelay);

            MoveCursor(mapX, mapY); await Task.Delay(minDelay);
            SimulateClick(right: false);
            await Task.Delay(dropDelay);

            MoveCursor(alchX, alchY); await Task.Delay(minDelay);
            SimulateClick(right: true);
            await Task.Delay(clickDelay);

            MoveCursor(mapX, mapY); await Task.Delay(minDelay);
            SimulateClick(right: false);
            await Task.Delay(dropDelay);

            StatusFunction.Text = "Scour+Alch: Done";
        }

        private bool _isChaosRunning = false;
        private System.Threading.CancellationTokenSource? _chaosCts;

        private void ToggleChaosSpam()
        {
            if (_isChaosRunning)
            {
                _chaosCts?.Cancel();
                _isChaosRunning = false;
                StatusFunction.Text = "Chaos Stopped";
            }
            else
            {
                _isChaosRunning = true;
                _chaosCts = new System.Threading.CancellationTokenSource();
                PerformChaosSpam(_chaosCts.Token);
            }
        }

        private async void PerformChaosSpam(System.Threading.CancellationToken token)
        {
            if (_ini == null) return;
            if (!int.TryParse(_ini.Read("ChaosSpam", "ChaosX", "0"), out int chaosX) ||
                !int.TryParse(_ini.Read("ChaosSpam", "ChaosY", "0"), out int chaosY) ||
                !int.TryParse(_ini.Read("ChaosSpam", "MapX", "0"), out int mapX) ||
                !int.TryParse(_ini.Read("ChaosSpam", "MapY", "0"), out int mapY) ||
                (chaosX == 0 || mapX == 0))
            {
                StatusFunction.Text = "Chaos Spam: Setup required!";
                _isChaosRunning = false;
                return;
            }

            StatusFunction.Text = "Chaos Spamming...";
            try {
                MoveCursor(chaosX, chaosY); await Task.Delay(50, token);
                SimulateClick(right: true); await Task.Delay(50, token);
                MoveCursor(mapX, mapY); await Task.Delay(50, token);
                var shiftDown = new INPUT { type = INPUT_KEYBOARD, u = new InputUnion { ki = new KEYBDINPUT { wVk = 0x10 } } };
                var shiftUp   = new INPUT { type = INPUT_KEYBOARD, u = new InputUnion { ki = new KEYBDINPUT { wVk = 0x10, dwFlags = KEYEVENTF_KEYUP } } };
                SendInput(1, new[] { shiftDown }, Marshal.SizeOf(typeof(INPUT)));
                
                while (!token.IsCancellationRequested)
                {
                    SimulateClick(right: false);
                    await Task.Delay(50, token);
                }
            }
            catch (OperationCanceledException) {}
            finally 
            {
                var shiftUpFinal = new INPUT { type = INPUT_KEYBOARD, u = new InputUnion { ki = new KEYBDINPUT { wVk = 0x10, dwFlags = KEYEVENTF_KEYUP } } };
                SendInput(1, new[] { shiftUpFinal }, Marshal.SizeOf(typeof(INPUT)));
                
                _isChaosRunning = false; 
                StatusFunction.Text = "Chaos Stopped"; 
            }
        }


        private void ToggleBeastAction()
        {
            if (_isBeastRunning)
            {
                _beastCts?.Cancel();
                _isBeastRunning = false;
                BeastStatusText.Text = "Stopped";
            }
            else
            {
                _isBeastRunning = true;
                _beastCts = new System.Threading.CancellationTokenSource();
                if (_isBeastDeleteMode) PerformBeastDelete(_beastCts.Token);
                else PerformBeastStore(_beastCts.Token);
            }
        }

        private async void PerformBeastDelete(System.Threading.CancellationToken token)
        {
            BeastStatusText.Text = "Deleting...";
            if (_ini == null) return;
            if (!int.TryParse(_ini.Read("DeletePos", "posX", "0"), out int dx) ||
                !int.TryParse(_ini.Read("DeletePos", "posY", "0"), out int dy)) return;

            try {
                while (!token.IsCancellationRequested)
                {
                    MoveCursor(dx, dy); await Task.Delay(60, token);
                    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero); await Task.Delay(20, token);
                    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero); await Task.Delay(150, token);
                    
                    keybd_event(0x0D, 0, 0, UIntPtr.Zero);
                    await Task.Delay(20, token);
                    keybd_event(0x0D, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
                    await Task.Delay(300, token);
                    
                    _beastDelBad++; UpdateStatsDisplay();
                }
            }
            catch (OperationCanceledException) {}
            finally { _isBeastRunning = false; BeastStatusText.Text = "Ready"; }
        }

        private async void PerformBeastStore(System.Threading.CancellationToken token)
        {
            if (_ini == null) return;
            BeastStatusText.Text = "Storing...";
            keybd_event(0x49, 0, 0, UIntPtr.Zero);
            await Task.Delay(20);
            keybd_event(0x49, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
            await Task.Delay(1500);

            int autoIndex = 1;
            try {
                while (!token.IsCancellationRequested && autoIndex <= 50)
                {
                    if (!int.TryParse(_ini.Read("BeastPos", "posX", "0"), out int bX) ||
                        !int.TryParse(_ini.Read("BeastPos", "posY", "0"), out int bY) || (bX == 0)) break;
                    if (!int.TryParse(_ini.Read("GridPos", $"gridposX{autoIndex}", "0"), out int gx) ||
                        !int.TryParse(_ini.Read("GridPos", $"gridposY{autoIndex}", "0"), out int gy) || (gx == 0)) break;
                    MoveCursor(bX, bY); await Task.Delay(200, token);
                    var shiftDown = new INPUT { type = INPUT_KEYBOARD, u = new InputUnion { ki = new KEYBDINPUT { wVk = 0x10 } } };
                    var shiftUp   = new INPUT { type = INPUT_KEYBOARD, u = new InputUnion { ki = new KEYBDINPUT { wVk = 0x10, dwFlags = KEYEVENTF_KEYUP } } };
                    SendInput(1, new[] { shiftDown }, Marshal.SizeOf(typeof(INPUT)));
                    SimulateClick();
                    SendInput(1, new[] { shiftUp }, Marshal.SizeOf(typeof(INPUT)));
                    await Task.Delay(200, token);
                    MoveCursor(gx, gy); await Task.Delay(200, token);
                    SimulateClick();
                    await Task.Delay(200, token);

                    _beastStrGood++; UpdateStatsDisplay();
                    autoIndex++;
                }
            }
            catch (OperationCanceledException) {}
            finally { _isBeastRunning = false; BeastStatusText.Text = "Store done"; }
        }


        private void StartAreaSelection()
        {
            var win = new RegionSelectWindow();
            win.ShowDialog();
            if (!win.IsCancelled)
            {
                _searchArea = win.SelectedRect;
                AreaCoordsText.Text = $"Area: {(int)_searchArea.X},{(int)_searchArea.Y} {(int)_searchArea.Width}x{(int)_searchArea.Height}";
                _ini?.Write("Area", "X", ((int)_searchArea.X).ToString());
                _ini?.Write("Area", "Y", ((int)_searchArea.Y).ToString());
                _ini?.Write("Area", "W", ((int)_searchArea.Width).ToString());
                _ini?.Write("Area", "H", ((int)_searchArea.Height).ToString());
                StatusFunction.Text = "Search Area Saved!";
            }
        }

        private void SearchYellowFrame()
        {
            if (_searchArea.IsEmpty || _searchArea.Width <= 0)
            {
                MessageBox.Show("Area not selected. Press Ctrl+Alt+S first.");
                return;
            }

            PlayStartupSound();

            StatusFunction.Text = "Searching for yellow frame...";
            
            int x = (int)_searchArea.X;
            int y = (int)_searchArea.Y;
            int w = (int)_searchArea.Width;
            int h = (int)_searchArea.Height;

            try
            {
                using (var bmp = new System.Drawing.Bitmap(w, h))
                {
                    using (var g = System.Drawing.Graphics.FromImage(bmp))
                    {
                        g.CopyFromScreen(x, y, 0, 0, new System.Drawing.Size(w, h));
                    }
                    var data = bmp.LockBits(new System.Drawing.Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
                    bool found = false;
                    unsafe
                    {
                        byte* ptr = (byte*)data.Scan0;
                        for (int i = 0; i < data.Height * data.Stride; i += 4)
                        {
                            if (ptr[i+2] >= 235 && ptr[i+1] >= 235 && ptr[i] <= 50) 
                            {
                                found = true;
                                break;
                            }
                        }
                    }
                    bmp.UnlockBits(data);

                    if (found)
                    {
                        StatusFunction.Text = "Yellow frame FOUND!";
                    }
                    else
                    {
                        StatusFunction.Text = "Yellow frame NOT found.";
                    }
                }
            }
            catch (Exception ex)
            {
                StatusFunction.Text = "Search Error: " + ex.Message;
            }
        }

        private void SelectArea_Click(object sender, RoutedEventArgs e)
        {
            StartAreaSelection();
        }

        private void Window_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ChangedButton == MouseButton.Left)
                this.DragMove();
        }

        private void Minimize_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }

        private void AlphaSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            this.Opacity = e.NewValue / 255.0;
        }

        private void VolumeSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (_startupPlayer != null && _startupPlayer.Source != null)
                _startupPlayer.Volume = e.NewValue;
        }

        private void Slider_PreviewMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            double alpha = AlphaSlider.Value;
            double vol = VolumeSlider.Value;
            Task.Run(() => {
                _ini?.Write("Settings", "Alpha", ((int)alpha).ToString());
                _ini?.Write("Settings", "StartVolume", vol.ToString("F2"));
            });
        }

        private void DetonateSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (DetonateDelayText != null)
            {
                DetonateDelayText.Text = ((int)e.NewValue).ToString();
                _ini?.Write("Settings", "DetonateDelay", ((int)e.NewValue).ToString());
            }
        }

        private void SetHotkey_Click(object sender, RoutedEventArgs e)
        {
            var btn = sender as Button;
            if (btn == null) return;

            string target = btn.Tag.ToString();
            _currentAwaitingHotkey = FindName("Key_" + target) as TextBlock;

            if (_currentAwaitingHotkey != null)
            {
                _currentAwaitingHotkey.Text = "...";
                _currentAwaitingHotkey.Foreground = System.Windows.Media.Brushes.White;
                StatusFunction.Text = "Press any key...";
            }
        }

        private void MainWindow_KeyDown(object sender, KeyEventArgs e)
        {
            if (_currentAwaitingHotkey != null)
            {
                bool isEscape = (e.Key == Key.Escape);
                string keyName = isEscape ? "None" : e.Key.ToString();
                if (e.Key == Key.System) keyName = e.SystemKey.ToString();

                _currentAwaitingHotkey.Text = keyName;
                _currentAwaitingHotkey.Foreground = (SolidColorBrush)FindResource("AccentYellow");
                StatusFunction.Text = isEscape ? "Hotkey Cleared" : "Hotkey Saved: " + keyName;

                string funcName = _currentAwaitingHotkey.Name.Replace("Key_", "");
                _ini?.Write("Hotkeys", funcName, keyName);
                _currentAwaitingHotkey = null;
                return;
            }
            if (e.Key == Key.F8 && _stashSetupState == 0)
            {
                SavePosition("Stash", "StartX", "StartY");
                _stashSetupState = -1;
                StatusFunction.Text = "Stash setup complete!";
            }
            else if (e.Key == Key.F5 && _beastSetupState >= 0)
            {
                if (_beastSetupState == 0)
                {
                    SavePosition("DeletePos", "posX", "posY");
                    _beastSetupState = 1;
                    BeastStatusText.Text = "Setup: Beast pickup (Press F5)";
                }
                else if (_beastSetupState == 1)
                {
                    SavePosition("BeastPos", "posX", "posY");
                    _beastSetupState = -1;
                    BeastStatusText.Text = "Setup complete!";
                }
            }
            else if (e.Key == Key.F9 && _gemSwapSetupState >= 0)
            {
                string[] keys = _isGemSwapMode3 
                    ? new[] { "Gem1Inv", "Gem1Socket", "Gem2Inv", "Gem2Socket", "Gem3Inv", "Gem3Socket" }
                    : new[] { "Gem1Inv", "Gem1Socket", "Gem2Inv", "Gem2Socket" };

                if (_gemSwapSetupState < keys.Length)
                {
                    SavePosition("GemSwap", keys[_gemSwapSetupState] + "X", keys[_gemSwapSetupState] + "Y");
                    _gemSwapSetupState++;
                    
                    if (_gemSwapSetupState < keys.Length)
                        GemSwapStatusText.Text = $"Setup: {keys[_gemSwapSetupState]} (Press F9)";
                    else
                    {
                        _gemSwapSetupState = -1;
                        GemSwapStatusText.Text = "Setup complete!";
                    }
                }
            }
        }

        private void SavePosition(string section, string keyX, string keyY)
        {
            POINT p;
            if (GetCursorPos(out p))
            {
                _ini?.Write(section, keyX, p.X.ToString());
                _ini?.Write(section, keyY, p.Y.ToString());
            }
        }

        private void StashSetup_Click(object sender, RoutedEventArgs e)
        {
            _stashSetupState = 0;
            StatusFunction.Text = "Setup: Hover Top-Left stash slot and press F8";
        }

        private void ScourAlchSetup_Click(object sender, RoutedEventArgs e)
        {
            _scourSetupState = 0;
            StatusFunction.Text = "Setup: Hover over SCOUR in stash and press F10";
        }

        private void ChaosSetup_Click(object sender, RoutedEventArgs e)
        {
            _chaosSetupState = 0;
            StatusFunction.Text = "Setup: Hover over CHAOS in stash and press F11";
        }

        private void GemSwapMode_Click(object sender, RoutedEventArgs e)
        {
            _isGemSwapMode3 = !_isGemSwapMode3;
            GemSwapModeText.Text = _isGemSwapMode3 ? "Mode: 3 Gems" : "Mode: 2 Gems";
            GemSwapStatusText.Text = "Status: Switched Mode";
        }

        private void GemSwapSetup_Click(object sender, RoutedEventArgs e)
        {
            _gemSwapSetupState = 0;
            GemSwapStatusText.Text = "Setup: Hover Gem 1 Inv and press F9";
        }

        private void GemSwapHelp_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("GemSwap Instructions:\n1. Click Setup\n2. Set positions\n3. Press assigned hotkey", "GemSwap Help");
        }

        private void BeastMode_Click(object sender, RoutedEventArgs e)
        {
            _isBeastDeleteMode = !_isBeastDeleteMode;
            BeastModeText.Text = _isBeastDeleteMode ? "Mode: Delete" : "Mode: Store";
            BeastStatusText.Text = "Status: Switched Mode";
        }

        private void BeastSetup_Click(object sender, RoutedEventArgs e)
        {
            _beastSetupState = 0;
            BeastStatusText.Text = "Setup: Hover 'Release' button and press F5";
        }

        private void BeastFilter_Click(object sender, RoutedEventArgs e)
        {
            RegexWindow rw = new RegexWindow();
            rw.Owner = this;
            
            rw.GoodBeastsBox.Text = _ini?.Read("BeastStrings", "GoodBeasts");
            rw.BadBeast1Box.Text = _ini?.Read("BeastStrings", "BadBeast1");
            rw.BadBeast2Box.Text = _ini?.Read("BeastStrings", "BadBeast2");

            if (rw.ShowDialog() == true)
            {
                _ini?.Write("BeastStrings", "GoodBeasts", rw.GoodBeastsBox.Text);
                _ini?.Write("BeastStrings", "BadBeast1", rw.BadBeast1Box.Text);
                _ini?.Write("BeastStrings", "BadBeast2", rw.BadBeast2Box.Text);
                BeastStatusText.Text = "Filters saved";
            }
        }

        private void BeastHelp_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Bestiary Instructions:\n1. Click Setup\n2. Set positions\n3. Use assigned hotkey to start/stop", "Bestiary Help");
        }

        private void ResetStats_Click(object sender, RoutedEventArgs e)
        {
            BeastStatsText.Text = "Del G:0 B:0 | Str G:0 B:0";
        }

        private void ToggleStatsWindow_Click(object sender, RoutedEventArgs e)
        {
            if (_statsWin == null) return;
            if (_statsWin.Visibility == Visibility.Visible)
                _statsWin.Hide();
            else
            {
                _statsWin.Show();
                UpdateStatsDisplay();
            }
        }

        public void ResetAllStats()
        {
            _beastDelGood = 0;
            _beastDelBad = 0;
            _beastStrGood = 0;
            _beastStrBad = 0;
            UpdateStatsDisplay();
        }

        private void UpdateStatsDisplay()
        {
            string stats = $"Del G:{_beastDelGood} B:{_beastDelBad} | Str G:{_beastStrGood} B:{_beastStrBad}";
            BeastStatsText.Text = stats;
            _statsWin?.UpdateStats(_beastDelGood, _beastDelBad, _beastStrGood, _beastStrBad);
        }

        private void LeagueCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (LeagueCombo.SelectedItem != null)
            {
                _ini?.Write("Settings", "League", LeagueCombo.SelectedItem.ToString()!);
            }
        }

        private async void RefreshRate_Click(object sender, RoutedEventArgs e)
        {
            string league = LeagueCombo.SelectedItem?.ToString()?.Trim() ?? "Standard";
            StatusFunction.Text = $"Fetching rate for {league}...";
            
            try
            {
                using var client = new HttpClient();
                client.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 PoeSvintus");
                string url = $"https://poe.ninja/api/data/currencyoverview?league={Uri.EscapeDataString(league)}&type=Currency";
                var response = await client.GetStringAsync(url);
                
                using var doc = JsonDocument.Parse(response);
                if (!doc.RootElement.TryGetProperty("lines", out var lines))
                {
                    StatusFunction.Text = $"Error: No 'lines' in API response for {league}";
                    return;
                }
                
                foreach (var line in lines.EnumerateArray())
                {
                    string? name = line.TryGetProperty("currencyTypeName", out var n) ? n.GetString() : null;
                    string? detailsId = line.TryGetProperty("detailsId", out var d) ? d.GetString() : null;

                    if (string.Equals(name, "Divine Orb", StringComparison.OrdinalIgnoreCase) || 
                        string.Equals(detailsId, "divine-orb", StringComparison.OrdinalIgnoreCase))
                    {
                        double val = line.GetProperty("chaosEquivalent").GetDouble();
                        DivineRateEdit.Text = val.ToString("F1");
                        _ini?.Write("Settings", "DivineRate", val.ToString("F1"));
                        StatusFunction.Text = $"Updated [{league}]: {val} C";
                        return;
                    }
                }
                StatusFunction.Text = $"Divine Orb not found in {league} API";
            }
            catch (Exception ex)
            {
                StatusFunction.Text = "Update Error: " + ex.Message;
            }
        }

        private void CalcDivine_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                double rate = double.Parse(DivineRateEdit.Text);
                double itemDiv = string.IsNullOrEmpty(ItemPriceDIV.Text) ? 0 : double.Parse(ItemPriceDIV.Text);
                double divGet = string.IsNullOrEmpty(DivineGet.Text) ? 0 : double.Parse(DivineGet.Text);
                double chaosGet = string.IsNullOrEmpty(ChaosGet.Text) ? 0 : double.Parse(ChaosGet.Text);

                double totalItemChaos = itemDiv * rate;
                double totalReceivedChaos = (divGet * rate) + chaosGet;
                double change = totalReceivedChaos - totalItemChaos;

                ChangeReturn.Text = change.ToString("F1");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Invalid input: " + ex.Message);
            }
        }
    }
}
