using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Shapes;

namespace PoeSvintus
{
    public partial class RegionSelectWindow : Window
    {
        private Point _startPoint;
        public Rect SelectedRect { get; private set; }
        public bool IsCancelled { get; private set; } = true;

        public RegionSelectWindow()
        {
            InitializeComponent();
        }

        private void Window_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
            {
                _startPoint = e.GetPosition(SelectionCanvas);
                Canvas.SetLeft(SelectionRect, _startPoint.X);
                Canvas.SetTop(SelectionRect, _startPoint.Y);
                SelectionRect.Width = 0;
                SelectionRect.Height = 0;
                SelectionRect.Visibility = Visibility.Visible;
            }
        }

        private void Window_MouseMove(object sender, MouseEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
            {
                var currentPoint = e.GetPosition(SelectionCanvas);

                var x = Math.Min(_startPoint.X, currentPoint.X);
                var y = Math.Min(_startPoint.Y, currentPoint.Y);
                var w = Math.Max(_startPoint.X, currentPoint.X) - x;
                var h = Math.Max(_startPoint.Y, currentPoint.Y) - y;

                Canvas.SetLeft(SelectionRect, x);
                Canvas.SetTop(SelectionRect, y);
                SelectionRect.Width = w;
                SelectionRect.Height = h;
            }
        }

        private void Window_MouseUp(object sender, MouseButtonEventArgs e)
        {
            if (SelectionRect.Width > 1 && SelectionRect.Height > 1)
            {
                SelectedRect = new Rect(Canvas.GetLeft(SelectionRect), Canvas.GetTop(SelectionRect), SelectionRect.Width, SelectionRect.Height);
                IsCancelled = false;
                this.Close();
            }
        }

        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Escape)
            {
                IsCancelled = true;
                this.Close();
            }
        }
    }
}
