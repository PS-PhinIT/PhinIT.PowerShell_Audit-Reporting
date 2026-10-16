<#
.SYNOPSIS
    Application_Audit - Software- und Client-Audit: Programm- und Nutzungsanalyse mit WPF GUI
    
.DESCRIPTION
    Erfasst installierte Programme, laufende Prozesse, Nutzungshäufigkeit und Programmverknüpfungen.
    Einheitliche PhinIT-Oberfläche (Vorlage ActiveDirectory_Audit): dunkle Kopf-/Fußzeile, Sidebar mit
    Audit-Optionen (links), Ergebnis-Karte (rechts).
    
.NOTES
    Version: 0.0.4
    Author: PhinIT (www.phinit.de)
    Date: 14.10.2026
    Versionshistorie: siehe CHANGELOG.md im Modulordner
#>

# Name, Version und Stand zentral – werden in Fenstertitel, Kopf-/Fußzeile, Info-Dialog und HTML-Report verwendet
$script:AppName    = 'Application_Audit'
$script:AppVersion = '0.0.4'
$script:AppDate    = '14.10.2026'

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

#region XAML Definition

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$($script:AppName) v$($script:AppVersion)"
        Width="1400"
        Height="850"
        MinWidth="1000"
        MinHeight="600"
        Background="#F8FAFC"
        FontFamily="Segoe UI"
        ResizeMode="CanResizeWithGrip"
        WindowStartupLocation="CenterScreen">
    <!--  Einheitliche PhinIT-Oberfläche (Vorlage: ActiveDirectory_Audit)  -->
    <Window.Resources>
        <!--  Modern Card Style  -->
        <Style x:Key="ModernCard" TargetType="Border">
            <Setter Property="Background" Value="White" />
            <Setter Property="CornerRadius" Value="6" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="BorderBrush" Value="#E5E7EB" />
        </Style>

        <!--  Modern Button Style  -->
        <Style x:Key="ModernButton" TargetType="Button">
            <Setter Property="Background" Value="White" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="BorderBrush" Value="#D1D5DB" />
            <Setter Property="Padding" Value="16,10" />
            <Setter Property="FontWeight" Value="Medium" />
            <Setter Property="FontSize" Value="13" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="border"
                            Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="4">
                            <ContentPresenter
                                Margin="{TemplateBinding Padding}"
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#F3F4F6" />
                                <Setter TargetName="border" Property="BorderBrush" Value="#6366F1" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#E5E7EB" />
                                <Setter TargetName="border" Property="BorderBrush" Value="#4F46E5" />
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!--  Primary Button Style  -->
        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="#6366F1" />
            <Setter Property="Foreground" Value="White" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Padding" Value="24,14" />
            <Setter Property="FontWeight" Value="SemiBold" />
            <Setter Property="FontSize" Value="14" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="border"
                            Background="{TemplateBinding Background}"
                            CornerRadius="4">
                            <ContentPresenter
                                Margin="{TemplateBinding Padding}"
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#5B5BD6" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#4F46E5" />
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!--  Category Header Style  -->
        <Style x:Key="CategoryHeader" TargetType="TextBlock">
            <Setter Property="FontSize" Value="14" />
            <Setter Property="FontWeight" Value="SemiBold" />
            <Setter Property="Foreground" Value="#1F2937" />
            <Setter Property="Margin" Value="0,8,0,4" />
        </Style>

        <!--  Expandable Section Style  -->
        <Style x:Key="ExpanderStyle" TargetType="Expander">
            <Setter Property="IsExpanded" Value="True" />
            <Setter Property="Margin" Value="0,2,0,6" />
            <Setter Property="Background" Value="#FFFFFF" />
            <Setter Property="BorderBrush" Value="#E5E7EB" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="FontSize" Value="13" />
            <Setter Property="FontWeight" Value="Medium" />
            <Setter Property="Foreground" Value="#374151" />
        </Style>

        <!--  Sidebar CheckBox Style  -->
        <Style x:Key="SidebarCheckBox" TargetType="CheckBox">
            <Setter Property="Margin" Value="12,5" />
            <Setter Property="FontSize" Value="13" />
            <Setter Property="FontWeight" Value="Normal" />
            <Setter Property="Foreground" Value="#374151" />
            <Setter Property="Cursor" Value="Hand" />
        </Style>

        <!--  Sidebar Info Text Style  -->
        <Style x:Key="SidebarInfoText" TargetType="TextBlock">
            <Setter Property="Margin" Value="12,4" />
            <Setter Property="FontSize" Value="12" />
            <Setter Property="FontWeight" Value="Normal" />
            <Setter Property="Foreground" Value="#6B7280" />
            <Setter Property="TextTrimming" Value="CharacterEllipsis" />
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="50" />
            <!--  Header  -->
            <RowDefinition Height="*" />
            <!--  Content Area  -->
            <RowDefinition Height="25" />
            <!--  Footer  -->
        </Grid.RowDefinitions>

        <!--  Header (Grid.Row="0")  -->
        <Border
            Grid.Row="0"
            Background="#374151"
            BorderBrush="#E5E7EB"
            BorderThickness="0,0,0,1">
            <Grid Margin="20,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>

                <!--  App Title  -->
                <TextBlock
                    Grid.Column="0"
                    Margin="0,0,16,0"
                    VerticalAlignment="Center"
                    FontSize="20"
                    FontWeight="SemiBold"
                    Foreground="#F9FAFB"
                    Text="$($script:AppName) v$($script:AppVersion)"
                    TextTrimming="CharacterEllipsis" />

                <!--  Counter + Help/About  -->
                <StackPanel
                    Grid.Column="1"
                    VerticalAlignment="Center"
                    Orientation="Horizontal">
                    <StackPanel Orientation="Vertical" Background="#FF4C5B73" Height="49" Width="90" Margin="0,0,1,0">
                        <TextBlock Text="Categories" FontSize="12" Foreground="#FFC1FFDB" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock x:Name="txtCategoryCount" Text="0" FontSize="18" FontWeight="Bold" Foreground="#FFEAEAEA" HorizontalAlignment="Center" TextAlignment="Center"/>
                    </StackPanel>
                    <StackPanel Orientation="Vertical" Background="#FF4C5B73" Height="49" Width="90">
                        <TextBlock Text="Total Results" FontSize="12" Foreground="#FFC1FFDB" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock x:Name="txtTotalCount" Text="0" FontSize="18" FontWeight="Bold" Foreground="#FFEAEAEA" HorizontalAlignment="Center" TextAlignment="Center"/>
                    </StackPanel>
                    <Button x:Name="btnHelp" Content="Help" Width="70" Height="30" Margin="16,0,0,0" Background="#4B5563" Foreground="#F9FAFB" BorderBrush="#6B7280" Cursor="Hand" ToolTip="Hilfe und Kurzanleitung anzeigen"/>
                    <Button x:Name="btnAbout" Content="About" Width="70" Height="30" Margin="6,0,0,0" Background="#4B5563" Foreground="#F9FAFB" BorderBrush="#6B7280" Cursor="Hand" ToolTip="Versions- und Programminformationen"/>
                </StackPanel>
            </Grid>
        </Border>

        <!--  Content Area (Grid.Row="1")  -->
        <Grid Grid.Row="1" Margin="24,20,24,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="320" />
                <!--  Sidebar  -->
                <ColumnDefinition Width="24" />
                <!--  Spacing  -->
                <ColumnDefinition Width="*" />
                <!--  Main Content  -->
            </Grid.ColumnDefinitions>

            <!--  Sidebar mit Audit-Optionen  -->
            <ScrollViewer
                Grid.Column="0"
                Margin="0,0,0,10"
                HorizontalScrollBarVisibility="Disabled"
                VerticalScrollBarVisibility="Auto">
                <Border
                    Padding="16,16"
                    Background="#F8FAFC"
                    BorderBrush="#E5E7EB"
                    BorderThickness="1"
                    CornerRadius="6">
                    <StackPanel>
                        <TextBlock
                            Margin="0,0,0,16"
                            FontSize="16"
                            FontWeight="Bold"
                            Foreground="#374151"
                            Text="📊 Client Audit" />

                        <!--  System Information  -->
                        <Expander Header="🖥️ System" Style="{StaticResource ExpanderStyle}">
                            <StackPanel Margin="0,4">
                                <TextBlock x:Name="txtComputerName" Style="{StaticResource SidebarInfoText}" />
                                <TextBlock x:Name="txtUserName" Style="{StaticResource SidebarInfoText}" />
                                <TextBlock x:Name="txtOS" Style="{StaticResource SidebarInfoText}" />
                            </StackPanel>
                        </Expander>

                        <!--  Audit Options  -->
                        <Expander Header="📦 Audit-Kategorien" Style="{StaticResource ExpanderStyle}">
                            <StackPanel Margin="0,4">
                                <CheckBox x:Name="chkInstalledPrograms" Content="Installierte Programme" IsChecked="True" Style="{StaticResource SidebarCheckBox}" />
                                <CheckBox x:Name="chkStoreApps" Content="Windows Store Apps" IsChecked="True" Style="{StaticResource SidebarCheckBox}" />
                                <CheckBox x:Name="chkRunningProcesses" Content="Laufende Prozesse" IsChecked="True" Style="{StaticResource SidebarCheckBox}" />
                                <CheckBox x:Name="chkPrefetch" Content="Prefetch-Analyse (Admin)" IsChecked="False" Style="{StaticResource SidebarCheckBox}" />
                                <CheckBox x:Name="chkProgramInventory" Content="Programm-Inventar" IsChecked="False" Style="{StaticResource SidebarCheckBox}" />
                                <CheckBox x:Name="chkEventLogs" Content="Event-Logs" IsChecked="False" Style="{StaticResource SidebarCheckBox}" />
                                <CheckBox x:Name="chkShortcuts" Content="Desktop-Verknüpfungen" IsChecked="True" Style="{StaticResource SidebarCheckBox}" />
                            </StackPanel>
                        </Expander>

                        <!--  Filter Options  -->
                        <Expander Header="🔍 Filter" Style="{StaticResource ExpanderStyle}">
                            <StackPanel Margin="0,4">
                                <CheckBox x:Name="chkExcludeWindows" Content="Windows-/Microsoft-Programme ausschließen" IsChecked="False" Style="{StaticResource SidebarCheckBox}" />
                            </StackPanel>
                        </Expander>

                        <Button
                            x:Name="btnStartAudit"
                            Margin="0,12,0,0"
                            HorizontalAlignment="Stretch"
                            Content="▶ Audit starten"
                            Style="{StaticResource PrimaryButton}" />
                    </StackPanel>
                </Border>
            </ScrollViewer>

            <!--  Results Section  -->
            <Border
                Grid.Column="2"
                Margin="0,0,0,10"
                Padding="20,16"
                Style="{StaticResource ModernCard}">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                        <RowDefinition Height="Auto" />
                    </Grid.RowDefinitions>

                    <!--  Results Header  -->
                    <Grid Grid.Row="0" Margin="0,0,0,16">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>
                        <TextBlock
                            Grid.Column="0"
                            Style="{StaticResource CategoryHeader}"
                            Text="Audit Results" />
                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                            <TextBlock Margin="0,0,8,0" VerticalAlignment="Center" Foreground="#374151" Text="Ansicht:" />
                            <ComboBox x:Name="cmbDataView" Width="240" Margin="0,0,8,0" VerticalAlignment="Center" IsEnabled="False" ToolTip="Kategorie für die Tabellenansicht wählen" />
                            <Button
                                x:Name="btnExport"
                                Margin="0,0,8,0"
                                Padding="8,4"
                                Content="Export"
                                IsEnabled="False"
                                Style="{StaticResource ModernButton}"
                                ToolTip="Ergebnisse als CSV oder HTML exportieren" />
                            <Button
                                x:Name="btnClear"
                                Padding="8,4"
                                Content="Clear Results"
                                IsEnabled="False"
                                Style="{StaticResource ModernButton}"
                                ToolTip="Ergebnisse löschen" />
                        </StackPanel>
                    </Grid>

                    <DataGrid
                        x:Name="dataGrid"
                        Grid.Row="1"
                        AlternatingRowBackground="#F8FAFC"
                        AutoGenerateColumns="True"
                        Background="White"
                        BorderBrush="#E5E7EB"
                        BorderThickness="1"
                        CanUserReorderColumns="True"
                        CanUserResizeColumns="True"
                        CanUserSortColumns="True"
                        GridLinesVisibility="Horizontal"
                        HeadersVisibility="Column"
                        IsReadOnly="True"
                        RowBackground="White">
                        <DataGrid.ColumnHeaderStyle>
                            <Style TargetType="DataGridColumnHeader">
                                <Setter Property="Background" Value="#F3F4F6" />
                                <Setter Property="Foreground" Value="#374151" />
                                <Setter Property="FontWeight" Value="SemiBold" />
                                <Setter Property="BorderBrush" Value="#E5E7EB" />
                                <Setter Property="BorderThickness" Value="0,0,1,1" />
                                <Setter Property="Padding" Value="12,8" />
                            </Style>
                        </DataGrid.ColumnHeaderStyle>
                        <DataGrid.CellStyle>
                            <Style TargetType="DataGridCell">
                                <Setter Property="Padding" Value="12,6" />
                                <Setter Property="BorderThickness" Value="0" />
                                <Style.Triggers>
                                    <Trigger Property="IsSelected" Value="True">
                                        <Setter Property="Background" Value="#EEF2FF" />
                                        <Setter Property="Foreground" Value="#6366F1" />
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </DataGrid.CellStyle>
                    </DataGrid>

                    <!--  Summary  -->
                    <TextBlock
                        x:Name="txtSummary"
                        Grid.Row="2"
                        Margin="0,8,0,0"
                        FontSize="12"
                        Foreground="#6B7280"
                        Text="Keine Daten geladen" />
                </Grid>
            </Border>
        </Grid>

        <!--  Footer (Grid.Row="2")  -->
        <Border
            Grid.Row="2"
            Background="#374151"
            BorderBrush="#E5E7EB"
            BorderThickness="0,1,0,0">
            <Grid Margin="20,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                    <ColumnDefinition Width="*" />
                </Grid.ColumnDefinitions>

                <TextBlock
                    Grid.Column="0"
                    VerticalAlignment="Center"
                    FontSize="11"
                    Foreground="#E5E7EB"
                    Text="$($script:AppName)  |  Version: v$($script:AppVersion)  |  Last Update: $($script:AppDate)"
                    TextTrimming="CharacterEllipsis" />

                <StackPanel
                    Grid.Column="1"
                    HorizontalAlignment="Center"
                    VerticalAlignment="Center"
                    Orientation="Horizontal">
                    <Ellipse x:Name="StatusIndicator" Width="16" Height="16" Fill="#10B981" Margin="0,0,8,0"/>
                    <TextBlock x:Name="txtStatus" Text="Bereit" FontWeight="Medium" Foreground="#FFFFBBBB" Margin="0,0,16,0" FontSize="16" Height="22" MaxWidth="900" TextTrimming="CharacterEllipsis"/>
                    <ProgressBar
                        x:Name="progressBar"
                        Width="140"
                        Height="8"
                        VerticalAlignment="Center"
                        Background="#4B5563"
                        BorderThickness="0"
                        Foreground="#6366F1"
                        Visibility="Collapsed" />
                </StackPanel>

                <StackPanel
                    Grid.Column="2"
                    HorizontalAlignment="Right"
                    VerticalAlignment="Center"
                    Orientation="Horizontal">
                    <TextBlock FontSize="11" Foreground="#E5E7EB" Text="© PhinIT  |  " />
                    <TextBlock
                        x:Name="linkWebsite"
                        Cursor="Hand"
                        FontSize="11"
                        Foreground="#93C5FD"
                        Text="www.phinit.de"
                        ToolTip="https://www.phinit.de öffnen" />
                </StackPanel>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

