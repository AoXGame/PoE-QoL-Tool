using System.Windows;
using System.Windows.Input;

namespace PoeSvintus
{
    public partial class StatsWindow : Window
    {
        public StatsWindow()
        {
            InitializeComponent();
        }

        public void UpdateStats(int delGood, int delBad, int strGood, int strBad)
        {
            StatsDelGood.Text = delGood.ToString();
            StatsDelBad.Text = delBad.ToString();
            StatsStrGood.Text = strGood.ToString();
            StatsStrBad.Text = strBad.ToString();
        }

        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            DragMove();
        }

        private void StatsAlphaSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (this.IsLoaded)
                this.Opacity = e.NewValue / 255.0;
        }

        private void Reset_Click(object sender, RoutedEventArgs e)
        {
            if (MessageBox.Show("Reset statistics?", "Confirm", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
            {
                ((MainWindow)Application.Current.MainWindow).ResetAllStats();
            }
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            this.Hide();
        }
    }
}
