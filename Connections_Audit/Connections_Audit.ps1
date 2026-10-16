# Connections_Audit.ps1 - Version 0.0.8 (Versionshistorie: siehe CHANGELOG.md)
# Advanced Network Connections Monitor with WPF GUI - Admin Edition
# Filter-Presets (presets.json) | Lazy Loading + Recording + Color-Coded Categories
# Performance: 80-90% schneller beim Start durch Lazy Loading
# Einheitliche PhinIT-Oberfläche (Vorlage ActiveDirectory_Audit): dunkle Kopf-/Fußzeile, Sidebar (Aktionen/Filter/Presets), Ergebnis-Karte

# Name, Version und Stand zentral – werden in Fenstertitel, Kopf-/Fußzeile, Info-Dialog, Log und HTML-Reports verwendet
$script:AppName    = 'Connections_Audit'
$script:AppVersion = '0.0.8'
$script:AppDate    = '15.10.2026'

# ===== Optional Logging System =====
$Global:LoggingEnabled = $false  # Set to $true to enable logging to file
$Global:LogFile = $null  # wird nach Ermittlung von $script:ScriptRoot gesetzt

function Write-Log {
    param([string]$Message)
    if ($Global:LoggingEnabled -and $Global:LogFile) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] $Message"
        Add-Content -Path $Global:LogFile -Value $logEntry -ErrorAction SilentlyContinue
    }
}

###############################################################################
# PS2EXE OPTIMIERUNGEN
###############################################################################
# PS2EXE: Progress Bars deaktivieren für -NoConsole Kompilierung
$ProgressPreference = 'SilentlyContinue'

# PS2EXE: Visual Styles aktivieren BEVOR GUI-Objekte erstellt werden
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# Universeller Pfad-Code für Script UND EXE-Kompatibilität
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") {
    # Script-Modus
    $script:ScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
} else {
    # Executable-Modus (PS2EXE)
    $script:ScriptRoot = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
    if ([string]::IsNullOrWhiteSpace($script:ScriptRoot)) { 
        $script:ScriptRoot = "."
    }
}
if (-not $script:ScriptRoot) { 
    $script:ScriptRoot = "."
}

$Global:LogFile = Join-Path -Path $script:ScriptRoot -ChildPath "Connections_Audit.log"
Write-Log "Script started: Connections_Audit.ps1 (v$($script:AppVersion))"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
# System.Windows.Forms wird bereits oben (EnableVisualStyles) geladen
Add-Type -AssemblyName Microsoft.VisualBasic  # für [Microsoft.VisualBasic.Interaction]::InputBox (Preset speichern)

Write-Log "Assemblies loaded successfully"