#endregion

#region Functions

function Update-Status {
    param(
        [string]$Message,
        # Farbe der Statusanzeige in der Fußzeile: Bereit (grün), Läuft (gelb), Fehler (rot)
        [ValidateSet('Ready', 'Busy', 'Error')]
        [string]$State = 'Ready'
    )
    # Nur vom UI-Thread aufrufen (die Datensammlung läuft im Hintergrund-Runspace)
    # Die Fußzeile ist einzeilig: mehrzeilige Meldungen zusammenfassen, vollständiger Text als ToolTip
    $lines = @(($Message -split "`r?`n") | Where-Object { $_ })
    $txtStatus.Text = $lines -join '  |  '
    $txtStatus.ToolTip = $lines -join [Environment]::NewLine
    if ($StatusIndicator) {
        $color = switch ($State) { 'Busy' { '#F59E0B' } 'Error' { '#EF4444' } default { '#10B981' } }
        $StatusIndicator.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($color)
    }
}

function Get-InstalledProgramsFromRegistry {
    $regPaths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($path in $regPaths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
    }
}

function Test-IsWindowsProgram {
    param(
        [string]$Name,
        [string]$Publisher,
        [string]$InstallLocation
    )
    return ($Publisher -match 'Microsoft|Windows' -or
            $Name -match 'Microsoft|Windows|Update|KB[0-9]' -or
            $InstallLocation -match 'System32')
}

