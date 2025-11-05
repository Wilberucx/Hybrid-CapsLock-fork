using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Threading;
using System.Text.Json;
using TooltipApp.Models;

namespace TooltipApp
{
    public partial class MainWindow : Window
    {
        private FileSystemWatcher? _fileWatcher;
        private DispatcherTimer? _hideTimer;
        private static readonly string[] CommandFiles = new[] { "tooltip_commands.json", "#tooltip_command.json" };
        private string? _lastJson;
        private TooltipCommand? currentTooltip;

        // Colores especificados
        public static class Colors
        {
            public const string AccentOptions = "#dbd6b9";    // Dorado
            public const string AccentNavigation = "#6c958e"; // Verde
            public const string Background = "#1e1e1e";       // Oscuro
            public const string Text = "#ffffff";             // Blanco
            public const string Border = "#404040";           // Gris
        }

        private Brush BrushFromHex(string? hex, string fallback)
        {
            try
            {
                var code = string.IsNullOrWhiteSpace(hex) ? fallback : hex!;
                return new SolidColorBrush((Color)ColorConverter.ConvertFromString(code));
            }
            catch
            {
                return new SolidColorBrush((Color)ColorConverter.ConvertFromString(fallback));
            }
        }

        public MainWindow()
        {
            InitializeComponent();
            InitializeWindow();
            StartFileWatcher();
            // Reposicionar cuando cambie el tamaño (evita desalineo al cambiar items)
            this.SizeChanged += (s, e) => PositionWindow();
            
        }

        private void InitializeWindow()
        {
            // Configurar ventana para click-through
            this.IsHitTestVisible = false;
            
            // Posicionar ventana
            this.Loaded += (s, e) => PositionWindow();

            // Iniciar oculta y sólo mostrar con comandos válidos
            this.Visibility = Visibility.Hidden;
            
            // Configurar timer para auto-hide
            _hideTimer = new DispatcherTimer();
            _hideTimer.Tick += (s, e) => HideTooltip();
        }

        private void PositionWindow()
        {
            ApplyPositionFromCommand(currentTooltip);
        }

        private void ApplyPositionFromCommand(TooltipCommand? command)
        {
            var screenWidth = SystemParameters.PrimaryScreenWidth;
            var screenHeight = SystemParameters.PrimaryScreenHeight;

            // Defaults
            double left = (screenWidth - this.ActualWidth) / 2;
            double top = screenHeight - this.ActualHeight - 50; // bottom_center default

            string preset = command?.Position?.Anchor ?? string.Empty;
            if (string.IsNullOrWhiteSpace(preset))
            {
                // Back-compat presets via tooltip_type
                switch (command?.TooltipType)
                {
                    case "status_persistent":
                        preset = "bottom_left";
                        break;
                    case "sidebar_right":
                        preset = "center_right"; // custom alias handled below
                        break;
                    case "bottom_right_list":
                        preset = "bottom_right";
                        break;
                    default:
                        preset = "bottom_center";
                        break;
                }
            }

            switch (preset)
            {
                case "bottom_left":
                    left = 20;
                    top = screenHeight - this.ActualHeight - 20;
                    break;
                case "bottom_right":
                    left = screenWidth - this.ActualWidth - 20;
                    top = screenHeight - this.ActualHeight - 20;
                    break;
                case "top_left":
                    left = 20;
                    top = 20;
                    break;
                case "top_right":
                    left = screenWidth - this.ActualWidth - 20;
                    top = 20;
                    break;
                case "top_center":
                    left = (screenWidth - this.ActualWidth) / 2;
                    top = 20;
                    break;
                case "center":
                    left = (screenWidth - this.ActualWidth) / 2;
                    top = (screenHeight - this.ActualHeight) / 2;
                    break;
                case "center_right":
                    left = screenWidth - this.ActualWidth - 24;
                    top = (screenHeight - this.ActualHeight) / 2;
                    break;
                case "manual":
                    left = command?.Position?.X ?? left;
                    top = command?.Position?.Y ?? top;
                    break;
                case "bottom_center":
                default:
                    left = (screenWidth - this.ActualWidth) / 2;
                    top = screenHeight - this.ActualHeight - 50;
                    break;
            }

            // Apply offsets
            double dx = command?.Position?.OffsetX ?? 0;
            double dy = command?.Position?.OffsetY ?? 0;

            this.Left = left + dx;
            this.Top = top + dy;
        }