# XAML: einheitliche PhinIT-Oberfläche (Vorlage: ActiveDirectory_Audit)
$xamlContent = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="$($script:AppName) v$($script:AppVersion)"
    Width="1400"
    Height="900"
    MinWidth="1100"
    MinHeight="650"
    Background="#F8FAFC"
    FontFamily="Segoe UI"
    ResizeMode="CanResizeWithGrip"
    WindowStartupLocation="CenterScreen">

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

        <!--  Danger Button Style (aktive Aufzeichnung)  -->
        <Style x:Key="DangerButton" TargetType="Button">
            <Setter Property="Background" Value="#EF4444" />
            <Setter Property="Foreground" Value="White" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Padding" Value="16,10" />
            <Setter Property="FontWeight" Value="SemiBold" />
            <Setter Property="FontSize" Value="13" />
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
                                <Setter TargetName="border" Property="Background" Value="#DC2626" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#B91C1C" />
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

        <!--  Sidebar Label / ComboBox Styles  -->
        <Style x:Key="SidebarLabel" TargetType="TextBlock">
            <Setter Property="Margin" Value="0,6,0,2" />
            <Setter Property="FontSize" Value="12" />
            <Setter Property="FontWeight" Value="Normal" />
            <Setter Property="Foreground" Value="#6B7280" />
        </Style>
        <Style x:Key="SidebarComboBox" TargetType="ComboBox">
            <Setter Property="Height" Value="28" />
            <Setter Property="FontSize" Value="12" />
            <Setter Property="FontWeight" Value="Normal" />
            <Setter Property="Margin" Value="0,0,0,4" />
            <Setter Property="VerticalContentAlignment" Value="Center" />
        </Style>

        <!--  DataGrid Row Style with Color Coding (Kategorie-Farben)  -->
        <Style x:Key="ColoredDataGridRowStyle" TargetType="DataGridRow">
            <Setter Property="FontSize" Value="12" />
            <Setter Property="Height" Value="28" />
            <Setter Property="Background" Value="#FFFFFF" />
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#F3F4F6" />
                </Trigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="Web">
                    <Setter Property="Background" Value="#E3F2FD" />
                </DataTrigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="Email">
                    <Setter Property="Background" Value="#FFF3E0" />
                </DataTrigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="Database">
                    <Setter Property="Background" Value="#E8F5E9" />
                </DataTrigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="Directory">
                    <Setter Property="Background" Value="#F3E5F5" />
                </DataTrigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="RemoteAccess">
                    <Setter Property="Background" Value="#FCE4EC" />
                </DataTrigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="FileServices">
                    <Setter Property="Background" Value="#FFFDE7" />
                </DataTrigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="Monitoring">
                    <Setter Property="Background" Value="#F5F5F5" />
                </DataTrigger>
                <DataTrigger Binding="{Binding CategoryColor}" Value="Virtualization">
                    <Setter Property="Background" Value="#E0F2F1" />
                </DataTrigger>
            </Style.Triggers>
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
                        <TextBlock Text="Connections" FontSize="12" Foreground="#FFC1FFDB" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock x:Name="txtConnectionCount" Text="0" FontSize="18" FontWeight="Bold" Foreground="#FFEAEAEA" HorizontalAlignment="Center" TextAlignment="Center"/>
                    </StackPanel>
                    <StackPanel Orientation="Vertical" Background="#FF4C5B73" Height="49" Width="90">
                        <TextBlock Text="Recorded" FontSize="12" Foreground="#FFC1FFDB" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock x:Name="txtRecordedCount" Text="0" FontSize="18" FontWeight="Bold" Foreground="#FFEAEAEA" HorizontalAlignment="Center" TextAlignment="Center"/>
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

            <!--  Sidebar: Aktionen, Filter, Presets  -->
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
                            Text="🌐 Network Monitor" />

                        <!--  Aktionen  -->
                        <Expander Header="⚡ Aktionen" Style="{StaticResource ExpanderStyle}">
                            <StackPanel Margin="8,8,8,4">
                                <Button x:Name="btnRefresh" Margin="0,0,0,8" HorizontalAlignment="Stretch" Content="🔄 Aktualisieren" Style="{StaticResource PrimaryButton}" ToolTip="Verbindungsliste mit den aktuellen Filtern laden"/>
                                <Button x:Name="btnStartRecording" Margin="0,0,0,8" HorizontalAlignment="Stretch" Content="⏺ Aufzeichnung starten" Style="{StaticResource ModernButton}" ToolTip="Alle 3 Sekunden: eine Zeile je Remote-IP, Anzahl neu beobachteter TCP-Sockets. Grenzen: 10.000 Zeilen / 50.000 aktuelle TCP-Sockets; danach expliziter Stopp."/>
                                <Button x:Name="btnShowLive" Margin="0,0,0,8" HorizontalAlignment="Stretch" Content="Live-Ansicht laden" Style="{StaticResource ModernButton}" ToolTip="Nach dem Stoppen zurück zur normalen Verbindungsliste; gespeicherte Aufzeichnung wird erst beim nächsten Start zurückgesetzt"/>
                                <Button x:Name="btnExportHTML" HorizontalAlignment="Stretch" Content="📊 HTML Export" Style="{StaticResource ModernButton}" ToolTip="Aktuell angezeigte Verbindungen als HTML exportieren"/>
                            </StackPanel>
                        </Expander>

                        <!--  Filter  -->
                        <Expander Header="🔍 Filter" Style="{StaticResource ExpanderStyle}">
                            <StackPanel Margin="8,4,8,8">
                                <TextBlock Text="Netzwerk" Style="{StaticResource SidebarLabel}" />
                                <ComboBox x:Name="cmbNetworkType" Style="{StaticResource SidebarComboBox}" ToolTip="Netzwerk-Typ filtern">
                                    <ComboBoxItem Content="Alle Netzwerke" IsSelected="True"/>
                                    <ComboBoxItem Content="Nur Private"/>
                                    <ComboBoxItem Content="Nur Public"/>
                                </ComboBox>

                                <TextBlock Text="Protokoll" Style="{StaticResource SidebarLabel}" />
                                <ComboBox x:Name="cmbTCPUDP" Style="{StaticResource SidebarComboBox}" ToolTip="TCP/UDP Typ">
                                    <ComboBoxItem Content="TCP + UDP" IsSelected="True"/>
                                    <ComboBoxItem Content="Nur TCP"/>
                                    <ComboBoxItem Content="Nur UDP"/>
                                </ComboBox>

                                <TextBlock Text="Richtung" Style="{StaticResource SidebarLabel}" />
                                <ComboBox x:Name="cmbDirection" Style="{StaticResource SidebarComboBox}" ToolTip="Verbindungsrichtung">
                                    <ComboBoxItem Content="Beide" IsSelected="True"/>
                                    <ComboBoxItem Content="Eingehend"/>
                                    <ComboBoxItem Content="Ausgehend"/>
                                </ComboBox>

                                <TextBlock Text="Kategorie" Style="{StaticResource SidebarLabel}" />
                                <ComboBox x:Name="cmbCategory" Style="{StaticResource SidebarComboBox}" ToolTip="Nach Kategorie filtern">
                                    <ComboBoxItem Content="Alle Kategorien" IsSelected="True"/>
                                    <ComboBoxItem Content="Web Services"/>
                                    <ComboBoxItem Content="Email Services"/>
                                    <ComboBoxItem Content="Database Services"/>
                                    <ComboBoxItem Content="Directory Services"/>
                                    <ComboBoxItem Content="Remote Access"/>
                                    <ComboBoxItem Content="File Services"/>
                                    <ComboBoxItem Content="Monitoring"/>
                                    <ComboBoxItem Content="Virtualization"/>
                                </ComboBox>

                                <TextBlock Text="Service" Style="{StaticResource SidebarLabel}" />
                                <ComboBox x:Name="cmbProtocol" Style="{StaticResource SidebarComboBox}" MaxDropDownHeight="360" ToolTip="Nach Protokoll/Service filtern">
                                    <ComboBoxItem Content="Alle" IsSelected="True"/>
                                    <ComboBoxItem Content="HTTP"/>
                                    <ComboBoxItem Content="HTTPS"/>
                                    <ComboBoxItem Content="FTP"/>
                                    <ComboBoxItem Content="FTPS"/>
                                    <ComboBoxItem Content="SMTP"/>
                                    <ComboBoxItem Content="SMTP 25 + POP3S 995"/>
                                    <ComboBoxItem Content="POP3"/>
                                    <ComboBoxItem Content="IMAP"/>
                                    <ComboBoxItem Content="DNS"/>
                                    <ComboBoxItem Content="DHCP"/>
                                    <ComboBoxItem Content="LDAP"/>
                                    <ComboBoxItem Content="LDAPS"/>
                                    <ComboBoxItem Content="SSH"/>
                                    <ComboBoxItem Content="Telnet"/>
                                    <ComboBoxItem Content="RDP"/>
                                    <ComboBoxItem Content="SMB/CIFS"/>
                                    <ComboBoxItem Content="NFS"/>
                                    <ComboBoxItem Content="SNMP"/>
                                    <ComboBoxItem Content="NTP"/>
                                    <ComboBoxItem Content="Kerberos"/>
                                    <ComboBoxItem Content="WinRM"/>
                                    <ComboBoxItem Content="PowerShell"/>
                                    <ComboBoxItem Content="SQL Server"/>
                                    <ComboBoxItem Content="MySQL"/>
                                    <ComboBoxItem Content="PostgreSQL"/>
                                    <ComboBoxItem Content="Oracle"/>
                                    <ComboBoxItem Content="MongoDB"/>
                                    <ComboBoxItem Content="Redis"/>
                                    <ComboBoxItem Content="VNC"/>
                                    <ComboBoxItem Content="TeamViewer"/>
                                    <ComboBoxItem Content="Syslog"/>
                                    <ComboBoxItem Content="RADIUS"/>
                                    <ComboBoxItem Content="TACACS+"/>
                                    <ComboBoxItem Content="NetBIOS"/>
                                    <ComboBoxItem Content="AD Replication"/>
                                    <ComboBoxItem Content="Exchange"/>
                                    <ComboBoxItem Content="Hyper-V"/>
                                    <ComboBoxItem Content="VMware"/>
                                </ComboBox>

                                <CheckBox x:Name="chkShowProcessInfo" Margin="0,10,0,0" Content="Prozessinformationen anzeigen" FontWeight="Normal" IsChecked="False" ToolTip="Spalten Prozess ID / Prozess Name einblenden (nächste Aktualisierung lädt die Prozessdaten)"/>
                            </StackPanel>
                        </Expander>

                        <!--  Presets  -->
                        <Expander Header="🎯 Presets" Style="{StaticResource ExpanderStyle}">
                            <StackPanel Margin="8,8,8,8">
                                <ComboBox x:Name="cmbPresets" Style="{StaticResource SidebarComboBox}" ToolTip="Filter-Presets (presets.json)">
                                    <ComboBoxItem Content="-- Neues Preset --" IsSelected="True"/>
                                </ComboBox>
                                <Grid Margin="0,6,0,0">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*" />
                                        <ColumnDefinition Width="6" />
                                        <ColumnDefinition Width="*" />
                                        <ColumnDefinition Width="6" />
                                        <ColumnDefinition Width="*" />
                                    </Grid.ColumnDefinitions>
                                    <Button x:Name="btnLoadPreset" Grid.Column="0" Padding="6,6" FontSize="12" Content="Laden" Style="{StaticResource ModernButton}" ToolTip="Ausgewähltes Preset laden"/>
                                    <Button x:Name="btnSavePreset" Grid.Column="2" Padding="6,6" FontSize="12" Content="Speichern" Style="{StaticResource ModernButton}" ToolTip="Aktuelle Filter als Preset speichern"/>
                                    <Button x:Name="btnDeletePreset" Grid.Column="4" Padding="6,6" FontSize="12" Content="Löschen" Style="{StaticResource ModernButton}" ToolTip="Ausgewähltes Preset löschen"/>
                                </Grid>
                            </StackPanel>
                        </Expander>
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
                            Text="Network Connections" />
                        <TextBlock
                            Grid.Column="1"
                            VerticalAlignment="Center"
                            FontSize="12"
                            Foreground="#6B7280"
                            Text="Zeilenfarbe = Kategorie" />
                    </Grid>

                    <DataGrid
                        x:Name="dgConnections"
                        Grid.Row="1"
                        AutoGenerateColumns="False"
                        Background="White"
                        BorderBrush="#E5E7EB"
                        BorderThickness="1"
                        CanUserReorderColumns="True"
                        CanUserResizeColumns="True"
                        CanUserSortColumns="True"
                        GridLinesVisibility="Horizontal"
                        HorizontalGridLinesBrush="#F3F4F6"
                        HeadersVisibility="Column"
                        IsReadOnly="True"
                        RowStyle="{StaticResource ColoredDataGridRowStyle}"
                        ScrollViewer.HorizontalScrollBarVisibility="Auto"
                        ScrollViewer.VerticalScrollBarVisibility="Auto">
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
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="Typ" Binding="{Binding Type}" Width="60"/>
                           <DataGridTextColumn x:Name="dgColCount" Header="Anzahl TCP" Binding="{Binding Count}" Width="100" Visibility="Collapsed"/>
                            <DataGridTextColumn Header="Lokale Adresse" Binding="{Binding LocalAddress}" Width="140"/>
                            <DataGridTextColumn Header="Lokaler Port" Binding="{Binding LocalPort}" Width="100"/>
                            <DataGridTextColumn Header="Remote Adresse" Binding="{Binding RemoteAddress}" Width="140"/>
                            <DataGridTextColumn Header="Remote Port" Binding="{Binding RemotePort}" Width="100"/>
                            <DataGridTextColumn Header="Remote Hostname" Binding="{Binding RemoteHostname}" Width="*" MinWidth="140"/>
                            <DataGridTextColumn Header="Status" Binding="{Binding State}" Width="100"/>
                            <DataGridTextColumn x:Name="dgColProcessID" Header="Prozess ID" Binding="{Binding OwningProcess}" Width="90"/>
                            <DataGridTextColumn x:Name="dgColProcessName" Header="Prozess Name" Binding="{Binding ProcessName}" Width="150"/>
                            <DataGridTextColumn Header="Kategorie" Binding="{Binding CategoryName}" Width="130"/>
                            <DataGridTextColumn x:Name="dgColFirstSeen" Header="Zuerst gesehen" Binding="{Binding FirstSeen, StringFormat=dd.MM.yyyy HH:mm:ss}" Width="155" Visibility="Collapsed"/>
                            <DataGridTextColumn x:Name="dgColLastSeen" Header="Zuletzt gesehen" Binding="{Binding LastSeen, StringFormat=dd.MM.yyyy HH:mm:ss}" Width="155" Visibility="Collapsed"/>
                            <DataGridTextColumn x:Name="dgColProtocols" Header="Protokolle / Dienste (Port)" Binding="{Binding Protocols}" Width="180" Visibility="Collapsed"/>
                        </DataGrid.Columns>
                    </DataGrid>
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
                    <TextBlock x:Name="txtStatus" Text="Bereit" FontWeight="Medium" Foreground="#FFFFBBBB" FontSize="16" Height="22" MaxWidth="900" TextTrimming="CharacterEllipsis"/>
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

$reader = New-Object System.Xml.XmlNodeReader ([xml]$xamlContent)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$btnRefresh = $window.FindName("btnRefresh")
$cmbProtocol = $window.FindName("cmbProtocol")
$cmbDirection = $window.FindName("cmbDirection")
$cmbCategory = $window.FindName("cmbCategory")
$cmbNetworkType = $window.FindName("cmbNetworkType")
$cmbTCPUDP = $window.FindName("cmbTCPUDP")
$chkShowProcessInfo = $window.FindName("chkShowProcessInfo")
$btnStartRecording = $window.FindName("btnStartRecording")
$btnShowLive = $window.FindName("btnShowLive")
$btnExportHTML = $window.FindName("btnExportHTML")
$dgConnections = $window.FindName("dgConnections")
$dgColProcessID = $window.FindName("dgColProcessID")
$dgColProcessName = $window.FindName("dgColProcessName")
$dgColCount = $window.FindName("dgColCount")
$dgColFirstSeen = $window.FindName("dgColFirstSeen")
$dgColLastSeen = $window.FindName("dgColLastSeen")
$dgColProtocols = $window.FindName("dgColProtocols")
$txtStatus = $window.FindName("txtStatus")
$cmbPresets = $window.FindName("cmbPresets")
$btnLoadPreset = $window.FindName("btnLoadPreset")
$btnSavePreset = $window.FindName("btnSavePreset")
$btnDeletePreset = $window.FindName("btnDeletePreset")
$txtConnectionCount = $window.FindName("txtConnectionCount")
$txtRecordedCount = $window.FindName("txtRecordedCount")
$StatusIndicator = $window.FindName("StatusIndicator")
$btnHelp = $window.FindName("btnHelp")
$btnAbout = $window.FindName("btnAbout")
$linkWebsite = $window.FindName("linkWebsite")