# Datensammlung - läuft im Hintergrund-Runspace, daher KEINE Zugriffe auf UI-Elemente!
# Benötigt: Get-InstalledProgramsFromRegistry, Test-IsWindowsProgram (siehe Start-AuditJob)
function Invoke-ClientAudit {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Options,
        # Synchronisierte Hashtable (Message/Percent), wird vom DispatcherTimer im UI-Thread gelesen
        [hashtable]$Progress
    )

    $allSteps = @(
        [PSCustomObject]@{ Key = 'InstalledPrograms'; Category = 'Installierte Programme'; Message = 'Erfasse installierte Programme...' }
        [PSCustomObject]@{ Key = 'StoreApps';         Category = 'Windows Store Apps';     Message = 'Erfasse Windows Store Apps...' }
        [PSCustomObject]@{ Key = 'RunningProcesses';  Category = 'Laufende Prozesse';      Message = 'Erfasse laufende Prozesse...' }
        [PSCustomObject]@{ Key = 'Prefetch';          Category = 'Prefetch-Analyse';       Message = 'Erfasse Prefetch-Daten...' }
        [PSCustomObject]@{ Key = 'ProgramInventory';  Category = 'Programm-Inventar';      Message = 'Erstelle Programm-Inventar...' }
        [PSCustomObject]@{ Key = 'EventLogs';         Category = 'Event-Logs';             Message = 'Erfasse Event-Logs...' }
        [PSCustomObject]@{ Key = 'Shortcuts';         Category = 'Programmverknüpfungen';  Message = 'Erfasse Desktop-Verknüpfungen...' }
    )
    $steps = @($allSteps | Where-Object { $Options[$_.Key] })
    $excludeWindows = [bool]$Options['ExcludeWindows']
    $results = [System.Collections.Generic.List[object]]::new()
    $notes = [System.Collections.Generic.List[string]]::new()
    # Registry wird pro Audit nur einmal gelesen (Installierte Programme + Programm-Inventar)
    $registryPrograms = $null

    for ($i = 0; $i -lt $steps.Count; $i++) {
        $step = $steps[$i]
        if ($Progress) {
            $Progress['Message'] = "$($step.Message) ($($i + 1)/$($steps.Count))"
            $Progress['Percent'] = [int](100 * $i / $steps.Count)
        }

        $data = @()
        try {
            switch ($step.Key) {
                'InstalledPrograms' {
                    if ($null -eq $registryPrograms) { $registryPrograms = @(Get-InstalledProgramsFromRegistry) }
                    $data = @($registryPrograms |
                        Select-Object @{N='ProgramName';E={$_.DisplayName}},
                                     @{N='Version';E={$_.DisplayVersion}},
                                     @{N='Publisher';E={$_.Publisher}},
                                     @{N='InstallDate';E={$_.InstallDate}},
                                     @{N='InstallLocation';E={$_.InstallLocation}})
                    if ($excludeWindows) {
                        $data = @($data | Where-Object {
                            -not (Test-IsWindowsProgram -Name $_.ProgramName -Publisher $_.Publisher -InstallLocation $_.InstallLocation)
                        })
                    }
                }
                'StoreApps' {
                    $data = @(Get-AppxPackage -ErrorAction SilentlyContinue | Select-Object Name, Version, Publisher, InstallLocation)
                    if ($excludeWindows) {
                        $data = @($data | Where-Object {
                            -not (Test-IsWindowsProgram -Name $_.Name -Publisher $_.Publisher -InstallLocation $_.InstallLocation)
                        })
                    }
                }
                'RunningProcesses' {
                    $data = @(Get-Process | Where-Object { $_.MainWindowTitle } |
                        Select-Object ProcessName, Id, @{N='MainWindowTitle';E={$_.MainWindowTitle}},
                                     @{N='Memory_MB';E={[math]::Round($_.WorkingSet64 / 1MB, 2)}})
                }
                'Prefetch' {
                    $prefetchPath = if ($env:SystemRoot) { Join-Path $env:SystemRoot 'Prefetch' } else { $null }
                    if (-not $Options['IsAdmin']) {
                        $notes.Add('Hinweis: Prefetch-Analyse erfordert Administrator-Rechte - wurde übersprungen')
                    } elseif (-not $prefetchPath -or -not (Test-Path -LiteralPath $prefetchPath)) {
                        $notes.Add("Hinweis: Prefetch-Ordner nicht gefunden ($prefetchPath)")
                    } else {
                        $data = @(Get-ChildItem -LiteralPath $prefetchPath -Filter '*.pf' -File -ErrorAction SilentlyContinue |
                            Select-Object @{N='ProgramName';E={$_.Name -replace '\.pf$',''}},
                                         @{N='LastAccess';E={$_.LastAccessTime}},
                                         @{N='Created';E={$_.CreationTime}},
                                         @{N='Size_KB';E={[math]::Round($_.Length / 1KB, 2)}})
                    }
                }
                'ProgramInventory' {
                    if ($null -eq $registryPrograms) { $registryPrograms = @(Get-InstalledProgramsFromRegistry) }
                    $data = @($registryPrograms |
                        Select-Object @{N='ProgramName';E={$_.DisplayName}},
                                     @{N='Publisher';E={$_.Publisher}},
                                     @{N='InstallLocation';E={$_.InstallLocation}} |
                        Sort-Object ProgramName -Unique)
                    if ($excludeWindows) {
                        $data = @($data | Where-Object {
                            -not (Test-IsWindowsProgram -Name $_.ProgramName -Publisher $_.Publisher -InstallLocation $_.InstallLocation)
                        })
                    }
                }
                'EventLogs' {
                    $data = @(Get-WinEvent -FilterHashtable @{LogName='Application'; ID=1000,1001,1002} -MaxEvents 100 -ErrorAction SilentlyContinue |
                        Select-Object TimeCreated,
                                     @{N='EventID';E={$_.Id}},
                                     @{N='Level';E={$_.LevelDisplayName}},
                                     @{N='Source';E={$_.ProviderName}},
                                     @{N='Message';E={if ($_.Message) { $_.Message.Substring(0, [Math]::Min(100, $_.Message.Length)) } else { "" }}})
                }
                'Shortcuts' {
                    # Tatsächliche Desktop-Pfade (berücksichtigt Ordnerumleitung / OneDrive)
                    $publicDesktop = [Environment]::GetFolderPath('CommonDesktopDirectory')
                    if (-not $publicDesktop -and $env:Public) { $publicDesktop = Join-Path $env:Public 'Desktop' }
                    $userDesktop = [Environment]::GetFolderPath('Desktop')
                    if (-not $userDesktop -and $env:USERPROFILE) { $userDesktop = Join-Path $env:USERPROFILE 'Desktop' }
                    $locations = @(
                        [PSCustomObject]@{ Path = $publicDesktop; Label = 'Public Desktop' }
                        [PSCustomObject]@{ Path = $userDesktop;   Label = 'User Desktop' }
                    )

                    $shortcuts = [System.Collections.Generic.List[object]]::new()
                    foreach ($loc in $locations) {
                        if ($loc.Path -and (Test-Path -LiteralPath $loc.Path)) {
                            $label = $loc.Label
                            $lnks = @(Get-ChildItem -LiteralPath $loc.Path -Filter '*.lnk' -File -ErrorAction SilentlyContinue |
                                Select-Object -First 300 |
                                Select-Object @{N='ShortcutName';E={$_.Name}},
                                             @{N='ShortcutPath';E={$_.FullName}},
                                             @{N='Location';E={$label}},
                                             @{N='LastModified';E={$_.LastWriteTime}})
                            foreach ($lnk in $lnks) { $shortcuts.Add($lnk) }
                        }
                    }
                    $data = $shortcuts.ToArray()
                }
            }
        } catch {
            $notes.Add("Fehler bei '$($step.Category)': $($_.Exception.Message)")
            $data = @()
        }

        if ($data.Count -gt 0) {
            $results.Add([PSCustomObject]@{ Name = $step.Category; Data = $data })
        }
    }

    if ($Progress) {
        $Progress['Message'] = 'Bereite Ergebnisse auf...'
        $Progress['Percent'] = 100
    }
    [PSCustomObject]@{ Results = $results.ToArray(); Notes = $notes.ToArray() }
}

