using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace PoeSvintus
{
    public class IniFile
    {
        private string _path;

        [DllImport("kernel32", CharSet = CharSet.Unicode)]
        private static extern long WritePrivateProfileString(string section, string key, string value, string filePath);

        [DllImport("kernel32", CharSet = CharSet.Unicode)]
        private static extern int GetPrivateProfileString(string section, string key, string @default, StringBuilder retVal, int size, string filePath);

        public IniFile(string iniPath)
        {
            _path = new FileInfo(iniPath).FullName;
        }

        public string Read(string section, string key, string @default = "")
        {
            var retVal = new StringBuilder(255);
            GetPrivateProfileString(section, key, @default, retVal, 255, _path);
            return retVal.ToString();
        }

        public void Write(string section, string key, string value)
        {
            WritePrivateProfileString(section, key, value, _path);
        }
    }
}