# Global variables for Recording Feature
$Global:RecordingActive = $false
$Global:RecordingTimer = $null
$Global:RecordedConnections = New-Object System.Collections.ArrayList
$Global:RecordedConnectionsHash = @{}
$Global:ProcessCache = @{}
$Global:HostnameCache = @{}
$Global:RecordingStartTime = $null
$Global:RecordingCategory = "Alle Kategorien"
$Global:RecordingView = $false
$Global:RecordingEndTime = $null
$Global:RecordingStopReason = ""
$Global:PreviousRecordingSockets = @{}
$script:MaxRecordingRows = 10000
$script:MaxRecordingSockets = 50000
$script:MaxRecordingPortsPerSide = 64
$script:MaxHostnameCache = 10000

# Preset Storage
$Global:PresetsFile = Join-Path -Path $script:ScriptRoot -ChildPath "presets.json"
$Global:FilterPresets = @{}

# Protocol port mappings
$protocolPorts = @{
    "HTTP" = @(80, 8080, 8008, 8000)
    "HTTPS" = @(443, 8443, 8444)
    "FTP" = @(21, 20)
    "FTPS" = @(990, 989)
    "SMTP" = @(25, 587, 465)
    "SMTP 25 + POP3S 995" = @(25, 995)
    "POP3" = @(110, 995)
    "IMAP" = @(143, 993)
    "DNS" = @(53)
    "DHCP" = @(67, 68)
    "LDAP" = @(389)
    "LDAPS" = @(636)
    "SSH" = @(22)
    "Telnet" = @(23)
    "RDP" = @(3389)
    "SMB/CIFS" = @(445, 139, 137, 138)
    "NFS" = @(2049, 111)
    "SNMP" = @(161, 162)
    "NTP" = @(123)
    "Kerberos" = @(88, 464)
    "WinRM" = @(5985, 5986)
    "PowerShell" = @(5985, 5986)
    "SQL Server" = @(1433, 1434)
    "MySQL" = @(3306)
    "PostgreSQL" = @(5432)
    "Oracle" = @(1521, 1522)
    "MongoDB" = @(27017, 27018, 27019)
    "Redis" = @(6379)
    "VNC" = @(5900, 5901, 5902, 5903, 5904, 5905)
    "TeamViewer" = @(5938)
    "Syslog" = @(514)
    "RADIUS" = @(1812, 1813)
    "TACACS+" = @(49)
    "NetBIOS" = @(137, 138, 139)
    "AD Replication" = @(135, 389, 636, 3268, 3269, 53, 88, 445)
    "Exchange" = @(25, 80, 110, 143, 443, 993, 995, 587, 465)
    "Hyper-V" = @(2179, 5985, 5986)
    "VMware" = @(443, 902, 903, 8080, 8443)
}

# Protocol categories
$protocolCategories = @{
    "Web Services" = @("HTTP", "HTTPS")
    "Email Services" = @("SMTP", "POP3", "IMAP", "Exchange")
    "Database Services" = @("SQL Server", "MySQL", "PostgreSQL", "Oracle", "MongoDB", "Redis")
    "Directory Services" = @("LDAP", "LDAPS", "AD Replication", "Kerberos")
    "Remote Access" = @("SSH", "Telnet", "RDP", "VNC", "TeamViewer", "WinRM", "PowerShell")
    "File Services" = @("FTP", "FTPS", "SMB/CIFS", "NFS", "NetBIOS")
    "Monitoring" = @("SNMP", "Syslog", "NTP")
    "Virtualization" = @("Hyper-V", "VMware")
}

# Category to color mapping
$categoryColorMap = @{
    "Web Services" = "Web"
    "Email Services" = "Email"
    "Database Services" = "Database"
    "Directory Services" = "Directory"
    "Remote Access" = "RemoteAccess"
    "File Services" = "FileServices"
    "Monitoring" = "Monitoring"
    "Virtualization" = "Virtualization"
}

# Statuszeile in der Fußzeile (einzeilig) inkl. Statusanzeige: Ready = grün, Busy = gelb, Error = rot
# Ohne -State: gelb während einer Aufzeichnung, sonst grün
function Update-StatusBar {
    param(
        [string]$Message,
        [ValidateSet('Auto', 'Ready', 'Busy', 'Error')]
        [string]$State = 'Auto'
    )
    $lines = @(($Message -split "`r?`n") | Where-Object { $_ })
    $txtStatus.Text = $lines -join '  |  '
    $txtStatus.ToolTip = $lines -join [Environment]::NewLine
    if ($State -eq 'Auto') {
        $State = if ($Global:RecordingActive) { 'Busy' } else { 'Ready' }
    }
    $color = switch ($State) { 'Busy' { '#F59E0B' } 'Error' { '#EF4444' } default { '#10B981' } }
    $StatusIndicator.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($color)
}

# Zähler in der Kopfzeile (angezeigte / aufgezeichnete Verbindungen)
function Update-ConnectionCounters {
    $items = $dgConnections.ItemsSource
    $txtConnectionCount.Text = if ($items) { [string]@($items).Count } else { '0' }
    $txtRecordedCount.Text = [string]$Global:RecordedConnections.Count
}

# Function to toggle process columns visibility
function Update-ProcessColumnsVisibility {
    param([bool]$showProcessInfo)
    
    if ($showProcessInfo -and -not $Global:RecordingView) {
        $dgColProcessID.Visibility = [System.Windows.Visibility]::Visible
        $dgColProcessName.Visibility = [System.Windows.Visibility]::Visible
    } else {
        $dgColProcessID.Visibility = [System.Windows.Visibility]::Collapsed
        $dgColProcessName.Visibility = [System.Windows.Visibility]::Collapsed
    }
}

# Function to check if IP is private
function Test-IsPrivateIP {
    param([string]$ip)
    
    if ($ip -eq "0.0.0.0" -or $ip -eq "::" -or $ip -eq "N/A") {
        return $true
    }
    
    # Loopback addresses
    if ($ip -eq "127.0.0.1" -or $ip -eq "::1") {
        return $true
    }
    
    # IPv4-mapped IPv6 (::ffff:a.b.c.d) wie IPv4 behandeln
    if ($ip -match "^::ffff:(\d{1,3}(\.\d{1,3}){3})$") { return (Test-IsPrivateIP -ip $Matches[1]) }

    # IPv4 private ranges
    if ($ip -match "^127\.") { return $true }           # 127.0.0.0/8
    if ($ip -match "^192\.168\.") { return $true }       # 192.168.0.0/16
    if ($ip -match "^10\.") { return $true }             # 10.0.0.0/8
    if ($ip -match "^172\.(1[6-9]|2[0-9]|3[01])\.") { 
        return $true 
    }                                                    # 172.16.0.0/12
    if ($ip -match "^169\.254\.") { return $true }      # 169.254.0.0/16 (Link-local/APIPA)
    if ($ip -match "^100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.") { return $true } # 100.64.0.0/10 (Carrier-Grade NAT)
    
    # IPv6 private ranges
    if ($ip -match "^fc[0-9a-f]{2}:") { return $true }   # fc00::/7
    if ($ip -match "^fd[0-9a-f]{2}:") { return $true }   # fd00::/8
    if ($ip -match "^fe80:") { return $true }            # fe80::/10 (Link-local)
    if ($ip -match "^::1") { return $true }              # Loopback
    
    # Alle anderen IPs sind öffentlich
    return $false
}

# Function to determine category and color based on port
function Get-CategoryAndColor {
    param([object]$LocalPort, [object]$RemotePort, [string]$Type)
    
    # Convert to int safely, handle "N/A" strings
    try {
        $localPortInt = if ($LocalPort -eq "N/A" -or $LocalPort -eq 0) { 0 } else { [int]$LocalPort }
        $remotePortInt = if ($RemotePort -eq "N/A" -or $RemotePort -eq 0) { 0 } else { [int]$RemotePort }
    } catch {
        $localPortInt = 0
        $remotePortInt = 0
    }
    
    $checkPort = if ($Type -eq "TCP" -and $remotePortInt -ne 0) { $remotePortInt } else { $localPortInt }
    
    foreach ($category in $protocolCategories.GetEnumerator()) {
        $categoryName = $category.Name
        $protocols = $category.Value
        
        foreach ($protocol in $protocols) {
            if ($protocolPorts.ContainsKey($protocol)) {
                if ($checkPort -in $protocolPorts[$protocol]) {
                    return @{
                        CategoryName = $categoryName
                        CategoryColor = $categoryColorMap[$categoryName]
                    }
                }
            }
        }
    }
    
    return @{
        CategoryName = "Sonstige"
        CategoryColor = "Other"
    }
}

# Function to get process name with caching
function Get-ProcessNameCached {
    param([int]$ProcessId)
    
    if ($Global:ProcessCache.ContainsKey($ProcessId)) {
        return $Global:ProcessCache[$ProcessId]
    }
    
    try {
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        $processName = if ($process) { $process.ProcessName } else { "Unknown" }
        $Global:ProcessCache[$ProcessId] = $processName
        return $processName
    } catch {
        $Global:ProcessCache[$ProcessId] = "Unknown"
        return "Unknown"
    }
}

