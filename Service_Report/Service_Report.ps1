#Requires -Version 5.1
<#
.SYNOPSIS
    Service_Report (easyServiceReport) - Windows Services Security Reporting Tool mit WPF GUI

.DESCRIPTION
    GUI-Tool, das alle Windows-Dienste mit ihrem Dienstkonto anzeigt und
    sicherheitskritische Konten (LocalSystem, Administrator-Konten) hervorhebt.
    Benutzerdefinierte Dienstkonten (gespeichertes Passwort) werden als Warnung,
    eingeschränkte Built-in-/virtuelle Konten als Normal eingestuft.
    Der Bericht kann als HTML exportiert werden.

.NOTES
    Version: 0.0.2
    Autor:   PhinIT
    Datum:   2026-10-14

.EXAMPLE
    .\Service_Report.ps1
#>

Set-StrictMode -Off
$ErrorActionPreference = "Continue"

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# ===========================
# CONFIGURATION
# ===========================

$script:ToolVersion = '0.0.2'

# Hochprivilegierte Konten (Regex, case-insensitive)
$script:CriticalAccountPatterns = @(
    '^(\.\\)?localsystem$',
    '^(nt authority\\)?system$',
    'admin'
)

# Eingeschränkte Built-in-/virtuelle Konten und gMSA (Regex, case-insensitive)
$script:LowPrivilegeAccountPatterns = @(
    '^nt authority\\local ?service$',
    '^nt authority\\network ?service$',
    '^(nt authority\\)?local ?service$',
    '^(nt authority\\)?network ?service$',
    '^nt service\\',
    '^nt virtual machine\\',
    '\$$'
)

$script:CurrentServices = @()

# ===========================
# FUNCTIONS
# ===========================

function Get-ServiceAccountInfo {
    try {
        $services = @(Get-CimInstance -ClassName Win32_Service -Property Name, DisplayName, State, StartMode, StartName, ProcessId -ErrorAction Stop |
            ForEach-Object {
                [PSCustomObject]@{
                    'Name'           = $_.Name
                    'DisplayName'    = $_.DisplayName
                    'State'          = $_.State
                    'StartMode'      = $_.StartMode
                    'ServiceAccount' = $_.StartName
                    'ProcessID'      = $_.ProcessId
                    'RiskLevel'      = Get-AccountRiskLevel -Account $_.StartName
                }
            })
        return $services
    }
    catch {
        [System.Windows.MessageBox]::Show("Fehler beim Abrufen der Services: $($_.Exception.Message)", "Fehler", "OK", "Error") | Out-Null
        return $null
    }
}

function Get-AccountRiskLevel {
    param([string]$Account)

    if ([string]::IsNullOrWhiteSpace($Account)) { return 'Unknown' }

    $accountName = $Account.Trim()

    foreach ($pattern in $script:CriticalAccountPatterns) {
        if ($accountName -match $pattern) { return 'Critical' }
    }

    foreach ($pattern in $script:LowPrivilegeAccountPatterns) {
        if ($accountName -match $pattern) { return 'Normal' }
    }

    # Benutzerdefiniertes Konto (Passwort wird im Dienst-Manager gespeichert)
    return 'Warning'
}

function Get-RiskSortOrder {
    param([string]$RiskLevel)
    switch ($RiskLevel) {
        'Critical' { 0 }
        'Warning'  { 1 }
        'Normal'   { 2 }
        default    { 3 }
    }
}

function Get-RiskStatistic {
    param([object[]]$Services)

    $stats = @{ 'Critical' = 0; 'Warning' = 0; 'Normal' = 0; 'Unknown' = 0 }
    foreach ($service in $Services) {
        $stats[$service.RiskLevel]++
    }
    return $stats
}

