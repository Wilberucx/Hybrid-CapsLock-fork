using System.Windows;

namespace TooltipApp
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            
            // Crear y mostrar la ventana principal (oculta inicialmente)
            var mainWindow = new MainWindow();
            // No llamar Show() aquí - la ventana se mostrará cuando sea necesario
            
        }
    }
}