# Function to get connections
function Get-NetworkConnections {
    param(
        [string]$protocol = "Alle", 
        [string]$direction = "Beide",
        [string]$category = "Alle Kategorien",
        [bool]$includeProcessInfo = $false,
        [string]$networkType = "Alle Netzwerke",
        [string]$tcpUdpType = "TCP + UDP",
        [switch]$recordingSnapshot
    )

    # Get TCP connections - convert to PSCustomObject
    # Prozess-Cache pro Abfrage neu aufbauen (PIDs werden vom System wiederverwendet)
    $Global:ProcessCache = @{}
    $queryErrorAction = if ($recordingSnapshot) { 'Stop' } else { 'Continue' }
    $tcpConnections = @()
    if ($tcpUdpType -ne "Nur UDP") {
        $tcpConnections = Get-NetTCPConnection -ErrorAction $queryErrorAction | ForEach-Object {
            [PSCustomObject]@{
                Type = "TCP"
                LocalAddress = $_.LocalAddress
                LocalPort = $_.LocalPort
                RemoteAddress = $_.RemoteAddress
                RemotePort = $_.RemotePort
                CreationTime = $_.CreationTime
                State = $_.State
                OwningProcess = $_.OwningProcess
                ProcessName = ""
                RemoteHostname = ""
                CategoryName = ""
                CategoryColor = ""
            }
        }
    }

    # Get UDP endpoints - convert to PSCustomObject
    $udpConnections = @()
    if ($tcpUdpType -ne "Nur TCP") {
        $udpConnections = Get-NetUDPEndpoint -ErrorAction $queryErrorAction | ForEach-Object {
            [PSCustomObject]@{
                Type = "UDP"
                LocalAddress = $_.LocalAddress
                LocalPort = $_.LocalPort
                RemoteAddress = "N/A"
                RemotePort = "N/A"
                State = "Listen"
                OwningProcess = $_.OwningProcess
                ProcessName = ""
                RemoteHostname = "N/A"
                CategoryName = ""
                CategoryColor = ""
            }
        }
    }

    $connections = @($tcpConnections) + @($udpConnections)

    # Filter by network type (Private/Public/All)
    if ($networkType -ne "Alle Netzwerke") {
        $connections = $connections | Where-Object {
            $isLocalPrivate = Test-IsPrivateIP -ip $_.LocalAddress
            $isRemotePrivate = Test-IsPrivateIP -ip $_.RemoteAddress
            $allPrivate = $isLocalPrivate -and $isRemotePrivate
            
            if ($networkType -eq "Nur Private") {
                $allPrivate
            } elseif ($networkType -eq "Nur Public") {
                -not $allPrivate
            } else {
                $true
            }
        }
    }

    # Filter by category first
    if ($category -ne "Alle Kategorien") {
        $categoryProtocols = $protocolCategories[$category]
        $categoryPorts = @(foreach ($prot in $categoryProtocols) {
            if ($protocolPorts.ContainsKey($prot)) {
                $protocolPorts[$prot]
            }
        })
        $connections = $connections | Where-Object { 
            ($_.LocalPort -in $categoryPorts) -or 
            ($_.RemotePort -in $categoryPorts -and $_.Type -eq "TCP")
        }
    }

    # Filter by specific protocol
    if ($protocol -ne "Alle") {
        $ports = $protocolPorts[$protocol]
        if ($direction -eq "Eingehend") {
            $connections = $connections | Where-Object { $_.LocalPort -in $ports }
        } elseif ($direction -eq "Ausgehend") {
            $connections = $connections | Where-Object { $_.RemotePort -in $ports -and $_.Type -eq "TCP" }
        } else {
            $connections = $connections | Where-Object { ($_.LocalPort -in $ports -or ($_.RemotePort -in $ports -and $_.Type -eq "TCP")) }
        }
    }

    # Resolve process names, hostnames and add category/color info
    foreach ($conn in $connections) {
        # Only resolve process names if requested
        if ($includeProcessInfo -and -not $conn.ProcessName) {
            $conn.ProcessName = Get-ProcessNameCached -ProcessId $conn.OwningProcess
        }
        
        # Add category and color info
        $categoryInfo = Get-CategoryAndColor -LocalPort $conn.LocalPort -RemotePort $conn.RemotePort -Type $conn.Type
        $conn.CategoryName = $categoryInfo.CategoryName
        $conn.CategoryColor = $categoryInfo.CategoryColor
        
        if ($recordingSnapshot) {
            $conn.RemoteHostname = $conn.RemoteAddress
        } elseif ($conn.Type -eq "TCP" -and $conn.RemoteAddress -ne "N/A" -and -not $conn.RemoteHostname) {
            if ($conn.RemoteAddress -match "^127\.|^192\.168\.|^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.") {
                $conn.RemoteHostname = Get-HostnameFast -ip $conn.RemoteAddress
            } else {
                $conn.RemoteHostname = $conn.RemoteAddress
            }
        }
    }

    return $connections
}

# Fast hostname resolution (mit Cache und Timeout, um den UI-Thread nicht zu blockieren)
function Get-HostnameFast {
    param([string]$ip)
    try {
        if ($ip -eq "0.0.0.0" -or $ip -eq "::" -or $ip -eq "127.0.0.1" -or $ip -eq "::1" -or $ip -eq "N/A") {
            return $ip
        }
        if ($Global:HostnameCache.ContainsKey($ip)) {
            return $Global:HostnameCache[$ip]
        }
        if ($Global:HostnameCache.Count -ge $script:MaxHostnameCache) {
            return $ip
        }
        $hostName = $ip
        $lookupTask = [System.Net.Dns]::GetHostEntryAsync($ip)
        if ($lookupTask.Wait(1000) -and $lookupTask.Result -and $lookupTask.Result.HostName) {
            $hostName = $lookupTask.Result.HostName
        }
        $Global:HostnameCache[$ip] = $hostName
        return $hostName
    } catch {
        $Global:HostnameCache[$ip] = $ip
        return $ip
    }
}