        private void ShowBasicTooltip()
        {
            // Mostrar mensaje de carga exitosa
            TitleText.Text = "HYBRIDCAPSLOCK LOADED";
            
            // Limpiar grid existente
            ItemsGrid.Children.Clear();
            ItemsGrid.RowDefinitions.Clear();
            
            // Mostrar información de carga
            var loadItems = new[]
            {
                new TooltipItem { Key = "✓", Description = "System initialized successfully" },
                new TooltipItem { Key = "✓", Description = "Configuration loaded" },
                new TooltipItem { Key = "✓", Description = "Tooltips enabled" },
                new TooltipItem { Key = "✓", Description = "Ready for use" }
            };
            
            CreateItemsLayout(loadItems);
            
            this.Visibility = Visibility.Visible;
            PositionWindow();
            
            // Auto-hide después de 2 segundos
            _hideTimer.Interval = TimeSpan.FromMilliseconds(2000);
            _hideTimer.Stop();
            _hideTimer.Start();
        }

        private void ApplyPersistentStatusStyle()
        {
            TooltipBorder.Background = BrushFromHex(currentTooltip?.Style?.Background, Colors.Background);
            TooltipBorder.BorderBrush = BrushFromHex(currentTooltip?.Style?.Border, Colors.Border);
            TooltipBorder.BorderThickness = new Thickness(currentTooltip?.Style?.BorderThickness ?? 2);
            TooltipBorder.Padding = currentTooltip?.Style?.Padding != null && currentTooltip.Style.Padding.Length == 4
                ? new Thickness(currentTooltip.Style.Padding[0], currentTooltip.Style.Padding[1], currentTooltip.Style.Padding[2], currentTooltip.Style.Padding[3])
                : new Thickness(12, 8, 12, 8);
            TooltipBorder.CornerRadius = new CornerRadius(currentTooltip?.Style?.CornerRadius ?? 3);

            TitleText.FontWeight = FontWeights.Bold;
            TitleText.FontSize = currentTooltip?.Style?.TitleFontSize ?? 12;
            TitleText.Foreground = BrushFromHex(currentTooltip?.Style?.Text, Colors.Text);
            TitleText.Text = TitleText.Text.ToUpper();

            ItemsGrid.Visibility = Visibility.Collapsed;
            NavigationPanel.Visibility = Visibility.Collapsed;

            this.Topmost = currentTooltip?.Topmost ?? true;
            this.IsHitTestVisible = !(currentTooltip?.ClickThrough ?? true) ? true : false;
            this.Opacity = currentTooltip?.Opacity ?? 1.0;
        }

        private void ApplyRegularTooltipStyle()
        {
            TooltipBorder.Background = BrushFromHex(currentTooltip?.Style?.Background, Colors.Background);
            TooltipBorder.BorderBrush = BrushFromHex(currentTooltip?.Style?.Border, Colors.Border);
            TooltipBorder.BorderThickness = new Thickness(currentTooltip?.Style?.BorderThickness ?? 1);
            TooltipBorder.Padding = currentTooltip?.Style?.Padding != null && currentTooltip.Style.Padding.Length == 4
                ? new Thickness(currentTooltip.Style.Padding[0], currentTooltip.Style.Padding[1], currentTooltip.Style.Padding[2], currentTooltip.Style.Padding[3])
                : new Thickness(16, 12, 16, 12);
            TooltipBorder.CornerRadius = new CornerRadius(currentTooltip?.Style?.CornerRadius ?? 4);
            
            TitleText.FontWeight = FontWeights.Bold;
            TitleText.FontSize = currentTooltip?.Style?.TitleFontSize ?? 14;
            TitleText.Foreground = BrushFromHex(currentTooltip?.Style?.Text, Colors.Text);
            
            ItemsGrid.Visibility = Visibility.Visible;
            NavigationPanel.Visibility = Visibility.Visible;

            // Apply window flags
            this.Topmost = currentTooltip?.Topmost ?? true;
            this.IsHitTestVisible = !(currentTooltip?.ClickThrough ?? true) ? true : false;
            this.Opacity = currentTooltip?.Opacity ?? 1.0;
        }