# Startet Invoke-ClientAudit in einem eigenen Runspace (die GUI bleibt bedienbar)
function Start-AuditJob {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Options,
        # Funktionen, deren Definitionen in den Runspace übernommen werden (keine UI-Funktionen!)
        [string[]]$FunctionNames = @('Get-InstalledProgramsFromRegistry', 'Test-IsWindowsProgram', 'Invoke-ClientAudit')
    )

    $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    foreach ($name in $FunctionNames) {
        $definition = (Get-Command -Name $name -CommandType Function -ErrorAction Stop).Definition
        $iss.Commands.Add([System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new($name, $definition))
    }

    $progress = [hashtable]::Synchronized(@{ Message = 'Starte Audit...'; Percent = 0 })
    $runspace = $null
    $ps = $null
    try {
        $runspace = [runspacefactory]::CreateRunspace($iss)
        $runspace.ThreadOptions = [System.Management.Automation.Runspaces.PSThreadOptions]::ReuseThread
        $runspace.Open()
        $ps = [powershell]::Create()
        $ps.Runspace = $runspace
        [void]$ps.AddCommand('Invoke-ClientAudit').AddParameter('Options', $Options).AddParameter('Progress', $progress)
        $handle = $ps.BeginInvoke()
    } catch {
        if ($ps) { $ps.Dispose() }
        if ($runspace) { $runspace.Dispose() }
        throw
    }

    [PSCustomObject]@{
        PowerShell = $ps
        Runspace   = $runspace
        Handle     = $handle
        Progress   = $progress
    }
}