function ConvertTo-HtmlText {
    param([AllowNull()][object]$Value)
    if ($null -eq $Value) { return '' }
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Export-HTMLReport {
    param([object[]]$Services, [string]$Path)

    $stats = Get-RiskStatistic -Services $Services
    $computer = ConvertTo-HtmlText $env:COMPUTERNAME
    $user = ConvertTo-HtmlText $env:USERNAME

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append(@"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Windows Services Security Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; background: #f5f5f5; color: #333; }
        .container { max-width: 1400px; margin: 0 auto; background: white; padding: 30px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .header { border-bottom: 3px solid #007bff; padding-bottom: 20px; margin-bottom: 30px; }
        .header h1 { color: #007bff; margin-bottom: 5px; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 4px; margin-bottom: 30px; border-left: 4px solid #007bff; }
        .summary { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .summary-box { padding: 20px; border-radius: 6px; text-align: center; border-left: 4px solid; }
        .critical-box { background: #ffe6e6; border-left-color: #dc3545; color: #721c24; }
        .warning-box { background: #fff3cd; border-left-color: #ffc107; color: #856404; }
        .normal-box { background: #d4edda; border-left-color: #28a745; color: #155724; }
        .unknown-box { background: #e2e3e5; border-left-color: #6c757d; color: #383d41; }
        .summary-box .number { font-size: 36px; font-weight: bold; margin: 10px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        thead { background: #007bff; color: white; }
        th { padding: 15px; text-align: left; font-weight: 600; }
        td { padding: 12px 15px; border-bottom: 1px solid #ddd; }
        tbody tr:hover { background: #f9f9f9; }
        .critical-row { background: #ffe6e6; font-weight: 600; }
        .warning-row { background: #fff3cd; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Windows Services Security Report</h1>
            <p>System: $computer | Generiert: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')</p>
        </div>
        <div class="info">
            <strong>Information:</strong> Dieser Report zeigt alle installierten Services und hebt kritische Konten hervor.
            Kritisch = LocalSystem/Administrator-Konten, Warnung = benutzerdefinierte Dienstkonten, Normal = eingeschränkte Built-in-/virtuelle Konten.
        </div>
        <h2>Zusammenfassung</h2>
        <div class="summary">
            <div class="summary-box critical-box">
                <div>Kritisch</div>
                <div class="number">$($stats['Critical'])</div>
            </div>
            <div class="summary-box warning-box">
                <div>Warnung</div>
                <div class="number">$($stats['Warning'])</div>
            </div>
            <div class="summary-box normal-box">
                <div>Normal</div>
                <div class="number">$($stats['Normal'])</div>
            </div>
            <div class="summary-box unknown-box">
                <div>Unbekannt</div>
                <div class="number">$($stats['Unknown'])</div>
            </div>
        </div>
        <h2>Services</h2>
        <table>
            <thead>
                <tr>
                    <th>Service Name</th>
                    <th>Anzeigename</th>
                    <th>Status</th>
                    <th>Starttyp</th>
                    <th>Konto</th>
                    <th>Risiko</th>
                </tr>
            </thead>
            <tbody>

"@)

    foreach ($service in ($Services | Sort-Object { Get-RiskSortOrder $_.RiskLevel }, Name)) {
        $rowClass = "$(([string]$service.RiskLevel).ToLower())-row"
        [void]$sb.Append(@"
                <tr class="$rowClass">
                    <td>$(ConvertTo-HtmlText $service.Name)</td>
                    <td>$(ConvertTo-HtmlText $service.DisplayName)</td>
                    <td>$(ConvertTo-HtmlText $service.State)</td>
                    <td>$(ConvertTo-HtmlText $service.StartMode)</td>
                    <td>$(ConvertTo-HtmlText $service.ServiceAccount)</td>
                    <td>$(ConvertTo-HtmlText $service.RiskLevel)</td>
                </tr>

"@)
    }

    [void]$sb.Append(@"
            </tbody>
        </table>
        <div class="footer">
            <p>Bericht erstellt mit Service_Report V$($script:ToolVersion)</p>
            <p>System: $computer | Benutzer: $user</p>
        </div>
    </div>
</body>
</html>
"@)

    try {
        $sb.ToString() | Out-File -FilePath $Path -Encoding UTF8 -Force -ErrorAction Stop
        [System.Windows.MessageBox]::Show("Report erfolgreich exportiert:`n$Path", "Erfolg", "OK", "Information") | Out-Null
    }
    catch {
        [System.Windows.MessageBox]::Show("Fehler beim Export: $($_.Exception.Message)", "Fehler", "OK", "Error") | Out-Null
    }
}

# ===========================
# WPF GUI
# ===========================

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Service_Report V$($script:ToolVersion) - Windows Services Security"
        WindowStartupLocation="CenterScreen"
        Width="1400" Height="900"
        Background="#F5F5F5">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Border Grid.Row="0" Background="#007bff" Padding="20">
            <StackPanel>
                <TextBlock Text="Service_Report - easyServiceReport" FontSize="24" FontWeight="Bold" Foreground="White"/>
                <TextBlock Text="Windows Services Security Analysis Tool" FontSize="12" Foreground="#E0E0E0" Margin="0,5,0,0"/>
            </StackPanel>
        </Border>

        <!-- Info Bar -->
        <Border Grid.Row="1" Background="#E7F3FF" BorderThickness="0,0,0,2" BorderBrush="#007bff" Padding="20">
            <StackPanel>
                <TextBlock x:Name="StatusText" Text="Status: Lädt Services..." FontSize="12" Foreground="#0066CC"/>
                <StackPanel Orientation="Horizontal" Margin="0,10,0,0">
                    <TextBlock Text="Kritisch: " FontWeight="Bold" Foreground="#DC3545"/>
                    <TextBlock x:Name="CriticalCount" Text="0" Foreground="#DC3545" Margin="5,0,20,0"/>
                    <TextBlock Text="Warnung: " FontWeight="Bold" Foreground="#B8860B"/>
                    <TextBlock x:Name="WarningCount" Text="0" Foreground="#B8860B" Margin="5,0,20,0"/>
                    <TextBlock Text="Normal: " FontWeight="Bold" Foreground="#28A745"/>
                    <TextBlock x:Name="NormalCount" Text="0" Foreground="#28A745" Margin="5,0,20,0"/>
                    <TextBlock Text="Unbekannt: " FontWeight="Bold" Foreground="#6C757D"/>
                    <TextBlock x:Name="UnknownCount" Text="0" Foreground="#6C757D"/>
                </StackPanel>
            </StackPanel>
        </Border>

        <!-- Data Grid -->
        <DataGrid Grid.Row="2" x:Name="ServiceGrid" AutoGenerateColumns="False" CanUserAddRows="False" IsReadOnly="True"
                  SelectionMode="Single" Background="White" GridLinesVisibility="Horizontal" BorderThickness="0" Margin="0"
                  EnableRowVirtualization="True">
            <DataGrid.Columns>
                <DataGridTextColumn Header="Service Name" Binding="{Binding Name}" Width="200"/>
                <DataGridTextColumn Header="Anzeigename" Binding="{Binding DisplayName}" Width="250"/>
                <DataGridTextColumn Header="Status" Binding="{Binding State}" Width="80"/>
                <DataGridTextColumn Header="Starttyp" Binding="{Binding StartMode}" Width="100"/>
                <DataGridTextColumn Header="Konto" Binding="{Binding ServiceAccount}" Width="250"/>
                <DataGridTextColumn Header="Risiko" Binding="{Binding RiskLevel}" Width="100"/>
            </DataGrid.Columns>
            <DataGrid.RowStyle>
                <Style TargetType="DataGridRow">
                    <Setter Property="Background" Value="White"/>
                    <Style.Triggers>
                        <DataTrigger Binding="{Binding RiskLevel}" Value="Critical">
                            <Setter Property="Background" Value="#FFE6E6"/>
                            <Setter Property="FontWeight" Value="Bold"/>
                        </DataTrigger>
                        <DataTrigger Binding="{Binding RiskLevel}" Value="Warning">
                            <Setter Property="Background" Value="#FFF3CD"/>
                        </DataTrigger>
                    </Style.Triggers>
                </Style>
            </DataGrid.RowStyle>
        </DataGrid>

        <!-- Footer -->
        <Border Grid.Row="3" Background="White" Padding="20" BorderThickness="0,1,0,0" BorderBrush="#DDD">
            <DockPanel LastChildFill="False">
                <Button x:Name="RefreshBtn" DockPanel.Dock="Left" Content="🔄 Aktualisieren" Padding="15,10" Margin="0,0,10,0"
                        Background="#007bff" Foreground="White" FontWeight="Bold" Cursor="Hand"
                        ToolTip="Services neu laden"/>
                <Button x:Name="ExportBtn" DockPanel.Dock="Left" Content="💾 Exportieren als HTML" Padding="15,10" Margin="0,0,10,0"
                        Background="#28A745" Foreground="White" FontWeight="Bold" Cursor="Hand"
                        ToolTip="Report als HTML exportieren"/>
                <Button x:Name="CopyBtn" DockPanel.Dock="Left" Content="📋 In Zwischenablage kopieren" Padding="15,10" Margin="0,0,10,0"
                        Background="#17A2B8" Foreground="White" FontWeight="Bold" Cursor="Hand"
                        ToolTip="Ausgewählte Zeile kopieren"/>
                <Button x:Name="CloseBtn" DockPanel.Dock="Right" Content="❌ Beenden" Padding="15,10"
                        Background="#6C757D" Foreground="White" FontWeight="Bold" Cursor="Hand"/>
            </DockPanel>
        </Border>
    </Grid>
</Window>
"@

# Create Window
$reader = [System.Xml.XmlNodeReader]::new([xml]$xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Get Controls
$ServiceGrid = $window.FindName("ServiceGrid")
$StatusText = $window.FindName("StatusText")
$CriticalCount = $window.FindName("CriticalCount")
$WarningCount = $window.FindName("WarningCount")
$NormalCount = $window.FindName("NormalCount")
$UnknownCount = $window.FindName("UnknownCount")
$RefreshBtn = $window.FindName("RefreshBtn")
$ExportBtn = $window.FindName("ExportBtn")
$CopyBtn = $window.FindName("CopyBtn")
$CloseBtn = $window.FindName("CloseBtn")

# Function to load services (MUST be here, after GUI is loaded)
function Show-ServiceList {
    try {
        $StatusText.Text = "Status: Lädt Services..."
        $ServiceGrid.ItemsSource = $null
        # UI aktualisieren, bevor die (blockierende) Abfrage startet
        $window.Dispatcher.Invoke([action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

        $services = Get-ServiceAccountInfo
        if ($null -eq $services) {
            $StatusText.Text = "Status: ❌ Fehler beim Laden der Services"
            return
        }

        $sorted = @($services | Sort-Object { Get-RiskSortOrder $_.RiskLevel }, Name)
        $script:CurrentServices = $sorted
        $ServiceGrid.ItemsSource = $sorted

        $stats = Get-RiskStatistic -Services $sorted
        $CriticalCount.Text = [string]$stats['Critical']
        $WarningCount.Text = [string]$stats['Warning']
        $NormalCount.Text = [string]$stats['Normal']
        $UnknownCount.Text = [string]$stats['Unknown']

        $StatusText.Text = "Status: ✓ Services geladen ($($sorted.Count) Services gefunden)"
    }
    catch {
        [System.Windows.MessageBox]::Show("Fehler: $($_.Exception.Message)", "Fehler", "OK", "Error") | Out-Null
        $StatusText.Text = "Status: ❌ Fehler"
    }
}

# Button Events
$RefreshBtn.Add_Click({
    Show-ServiceList
})

$ExportBtn.Add_Click({
    if (@($script:CurrentServices).Count -eq 0) {
        [System.Windows.MessageBox]::Show("Keine Daten zum Exportieren vorhanden.", "Hinweis", "OK", "Warning") | Out-Null
        return
    }

    $dialog = New-Object Microsoft.Win32.SaveFileDialog
    $dialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*"
    $dialog.FileName = "ServiceReport_$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    $dialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')

    if ($dialog.ShowDialog($window) -eq $true) {
        Export-HTMLReport -Services $script:CurrentServices -Path $dialog.FileName
    }
})

$CopyBtn.Add_Click({
    if ($ServiceGrid.SelectedItem) {
        $item = $ServiceGrid.SelectedItem
        $text = "$($item.Name) | $($item.DisplayName) | $($item.State) | $($item.StartMode) | $($item.ServiceAccount) | $($item.RiskLevel)"
        [System.Windows.Clipboard]::SetText($text)
        [System.Windows.MessageBox]::Show("✓ In Zwischenablage kopiert!", "Erfolg", "OK", "Information") | Out-Null
    } else {
        [System.Windows.MessageBox]::Show("Bitte wählen Sie eine Zeile aus!", "Hinweis", "OK", "Warning") | Out-Null
    }
})

$CloseBtn.Add_Click({
    $window.Close()
})

# Load services after the window has been rendered
$window.Add_ContentRendered({
    Show-ServiceList
})

# Show window
$window.ShowDialog() | Out-Null