        private void CreateItemsLayout(TooltipItem[] items)
        {
            int columns = currentTooltip?.Columns > 0 ? currentTooltip.Columns : 4;
            columns = Math.Max(1, columns);

            // Clear, then create column defs dynamically
            ItemsGrid.Children.Clear();
            ItemsGrid.RowDefinitions.Clear();
            ItemsGrid.ColumnDefinitions.Clear();
            for (int c = 0; c < columns; c++)
            {
                ItemsGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            }

            int itemsPerColumn = (int)Math.Ceiling(items.Length / (double)columns);
            itemsPerColumn = Math.Max(1, itemsPerColumn);

            for (int i = 0; i < itemsPerColumn; i++)
            {
                ItemsGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            }

            int currentRow = 0;
            int currentColumn = 0;

            foreach (var item in items)
            {
                var itemPanel = new StackPanel
                {
                    Orientation = Orientation.Horizontal,
                    Margin = new Thickness(8, 2, 8, 2)
                };

                var keyText = new TextBlock
                {
                    Text = string.IsNullOrWhiteSpace(item.Key) ? "" : $"[{item.Key}]",
                    FontFamily = new FontFamily("Segoe UI Symbol"),
                    FontSize = currentTooltip?.Style?.ItemFontSize ?? 12,
                    FontWeight = FontWeights.Bold,
                    Foreground = BrushFromHex(item.Color ?? currentTooltip?.Style?.AccentOptions, Colors.AccentOptions),
                    Margin = new Thickness(0, 0, 8, 0)
                };

                var descText = new TextBlock
                {
                    Text = item.Description,
                    FontFamily = new FontFamily("Consolas"),
                    FontSize = currentTooltip?.Style?.ItemFontSize ?? 12,
                    Foreground = BrushFromHex(currentTooltip?.Style?.Text, Colors.Text)
                };

                itemPanel.Children.Add(keyText);
                itemPanel.Children.Add(descText);

                Grid.SetRow(itemPanel, currentRow);
                Grid.SetColumn(itemPanel, currentColumn);
                ItemsGrid.Children.Add(itemPanel);

                currentRow++;
                if (currentRow >= itemsPerColumn)
                {
                    currentRow = 0;
                    currentColumn++;
                }
            }
        }

        // Create a single-column vertical list for list layout or sidebar_right
        private void CreateItemsList(TooltipItem[] items)
        {
            ItemsGrid.Children.Clear();
            ItemsGrid.RowDefinitions.Clear();
            ItemsGrid.ColumnDefinitions.Clear();
            ItemsGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });

            for (int i = 0; i < items.Length; i++)
            {
                ItemsGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
                var itemPanel = new StackPanel
                {
                    Orientation = Orientation.Horizontal,
                    Margin = new Thickness(0, 2, 0, 2)
                };

                var keyText = new TextBlock
                {
                    Text = items[i].Key,
                    FontFamily = new FontFamily("Segoe UI Symbol"),
                    FontSize = currentTooltip?.Style?.ItemFontSize ?? 12,
                    FontWeight = FontWeights.Bold,
                    Foreground = BrushFromHex(items[i].Color ?? currentTooltip?.Style?.AccentOptions, Colors.AccentOptions),
                    Width = 28
                };

                var descText = new TextBlock
                {
                    Text = items[i].Description,
                    FontFamily = new FontFamily("Consolas"),
                    FontSize = currentTooltip?.Style?.ItemFontSize ?? 12,
                    Foreground = BrushFromHex(currentTooltip?.Style?.Text, Colors.Text),
                    Margin = new Thickness(8, 0, 0, 0)
                };

                itemPanel.Children.Add(keyText);
                itemPanel.Children.Add(descText);

                Grid.SetRow(itemPanel, i);
                Grid.SetColumn(itemPanel, 0);
                ItemsGrid.Children.Add(itemPanel);
            }
        }

        private void StartFileWatcher()
        {
            try
            {
                _fileWatcher = new FileSystemWatcher(Directory.GetCurrentDirectory())
                {
                    Filter = "*tooltip_command*.json",
                    NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.CreationTime | NotifyFilters.FileName
                };

                _fileWatcher.Changed += OnCommandFileChanged;
                _fileWatcher.Created += OnCommandFileChanged;
                _fileWatcher.EnableRaisingEvents = true;
            }
            catch (Exception ex)
            {
                // Log error but don't crash
                Console.WriteLine($"Error starting file watcher: {ex.Message}");
            }
        }

        private void OnCommandFileChanged(object sender, FileSystemEventArgs e)
        {
            // Pequeño delay para evitar múltiples eventos
            System.Threading.Thread.Sleep(50);
            
            try
            {
                var command = ReadTooltipCommand();
                if (command != null)
                {
                    Dispatcher.Invoke(() => UpdateTooltip(command));
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error processing command file: {ex.Message}");
            }
        }

        private TooltipCommand? ReadTooltipCommand()
        {
            try
            {
                string? found = null;
                foreach (var f in CommandFiles)
                {
                    if (File.Exists(f)) { found = f; break; }
                }
                if (found == null) return null;

                var jsonContent = File.ReadAllText(found);
                if (string.IsNullOrWhiteSpace(jsonContent))
                    return null;

                // Ignorar si el contenido no cambió (reduce parpadeos)
                if (string.Equals(_lastJson, jsonContent, StringComparison.Ordinal))
                    return null;
                _lastJson = jsonContent;

                // Usar System.Text.Json en lugar de Newtonsoft.Json
                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                };
                
                return JsonSerializer.Deserialize<TooltipCommand>(jsonContent, options);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error reading command file: {ex.Message}");
                return null;
            }
        }

        private void UpdateTooltip(TooltipCommand command)
        {
            try
            {
                if (!command.Show)
                {
                    HideTooltip();
                    return;
                }

                // Guardar referencia al comando actual
                currentTooltip = command;

                // Flags globales de ventana
                this.Topmost = command.Topmost ?? true;
                this.IsHitTestVisible = !(command.ClickThrough ?? true) ? true : false;
                this.Opacity = command.Opacity ?? 1.0;

                // Actualizar título
                TitleText.Text = !string.IsNullOrEmpty(command.Title) ? command.Title : TitleText.Text;

                // Decidir estilo: usar estilo regular cuando haya layout=list, style en JSON o tooltip_type específico
                bool isList = string.Equals(command.Layout, "list", StringComparison.OrdinalIgnoreCase)
                               || string.Equals(command.TooltipType, "bottom_right_list", StringComparison.OrdinalIgnoreCase)
                               || string.Equals(command.TooltipType, "sidebar_right", StringComparison.OrdinalIgnoreCase);
                bool hasStyle = command.Style != null;

                if (!isList && !hasStyle && command.TooltipType == "status_persistent")
                {
                    ApplyPersistentStatusStyle();
                }
                else
                {
                    ApplyRegularTooltipStyle();

                    // Decidir layout: JSON layout tiene prioridad. Si no, mantener compatibilidad con tooltip_type presets
                    bool useList = string.Equals(command.Layout, "list", StringComparison.OrdinalIgnoreCase)
                                   || command.TooltipType == "sidebar_right"
                                   || command.TooltipType == "bottom_right_list";

                    // Actualizar items si están presentes
                    if (command.Items?.Count > 0)
                    {
                        if (useList)
                            CreateItemsList(command.Items.ToArray());
                        else
                            CreateItemsLayout(command.Items.ToArray());
                    }
                }

                // Actualizar navegación; ocultar si no hay
                if (command.Navigation?.Count > 0)
                {
                    NavigationPanel.Visibility = Visibility.Visible;
                    UpdateNavigation(command.Navigation);
                }
                else
                {
                    NavigationPanel.Children.Clear();
                    NavigationPanel.Visibility = Visibility.Collapsed;
                }

                // Aplicar límites opcionales de tamaño
                if (command.Style != null)
                {
                    this.MaxWidth = command.Style.MaxWidth ?? double.PositiveInfinity;
                    this.MaxHeight = command.Style.MaxHeight ?? double.PositiveInfinity;
                }

                // Mostrar tooltip
                this.Visibility = Visibility.Visible;
                PositionWindow();

                // Configurar auto-hide timer
                if (command.TimeoutMs > 0)
                {
                    _hideTimer.Interval = TimeSpan.FromMilliseconds(command.TimeoutMs);
                    _hideTimer.Stop();
                    _hideTimer.Start();
                }
                else
                {
                    // Timeout 0 => persistente hasta que llegue show=false
                    _hideTimer.Stop();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating tooltip: {ex.Message}");
            }
        }

        private void UpdateNavigation(System.Collections.Generic.List<string> navigation)
        {
            NavigationPanel.Children.Clear();

            foreach (var navItem in navigation)
            {
                var border = new Border
                {
                    Background = BrushFromHex(currentTooltip?.Style?.AccentNavigation, Colors.AccentNavigation),
                    CornerRadius = new CornerRadius(2),
                    Padding = new Thickness(4, 2, 4, 2),
                    Margin = new Thickness(2, 0, 2, 0)
                };

                var text = new TextBlock
                {
                    Text = navItem,
                    FontFamily = new FontFamily("Consolas"),
                    FontSize = currentTooltip?.Style?.NavigationFontSize ?? 10,
                    Foreground = BrushFromHex(currentTooltip?.Style?.NavigationText ?? currentTooltip?.Style?.Text, Colors.Text)
                };

                border.Child = text;
                NavigationPanel.Children.Add(border);
            }
        }

        private void HideTooltip()
        {
            this.Visibility = Visibility.Hidden;
            _hideTimer?.Stop();
        }

        protected override void OnClosed(EventArgs e)
        {
            // Cleanup recursos
            _fileWatcher?.Dispose();
            _hideTimer?.Stop();
            base.OnClosed(e);
        }

        // Permitir que la ventana sea movida (para testing)
        protected override void OnMouseLeftButtonDown(MouseButtonEventArgs e)
        {
            if (e.ButtonState == MouseButtonState.Pressed)
                this.DragMove();
        }
    }
}