# HTML-Encoding für Werte in HTML-Reports (Schutz vor HTML-/Script-Injection)
function ConvertTo-HtmlSafe {
    param([object]$Value)
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Reset-RecordingData {
    $Global:RecordedConnections = New-Object System.Collections.ArrayList
    $Global:RecordedConnectionsHash = @{}
    $Global:PreviousRecordingSockets = @{}
    $Global:HostnameCache = @{}
    $Global:RecordingEndTime = $null
    $Global:RecordingStopReason = ""
    $Global:RecordingStartTime = Get-Date
    $script:RecordingServicesByPort = @{}
    foreach ($service in $protocolPorts.Keys) {
        if ($service -eq "SMTP 25 + POP3S 995") { continue }
        foreach ($port in $protocolPorts[$service]) {
            if (-not $script:RecordingServicesByPort.ContainsKey([int]$port)) {
                $script:RecordingServicesByPort[[int]$port] = New-Object 'System.Collections.Generic.HashSet[string]'
            }
            $name = if ($port -eq 995) { 'POP3S' } else { $service }
            [void]$script:RecordingServicesByPort[[int]$port].Add($name)
        }
    }
}

function Update-RecordingData {
    param([object[]]$Connections = @(), [datetime]$ObservedAt = (Get-Date))

    # Preflight the entire snapshot: limits never leave a partially counted poll.
    $currentSockets = @{}
    $snapshotRows = @{}
    $pending = New-Object 'System.Collections.Generic.List[object]'
    $newRows = 0
    foreach ($conn in $Connections) {
        if ($conn.Type -eq 'TCP') {
            $ip = $null
            if (-not [System.Net.IPAddress]::TryParse([string]$conn.RemoteAddress, [ref]$ip)) { continue }
            if ($ip.Equals([System.Net.IPAddress]::Any) -or $ip.Equals([System.Net.IPAddress]::IPv6Any) -or [int]$conn.RemotePort -eq 0) { continue }
            if ($ip.IsIPv4MappedToIPv6) { $ip = $ip.MapToIPv4() }
            $remoteIP = $ip.ToString()
            $rowKey = "TCP|$remoteIP"
            $created = if ($conn.CreationTime) { ([datetime]$conn.CreationTime).Ticks } else { 0 }
            # State and PID can change without creating a new socket.
            $socketKey = "$($conn.LocalAddress)|$($conn.LocalPort)|$remoteIP|$($conn.RemotePort)|$created"
            if ($currentSockets.ContainsKey($socketKey)) { continue }
            if ($currentSockets.Count -ge $script:MaxRecordingSockets) {
                throw "Ressourcenlimit: $($script:MaxRecordingSockets) aktuelle TCP-Sockets. Letzter vollständiger Stand bleibt erhalten."
            }
            $currentSockets[$socketKey] = $true
        } elseif ($conn.Type -eq 'UDP') {
            $remoteIP = 'N/A (lokaler UDP-Endpunkt)'
            $rowKey = "UDP|$($conn.LocalAddress)|$($conn.LocalPort)"
            $socketKey = $null
            if ($snapshotRows.ContainsKey($rowKey)) { continue }
        } else {
            continue
        }
        if (-not $snapshotRows.ContainsKey($rowKey)) {
            $snapshotRows[$rowKey] = $true
            if (-not $Global:RecordedConnectionsHash.ContainsKey($rowKey)) {
                $newRows++
                if (($Global:RecordedConnections.Count + $newRows) -gt $script:MaxRecordingRows) {
                    throw "Ressourcenlimit: $($script:MaxRecordingRows) IP-/Endpunktzeilen. Letzter vollständiger Stand bleibt erhalten."
                }
            }
        }
        $pending.Add([pscustomobject]@{ Connection = $conn; RowKey = $rowKey; SocketKey = $socketKey; RemoteIP = $remoteIP })
    }

    foreach ($entry in $pending) {
        $conn = $entry.Connection
        $row = $Global:RecordedConnectionsHash[$entry.RowKey]
        if ($null -eq $row) {
            $row = [pscustomobject]@{
                Type = $conn.Type
                LocalAddress = $(if ($conn.Type -eq 'UDP') { $conn.LocalAddress } else { '(je Remote-IP)' })
                LocalPort = ''; RemoteAddress = $entry.RemoteIP; RemotePort = ''
                LocalPortPreview = ''; RemotePortPreview = ''
                LocalPortsOmitted = $false; RemotePortsOmitted = $false
                RemoteHostname = $entry.RemoteIP
                State = $(if ($conn.Type -eq 'UDP') { 'Lokaler Endpunkt' } else { 'Aggregiert' })
                OwningProcess = ''; ProcessName = ''
                CategoryName = $(if ($conn.Type -eq 'UDP') { 'UDP-Endpunkt' } else { 'Remote-IP' })
                CategoryColor = 'Other'
                Count = $(if ($conn.Type -eq 'TCP') { [long]0 } else { 'N/A' })
                FirstSeen = $ObservedAt; LastSeen = $ObservedAt
                LocalPorts = (New-Object 'System.Collections.Generic.HashSet[int]')
                RemotePorts = (New-Object 'System.Collections.Generic.HashSet[int]')
                ProtocolSet = (New-Object 'System.Collections.Generic.HashSet[string]')
                Protocols = ''; PortsChanged = $true
            }
            [void]$Global:RecordedConnections.Add($row)
            $Global:RecordedConnectionsHash[$entry.RowKey] = $row
        }
        $row.LastSeen = $ObservedAt
        if ($conn.Type -eq 'TCP' -and -not $Global:PreviousRecordingSockets.ContainsKey($entry.SocketKey)) {
            $row.Count++
        }
        foreach ($side in @('Local', 'Remote')) {
            $port = 0
            if ([int]::TryParse([string]$conn.("${side}Port"), [ref]$port) -and $port -ge 0 -and $port -le 65535) {
                $portSet = $row.("${side}Ports")
                if (-not $portSet.Contains($port)) {
                    if ($portSet.Count -lt $script:MaxRecordingPortsPerSide) {
                        [void]$portSet.Add($port)
                        $row.PortsChanged = $true
                        if ($portSet.Count -le 16) {
                            $preview = $row.("${side}PortPreview")
                            $row.("${side}PortPreview") = if ($preview) { "$preview, $port" } else { [string]$port }
                        }
                    } elseif (-not $row.("${side}PortsOmitted")) {
                        $row.("${side}PortsOmitted") = $true
                        $row.PortsChanged = $true
                    }
                }
                if ($script:RecordingServicesByPort.ContainsKey($port)) {
                    foreach ($service in $script:RecordingServicesByPort[$port]) {
                        if ($row.ProtocolSet.Add($service)) { $row.PortsChanged = $true }
                    }
                }
            }
        }
        if ($row.ProtocolSet.Add([string]$conn.Type)) { $row.PortsChanged = $true }
    }
    $Global:PreviousRecordingSockets = $currentSockets
    foreach ($row in $Global:RecordedConnections) {
        if ($row.PortsChanged) {
            # Keep GUI work constant; HTML exports all stored ports and any omission flags.
            foreach ($side in @('Local', 'Remote')) {
                $ports = $row.("${side}Ports")
                if ($ports.Count -le 16) {
                    $row.("${side}PortPreview") = ($ports | Sort-Object) -join ', '
                }
                $row.("${side}Port") = if ($row.("${side}PortsOmitted")) {
                    "$($row.("${side}PortPreview")), ... (weitere Ports nicht gespeichert)"
                } elseif ($ports.Count -gt 16) {
                    "$($row.("${side}PortPreview")), ... ($($ports.Count) Ports; HTML vollständig)"
                } else {
                    $row.("${side}PortPreview")
                }
            }
            if ($row.Type -eq 'UDP') { $row.RemotePort = 'N/A' }
            $row.Protocols = ($row.ProtocolSet | Sort-Object) -join ', '
            $row.PortsChanged = $false
        }
    }
}

function Update-RecordingView {
    $visibility = if ($Global:RecordingView) { 'Visible' } else { 'Collapsed' }
    foreach ($column in @($dgColCount, $dgColFirstSeen, $dgColLastSeen, $dgColProtocols)) {
        $column.Visibility = $visibility
    }
    Update-ProcessColumnsVisibility -showProcessInfo ([bool]$chkShowProcessInfo.IsChecked)
    if ($Global:RecordingView) {
        $dgConnections.ItemsSource = $Global:RecordedConnections
        $dgConnections.Items.Refresh()
    }
    Update-ConnectionCounters
}

function Set-RecordingControls {
    param([bool]$Active)
    foreach ($control in @($cmbProtocol, $cmbDirection, $cmbCategory, $cmbNetworkType, $cmbTCPUDP, $chkShowProcessInfo, $btnLoadPreset, $btnShowLive)) {
        $control.IsEnabled = -not $Active
    }
}

# Function to start Recording
function Start-ConnectionRecording {
    Reset-RecordingData
    $Global:RecordingCategory = $cmbCategory.SelectedItem.Content
    $Global:RecordingFilters = @{
        protocol = $cmbProtocol.SelectedItem.Content
        direction = $cmbDirection.SelectedItem.Content
        category = $Global:RecordingCategory
        networkType = $cmbNetworkType.SelectedItem.Content
        tcpUdpType = $cmbTCPUDP.SelectedItem.Content
        includeProcessInfo = $false
        recordingSnapshot = $true
    }
    $Global:RecordingActive = $true
    $Global:RecordingView = $true
    Set-RecordingControls -Active $true
    Update-RecordingView
    $btnStartRecording.Content = "⏹ Aufzeichnung stoppen"
    $btnStartRecording.Style = $window.FindResource('DangerButton')
    
    $Global:RecordingTimer = New-Object System.Windows.Threading.DispatcherTimer
    $Global:RecordingTimer.Interval = [System.TimeSpan]::FromSeconds(3)
    
    $Global:RecordingTimer.Add_Tick({
      try {
        if (-not $Global:RecordingActive) { return }
        $filters = $Global:RecordingFilters
        $connections = @(Get-NetworkConnections @filters)
        Update-RecordingData -Connections $connections
        Update-RecordingView
        $duration = ((Get-Date) - $Global:RecordingStartTime).TotalSeconds
        Update-StatusBar "Aufzeichnung läuft... IP-/Endpunktzeilen: $($Global:RecordedConnections.Count)/$($script:MaxRecordingRows) | Aktuelle TCP-Sockets: $($Global:PreviousRecordingSockets.Count)/$($script:MaxRecordingSockets) | Dauer: $([Math]::Floor($duration))s" -State Busy
      } catch {
        Stop-ConnectionRecording -FailureReason $_.Exception.Message -NoExport
        Write-Log "Recording tick error: $($_.Exception.Message)"
      }
    })
    
    $Global:RecordingTimer.Start()
    Update-ConnectionCounters
    Update-StatusBar "Aufzeichnung gestartet für Kategorie: $($cmbCategory.SelectedItem.Content)" -State Busy
}

# Function to stop Recording
function Stop-ConnectionRecording {
    param([string]$FailureReason = '', [switch]$NoExport)
    $Global:RecordingActive = $false
    $Global:RecordingEndTime = Get-Date
    $Global:RecordingStopReason = $FailureReason
    Set-RecordingControls -Active $false
    $btnStartRecording.Content = "⏺ Aufzeichnung starten"
    $btnStartRecording.Style = $window.FindResource('ModernButton')
    
    if ($Global:RecordingTimer) {
        $Global:RecordingTimer.Stop()
        $Global:RecordingTimer = $null
    }
    
    $duration = ((Get-Date) - $Global:RecordingStartTime).TotalSeconds
    Update-RecordingView
    if ($FailureReason) {
        Update-StatusBar "Aufzeichnung GESTOPPT: $FailureReason HTML Export sichert den letzten vollständigen Stand." -State Error
    } else {
        Update-StatusBar "Aufzeichnung beendet. IP-/Endpunktzeilen: $($Global:RecordedConnections.Count) | Dauer: $([Math]::Floor($duration))s" -State Ready
    }
    
    if (-not $NoExport -and $Global:RecordedConnections.Count -gt 0) {
        Export-RecordingReportHTML
    }
}

# Build the recording report independently of the Windows save dialog.
function Get-RecordingReportHTML {
    $DateTimeNow = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
    $endTime = if ($Global:RecordingEndTime) { $Global:RecordingEndTime } else { Get-Date }
    $RecordingEnd = $endTime.ToString("dd.MM.yyyy HH:mm:ss")
    $RecordingStart = $Global:RecordingStartTime.ToString("dd.MM.yyyy HH:mm:ss")
    $duration = ($endTime - $Global:RecordingStartTime).TotalSeconds
    $totalConnections = $Global:RecordedConnections.Count
    $tcpRows = @($Global:RecordedConnections | Where-Object { $_.Type -eq "TCP" })
    $tcpCount = $tcpRows.Count
    $udpCount = @($Global:RecordedConnections | Where-Object { $_.Type -eq "UDP" }).Count
    $socketCount = [long]0
    foreach ($row in $tcpRows) { $socketCount += $row.Count }
    $limitedPortRows = @($Global:RecordedConnections | Where-Object { $_.LocalPortsOmitted -or $_.RemotePortsOmitted }).Count
    $computerName = ConvertTo-HtmlSafe $env:COMPUTERNAME
    $userName = ConvertTo-HtmlSafe $env:USERNAME
    $category = ConvertTo-HtmlSafe $Global:RecordingCategory
    $filters = ConvertTo-HtmlSafe ("Service: {0} | Richtung: {1} | Netzwerk: {2} | Typ: {3}" -f $Global:RecordingFilters.protocol, $Global:RecordingFilters.direction, $Global:RecordingFilters.networkType, $Global:RecordingFilters.tcpUdpType)
    $captureStatus = if ($Global:RecordingStopReason) {
        "Vorzeitig gestoppt / unvollständiger Zeitraum: $(ConvertTo-HtmlSafe $Global:RecordingStopReason) Der letzte vollständige Snapshot ist enthalten; der fehlgeschlagene Snapshot wurde nicht übernommen."
    } elseif ($Global:RecordingActive) {
        'Aufzeichnung läuft; Zwischenstand. Kein Ressourcenlimit erreicht.'
    } else {
        'Regulär beendet. Kein Ressourcenlimit erreicht.'
    }

    $html = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Aufzeichnungs-Report - Connections_Audit</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f3f3f3; color: #333; }
        .container { max-width: 1400px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #0078D4; padding-bottom: 20px; }
        h1 { color: #0078D4; margin: 0; font-size: 2.5em; }
        .subtitle { color: #666; font-size: 1.2em; margin: 10px 0; }
        .info-box { background-color: #e6f3ff; padding: 15px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid #0078D4; }
        .summary { display: flex; justify-content: space-around; margin-bottom: 20px; }
        .summary-item { text-align: center; background: #f8f9fa; padding: 10px; border-radius: 4px; }
        .timestamp { text-align: center; color: #666; margin-bottom: 20px; font-style: italic; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; font-size: 14px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #0078D4; color: white; font-weight: bold; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #e6f3ff; }
        .footer { text-align: center; margin-top: 30px; color: #666; border-top: 1px solid #ddd; padding-top: 20px; }
        .footer p { margin: 5px 0; }
        .footer a { color: #0078D4; text-decoration: none; }
        .footer a:hover { text-decoration: underline; }
        .recording-info { background-color: #fff3cd; padding: 10px; border-radius: 4px; margin-bottom: 20px; border-left: 4px solid #ffc107; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Netzwerk-Aufzeichnungs-Report</h1>
            <div class="subtitle">Connections_Audit Tool - Kontinuierliche Überwachung</div>
            <div class="info-box">
                <strong>Computer:</strong> $computerName | <strong>Benutzer:</strong> $userName<br>
                <strong>Kategorie:</strong> $category<br>$filters
            </div>
            <div class="recording-info">
                <strong>Aufzeichnungszeitraum:</strong> $RecordingStart bis $RecordingEnd<br>
                <strong>Dauer:</strong> $([Math]::Floor($duration)) Sekunden<br>
                <strong>Erfassungsstatus:</strong> $captureStatus<br>
                Eine Zeile je Remote-IP, unabhängig von Ports und Diensten. Anzahl = neu beobachtete TCP-Sockets:
                ein durchgehend sichtbarer Socket zählt einmal, nach einem fehlenden Snapshot erneut.
                CreationTime unterscheidet Port-Wiederverwendung, soweit vom Betriebssystem geliefert.<br>
                Polling alle 3 Sekunden (zzgl. Abfragedauer): keine Mail-/Request-Zählung; kurzlebige Verbindungen zwischen Abfragen können fehlen.
                TCP-Listener ohne Gegenstelle werden nicht gezählt. UDP zeigt nur lokale Endpunkte, keine Clients oder Verbindungsanzahl.
                Dienste sind nur aus Ports abgeleitet, keine Protokollanalyse.<br>
                <strong>Port-Historie:</strong> maximal $($script:MaxRecordingPortsPerSide) verschiedene Ports je Zeile und Seite;
                weitere Ports werden nicht gespeichert. Betroffene Zeilen: $limitedPortRows.
                TCP-Zählung und Diensterkennung laufen dennoch für alle beobachteten Sockets/Ports weiter.<br>
                Grenzen: $($script:MaxRecordingRows) IP-/Endpunktzeilen, $($script:MaxRecordingSockets) aktuelle TCP-Sockets;
                bei Überschreitung expliziter Stopp ohne stilles Verwerfen.
            </div>
        </div>
        <div class="summary">
            <div class="summary-item">
                <strong>IP-/Endpunktzeilen</strong><br>$totalConnections
            </div>
            <div class="summary-item">
                <strong>TCP Remote-IPs</strong><br>$tcpCount
            </div>
            <div class="summary-item">
                <strong>UDP lokale Endpunkte</strong><br>$udpCount
            </div>
            <div class="summary-item">
                <strong>Neu beobachtete TCP-Sockets</strong><br>$socketCount
            </div>
        </div>
        <div class="timestamp">Erstellt am $DateTimeNow</div>
        <table>
            <thead>
                <tr>
                    <th>Typ</th>
                    <th>Lokale Adresse</th>
                    <th>Lokale Ports</th>
                    <th>Remote Adresse</th>
                    <th>Remote Ports</th>
                    <th>Remote Hostname</th>
                    <th>Status</th>
                    <th>Anzahl TCP</th>
                    <th>Zuerst gesehen</th>
                    <th>Zuletzt gesehen</th>
                    <th>Protokolle / Dienste (Port)</th>
                </tr>
            </thead>
            <tbody>
"@

    $rows = foreach ($conn in $Global:RecordedConnections) {
        $localPorts = ($conn.LocalPorts | Sort-Object) -join ', '
        $remotePorts = if ($conn.Type -eq 'UDP') { 'N/A' } else { ($conn.RemotePorts | Sort-Object) -join ', ' }
        if ($conn.LocalPortsOmitted) { $localPorts += ', ... (weitere Ports nicht gespeichert)' }
        if ($conn.RemotePortsOmitted) { $remotePorts += ', ... (weitere Ports nicht gespeichert)' }
        "<tr><td>$(ConvertTo-HtmlSafe $conn.Type)</td><td>$(ConvertTo-HtmlSafe $conn.LocalAddress)</td><td>$(ConvertTo-HtmlSafe $localPorts)</td><td>$(ConvertTo-HtmlSafe $conn.RemoteAddress)</td><td>$(ConvertTo-HtmlSafe $remotePorts)</td><td>$(ConvertTo-HtmlSafe $conn.RemoteHostname)</td><td>$(ConvertTo-HtmlSafe $conn.State)</td><td>$(ConvertTo-HtmlSafe $conn.Count)</td><td>$(ConvertTo-HtmlSafe $conn.FirstSeen.ToString('dd.MM.yyyy HH:mm:ss'))</td><td>$(ConvertTo-HtmlSafe $conn.LastSeen.ToString('dd.MM.yyyy HH:mm:ss'))</td><td>$(ConvertTo-HtmlSafe $conn.Protocols)</td></tr>"
    }
    $html += ($rows -join "`n")

    $html += @"
            </tbody>
        </table>
    </div>
    <div class="footer">
        <p>Copyright © $(Get-Date -Format "yyyy") | Autor: Andreas Hepp | Webseite: <a href="https://www.phinit.de">www.phinit.de</a> / <a href="https://www.psscripts.de">www.psscripts.de</a></p>
        <p>Generiert mit $($script:AppName) v$($script:AppVersion) - Kontinuierliche Aufzeichnung</p>
    </div>
</body>
</html>
"@
    return $html
}

function Export-RecordingReportHTML {
    $html = Get-RecordingReportHTML
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "HTML files (*.html)|*.html"
    $saveFileDialog.Title = "Aufzeichnungs-Report speichern"
    $saveFileDialog.FileName = "RecordingReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $html | Out-File -FilePath $saveFileDialog.FileName -Encoding UTF8
        [System.Windows.MessageBox]::Show("Aufzeichnungs-Report gespeichert: $($saveFileDialog.FileName)", "Erfolg", "OK", "Information")
    }
}

# Function to export HTML report
function Export-HTMLReport {
    param(
        [Parameter(Mandatory=$true)]$connections,
        [Parameter(Mandatory=$true)][string]$protocol,
        [Parameter(Mandatory=$true)][string]$direction,
        [Parameter(Mandatory=$false)][string]$category = "Alle Kategorien"
    )

    $DateTimeNow = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
    $totalConnections = $connections.Count
    $tcpCount = @($connections | Where-Object { $_.Type -eq "TCP" }).Count
    $udpCount = @($connections | Where-Object { $_.Type -eq "UDP" }).Count
    $computerName = ConvertTo-HtmlSafe $env:COMPUTERNAME
    $userName = ConvertTo-HtmlSafe $env:USERNAME
    $protocol = ConvertTo-HtmlSafe $protocol
    $direction = ConvertTo-HtmlSafe $direction
    $category = ConvertTo-HtmlSafe $category

    $html = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Network Connections Report - Connections_Audit</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f3f3f3; color: #333; }
        .container { max-width: 1400px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #0078D4; padding-bottom: 20px; }
        h1 { color: #0078D4; margin: 0; font-size: 2.5em; }
        .subtitle { color: #666; font-size: 1.2em; margin: 10px 0; }
        .info-box { background-color: #e6f3ff; padding: 15px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid #0078D4; }
        .summary { display: flex; justify-content: space-around; margin-bottom: 20px; }
        .summary-item { text-align: center; background: #f8f9fa; padding: 10px; border-radius: 4px; }
        .timestamp { text-align: center; color: #666; margin-bottom: 20px; font-style: italic; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; font-size: 14px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #0078D4; color: white; font-weight: bold; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #e6f3ff; }
        .footer { text-align: center; margin-top: 30px; color: #666; border-top: 1px solid #ddd; padding-top: 20px; }
        .footer p { margin: 5px 0; }
        .footer a { color: #0078D4; text-decoration: none; }
        .footer a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Network Connections Report</h1>
            <div class="subtitle">Connections_Audit Tool</div>
            <div class="info-box">
                <strong>Computer:</strong> $computerName | <strong>Benutzer:</strong> $userName<br>
                <strong>Filter:</strong> Kategorie: $category | Protokoll: $protocol | Richtung: $direction
            </div>
        </div>
        <div class="summary">
            <div class="summary-item">
                <strong>Gesamt</strong><br>$totalConnections
            </div>
            <div class="summary-item">
                <strong>TCP</strong><br>$tcpCount
            </div>
            <div class="summary-item">
                <strong>UDP</strong><br>$udpCount
            </div>
        </div>
        <div class="timestamp">Erstellt am $DateTimeNow</div>
        <table>
            <thead>
                <tr>
                    <th>Typ</th>
                    <th>Lokale Adresse</th>
                    <th>Lokaler Port</th>
                    <th>Remote Adresse</th>
                    <th>Remote Port</th>
                    <th>Remote Hostname</th>
                    <th>Status</th>
                    <th>Prozess ID</th>
                    <th>Prozess Name</th>
                </tr>
            </thead>
            <tbody>
"@

    $rows = foreach ($conn in $connections) {
        $processName = if ($conn.ProcessName) { $conn.ProcessName } else { "N/A" }
        "<tr><td>$(ConvertTo-HtmlSafe $conn.Type)</td><td>$(ConvertTo-HtmlSafe $conn.LocalAddress)</td><td>$(ConvertTo-HtmlSafe $conn.LocalPort)</td><td>$(ConvertTo-HtmlSafe $conn.RemoteAddress)</td><td>$(ConvertTo-HtmlSafe $conn.RemotePort)</td><td>$(ConvertTo-HtmlSafe $conn.RemoteHostname)</td><td>$(ConvertTo-HtmlSafe $conn.State)</td><td>$(ConvertTo-HtmlSafe $conn.OwningProcess)</td><td>$(ConvertTo-HtmlSafe $processName)</td></tr>"
    }
    $html += ($rows -join "`n")

    $html += @"
            </tbody>
        </table>
    </div>
    <div class="footer">
        <p>Copyright © $(Get-Date -Format "yyyy") | Autor: Andreas Hepp | Webseite: <a href="https://www.phinit.de">www.phinit.de</a> / <a href="https://www.psscripts.de">www.psscripts.de</a></p>
        <p>Generiert mit $($script:AppName) v$($script:AppVersion)</p>
    </div>
</body>
</html>
"@

    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "HTML files (*.html)|*.html"
    $saveFileDialog.Title = "HTML Report speichern"
    $saveFileDialog.FileName = "NetworkConnectionsReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $html | Out-File -FilePath $saveFileDialog.FileName -Encoding UTF8
        [System.Windows.MessageBox]::Show("HTML Report gespeichert: $($saveFileDialog.FileName)", "Erfolg", "OK", "Information")
    }
}

# Event handlers
$btnRefresh.Add_Click({
    if ($Global:RecordingView) {
        Update-RecordingView
        return
    }
    try {
        $originalText = $btnRefresh.Content
        $btnRefresh.Content = "Lädt..."
        $btnRefresh.IsEnabled = $false
        
        $selectedProtocol = $cmbProtocol.SelectedItem.Content
        $selectedDirection = $cmbDirection.SelectedItem.Content
        $selectedCategory = $cmbCategory.SelectedItem.Content
        $showProcessInfo = $chkShowProcessInfo.IsChecked
        $networkType = $cmbNetworkType.SelectedItem.Content
        $tcpUdpType = $cmbTCPUDP.SelectedItem.Content
        
        $connections = Get-NetworkConnections -protocol $selectedProtocol -direction $selectedDirection -category $selectedCategory -includeProcessInfo $showProcessInfo -networkType $networkType -tcpUdpType $tcpUdpType
        
        # Ensure connections is always an array
        if ($connections -is [System.Management.Automation.PSCustomObject]) {
            $connections = @($connections)
        } elseif ($null -eq $connections) {
            $connections = @()
        }
        
        $dgConnections.ItemsSource = [System.Collections.ArrayList]@($connections)
        Update-ConnectionCounters
        
        Update-StatusBar "Verbindungen geladen: $($connections.Count) gefunden | Protokoll: $selectedProtocol | Richtung: $selectedDirection | Kategorie: $selectedCategory | Netzwerk: $networkType | TCP/UDP: $tcpUdpType"
    } catch {
        Update-StatusBar "Fehler beim Laden der Verbindungen: $($_.Exception.Message)" -State Error
        [System.Windows.MessageBox]::Show("Fehler beim Laden der Verbindungen: $($_.Exception.Message)", "Fehler", "OK", "Error") | Out-Null
    } finally {
        $btnRefresh.Content = $originalText
        $btnRefresh.IsEnabled = $true
    }
})

$btnShowLive.Add_Click({
    if ($Global:RecordingActive) { return }
    $Global:RecordingView = $false
    Update-RecordingView
    $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
})

# Checkbox event handler for process info visibility
# Checked/Unchecked statt Click: greift auch, wenn ein Preset die Option per Code setzt
$chkShowProcessInfo.Add_Checked({ Update-ProcessColumnsVisibility -showProcessInfo $true })
$chkShowProcessInfo.Add_Unchecked({ Update-ProcessColumnsVisibility -showProcessInfo $false })

# Recording button event
$btnStartRecording.Add_Click({
    if ($Global:RecordingActive) {
        Stop-ConnectionRecording
    } else {
        Start-ConnectionRecording
    }
})

# Export HTML button event
$btnExportHTML.Add_Click({
    if ($Global:RecordingView) {
        Export-RecordingReportHTML
        return
    }
    if ($dgConnections.ItemsSource.Count -eq 0) {
        [System.Windows.MessageBox]::Show("Keine Verbindungen zum Exportieren. Bitte klicken Sie zuerst auf 'Aktualisieren'.", "Information", "OK", "Information")
        return
    }
    
    $selectedProtocol = $cmbProtocol.SelectedItem.Content
    $selectedDirection = $cmbDirection.SelectedItem.Content
    $selectedCategory = $cmbCategory.SelectedItem.Content
    $connections = $dgConnections.ItemsSource
    Export-HTMLReport -connections $connections -protocol $selectedProtocol -direction $selectedDirection -category $selectedCategory
})

# Preset Functions
function Import-FilterPresets {
    # Initialize with default presets
    $defaultPresets = @{
        "Web-Debugging" = @{
            Protocol = "HTTP"
            Direction = "Beide"
            Category = "Web Services"
            NetworkType = "Alle Netzwerke"
            TCPUDPType = "Nur TCP"
            ProcessInfo = $true
        }
        "Datenbank-Monitor" = @{
            Protocol = "Alle"
            Direction = "Beide"
            Category = "Database Services"
            NetworkType = "Alle Netzwerke"
            TCPUDPType = "Nur TCP"
            ProcessInfo = $true
        }
        "Security-Audit" = @{
            Protocol = "Alle"
            Direction = "Beide"
            Category = "Alle Kategorien"
            NetworkType = "Nur Public"
            TCPUDPType = "Nur TCP"
            ProcessInfo = $true
        }
        "Interne Services" = @{
            Protocol = "Alle"
            Direction = "Beide"
            Category = "Alle Kategorien"
            NetworkType = "Nur Private"
            TCPUDPType = "Nur TCP"
            ProcessInfo = $true
        }
        "Externe Verbindungen" = @{
            Protocol = "Alle"
            Direction = "Beide"
            Category = "Alle Kategorien"
            NetworkType = "Nur Public"
            TCPUDPType = "TCP + UDP"
            ProcessInfo = $true
        }
        "DNS Monitoring" = @{
            Protocol = "DNS"
            Direction = "Beide"
            Category = "Monitoring"
            NetworkType = "Alle Netzwerke"
            TCPUDPType = "Nur UDP"
            ProcessInfo = $true
        }
        "Email Services" = @{
            Protocol = "SMTP"
            Direction = "Beide"
            Category = "Email Services"
            NetworkType = "Alle Netzwerke"
            TCPUDPType = "Nur TCP"
            ProcessInfo = $true
        }
    }
    
    # Load saved presets from JSON file
    if (Test-Path -LiteralPath $Global:PresetsFile) {
        try {
            # Kompatibel zu Windows PowerShell 5.1 (ConvertFrom-Json -AsHashtable erst ab PS 6)
            $jsonContent = Get-Content -LiteralPath $Global:PresetsFile -Raw -Encoding UTF8 -ErrorAction Stop
            $savedPresets = @{}
            if (-not [string]::IsNullOrWhiteSpace($jsonContent)) {
                $jsonObject = $jsonContent | ConvertFrom-Json -ErrorAction Stop
                foreach ($prop in $jsonObject.PSObject.Properties) {
                    # Nur Objekt-Einträge übernehmen (ungültige Einträge werden ignoriert)
                    if ($prop.Value -is [System.Management.Automation.PSCustomObject]) {
                        $presetEntry = @{}
                        foreach ($presetProp in $prop.Value.PSObject.Properties) {
                            $presetEntry[$presetProp.Name] = $presetProp.Value
                        }
                        $savedPresets[$prop.Name] = $presetEntry
                    }
                }
            }
            
            # Start with default presets
            $Global:FilterPresets = [hashtable]$defaultPresets
            
            # Add or override with saved presets (custom user presets)
            foreach ($key in $savedPresets.Keys) {
                $Global:FilterPresets[$key] = $savedPresets[$key]
            }
        } catch {
            # If JSON loading fails, use defaults (vorhandene Datei nicht überschreiben, um Benutzer-Presets zu erhalten)
            Write-Log "Presets could not be loaded: $($_.Exception.Message)"
            $Global:FilterPresets = [hashtable]$defaultPresets
        }
    } else {
        # Use defaults and save them
        $Global:FilterPresets = [hashtable]$defaultPresets
        $null = Export-FilterPresets
    }
}

function Export-FilterPresets {
    try {
        $Global:FilterPresets | ConvertTo-Json -Depth 5 | Out-File -LiteralPath $Global:PresetsFile -Encoding UTF8 -ErrorAction Stop
        return $true
    } catch {
        Write-Log "Presets could not be saved: $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show("Presets konnten nicht gespeichert werden ($Global:PresetsFile): $($_.Exception.Message)", "Fehler", "OK", "Error") | Out-Null
        return $false
    }
}

function Get-CurrentFilterState {
    return @{
        Protocol = $cmbProtocol.SelectedItem.Content
        Direction = $cmbDirection.SelectedItem.Content
        Category = $cmbCategory.SelectedItem.Content
        NetworkType = $cmbNetworkType.SelectedItem.Content
        TCPUDPType = $cmbTCPUDP.SelectedItem.Content
        ProcessInfo = $chkShowProcessInfo.IsChecked
    }
}

function Set-FilterPreset {
    param([hashtable]$preset)
    if ($Global:RecordingActive) { return }
    
    # Apply preset values to UI
    for ($i = 0; $i -lt $cmbProtocol.Items.Count; $i++) {
        if ($cmbProtocol.Items[$i].Content -eq $preset.Protocol) {
            $cmbProtocol.SelectedIndex = $i
            break
        }
    }
    for ($i = 0; $i -lt $cmbDirection.Items.Count; $i++) {
        if ($cmbDirection.Items[$i].Content -eq $preset.Direction) {
            $cmbDirection.SelectedIndex = $i
            break
        }
    }
    for ($i = 0; $i -lt $cmbCategory.Items.Count; $i++) {
        if ($cmbCategory.Items[$i].Content -eq $preset.Category) {
            $cmbCategory.SelectedIndex = $i
            break
        }
    }
    for ($i = 0; $i -lt $cmbNetworkType.Items.Count; $i++) {
        if ($cmbNetworkType.Items[$i].Content -eq $preset.NetworkType) {
            $cmbNetworkType.SelectedIndex = $i
            break
        }
    }
    for ($i = 0; $i -lt $cmbTCPUDP.Items.Count; $i++) {
        if ($cmbTCPUDP.Items[$i].Content -eq $preset.TCPUDPType) {
            $cmbTCPUDP.SelectedIndex = $i
            break
        }
    }
    $chkShowProcessInfo.IsChecked = $preset.ProcessInfo
    
    # Automatically refresh with new filters
    $btnRefresh.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
}

# Load saved presets
Import-FilterPresets

# Function to populate presets in ComboBox
function Update-PresetsComboBox {
    # Clear existing items except "-- Neues Preset --"
    while ($cmbPresets.Items.Count -gt 1) {
        $cmbPresets.Items.RemoveAt($cmbPresets.Items.Count - 1)
    }
    
    # Add all presets to ComboBox
    foreach ($presetName in $Global:FilterPresets.Keys | Sort-Object) {
        $item = New-Object System.Windows.Controls.ComboBoxItem
        $item.Content = $presetName
        $cmbPresets.Items.Add($item) | Out-Null
    }
}

# Populate presets in ComboBox
Update-PresetsComboBox

# Preset Button Event Handlers
$btnLoadPreset.Add_Click({
    $selectedPresetName = $cmbPresets.SelectedItem.Content
    
    if ([string]::IsNullOrEmpty($selectedPresetName) -or $selectedPresetName -eq "-- Neues Preset --") {
        [System.Windows.MessageBox]::Show("Bitte wählen Sie ein Preset aus der Liste.", "Information", "OK", "Information")
        return
    }
    
    if ($Global:FilterPresets.ContainsKey($selectedPresetName)) {
        Set-FilterPreset -preset $Global:FilterPresets[$selectedPresetName]
        Update-StatusBar "Preset geladen: $selectedPresetName"
    } else {
        [System.Windows.MessageBox]::Show("Preset '$selectedPresetName' nicht gefunden.", "Fehler", "OK", "Error")
    }
})

$btnSavePreset.Add_Click({
    $inputBox = [Microsoft.VisualBasic.Interaction]::InputBox("Geben Sie einen Namen für das Preset ein:", "Preset speichern")
    
    if ([string]::IsNullOrWhiteSpace($inputBox) -or $inputBox -eq "-- Neues Preset --") {
        return
    }
    
    $currentFilters = Get-CurrentFilterState
    $Global:FilterPresets[$inputBox] = $currentFilters
    if (-not (Export-FilterPresets)) {
        return
    }
    
    # Add to ComboBox
    if (-not ($cmbPresets.Items | Where-Object { $_.Content -eq $inputBox })) {
        $cmbPresets.Items.Add((New-Object System.Windows.Controls.ComboBoxItem -Property @{ Content = $inputBox }))
    }
    
    Update-StatusBar "Preset gespeichert: $inputBox"
    [System.Windows.MessageBox]::Show("Preset '$inputBox' wurde gespeichert.", "Erfolg", "OK", "Information")
})

$btnDeletePreset.Add_Click({
    $selectedPresetName = $cmbPresets.SelectedItem.Content
    
    if ([string]::IsNullOrEmpty($selectedPresetName) -or $selectedPresetName -eq "-- Neues Preset --") {
        [System.Windows.MessageBox]::Show("Bitte wählen Sie ein Preset zum Löschen aus.", "Information", "OK", "Information")
        return
    }
    
    $result = [System.Windows.MessageBox]::Show("Möchten Sie das Preset '$selectedPresetName' wirklich löschen?", "Bestätigung", "YesNo", "Question")
    
    if ($result -eq "Yes") {
        $Global:FilterPresets.Remove($selectedPresetName)
        $null = Export-FilterPresets
        
        # Remove from ComboBox
        for ($i = 0; $i -lt $cmbPresets.Items.Count; $i++) {
            if ($cmbPresets.Items[$i].Content -eq $selectedPresetName) {
                $cmbPresets.Items.RemoveAt($i)
                break
            }
        }
        
        $cmbPresets.SelectedIndex = 0
        Update-StatusBar "Preset gelöscht: $selectedPresetName"
    }
})

# Hilfe
$btnHelp.Add_Click({
    $helpText = @"
$($script:AppName) - Kurzanleitung

1. Links unter 'Filter' Netzwerk, Protokoll, Richtung, Kategorie und Service wählen.
2. '🔄 Aktualisieren' lädt die aktuellen Verbindungen (Zeilenfarbe = Kategorie).
3. '⏺ Aufzeichnung starten': eine Zeile je Remote-IP mit Anzahl neu beobachteter
   TCP-Sockets, Ports und erster/letzter Sichtung. Filter bleiben fest.
   Dauerhaft sichtbare Sockets zählen einmal; nach Verschwinden erneut.
   UDP: nur lokale Endpunkte, keine Remote-Clients / Verbindungsanzahl.
   Beim Stoppen wird ein HTML-Report angeboten; die Tabelle bleibt erhalten.
4. '📊 HTML Export' speichert die angezeigte Live-Liste bzw. Aufzeichnung.
   'Live-Ansicht laden' verlässt die Zusammenfassung nach dem Stoppen.
5. Unter 'Presets' Filterkombinationen laden, speichern oder löschen (presets.json).

Exchange-Beispiel: Nur TCP, Eingehend, Alle Kategorien, SMTP 25 + POP3S 995.
Grenzen: 10.000 IP-/Endpunktzeilen und 50.000 aktuelle TCP-Sockets.
Bei Überschreitung / Abfragefehler: expliziter Stopp (rot), HTML Export bleibt möglich.
3-Sekunden-Polling (zzgl. Abfragedauer) kann kurze Verbindungen verpassen und
zählt keine Mails oder Requests. Dienste sind aus Ports abgeleitet.
Port-Historie: maximal 64 verschiedene Ports je IP und Seite, weitere Ports
werden als ausgelassen markiert; TCP-Zählung und Diensterkennung laufen weiter.
Tabelle: bis 16 Werte als Vorschau; HTML: alle bis zu 64 gespeicherten Ports.
Aufzeichnung ohne DNS-/Prozessabfragen; Live-Ansicht weiterhin mit Lazy Loading.
Hostname-Cache: maximal 10.000 Einträge; danach IP statt neuer DNS-Auflösung.
"@
    [System.Windows.MessageBox]::Show($window, $helpText, "$($script:AppName) - Hilfe", 'OK', 'Information') | Out-Null
})

# Info
$btnAbout.Add_Click({
    $aboutText = @"
$($script:AppName)
Netzwerkverbindungs-Monitor mit WPF-Oberfläche

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
        Update-StatusBar "Website konnte nicht geöffnet werden: $($_.Exception.Message)" -State Error
    }
})

# Prozess-Spalten entsprechend der Checkbox initialisieren (vorher waren sie beim Start leer sichtbar)
Update-ProcessColumnsVisibility -showProcessInfo ([bool]$chkShowProcessInfo.IsChecked)

# Timer beim Schließen des Fensters sauber beenden
$window.Add_Closing({
    if ($Global:RecordingTimer) {
        $Global:RecordingTimer.Stop()
        $Global:RecordingTimer = $null
    }
    $Global:RecordingActive = $false
})

# Show window
$window.ShowDialog() | Out-Null

Write-Log "Application closed"