# Bricht einen laufenden Audit-Job ab (falls nötig) und gibt PowerShell/Runspace frei
function Stop-AuditJob {
    param($Job)
    if (-not $Job) { return }
    try {
        if ($Job.PowerShell -and $Job.PowerShell.InvocationStateInfo.State -eq 'Running') { $Job.PowerShell.Stop() }
    } catch { Write-Verbose "Audit-Job konnte nicht gestoppt werden: $($_.Exception.Message)" }
    try { if ($Job.PowerShell) { $Job.PowerShell.Dispose() } } catch { Write-Verbose "PowerShell-Dispose fehlgeschlagen: $($_.Exception.Message)" }
    try { if ($Job.Runspace) { $Job.Runspace.Dispose() } } catch { Write-Verbose "Runspace-Dispose fehlgeschlagen: $($_.Exception.Message)" }
}

# Holt das Ergebnis eines abgeschlossenen Audit-Jobs ab (Ergebnisse, Hinweise, Fehler) und räumt auf
function Receive-AuditJob {
    param([Parameter(Mandatory=$true)]$Job)

    $output = $null
    $errors = [System.Collections.Generic.List[string]]::new()
    try {
        $output = $Job.PowerShell.EndInvoke($Job.Handle)
    } catch {
        $errors.Add($_.Exception.GetBaseException().Message)
    } finally {
        foreach ($err in @($Job.PowerShell.Streams.Error)) {
            if ($err) { $errors.Add($err.ToString()) }
        }
        Stop-AuditJob -Job $Job
    }

    $auditResult = @($output | Where-Object { $_ -and $_.PSObject.Properties['Results'] }) | Select-Object -Last 1
    [PSCustomObject]@{
        Results = if ($auditResult) { @($auditResult.Results) } else { @() }
        Notes   = if ($auditResult) { @($auditResult.Notes) } else { @() }
        Errors  = $errors.ToArray()
    }
}

# Schutz vor CSV-/Formel-Injection: Zeichenketten, die in Excel als Formel interpretiert würden, mit ' maskieren
# (Telefonnummern/negative Zahlen wie "+49 711 123" bzw. "-5" bleiben unverändert)
function ConvertTo-CsvSafeObject {
    param([Parameter(ValueFromPipeline = $true)][object]$InputObject)
    process {
        if ($null -eq $InputObject) { return }
        $safeRow = [ordered]@{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $val = $prop.Value
            if ($val -is [string] -and ($val -match '^[=@\t\r]' -or ($val -match '^[+-]' -and $val -notmatch '^[+-][\d\s()./-]*$'))) {
                $val = "'" + $val
            }
            $safeRow[$prop.Name] = $val
        }
        [PSCustomObject]$safeRow
    }
}

function Export-ToCSV {
    param(
        [Parameter(Mandatory=$true)]
        [System.Collections.IDictionary]$DataSets,
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
        }
        
        foreach ($key in $DataSets.Keys) {
            $fileName = $key -replace '[^\w]', '_'
            $filePath = Join-Path $Path "$fileName.csv"
            if ($DataSets[$key] -and $DataSets[$key].Count -gt 0) {
                $DataSets[$key] | ConvertTo-CsvSafeObject | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8
            }
        }
        return $true
    }
    catch {
        Write-Warning "CSV-Export fehlgeschlagen: $($_.Exception.Message)"
        return $false
    }
}

function Export-ToHTML {
    param(
        [Parameter(Mandatory=$true)]
        [System.Collections.IDictionary]$DataSets,
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    try {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $filePath = Join-Path $Path "ClientAudit_Report_$timestamp.html"
        $encComputer = [System.Net.WebUtility]::HtmlEncode($env:COMPUTERNAME)
        $encUser = [System.Net.WebUtility]::HtmlEncode($env:USERNAME)
        
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Client Audit Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f6fa; }
        h1 { color: #0078D4; }
        h2 { color: #106EBE; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 30px; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th { background-color: #0078D4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #e1e1e1; }
        tr:hover { background-color: #f9f9f9; }
        .summary { background: white; padding: 15px; margin-bottom: 20px; border-left: 4px solid #0078D4; }
    </style>
</head>
<body>
    <h1>🔍 Client Audit Report</h1>
    <div class="summary">
        <p><strong>Computername:</strong> $encComputer</p>
        <p><strong>Benutzer:</strong> $encUser</p>
        <p><strong>Datum:</strong> $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')</p>
    </div>
"@
        
        foreach ($key in $DataSets.Keys) {
            if (-not $DataSets[$key]) { continue }
            # ConvertTo-Html kodiert die Zellwerte selbst; Überschrift separat kodieren
            $html += "<h2>$([System.Net.WebUtility]::HtmlEncode($key))</h2>"
            $html += ($DataSets[$key] | ConvertTo-Html -Fragment) -join "`n"
        }
        
        $html += @"
    <p style="color:#6B7280;font-size:12px;margin-top:30px;">Erstellt mit $($script:AppName) v$($script:AppVersion) &middot; &copy; PhinIT &middot; www.phinit.de</p>
</body>
</html>
"@
        
        $html | Out-File -FilePath $filePath -Encoding UTF8
        return $filePath
    }
    catch {
        Write-Warning "HTML-Export fehlgeschlagen: $($_.Exception.Message)"
        return $null
    }
}

#endregion

#region GUI

# Parse XAML
$reader = [System.Xml.XmlNodeReader]::new([xml]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get Controls
$txtComputerName = $window.FindName('txtComputerName')
$txtUserName = $window.FindName('txtUserName')
$txtOS = $window.FindName('txtOS')
$chkInstalledPrograms = $window.FindName('chkInstalledPrograms')
$chkStoreApps = $window.FindName('chkStoreApps')
$chkRunningProcesses = $window.FindName('chkRunningProcesses')
$chkPrefetch = $window.FindName('chkPrefetch')
$chkProgramInventory = $window.FindName('chkProgramInventory')
$chkEventLogs = $window.FindName('chkEventLogs')
$chkShortcuts = $window.FindName('chkShortcuts')
$chkExcludeWindows = $window.FindName('chkExcludeWindows')
$btnStartAudit = $window.FindName('btnStartAudit')
$btnExport = $window.FindName('btnExport')
$btnClear = $window.FindName('btnClear')
$txtStatus = $window.FindName('txtStatus')
$progressBar = $window.FindName('progressBar')
$cmbDataView = $window.FindName('cmbDataView')
$dataGrid = $window.FindName('dataGrid')
$txtSummary = $window.FindName('txtSummary')
$txtCategoryCount = $window.FindName('txtCategoryCount')
$txtTotalCount = $window.FindName('txtTotalCount')
$StatusIndicator = $window.FindName('StatusIndicator')
$btnHelp = $window.FindName('btnHelp')
$btnAbout = $window.FindName('btnAbout')
$linkWebsite = $window.FindName('linkWebsite')

# Global Data (geordnet: Reihenfolge der Kategorien wie in der GUI, auch im HTML-Report)
$script:auditData = [ordered]@{}
# Tatsächlichen Desktop-Pfad ermitteln (berücksichtigt Ordnerumleitung / OneDrive)
$script:exportPath = [Environment]::GetFolderPath('Desktop')
if (-not $script:exportPath) { $script:exportPath = Join-Path $env:USERPROFILE 'Desktop' }
$script:isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Initialize System Info
$txtComputerName.Text = "Computer: $env:COMPUTERNAME"
$txtUserName.Text = "Benutzer: $env:USERNAME"
try {
    $os = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).Caption
    $txtOS.Text = "OS: $os"
} catch {
    $txtOS.Text = "OS: Windows"
}
$txtOS.ToolTip = $txtOS.Text
if (-not $script:isAdmin) {
    $chkPrefetch.ToolTip = 'Erfordert Administrator-Rechte – ohne Rechte wird die Kategorie übersprungen'
}

# Zähler in der Kopfzeile (Kategorien / Einträge) aktualisieren (nur UI-Thread)
function Update-ResultCounters {
    $total = 0
    foreach ($value in $script:auditData.Values) { $total += @($value).Count }
    $txtCategoryCount.Text = [string]$script:auditData.Count
    $txtTotalCount.Text = [string]$total
}

# UI-Status während des Audits (nur UI-Thread)
function Set-AuditUiBusy {
    param([bool]$Busy)
    foreach ($ctrl in @($btnStartAudit, $chkInstalledPrograms, $chkStoreApps, $chkRunningProcesses, $chkPrefetch,
                        $chkProgramInventory, $chkEventLogs, $chkShortcuts, $chkExcludeWindows)) {
        $ctrl.IsEnabled = -not $Busy
    }
    if ($Busy) {
        $btnExport.IsEnabled = $false
        $btnClear.IsEnabled = $false
        $cmbDataView.IsEnabled = $false
        $progressBar.IsIndeterminate = $false
        $progressBar.Minimum = 0
        $progressBar.Maximum = 100
        $progressBar.Value = 0
        $progressBar.Visibility = 'Visible'
        $window.Cursor = [System.Windows.Input.Cursors]::AppStarting
    } else {
        $hasData = $script:auditData.Count -gt 0
        $btnExport.IsEnabled = $hasData
        $btnClear.IsEnabled = $hasData
        $cmbDataView.IsEnabled = $hasData
        $progressBar.Visibility = 'Collapsed'
        $window.Cursor = $null
    }
}

# Ergebnisse des Hintergrund-Audits in die GUI übernehmen (nur UI-Thread)
function Complete-Audit {
    param([Parameter(Mandatory=$true)]$AuditResult)

    $script:auditData = [ordered]@{}
    $cmbDataView.Items.Clear()
    foreach ($category in @($AuditResult.Results)) {
        if (-not $category -or -not $category.Name) { continue }
        $categoryName = [string]$category.Name
        $script:auditData[$categoryName] = @($category.Data)
        [void]$cmbDataView.Items.Add($categoryName)
    }

    if ($script:auditData.Count -gt 0) {
        $totalItems = ($script:auditData.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
        $message = "✓ Audit abgeschlossen! $($script:auditData.Keys.Count) Kategorien mit $totalItems Einträgen erfasst"
    } else {
        $message = "Audit abgeschlossen - Keine Daten gefunden"
    }
    foreach ($note in @($AuditResult.Notes)) {
        if ($note) { $message += "`n$note" }
    }
    $state = 'Ready'
    $errors = @($AuditResult.Errors | Where-Object { $_ })
    if ($errors.Count -gt 0) {
        foreach ($err in $errors) { Write-Warning "Audit: $err" }
        $message += "`n⚠ $($errors.Count) Fehler bei der Datensammlung: $($errors[0])"
        $state = 'Error'
    }

    Set-AuditUiBusy $false
    Update-ResultCounters
    if ($script:auditData.Count -gt 0) {
        $cmbDataView.SelectedIndex = 0
    }
    Update-Status $message -State $state
}

# Hintergrund-Audit: Fortschritt per DispatcherTimer im UI-Thread abfragen
$script:auditJob = $null
$script:auditTimer = [System.Windows.Threading.DispatcherTimer]::new()
$script:auditTimer.Interval = [TimeSpan]::FromMilliseconds(200)
$script:auditTimer.Add_Tick({
    $job = $script:auditJob
    if (-not $job) {
        $script:auditTimer.Stop()
        return
    }

    $message = $job.Progress['Message']
    $percent = $job.Progress['Percent']
    if ($message) { $txtStatus.Text = $message }
    if ($null -ne $percent) { $progressBar.Value = [double]$percent }
    if (-not $job.Handle.IsCompleted) { return }

    $script:auditTimer.Stop()
    $script:auditJob = $null
    try {
        $auditResult = Receive-AuditJob -Job $job
        Complete-Audit -AuditResult $auditResult
    } catch {
        Set-AuditUiBusy $false
        Update-Status "Fehler beim Audit: $($_.Exception.Message)" -State Error
    }
})

# Start Audit Button
$btnStartAudit.Add_Click({
    if ($script:auditJob) { return }

    # Auswahl im UI-Thread lesen und als Parameter an den Runspace übergeben
    $options = @{
        InstalledPrograms = [bool]$chkInstalledPrograms.IsChecked
        StoreApps         = [bool]$chkStoreApps.IsChecked
        RunningProcesses  = [bool]$chkRunningProcesses.IsChecked
        Prefetch          = [bool]$chkPrefetch.IsChecked
        ProgramInventory  = [bool]$chkProgramInventory.IsChecked
        EventLogs         = [bool]$chkEventLogs.IsChecked
        Shortcuts         = [bool]$chkShortcuts.IsChecked
        ExcludeWindows    = [bool]$chkExcludeWindows.IsChecked
        IsAdmin           = [bool]$script:isAdmin
    }
    $categoryKeys = @('InstalledPrograms', 'StoreApps', 'RunningProcesses', 'Prefetch', 'ProgramInventory', 'EventLogs', 'Shortcuts')
    if (-not ($categoryKeys | Where-Object { $options[$_] })) {
        Update-Status "Bitte mindestens eine Audit-Kategorie auswählen" -State Error
        return
    }

    $script:auditData = [ordered]@{}
    $cmbDataView.Items.Clear()
    $dataGrid.ItemsSource = $null
    $txtSummary.Text = "Keine Daten geladen"
    Update-ResultCounters
    Set-AuditUiBusy $true
    Update-Status "Starte Audit..." -State Busy

    try {
        $script:auditJob = Start-AuditJob -Options $options
        $script:auditTimer.Start()
    } catch {
        $script:auditJob = $null
        Set-AuditUiBusy $false
        Update-Status "Fehler beim Starten des Audits: $($_.Exception.Message)" -State Error
    }
})

# ComboBox Selection Changed
$cmbDataView.Add_SelectionChanged({
    if ($cmbDataView.SelectedItem -and $script:auditData.Contains($cmbDataView.SelectedItem)) {
        $selectedData = $script:auditData[$cmbDataView.SelectedItem]
        $dataGrid.ItemsSource = $selectedData
        $txtSummary.Text = "$($cmbDataView.SelectedItem): $($selectedData.Count) Einträge"
    }
})

# Export mit Dialog
$btnExport.Add_Click({
    if ($script:auditData.Count -eq 0) {
        Update-Status "Keine Daten zum Exportieren vorhanden" -State Error
        return
    }
    
    # Export-Dialog XAML (Farben/Schrift wie Hauptfenster; Button-Styles werden aus dem Hauptfenster übernommen)
    $exportDialogXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Export-Optionen" Width="480" SizeToContent="Height" WindowStartupLocation="CenterOwner" ResizeMode="NoResize"
        Background="#F8FAFC" FontFamily="Segoe UI" ShowInTaskbar="False">
    <Border Margin="16" Padding="20,16" Background="White" BorderBrush="#E5E7EB" BorderThickness="1" CornerRadius="6">
        <StackPanel>
            <TextBlock Text="Export-Format" FontSize="14" FontWeight="SemiBold" Foreground="#1F2937" Margin="0,0,0,8"/>
            <RadioButton x:Name="rbCSV" Content="CSV (eine Datei pro Kategorie)" IsChecked="True" Margin="0,4" Foreground="#374151"/>
            <RadioButton x:Name="rbHTML" Content="HTML-Report" Margin="0,4" Foreground="#374151"/>

            <TextBlock Text="Filter-Optionen" FontSize="14" FontWeight="SemiBold" Foreground="#1F2937" Margin="0,16,0,8"/>
            <CheckBox x:Name="chkExcludeSystem" IsChecked="False" Margin="0,4" Foreground="#374151">
                <TextBlock Text="System-Programme ausschließen (vorinstallierte OS-Programme)" TextWrapping="Wrap"/>
            </CheckBox>

            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,20,0,0">
                <Button x:Name="btnOK" Content="Export" MinWidth="100" Padding="16,8" Margin="0,0,8,0" IsDefault="True"/>
                <Button x:Name="btnCancel" Content="Abbrechen" MinWidth="100" Padding="16,8" IsCancel="True"/>
            </StackPanel>
        </StackPanel>
    </Border>
</Window>
"@
    
    # Export-Dialog erstellen
    $exportDialog = [Windows.Markup.XamlReader]::Parse($exportDialogXaml)
    $exportDialog.Owner = $window
    $rbCSV = $exportDialog.FindName('rbCSV')
    $rbHTML = $exportDialog.FindName('rbHTML')
    $chkExcludeSystem = $exportDialog.FindName('chkExcludeSystem')
    $btnOK = $exportDialog.FindName('btnOK')
    $btnCancel = $exportDialog.FindName('btnCancel')
    $btnOK.Style = $window.FindResource('PrimaryButton')
    $btnCancel.Style = $window.FindResource('ModernButton')
    
    # Setzen von DialogResult schließt den modalen Dialog bereits (zusätzliches Close() entfällt)
    $btnOK.Add_Click({ $exportDialog.DialogResult = $true })
    $btnCancel.Add_Click({ $exportDialog.DialogResult = $false })
    
    $result = $exportDialog.ShowDialog()
    
    if ($result -eq $true) {
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        
        # Daten filtern falls System-Programme ausgeschlossen werden sollen
        $filteredData = [ordered]@{}
        foreach ($key in $script:auditData.Keys) {
            if ($chkExcludeSystem.IsChecked -and ($key -in @('Installierte Programme', 'Windows Store Apps', 'Programm-Inventar'))) {
                # System-Programme filtern (Microsoft, Windows, Update, KB, System32)
                $filteredData[$key] = @($script:auditData[$key] | Where-Object {
                    $itemName = if ($_.PSObject.Properties['ProgramName']) { $_.ProgramName } else { $_.Name }
                    -not (Test-IsWindowsProgram -Name $itemName -Publisher $_.Publisher -InstallLocation $_.InstallLocation)
                })
            } else {
                $filteredData[$key] = $script:auditData[$key]
            }
        }
        
        # Export basierend auf Format
        if ($rbCSV.IsChecked) {
            $csvPath = Join-Path $script:exportPath "ClientAudit_CSV_$timestamp"
            $csvExported = Export-ToCSV -DataSets $filteredData -Path $csvPath
            if ($csvExported) {
                Update-Status "CSV-Export erfolgreich erstellt: $csvPath"
                Start-Process $csvPath
            } else {
                Update-Status "Fehler beim CSV-Export" -State Error
            }
        } else {
            $htmlPath = $script:exportPath
            $htmlExported = Export-ToHTML -DataSets $filteredData -Path $htmlPath
            if ($htmlExported) {
                Update-Status "HTML-Report erstellt: $htmlExported"
                Start-Process $htmlExported
            } else {
                Update-Status "Fehler beim HTML-Export" -State Error
            }
        }
    }
})

# Clear Results
$btnClear.Add_Click({
    if ($script:auditJob) { return }
    $script:auditData = [ordered]@{}
    $cmbDataView.Items.Clear()
    $cmbDataView.IsEnabled = $false
    $dataGrid.ItemsSource = $null
    $txtSummary.Text = "Keine Daten geladen"
    Update-ResultCounters
    Update-Status "Bereit"
    $btnExport.IsEnabled = $false
    $btnClear.IsEnabled = $false
})

# Hilfe
$btnHelp.Add_Click({
    $helpText = @"
$($script:AppName) - Kurzanleitung

1. Links unter 'Audit-Kategorien' die gewünschten Bereiche auswählen.
2. Optional unter 'Filter' Windows-/Microsoft-Programme ausschließen.
3. '▶ Audit starten' klicken - die Datensammlung läuft im Hintergrund,
   die Oberfläche bleibt bedienbar. Fortschritt in der Fußzeile.
4. Über 'Ansicht' die Kategorie für die Tabelle wählen.
5. 'Export' speichert CSV-Dateien oder einen HTML-Report auf dem Desktop.

Hinweis: Die Prefetch-Analyse erfordert Administrator-Rechte.
"@
    [System.Windows.MessageBox]::Show($window, $helpText, "$($script:AppName) - Hilfe", 'OK', 'Information') | Out-Null
})

# Info
$btnAbout.Add_Click({
    $aboutText = @"
$($script:AppName) (Application_Audit)
Software- und Client-Audit mit WPF-Oberfläche

Version: $($script:AppVersion)
Stand: $($script:AppDate)

© PhinIT - www.phinit.de
Versionshistorie: CHANGELOG.md im Modulordner
"@
    [System.Windows.MessageBox]::Show($window, $aboutText, "Über $($script:AppName)", 'OK', 'Information') | Out-Null
})

# Website-Link in der Fußzeile
$linkWebsite.Add_MouseLeftButtonUp({
    try {
        Start-Process 'https://www.phinit.de'
    } catch {
        Update-Status "Website konnte nicht geöffnet werden: $($_.Exception.Message)" -State Error
    }
})

# Beim Schließen: Timer stoppen, laufendes Audit abbrechen und Runspace freigeben
$window.Add_Closing({
    $script:auditTimer.Stop()
    if ($script:auditJob) {
        Stop-AuditJob -Job $script:auditJob
        $script:auditJob = $null
    }
})

#endregion

# Show Window
[void]$window.ShowDialog()
