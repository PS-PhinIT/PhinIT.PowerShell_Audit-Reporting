<#
================================================================================
    WindowsServer_Audit - Windows Server Audit Tool
    Version: 0.4.5
    
    Beschreibung:
    Umfassendes Server-Audit-Tool mit moderner WPF-GUI.
    Bietet detaillierte Analysen von Systemkonfiguration, Sicherheit, Diensten,
    Rollen und Replikation mit Export-Funktionen (CSV, HTML).
    
    Design: einheitliche PhinIT-Oberfläche (Vorlage ActiveDirectory_Audit) – dunkle Kopf-/Fußzeile,
            Sidebar mit Audit-Kategorien (links), Ergebnis-Karte (rechts)
    
================================================================================
#>

# Name, Version und Stand zentral – werden in Fenstertitel, Kopf-/Fußzeile, Info-Dialog und HTML-Report verwendet
$script:AppName    = 'WindowsServer_Audit'
$script:AppVersion = '0.4.5'
$script:AppDate    = '14.10.2026'

[xml]$Global:XAML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    Title="$($script:AppName) v$($script:AppVersion)"
    Width="1850"
    Height="1000"
    Background="#F8FAFC"
    FontFamily="Segoe UI"
    ResizeMode="CanResizeWithGrip"
    WindowStartupLocation="CenterScreen">

    <!--  Window Resources for Modern Styling  -->
    <Window.Resources>
        <!--  Modern Card Style  -->
        <Style x:Key="ModernCard" TargetType="Border">
            <Setter Property="Background" Value="White" />
            <Setter Property="CornerRadius" Value="6" />
            <Setter Property="BorderThickness" Value="1" />
            <Setter Property="BorderBrush" Value="#E5E7EB" />
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
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
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

        <!--  Category Header Style  -->
        <Style x:Key="CategoryHeader" TargetType="TextBlock">
            <Setter Property="FontSize" Value="14" />
            <Setter Property="FontWeight" Value="SemiBold" />
            <Setter Property="Foreground" Value="#1F2937" />
            <Setter Property="Margin" Value="0,8,0,4" />
        </Style>

        <!--  Sidebar Menu Button Style  -->
        <Style x:Key="SidebarButton" TargetType="Button">
            <Setter Property="Background" Value="Transparent" />
            <Setter Property="BorderThickness" Value="0" />
            <Setter Property="Padding" Value="12,8" />
            <Setter Property="FontWeight" Value="Normal" />
            <Setter Property="FontSize" Value="13" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="HorizontalAlignment" Value="Stretch" />
            <Setter Property="HorizontalContentAlignment" Value="Left" />
            <Setter Property="Margin" Value="0,1" />
            <Setter Property="Foreground" Value="#374151" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="border"
                            Padding="{TemplateBinding Padding}"
                            Background="{TemplateBinding Background}"
                            CornerRadius="3">
                            <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#F3F4F6" />
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#E5E7EB" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!--  Active Sidebar Button Style  -->
        <Style
            x:Key="SidebarButtonActive"
            BasedOn="{StaticResource SidebarButton}"
            TargetType="Button">
            <Setter Property="Background" Value="#EEF2FF" />
            <Setter Property="Foreground" Value="#6366F1" />
            <Setter Property="FontWeight" Value="Medium" />
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

                <!--  Results Counter + Help/About  -->
                <StackPanel
                    Grid.Column="1"
                    VerticalAlignment="Center"
                    Orientation="Horizontal">
                    <StackPanel Orientation="Vertical" Background="#FF4C5B73" Height="49" Width="90">
                        <TextBlock Text="Results" FontSize="12" Foreground="#FFC1FFDB" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                        <TextBlock x:Name="TotalResultCountText" Text="0" FontSize="18" FontWeight="Bold" Foreground="#FFEAEAEA" HorizontalAlignment="Center" TextAlignment="Center"/>
                    </StackPanel>
                    <Button x:Name="ButtonHelp" Content="Help" Width="70" Height="30" Margin="16,0,0,0" Background="#4B5563" Foreground="#F9FAFB" BorderBrush="#6B7280" Cursor="Hand" ToolTip="Hilfe und Kurzanleitung anzeigen"/>
                    <Button x:Name="ButtonAbout" Content="About" Width="70" Height="30" Margin="6,0,0,0" Background="#4B5563" Foreground="#F9FAFB" BorderBrush="#6B7280" Cursor="Hand" ToolTip="Versions- und Programminformationen"/>
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

            <!--  Modern Sidebar with Categorized Reports  -->
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
                        <!--  Sidebar Header  -->
                        <Grid Margin="0,0,0,16">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto" />
                                <RowDefinition Height="Auto" />
                            </Grid.RowDefinitions>
                            <TextBlock
                                Grid.Row="0"
                                Margin="0,0,0,8"
                                FontSize="16"
                                FontWeight="Bold"
                                Foreground="#374151"
                                Text="📊 Audit Reports" />
                        </Grid>

                        <!--  System Information  -->
                        <Expander
                            Header="🖥️ System Information"
                            IsExpanded="True"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonSystemInfo" Content="System Overview" Style="{StaticResource SidebarButton}" ToolTip="Retrieve system information" />
                                <Button x:Name="ButtonOSInfo" Content="OS Details" Style="{StaticResource SidebarButton}" ToolTip="Get operating system details" />
                                <Button x:Name="ButtonHardwareInfo" Content="Hardware Summary" Style="{StaticResource SidebarButton}" ToolTip="Display hardware information" />
                                <Button x:Name="ButtonCPUInfo" Content="CPU Details" Style="{StaticResource SidebarButton}" ToolTip="CPU specifications" />
                                <Button x:Name="ButtonMemoryInfo" Content="Memory Details" Style="{StaticResource SidebarButton}" ToolTip="Memory information" />
                                <Button x:Name="ButtonStorageInfo" Content="Storage Summary" Style="{StaticResource SidebarButton}" ToolTip="Disk and volume information" />
                            </StackPanel>
                        </Expander>

                        <!--  Network Configuration  -->
                        <Expander
                            Header="🌐 Network Configuration"
                            IsExpanded="True"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonNetConfig" Content="IP Configuration" Style="{StaticResource SidebarButton}" ToolTip="Network IP settings" />
                                <Button x:Name="ButtonNetAdapters" Content="Network Adapters" Style="{StaticResource SidebarButton}" ToolTip="Network adapter status" />
                                <Button x:Name="ButtonTCPConnections" Content="Active Connections" Style="{StaticResource SidebarButton}" ToolTip="Listen ports and connections" />
                                <Button x:Name="ButtonFirewallRules" Content="Firewall Rules" Style="{StaticResource SidebarButton}" ToolTip="Active firewall rules" />
                                <Button x:Name="ButtonFirewallProfiles" Content="Firewall Profiles" Style="{StaticResource SidebarButton}" ToolTip="Firewall profile status and default actions" />
                            </StackPanel>
                        </Expander>

                        <!--  Services & Tasks  -->
                        <Expander
                            Header="⚙️ Services &amp; Tasks"
                            IsExpanded="True"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonAutomaticServices" Content="Automatic Services" Style="{StaticResource SidebarButton}" ToolTip="Services set to automatic" />
                                <Button x:Name="ButtonRunningServices" Content="Running Services" Style="{StaticResource SidebarButton}" ToolTip="Currently running services" />
                                <Button x:Name="ButtonScheduledTasks" Content="Scheduled Tasks" Style="{StaticResource SidebarButton}" ToolTip="Ready scheduled tasks" />
                            </StackPanel>
                        </Expander>

                        <!--  Roles &amp; Features  -->
                        <Expander
                            Header="📦 Roles &amp; Features"
                            IsExpanded="True"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonInstalledFeatures" Content="Installed Features" Style="{StaticResource SidebarButton}" ToolTip="Windows features in use" />
                                <Button x:Name="ButtonInstalledPrograms" Content="Installed Programs" Style="{StaticResource SidebarButton}" ToolTip="Software inventory" />
                                <Button x:Name="ButtonWindowsUpdates" Content="Recent Updates" Style="{StaticResource SidebarButton}" ToolTip="Latest Windows patches" />
                                <Button x:Name="ButtonServerBackup" Content="Windows Server Backup" Style="{StaticResource SidebarButton}" ToolTip="Windows Server Backup sets" />
                            </StackPanel>
                        </Expander>

                        <!--  PKI / Certificates  -->
                        <Expander
                            Header="🔐 PKI &amp; Certificates"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonInstalledCertificates" Content="Installed Certificates" Style="{StaticResource SidebarButton}" ToolTip="Local machine certificates" />
                                <Button x:Name="ButtonCertificateAuthorities" Content="Certificate Authorities" Style="{StaticResource SidebarButton}" ToolTip="Root and intermediate CAs" />
                                <Button x:Name="ButtonExpiringCertificates" Content="Expiring Certificates" Style="{StaticResource SidebarButton}" ToolTip="Certificates expiring in 90 days" />
                            </StackPanel>
                        </Expander>

                        <!--  IIS  -->
                        <Expander
                            Header="🌐 IIS Web Server"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonIISWebsites" Content="Websites" Style="{StaticResource SidebarButton}" ToolTip="IIS websites" />
                                <Button x:Name="ButtonIISAppPools" Content="Application Pools" Style="{StaticResource SidebarButton}" ToolTip="App pool configuration" />
                                <Button x:Name="ButtonIISBindings" Content="SSL Bindings" Style="{StaticResource SidebarButton}" ToolTip="SSL certificates and bindings" />
                            </StackPanel>
                        </Expander>

                        <!--  RDS / WTS  -->
                        <Expander
                            Header="🖥️ Remote Desktop Services"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonRDSCollections" Content="Session Collections" Style="{StaticResource SidebarButton}" ToolTip="RDS session collections" />
                                <Button x:Name="ButtonRDSSessionHosts" Content="Session Hosts" Style="{StaticResource SidebarButton}" ToolTip="RDS session hosts" />
                                <Button x:Name="ButtonRDSLicensing" Content="RDS Licensing" Style="{StaticResource SidebarButton}" ToolTip="RDS licensing configuration" />
                            </StackPanel>
                        </Expander>

                        <!--  DFS  -->
                        <Expander
                            Header="🔀 Distributed File System"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonDFSNamespaces" Content="DFS Namespaces" Style="{StaticResource SidebarButton}" ToolTip="DFS namespace configuration" />
                                <Button x:Name="ButtonDFSReplication" Content="Replication Groups" Style="{StaticResource SidebarButton}" ToolTip="DFS replication groups" />
                            </StackPanel>
                        </Expander>

                        <!--  Print Server  -->
                        <Expander
                            Header="🖨️ Print Server"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonPrinters" Content="Printers" Style="{StaticResource SidebarButton}" ToolTip="Print server printers" />
                                <Button x:Name="ButtonPrinterDrivers" Content="Printer Drivers" Style="{StaticResource SidebarButton}" ToolTip="Installed printer drivers" />
                            </StackPanel>
                        </Expander>

                        <!--  WSUS  -->
                        <Expander
                            Header="🔄 WSUS (Update Services)"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonWSUSConfig" Content="WSUS Configuration" Style="{StaticResource SidebarButton}" ToolTip="WSUS server configuration" />
                                <Button x:Name="ButtonWSUSGroups" Content="Computer Groups" Style="{StaticResource SidebarButton}" ToolTip="WSUS computer target groups" />
                                <Button x:Name="ButtonWSUSUpdates" Content="Available Updates" Style="{StaticResource SidebarButton}" ToolTip="Available updates in WSUS" />
                            </StackPanel>
                        </Expander>

                        <!--  Hyper-V  -->
                        <Expander
                            Header="🔧 Hyper-V Virtualization"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonHyperVVMs" Content="Virtual Machines" Style="{StaticResource SidebarButton}" ToolTip="Hyper-V virtual machines" />
                                <Button x:Name="ButtonHyperVSwitches" Content="Virtual Switches" Style="{StaticResource SidebarButton}" ToolTip="Hyper-V virtual network switches" />
                                <Button x:Name="ButtonHyperVSnapshots" Content="Snapshots" Style="{StaticResource SidebarButton}" ToolTip="VM snapshots" />
                            </StackPanel>
                        </Expander>

                        <!--  NRAS / NPS  -->
                        <Expander
                            Header="🔒 Network Access Protection"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonNPASConfig" Content="NRAS/NPS Configuration" Style="{StaticResource SidebarButton}" ToolTip="Network Policy Server configuration" />
                                <Button x:Name="ButtonNASClients" Content="RADIUS NAS Clients" Style="{StaticResource SidebarButton}" ToolTip="RADIUS network access servers" />
                            </StackPanel>
                        </Expander>

                        <!--  KMS (Volume Activation)  -->
                        <Expander
                            Header="🔑 KMS (Volume Activation)"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonKMSConfig" Content="KMS Configuration" Style="{StaticResource SidebarButton}" ToolTip="Key Management Service configuration" />
                            </StackPanel>
                        </Expander>

                        <!--  WDS (Windows Deployment)  -->
                        <Expander
                            Header="📦 WDS (Deployment Services)"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonWDSConfig" Content="WDS Configuration" Style="{StaticResource SidebarButton}" ToolTip="Windows Deployment Services configuration" />
                                <Button x:Name="ButtonWDSBootImages" Content="Boot Images" Style="{StaticResource SidebarButton}" ToolTip="WDS boot images" />
                                <Button x:Name="ButtonWDSInstallImages" Content="Install Images" Style="{StaticResource SidebarButton}" ToolTip="WDS install images" />
                            </StackPanel>
                        </Expander>

                        <!--  Server Applications  -->
                        <Expander
                            Header="🏢 Server Applications"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonSQLServer" Content="SQL Server" Style="{StaticResource SidebarButton}" ToolTip="SQL Server services (all instances)" />
                                <Button x:Name="ButtonExchange" Content="Exchange Server" Style="{StaticResource SidebarButton}" ToolTip="Exchange services" />
                                <Button x:Name="ButtonSharePoint" Content="SharePoint" Style="{StaticResource SidebarButton}" ToolTip="SharePoint services" />
                            </StackPanel>
                        </Expander>

                        <!--  File Services &amp; SMB  -->
                        <Expander
                            Header="📁 File Services (SMB)"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonFileShares" Content="File Shares" Style="{StaticResource SidebarButton}" ToolTip="SMB file shares" />
                                <Button x:Name="ButtonSharePermissions" Content="Share Permissions" Style="{StaticResource SidebarButton}" ToolTip="Share ACLs and permissions" />
                                <Button x:Name="ButtonFileQuotas" Content="File Quotas (FSRM)" Style="{StaticResource SidebarButton}" ToolTip="File Server Resource Manager quotas" />
                                <Button x:Name="ButtonShadowCopies" Content="Shadow Copies" Style="{StaticResource SidebarButton}" ToolTip="Volume shadow copies / snapshots" />
                            </StackPanel>
                        </Expander>

                        <!--  Advanced Active Directory  -->
                        <Expander
                            Header="🌳 AD Advanced Info"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonADDCExtended" Content="Domain Controllers (Extended)" Style="{StaticResource SidebarButton}" ToolTip="Detailed DC information" />
                                <Button x:Name="ButtonADFunctionalLevels" Content="Functional Levels" Style="{StaticResource SidebarButton}" ToolTip="Domain and forest functional levels" />
                                <Button x:Name="ButtonADSites" Content="Sites &amp; Subnets" Style="{StaticResource SidebarButton}" ToolTip="AD sites and subnets configuration" />
                                <Button x:Name="ButtonADGPO" Content="Group Policy Summary" Style="{StaticResource SidebarButton}" ToolTip="GPO overview and statistics" />
                                <Button x:Name="ButtonADClustering" Content="Failover Clustering" Style="{StaticResource SidebarButton}" ToolTip="Failover cluster configuration" />
                                <Button x:Name="ButtonADGroups" Content="Groups" Style="{StaticResource SidebarButton}" ToolTip="AD groups (scope, category)" />
                                <Button x:Name="ButtonADServiceAccounts" Content="Service Accounts (MSA/gMSA)" Style="{StaticResource SidebarButton}" ToolTip="Managed service accounts" />
                                <Button x:Name="ButtonADComputerSummary" Content="Computer Account Summary" Style="{StaticResource SidebarButton}" ToolTip="Computer accounts: enabled, disabled, stale, by OS" />
                                <Button x:Name="ButtonADPasswordPolicy" Content="Password Policy" Style="{StaticResource SidebarButton}" ToolTip="Default domain and fine-grained password policies" />
                                <Button x:Name="ButtonADReplSites" Content="Replication Sites" Style="{StaticResource SidebarButton}" ToolTip="Sites with subnets and domain controllers" />
                                <Button x:Name="ButtonADReplSubnets" Content="Replication Subnets" Style="{StaticResource SidebarButton}" ToolTip="AD subnets and site assignment" />
                                <Button x:Name="ButtonADSiteLinks" Content="Site Links" Style="{StaticResource SidebarButton}" ToolTip="AD site links (cost, interval)" />
                                <Button x:Name="ButtonADOptionalFeatures" Content="Optional Features" Style="{StaticResource SidebarButton}" ToolTip="AD optional features (e.g. Recycle Bin)" />
                                <Button x:Name="ButtonADDCServiceHealth" Content="DC Service Health" Style="{StaticResource SidebarButton}" ToolTip="NTDS, DFSR, DNS, KDC service status per DC" />
                                <Button x:Name="ButtonADDcdiag" Content="DC Diagnostics (dcdiag)" Style="{StaticResource SidebarButton}" ToolTip="dcdiag test results" />
                            </StackPanel>
                        </Expander>

                        <!--  Event Logs  -->
                        <Expander
                            Header="📋 Event Logs"
                            IsExpanded="True"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonSystemEvents" Content="System Events (24h)" Style="{StaticResource SidebarButton}" ToolTip="System event log" />
                                <Button x:Name="ButtonAppEvents" Content="Application Events (24h)" Style="{StaticResource SidebarButton}" ToolTip="Application event log" />
                                <Button x:Name="ButtonSecurityEvents" Content="Security Events (100)" Style="{StaticResource SidebarButton}" ToolTip="Security event log" />
                                <Button x:Name="ButtonFailedLogons" Content="Failed Logon Attempts" Style="{StaticResource SidebarButton}" ToolTip="Event ID 4625" />
                                <Button x:Name="ButtonAccountLockouts" Content="Account Lockouts" Style="{StaticResource SidebarButton}" ToolTip="Event ID 4740" />
                            </StackPanel>
                        </Expander>

                        <!--  Security  -->
                        <Expander
                            Header="🔒 Security &amp; Users"
                            IsExpanded="True"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonLocalUsers" Content="Local Users" Style="{StaticResource SidebarButton}" ToolTip="Local user accounts" />
                                <Button x:Name="ButtonLocalGroups" Content="Local Groups" Style="{StaticResource SidebarButton}" ToolTip="Local group membership" />
                                <Button x:Name="ButtonPrivilegeAudit" Content="Privilege Use Audit" Style="{StaticResource SidebarButton}" ToolTip="Event IDs 4672/4673/4674" />
                                <Button x:Name="ButtonDefender" Content="Microsoft Defender" Style="{StaticResource SidebarButton}" ToolTip="Defender status and signatures" />
                                <Button x:Name="ButtonUAC" Content="UAC Settings" Style="{StaticResource SidebarButton}" ToolTip="User Account Control configuration" />
                            </StackPanel>
                        </Expander>

                        <!--  Active Directory  -->
                        <Expander
                            Header="🌳 Active Directory"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonADDC" Content="Domain Controllers" Style="{StaticResource SidebarButton}" ToolTip="AD domain controller status" />
                                <Button x:Name="ButtonADDomain" Content="Domain Info" Style="{StaticResource SidebarButton}" ToolTip="AD domain properties" />
                                <Button x:Name="ButtonADForest" Content="Forest Info" Style="{StaticResource SidebarButton}" ToolTip="AD forest properties" />
                                <Button x:Name="ButtonADOUs" Content="Organizational Units" Style="{StaticResource SidebarButton}" ToolTip="AD OUs" />
                                <Button x:Name="ButtonADAdmins" Content="Domain Admins" Style="{StaticResource SidebarButton}" ToolTip="Domain admin members" />
                                <Button x:Name="ButtonADComputers" Content="Computer Accounts" Style="{StaticResource SidebarButton}" ToolTip="AD computer objects" />
                                <Button x:Name="ButtonADUsers" Content="User Accounts" Style="{StaticResource SidebarButton}" ToolTip="AD user account overview (enabled, disabled, locked, stale)" />
                                <Button x:Name="ButtonADFSMO" Content="FSMO Roles" Style="{StaticResource SidebarButton}" ToolTip="FSMO role holders" />
                                <Button x:Name="ButtonADReplStatus" Content="Replication Status" Style="{StaticResource SidebarButton}" ToolTip="AD replication status" />
                                <Button x:Name="ButtonADTrusts" Content="Trust Relationships" Style="{StaticResource SidebarButton}" ToolTip="AD domain trusts" />
                            </StackPanel>
                        </Expander>

                        <!--  DNS  -->
                        <Expander
                            Header="🔗 DNS Server"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonDNSConfig" Content="DNS Configuration" Style="{StaticResource SidebarButton}" ToolTip="DNS server settings" />
                                <Button x:Name="ButtonDNSZones" Content="DNS Zones" Style="{StaticResource SidebarButton}" ToolTip="DNS zones" />
                                <Button x:Name="ButtonDNSForwarders" Content="DNS Forwarders" Style="{StaticResource SidebarButton}" ToolTip="DNS forwarders" />
                                <Button x:Name="ButtonDNSCache" Content="DNS Cache" Style="{StaticResource SidebarButton}" ToolTip="DNS cache entries" />
                                <Button x:Name="ButtonDNSRecords" Content="Resource Records" Style="{StaticResource SidebarButton}" ToolTip="DNS resource records (first zones)" />
                                <Button x:Name="ButtonDNSStatistics" Content="Server Statistics" Style="{StaticResource SidebarButton}" ToolTip="DNS server statistics" />
                                <Button x:Name="ButtonDNSScavenging" Content="Scavenging" Style="{StaticResource SidebarButton}" ToolTip="DNS scavenging settings" />
                                <Button x:Name="ButtonDNSSec" Content="DNSSEC Zones" Style="{StaticResource SidebarButton}" ToolTip="DNSSEC signing status per zone" />
                            </StackPanel>
                        </Expander>

                        <!--  DHCP  -->
                        <Expander
                            Header="📡 DHCP Server"
                            IsExpanded="False"
                            Style="{StaticResource ExpanderStyle}">
                            <StackPanel>
                                <Button x:Name="ButtonDHCPConfig" Content="DHCP Configuration" Style="{StaticResource SidebarButton}" ToolTip="DHCP server settings" />
                                <Button x:Name="ButtonDHCPv4Scopes" Content="IPv4 Scopes" Style="{StaticResource SidebarButton}" ToolTip="DHCP IPv4 scopes" />
                                <Button x:Name="ButtonDHCPv6Scopes" Content="IPv6 Scopes" Style="{StaticResource SidebarButton}" ToolTip="DHCP IPv6 scopes" />
                                <Button x:Name="ButtonDHCPReservations" Content="DHCP Reservations" Style="{StaticResource SidebarButton}" ToolTip="DHCP reservations" />
                                <Button x:Name="ButtonDHCPAuthorized" Content="Authorized Servers (AD)" Style="{StaticResource SidebarButton}" ToolTip="DHCP servers authorized in Active Directory" />
                                <Button x:Name="ButtonDHCPLeases" Content="Leases" Style="{StaticResource SidebarButton}" ToolTip="DHCP IPv4 leases" />
                                <Button x:Name="ButtonDHCPOptions" Content="Server Options" Style="{StaticResource SidebarButton}" ToolTip="DHCP IPv4 server options" />
                                <Button x:Name="ButtonDHCPScopeStats" Content="Scope Statistics" Style="{StaticResource SidebarButton}" ToolTip="DHCP IPv4 scope utilization" />
                                <Button x:Name="ButtonDHCPFailover" Content="Failover" Style="{StaticResource SidebarButton}" ToolTip="DHCP failover relationships" />
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
                            Text="Audit Results" />
                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                            <Button
                                x:Name="ButtonExportCSV"
                                Margin="0,0,8,0"
                                Padding="8,4"
                                Content="Export CSV"
                                Style="{StaticResource ModernButton}"
                                ToolTip="Aktuelle Ergebnisse als CSV speichern" />
                            <Button
                                x:Name="ButtonExportHTML"
                                Margin="0,0,8,0"
                                Padding="8,4"
                                Content="Export HTML"
                                Style="{StaticResource ModernButton}"
                                ToolTip="Aktuelle Ergebnisse als HTML-Report speichern" />
                            <Button
                                x:Name="ButtonClearOutput"
                                Padding="8,4"
                                Content="Clear Results"
                                Style="{StaticResource ModernButton}"
                                ToolTip="Ergebnisliste leeren" />
                        </StackPanel>
                    </Grid>

                    <DataGrid
                        x:Name="DataGridResults"
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
                    <TextBlock x:Name="StatusBarText" Text="Ready" FontWeight="Medium" Foreground="#FFFFBBBB" Margin="0,0,16,0" FontSize="16" Height="22" MaxWidth="900" TextTrimming="CharacterEllipsis"/>
                    <ProgressBar
                        x:Name="AuditProgressBar"
                        Width="140"
                        Height="8"
                        VerticalAlignment="Center"
                        Background="#4B5563"
                        BorderThickness="0"
                        Foreground="#6366F1"
                        IsIndeterminate="False"
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

# Add required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Create WPF window
$reader = New-Object System.Xml.XmlNodeReader $Global:XAML
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Get control references
$DataGridResults = $window.FindName("DataGridResults")
$StatusBarText = $window.FindName("StatusBarText")
$TotalResultCountText = $window.FindName("TotalResultCountText")
$AuditProgressBar = $window.FindName("AuditProgressBar")
$StatusIndicator = $window.FindName("StatusIndicator")

# Variables for UI state
$script:ResultsCount = 0
$script:AllResults = @()
$script:CurrentButton = $null
$script:LastAuditTitle = $null

# Hintergrund-Audit (Runspace) – laufender Auftrag, Poll-Timer und alle Audit-Buttons (werden während eines Laufs deaktiviert)
$script:AuditJob = $null
$script:AuditTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:AuditTimer.Interval = [TimeSpan]::FromMilliseconds(250)
$script:NonAuditButtons = @("ButtonExportCSV", "ButtonExportHTML", "ButtonClearOutput", "ButtonHelp", "ButtonAbout")
$script:AuditButtons = @(
    $Global:XAML.SelectNodes("//*[local-name()='Button']") |
        ForEach-Object { $_.GetAttribute("Name", "http://schemas.microsoft.com/winfx/2006/xaml") } |
        Where-Object { -not [string]::IsNullOrEmpty($_) -and $script:NonAuditButtons -notcontains $_ } |
        ForEach-Object { $window.FindName($_) } |
        Where-Object { $null -ne $_ }
)
# Hilfsfunktionen, die von Audit-Funktionen aufgerufen werden und daher zusätzlich in den Runspace übernommen werden
$script:AuditHelperFunctions = @("Get-WDSRootPath", "Get-AuditWinEvent")

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

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

function Update-Output {
    param([PSObject[]]$Data)
    try {
        # Konvertiere alle Eingaben zu einem konsistenten Array-Format
        $processedData = New-Object System.Collections.Generic.List[Object]
        
        if ($null -eq $Data -or $Data.Count -eq 0) {
            $script:ResultsCount = 0
        } else {
            # Handle verschiedene Input-Typen
            foreach ($item in $Data) {
                if ($null -ne $item) {
                    # Wenn einzelnes Objekt (nicht in einem Array)
                    if ($item -is [System.Collections.IEnumerable] -and $item -isnot [string] -and $item -isnot [System.Collections.Specialized.OrderedDictionary]) {
                        foreach ($subitem in $item) {
                            $processedData.Add($subitem)
                        }
                    } else {
                        $processedData.Add($item)
                    }
                }
            }
            
            # Erstelle ObservableCollection
            $collection = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
            foreach ($item in $processedData) {
                $collection.Add($item)
            }
            $script:ResultsCount = $collection.Count
            
            # UI-Update auf dem Dispatcher-Thread
            $window.Dispatcher.Invoke({
                try {
                    $DataGridResults.ItemsSource = $null
                    
                    # Auto-Generate Columns basierend auf den Daten
                    $DataGridResults.AutoGenerateColumns = $true
                    
                    $DataGridResults.ItemsSource = $collection
                    $TotalResultCountText.Text = $script:ResultsCount.ToString()
                    
                    # Force Refresh
                    $DataGridResults.Items.Refresh()
                } catch {
                    Write-Host "UI-Update Fehler: $_" -ForegroundColor Red
                }
            }, "Normal")
            
            return
        }
        
        # Fallback wenn Daten leer sind
        $window.Dispatcher.Invoke({
            $DataGridResults.ItemsSource = $null
            $TotalResultCountText.Text = "0"
        }, "Normal")
        
    } catch {
        Write-Host "Update-Output Fehler: $_" -ForegroundColor Red
        $window.Dispatcher.Invoke({
            try {
                $DataGridResults.ItemsSource = $null
                $TotalResultCountText.Text = "0"
            } catch {}
        }, "Normal")
    }
}

function Clear-Output {
    $DataGridResults.ItemsSource = @()
    $script:ResultsCount = 0
    $TotalResultCountText.Text = "0"
}

function Update-Status {
    param([string]$Status)
    # Letzten Audit-Titel merken (Statustext ist nach dem Laden immer "Fertig")
    if ($Status -match '^(.+?) (wird|werden) geladen\.\.\.$') {
        $script:LastAuditTitle = $Matches[1]
    }
    $StatusBarText.Text = $Status
    $window.Dispatcher.Invoke([Action]{}, "Background")
}

# ============================================================================
# HINTERGRUND-AUSFÜHRUNG (RUNSPACE) – hält die GUI während eines Audits bedienbar
# ============================================================================

# Statusanzeige in der Fußzeile (wie ActiveDirectory_Audit): Grün = bereit, Gelb = Audit läuft, Rot = Fehler
function Set-StatusIndicator {
    param([ValidateSet('Ready', 'Busy', 'Error')][string]$State)
    if ($null -eq $StatusIndicator) { return }
    $color = switch ($State) { 'Busy' { '#F59E0B' } 'Error' { '#EF4444' } default { '#10B981' } }
    $StatusIndicator.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($color)
}

function Set-AuditUiBusy {
    param([bool]$Busy)
    foreach ($button in $script:AuditButtons) { $button.IsEnabled = -not $Busy }
    $AuditProgressBar.IsIndeterminate = $Busy
    $AuditProgressBar.Visibility = if ($Busy) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $window.Cursor = if ($Busy) { [System.Windows.Input.Cursors]::AppStarting } else { $null }
    Set-StatusIndicator -State $(if ($Busy) { 'Busy' } else { 'Ready' })
}

function Remove-AuditJob {
    # Gibt PowerShell-Instanz und Runspace des aktuellen Auftrags frei
    $job = $script:AuditJob
    $script:AuditJob = $null
    if ($null -eq $job) { return }
    try { $job.PowerShell.Dispose() } catch { }
    try { $job.Runspace.Dispose() } catch { }
}

# Startet eine reine Datensammel-Funktion (Get-*) in einem eigenen Runspace.
# Nur die Funktionsdefinitionen werden übergeben – UI-Funktionen/-Controls werden im Runspace nie verwendet.
function Start-AuditJob {
    param(
        [Parameter(Mandatory = $true)][string]$FunctionName,
        [Parameter(Mandatory = $true)][string]$Status
    )
    if ($null -ne $script:AuditJob) {
        $StatusBarText.Text = "Bitte warten – es läuft bereits ein Audit ($($script:AuditJob.Status))"
        return
    }

    Update-Status $Status
    $runspace = $null
    $ps = $null
    try {
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($name in (@($FunctionName) + $script:AuditHelperFunctions | Select-Object -Unique)) {
            $definition = (Get-Item -Path "function:\$name" -ErrorAction Stop).Definition
            $iss.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $name, $definition))
        }

        $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($iss)
        $runspace.Open()
        $ps = [System.Management.Automation.PowerShell]::Create()
        $ps.Runspace = $runspace
        [void]$ps.AddCommand($FunctionName)

        $script:AuditJob = [PSCustomObject]@{
            PowerShell   = $ps
            Runspace     = $runspace
            Handle       = $ps.BeginInvoke()
            FunctionName = $FunctionName
            Status       = $Status -replace '\.\.\.$', ''
            Started      = [DateTime]::Now
        }
        Set-AuditUiBusy $true
        $script:AuditTimer.Start()
    } catch {
        if ($null -ne $ps) { try { $ps.Dispose() } catch { } }
        if ($null -ne $runspace) { try { $runspace.Dispose() } catch { } }
        $script:AuditJob = $null
        Set-AuditUiBusy $false
        Update-Output @([PSCustomObject]@{"Fehler" = "Audit konnte nicht gestartet werden: $($_.Exception.Message)"})
        $StatusBarText.Text = "Fehler beim Start von $FunctionName"
        Set-StatusIndicator -State Error
    }
}

# Wird vom DispatcherTimer (UI-Thread) aufgerufen: Fortschritt anzeigen bzw. Ergebnis übernehmen
function Complete-AuditJob {
    $job = $script:AuditJob
    if ($null -eq $job) {
        $script:AuditTimer.Stop()
        return
    }

    $elapsed = ([DateTime]::Now - $job.Started).TotalSeconds
    if (-not $job.Handle.IsCompleted) {
        $StatusBarText.Text = "{0} ... ({1:N0} s)" -f $job.Status, $elapsed
        return
    }

    $script:AuditTimer.Stop()
    $hadError = $false
    try {
        $results = $job.PowerShell.EndInvoke($job.Handle)
        $data = @($results | Where-Object { $null -ne $_ })
        $errors = @($job.PowerShell.Streams.Error | ForEach-Object { $_.ToString() } | Where-Object { $_ })
        foreach ($err in $errors) { Write-Warning "[$($job.FunctionName)] $err" }

        if ($data.Count -eq 0 -and $errors.Count -gt 0) {
            $data = @([PSCustomObject]@{"Fehler" = ($errors -join " | ")})
        } elseif ($data.Count -eq 0) {
            $data = @([PSCustomObject]@{"Information" = "Keine Daten gefunden"})
        }
        Update-Output $data

        $statusText = "Fertig – {0} Ergebnis(se) in {1:N1} s" -f $script:ResultsCount, $elapsed
        if ($errors.Count -gt 0) {
            $statusText += " ($($errors.Count) Fehlermeldung(en), siehe Konsole)"
            $hadError = $true
        }
        $StatusBarText.Text = $statusText
    } catch {
        $hadError = $true
        Update-Output @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
        $StatusBarText.Text = "Fehler bei $($job.FunctionName): $($_.Exception.Message)"
    } finally {
        Remove-AuditJob
        Set-AuditUiBusy $false
        if ($hadError) { Set-StatusIndicator -State Error }
    }
}

$script:AuditTimer.Add_Tick({ Complete-AuditJob })

# ============================================================================
# TABLE FORMATTING FUNCTIONS - REMOVED (Using DataGrid Now)
# ============================================================================

# Alle Ausgaben erfolgen jetzt direkt über DataGrid mit PSObjects
# Die alten Format-* Funktionen werden nicht mehr benötigt

# ============================================================================
# AUDIT FUNCTIONS
# ============================================================================

function Get-SystemInformation {
    try {
        $info = Get-ComputerInfo -ErrorAction Stop
        $data = @(
            [ordered]@{"Attribut" = "Computername"; "Wert" = $info.CsComputerName},
            [ordered]@{"Attribut" = "Domäne"; "Wert" = $info.CsDomain},
            [ordered]@{"Attribut" = "Betriebssystem"; "Wert" = $info.OsName},
            [ordered]@{"Attribut" = "Installationsdatum"; "Wert" = $info.OsInstallDate},
            [ordered]@{"Attribut" = "Letzter Boot"; "Wert" = $info.OsLastBootUpTime}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-OSDetails {
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $data = @(
            [ordered]@{"Eigenschaft" = "Caption"; "Wert" = $os.Caption},
            [ordered]@{"Eigenschaft" = "Version"; "Wert" = $os.Version},
            [ordered]@{"Eigenschaft" = "Build"; "Wert" = $os.BuildNumber},
            [ordered]@{"Eigenschaft" = "Gesamtarbeitsspeicher"; "Wert" = "$('{0:N0}' -f ($os.TotalVisibleMemorySize / 1024)) MB"},
            [ordered]@{"Eigenschaft" = "Freier Arbeitsspeicher"; "Wert" = "$('{0:N0}' -f ($os.FreePhysicalMemory / 1024)) MB"},
            [ordered]@{"Eigenschaft" = "Letzter Boot"; "Wert" = $os.LastBootUpTime}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-HardwareSummary {
    try {
        $hw = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $data = @(
            [ordered]@{"Eigenschaft" = "Hersteller"; "Wert" = $hw.Manufacturer},
            [ordered]@{"Eigenschaft" = "Modell"; "Wert" = $hw.Model},
            [ordered]@{"Eigenschaft" = "Prozessoren"; "Wert" = $hw.NumberOfProcessors},
            [ordered]@{"Eigenschaft" = "Logische Kerne"; "Wert" = $hw.NumberOfLogicalProcessors},
            [ordered]@{"Eigenschaft" = "RAM (GB)"; "Wert" = "$('{0:N2}' -f ($hw.TotalPhysicalMemory / 1GB))"},
            [ordered]@{"Eigenschaft" = "Systemtyp"; "Wert" = $hw.SystemType}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-CPUDetails {
    try {
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        $data = @(
            [ordered]@{"Eigenschaft" = "Name"; "Wert" = $cpu.Name},
            [ordered]@{"Eigenschaft" = "Kerne"; "Wert" = $cpu.NumberOfCores},
            [ordered]@{"Eigenschaft" = "Logische Prozessoren"; "Wert" = $cpu.NumberOfLogicalProcessors},
            [ordered]@{"Eigenschaft" = "Geschwindigkeit (GHz)"; "Wert" = "$('{0:N2}' -f ($cpu.MaxClockSpeed / 1000))"},
            [ordered]@{"Eigenschaft" = "Architektur"; "Wert" = $cpu.Architecture},
            [ordered]@{"Eigenschaft" = "Cache (KB)"; "Wert" = $cpu.L3CacheSize}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-MemoryDetails {
    try {
        $mem = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop
        $data = [System.Collections.Generic.List[object]]::new()
        $data.Add([ordered]@{"Eigenschaft" = "Anzahl Module"; "Wert" = $mem.Count})
        foreach ($m in $mem) {
            $data.Add([ordered]@{
                "Eigenschaft" = $m.PartNumber
                "Wert" = "$('{0:N2}' -f ($m.Capacity / 1GB)) GB @ $($m.Speed) MHz"
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-StorageSummary {
    try {
        $disks = Get-CimInstance Win32_LogicalDisk -ErrorAction Stop | Where-Object DriveType -eq 3
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($disk in $disks) {
            if ($disk.Size -gt 0) {
                $used = '{0:N2}' -f (($disk.Size - $disk.FreeSpace) / 1GB)
                $total = '{0:N2}' -f ($disk.Size / 1GB)
                $percent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 2)
                $freePercent = [math]::Round(100 - $percent, 2)
            } else {
                $used = "0"
                $total = "0"
                $percent = "0"
                $freePercent = "100"
            }
            $data.Add([ordered]@{
                "Laufwerk" = $disk.Name
                "Gesamt(GB)" = $total
                "Belegt(GB)" = $used
                "Frei(%)" = $freePercent
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-NetworkConfiguration {
    try {
        $config = Get-NetIPConfiguration -ErrorAction Stop
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($cfg in $config) {
            $data.Add([ordered]@{
                "Interface" = $cfg.InterfaceAlias
                "IPv4" = ($cfg.IPv4Address.IPAddress -join ', ')
                "Gateway" = ($cfg.IPv4DefaultGateway.NextHopAddress -join ', ')
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-NetworkAdapters {
    try {
        $adapters = Get-NetAdapter -ErrorAction Stop
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($adapter in $adapters) {
            $speedGbps = '{0:N2}' -f ($adapter.Speed / 1000000000)
            $data.Add([ordered]@{
                "Name" = $adapter.Name
                "Status" = $adapter.Status
                "Speed(Gbps)" = $speedGbps
                "MAC" = $adapter.MacAddress
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ActiveConnections {
    try {
        $connections = Get-NetTCPConnection -State Listen -ErrorAction Stop | Select-Object LocalAddress, LocalPort, OwningProcess -First 50
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($conn in $connections) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            $data.Add([ordered]@{
                "IP:Port" = "$($conn.LocalAddress):$($conn.LocalPort)"
                "PID" = $conn.OwningProcess
                "Process" = $process.ProcessName
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-FirewallRules {
    try {
        $rules = Get-NetFirewallRule -ErrorAction Stop | Where-Object { $_.Enabled -eq 'True' } | Select-Object DisplayName, Direction, Action -First 50
        if ($null -eq $rules) {
            return @([PSCustomObject]@{"Information" = "Keine aktivierten Firewall-Regeln gefunden"})
        }
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($rule in $rules) {
            $name = $rule.DisplayName.Substring(0, [Math]::Min(40, $rule.DisplayName.Length))
            $data.Add([ordered]@{
                "Name" = $name
                "Direction" = $rule.Direction
                "Action" = $rule.Action
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-AutomaticServices {
    try {
        $services = Get-Service -ErrorAction Stop | Where-Object StartType -eq 'Automatic' | Sort-Object Status, Name | Select-Object -First 50
        return $services | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Status" = $_.Status; "Display" = $_.DisplayName} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-RunningServices {
    try {
        $services = Get-Service -ErrorAction Stop | Where-Object Status -eq 'Running' | Sort-Object Name | Select-Object -First 50
        return $services | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Display" = $_.DisplayName} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ScheduledTasks {
    try {
        $tasks = Get-ScheduledTask -ErrorAction Stop | Where-Object State -eq 'Ready' | Select-Object -First 50
        return $tasks | ForEach-Object { [PSCustomObject]@{"Path" = $_.TaskPath; "Name" = $_.TaskName; "State" = $_.State} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-InstalledFeatures {
    try {
        $features = Get-WindowsFeature -ErrorAction Stop | Where-Object Installed -eq $true | Select-Object Name, DisplayName, FeatureType
        return $features | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Display" = $_.DisplayName; "Type" = $_.FeatureType} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-InstalledPrograms {
    try {
        # Registry statt Win32_Product (Win32_Product ist langsam und löst MSI-Konsistenzprüfungen/Reparaturen aus)
        $uninstallPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        $programs = Get-ItemProperty -Path $uninstallPaths -ErrorAction SilentlyContinue |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_.DisplayName) } |
            Select-Object @{Name='Name';Expression={$_.DisplayName}}, @{Name='Version';Expression={$_.DisplayVersion}}, @{Name='Vendor';Expression={$_.Publisher}} |
            Sort-Object Name -Unique | Select-Object -First 100
        return $programs | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Version" = $_.Version; "Vendor" = $_.Vendor} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-WindowsUpdates {
    try {
        $updates = Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending | Select-Object -First 20
        return $updates | ForEach-Object { [PSCustomObject]@{"KB" = $_.HotFixID; "InstalledOn" = $_.InstalledOn; "Description" = $_.Description} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# Get-WinEvent wirft bei leerem Ergebnis "No events were found..." (NoMatchingEventsFound) – das ist kein Fehler,
# sondern ein leeres Ergebnis. Alle anderen Fehler (z.B. Zugriff verweigert) werden weitergereicht.
function Get-AuditWinEvent {
    param(
        [Parameter(Mandatory = $true)][hashtable]$FilterHashtable,
        [int]$MaxEvents = 50
    )
    try {
        Get-WinEvent -FilterHashtable $FilterHashtable -MaxEvents $MaxEvents -ErrorAction Stop
    } catch {
        if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') { return }
        throw
    }
}

function Get-SystemEvents {
    try {
        $events = @(Get-AuditWinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 50)
        if ($events.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine System Events gefunden"})
        }
        return $events | Select-Object -First 50 | ForEach-Object { 
            [PSCustomObject]@{
                "Zeit" = $_.TimeCreated
                "ID" = $_.Id
                "Level" = $_.LevelDisplayName
                "Message" = ([string]$_.Message).Substring(0, [Math]::Min(50, ([string]$_.Message).Length))
            } 
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ApplicationEvents {
    try {
        $events = @(Get-AuditWinEvent -FilterHashtable @{LogName='Application'; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 50)
        if ($events.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Application Events gefunden"})
        }
        return $events | ForEach-Object { 
            [PSCustomObject]@{
                "Zeit" = $_.TimeCreated
                "ID" = $_.Id
                "Level" = $_.LevelDisplayName
            } 
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-SecurityEvents {
    try {
        $events = @(Get-AuditWinEvent -FilterHashtable @{LogName='Security'} -MaxEvents 100)
        if ($events.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Security Events gefunden"})
        }
        return $events | ForEach-Object { 
            [PSCustomObject]@{
                "Zeit" = $_.TimeCreated
                "ID" = $_.Id
                "Level" = $_.LevelDisplayName
            } 
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-FailedLogons {
    try {
        $events = @(Get-AuditWinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 50)
        if ($events.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine fehlgeschlagenen Anmeldungen gefunden"})
        }
        return $events | ForEach-Object { 
            [PSCustomObject]@{
                "Zeit" = $_.TimeCreated
                "Message" = ([string]$_.Message).Substring(0, [Math]::Min(80, ([string]$_.Message).Length))
            } 
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-AccountLockouts {
    try {
        $events = @(Get-AuditWinEvent -FilterHashtable @{LogName='Security'; ID=4740} -MaxEvents 50)
        if ($events.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Account-Sperren gefunden"})
        }
        return $events | ForEach-Object { 
            [PSCustomObject]@{
                "Zeit" = $_.TimeCreated
                "Message" = ([string]$_.Message).Substring(0, [Math]::Min(80, ([string]$_.Message).Length))
            } 
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-LocalUsers {
    try {
        $users = Get-LocalUser -ErrorAction Stop
        if ($null -eq $users) {
            return @([PSCustomObject]@{"Information" = "Keine lokalen Benutzer gefunden"})
        }
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($user in $users) {
            $data.Add([ordered]@{
                "Name" = $user.Name
                "Enabled" = if($user.Enabled) {"Ja"} else {"Nein"}
                "LastLogon" = $user.LastLogon
                "PwdRequired" = if($user.PasswordRequired) {"Ja"} else {"Nein"}
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-LocalGroups {
    try {
        $groups = Get-LocalGroup -ErrorAction Stop
        if ($null -eq $groups) {
            return @([PSCustomObject]@{"Information" = "Keine lokalen Gruppen gefunden"})
        }
        return $groups | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Description" = $_.Description} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-PrivilegeAudit {
    try {
        $events = @(Get-AuditWinEvent -FilterHashtable @{LogName='Security'; ID=4672,4673,4674} -MaxEvents 50)
        if ($events.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Privilege-Audit Events gefunden"})
        }
        return $events | ForEach-Object { 
            [PSCustomObject]@{
                "Zeit" = $_.TimeCreated
                "ID" = $_.Id
                "Message" = ([string]$_.Message).Substring(0, [Math]::Min(60, ([string]$_.Message).Length))
            } 
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# AD Functions (String alt noch umgestellt auf PSObjects)
function Get-ADDomainControllers {
    try {
        $dcs = Get-ADDomainController -Filter * -ErrorAction Stop | Select-Object Name, Site, IPv4Address, OperatingSystem, IsGlobalCatalog, IsReadOnly
        return $dcs | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Site" = $_.Site; "IP" = $_.IPv4Address; "GC" = $_.IsGlobalCatalog} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADDomainInfo {
    try {
        $domain = Get-ADDomain -ErrorAction Stop
        $data = @(
            [ordered]@{"Property" = "Name"; "Value" = $domain.Name},
            [ordered]@{"Property" = "NetBIOS"; "Value" = $domain.NetBIOSName},
            [ordered]@{"Property" = "Mode"; "Value" = $domain.DomainMode},
            [ordered]@{"Property" = "PDC"; "Value" = $domain.PDCEmulator}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DNSZones {
    try {
        $zones = Get-DnsServerZone -ErrorAction Stop | Select-Object -First 50
        return $zones | ForEach-Object { [PSCustomObject]@{"Zone" = $_.ZoneName; "Type" = $_.ZoneType; "DS" = $_.IsDsIntegrated} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-FileShares {
    try {
        $shares = Get-SmbShare -ErrorAction Stop | Select-Object Name, Path, Description, ShareType
        return $shares | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Path" = $_.Path; "Type" = $_.ShareType} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-IISWebsites {
    try {
        Import-Module WebAdministration -ErrorAction Stop
        $sites = Get-Website -ErrorAction Stop | Select-Object Name, State, PhysicalPath
        return $sites | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "State" = $_.State; "Path" = $_.PhysicalPath} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "IIS: " + $_.Exception.Message})
    }
}

function Get-RDSCollections {
    try {
        $collections = Get-RDSessionCollection -ErrorAction Stop | Select-Object CollectionName, CollectionDescription
        return $collections | ForEach-Object { [PSCustomObject]@{"Name" = $_.CollectionName; "Description" = $_.CollectionDescription} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "RDS: " + $_.Exception.Message})
    }
}

# ============================================================================
# EXTENDED AD FUNCTIONS
# ============================================================================

function Get-ADForestInfo {
    try {
        $forest = Get-ADForest -ErrorAction Stop
        $data = @(
            [ordered]@{"Property" = "Name"; "Value" = $forest.Name},
            [ordered]@{"Property" = "Mode"; "Value" = $forest.ForestMode},
            [ordered]@{"Property" = "Domains"; "Value" = ($forest.Domains | Measure-Object).Count},
            [ordered]@{"Property" = "Sites"; "Value" = ($forest.Sites | Measure-Object).Count}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADOUs {
    try {
        $ous = Get-ADOrganizationalUnit -Filter * -ErrorAction Stop | Select-Object Name, DistinguishedName | Sort-Object Name | Select-Object -First 50
        return $ous | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "DN" = $_.DistinguishedName} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADDomainAdmins {
    try {
        # Gruppe über well-known RID 512 ermitteln (Name ist sprachabhängig, z.B. "Domänen-Admins")
        $domainAdminsSid = "$((Get-ADDomain -ErrorAction Stop).DomainSID.Value)-512"
        $admins = Get-ADGroupMember -Identity $domainAdminsSid -ErrorAction Stop | Get-ADUser -Properties LastLogonDate, PasswordLastSet, Enabled -ErrorAction SilentlyContinue | Select-Object Name, SamAccountName, Enabled, LastLogonDate
        return $admins | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Account" = $_.SamAccountName; "Enabled" = $_.Enabled; "LastLogon" = $_.LastLogonDate} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADComputers {
    try {
        $computers = Get-ADComputer -Filter * -Properties OperatingSystem, LastLogonDate -ErrorAction Stop | Select-Object Name, OperatingSystem, LastLogonDate, Enabled | Sort-Object LastLogonDate -Descending | Select-Object -First 50
        return $computers | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "OS" = $_.OperatingSystem; "LastLogon" = $_.LastLogonDate; "Enabled" = $_.Enabled} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADReplicationStatus {
    try {
        $output = repadmin /replsummary 2>&1
        $data = [System.Collections.Generic.List[object]]::new()
        
        # Parse der repadmin Ausgabe
        foreach ($line in $output) {
            if (-not [string]::IsNullOrWhiteSpace($line) -and $line -match '\S') {
                $data.Add([ordered]@{
                    "Information" = $line.Trim()
                })
            }
        }
        
        if ($data.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Replikationsinformationen verfügbar"})
        }
        
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADTrusts {
    try {
        $trusts = Get-ADTrust -Filter * -ErrorAction Stop | Select-Object Name, Direction, TrustType
        return $trusts | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Direction" = $_.Direction; "Type" = $_.TrustType} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# DNS FUNCTIONS
# ============================================================================

function Get-DNSConfiguration {
    try {
        # Versuche Get-DnsServerSetting zuerst (besser als Get-DnsServer)
        # -All: ListeningIPAddress/RoundRobin sind nicht in allen Versionen Teil der Kurzausgabe
        $dnsSettings = Get-DnsServerSetting -All -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        
        if ($null -ne $dnsSettings) {
            # Logging-Einstellungen stehen nicht in DnsServerSetting, sondern in Get-DnsServerDiagnostics
            $dnsDiag = Get-DnsServerDiagnostics -ErrorAction SilentlyContinue
            $data = @(
                [ordered]@{"Setting" = "Listen Addresses"; "Value" = ($dnsSettings.ListeningIPAddress -join ", ")},
                [ordered]@{"Setting" = "Round Robin"; "Value" = if($dnsSettings.RoundRobin) {"Ja"} else {"Nein"}},
                [ordered]@{"Setting" = "DNSSEC Enabled"; "Value" = if($dnsSettings.EnableDnsSec) {"Ja"} else {"Nein"}},
                [ordered]@{"Setting" = "Log Queries"; "Value" = if($dnsDiag.Queries) {"Ja"} else {"Nein"}},
                [ordered]@{"Setting" = "Write to Log"; "Value" = if($dnsDiag.EnableLoggingToFile) {"Ja"} else {"Nein"}}
            )
            return $data | ForEach-Object { [PSCustomObject]$_ }
        } else {
            # Fallback: Get-DnsServer liefert ein Gesamtobjekt; die Werte stehen in den Unterobjekten
            # (ServerSetting, ServerRecursion, ServerCache, ServerDiagnostics, ServerForwarder)
            $dns = Get-DnsServer -ErrorAction Stop -WarningAction SilentlyContinue
            $setting = $dns.ServerSetting
            $data = @(
                [ordered]@{"Setting" = "Computer"; "Value" = $setting.ComputerName},
                [ordered]@{"Setting" = "Version"; "Value" = "$($setting.MajorVersion).$($setting.MinorVersion).$($setting.BuildNumber)"},
                [ordered]@{"Setting" = "Listen Addresses"; "Value" = ($setting.ListeningIPAddress -join ", ")},
                [ordered]@{"Setting" = "Round Robin"; "Value" = if($setting.RoundRobin) {"Ja"} else {"Nein"}},
                [ordered]@{"Setting" = "DNSSEC Enabled"; "Value" = if($setting.EnableDnsSec) {"Ja"} else {"Nein"}},
                [ordered]@{"Setting" = "Recursion"; "Value" = if($dns.ServerRecursion.Enable) {"Ja"} else {"Nein"}},
                [ordered]@{"Setting" = "Cache Max TTL"; "Value" = $dns.ServerCache.MaxTTL},
                [ordered]@{"Setting" = "Forwarders"; "Value" = ($dns.ServerForwarder.IPAddress -join ", ")},
                [ordered]@{"Setting" = "Log Queries"; "Value" = if($dns.ServerDiagnostics.Queries) {"Ja"} else {"Nein"}},
                [ordered]@{"Setting" = "Write to Log"; "Value" = if($dns.ServerDiagnostics.EnableLoggingToFile) {"Ja"} else {"Nein"}}
            )
            return $data | ForEach-Object { [PSCustomObject]$_ }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "DNS nicht verfügbar oder kein Zugriff: $($_.Exception.Message)"})
    }
}

function Get-DNSForwarders {
    try {
        $fwd = Get-DnsServerForwarder -ErrorAction Stop
        if ($null -ne $fwd.IPAddress) {
            return $fwd.IPAddress | ForEach-Object { [PSCustomObject]@{"Forwarder" = $_} }
        } else {
            return @([PSCustomObject]@{"Forwarder" = "Keine Forwarder konfiguriert"})
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DNSCache {
    try {
        $cache = Get-DnsServerCache -ErrorAction Stop
        return @([PSCustomObject]@{"CacheSize" = $cache.MaxKBSize; "MaxTTL" = $cache.MaxTTL; "MaxNegativeTTL" = $cache.MaxNegativeTTL})
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# DHCP FUNCTIONS
# ============================================================================

function Get-DHCPConfiguration {
    try {
        # Einstellungen des lokalen DHCP-Servers (autorisierte Server in AD liefert Get-DHCPServerAuthorization)
        $setting = Get-DhcpServerSetting -ErrorAction Stop
        $database = Get-DhcpServerDatabase -ErrorAction SilentlyContinue
        $version = Get-DhcpServerVersion -ErrorAction SilentlyContinue
        $data = @(
            [ordered]@{"Einstellung" = "Version"; "Wert" = if ($version) { "$($version.MajorVersion).$($version.MinorVersion)" } else { $null }},
            [ordered]@{"Einstellung" = "In AD autorisiert"; "Wert" = if ($setting.IsAuthorized) {"Ja"} else {"Nein"}},
            [ordered]@{"Einstellung" = "Domänenmitglied"; "Wert" = if ($setting.IsDomainJoined) {"Ja"} else {"Nein"}},
            [ordered]@{"Einstellung" = "Konflikterkennungsversuche"; "Wert" = $setting.ConflictDetectionAttempts},
            [ordered]@{"Einstellung" = "Dynamisches BOOTP"; "Wert" = if ($setting.DynamicBootp) {"Ja"} else {"Nein"}},
            [ordered]@{"Einstellung" = "Richtlinien aktiv"; "Wert" = if ($setting.ActivatePolicies) {"Ja"} else {"Nein"}},
            [ordered]@{"Einstellung" = "Datenbankdatei"; "Wert" = $database.FileName},
            [ordered]@{"Einstellung" = "Sicherungspfad"; "Wert" = $database.BackupPath},
            [ordered]@{"Einstellung" = "Sicherungsintervall (min)"; "Wert" = $database.BackupInterval},
            [ordered]@{"Einstellung" = "Bereinigungsintervall (min)"; "Wert" = $database.CleanupInterval},
            [ordered]@{"Einstellung" = "Überwachungsprotokoll"; "Wert" = if ($database.LoggingEnabled) {"Ja"} else {"Nein"}}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DHCPv4Scopes {
    try {
        $scopes = Get-DhcpServerv4Scope -ErrorAction Stop | Select-Object ScopeId, Name, StartRange, EndRange, State | Select-Object -First 50
        return $scopes | ForEach-Object { [PSCustomObject]@{"ScopeID" = $_.ScopeId; "Name" = $_.Name; "Start" = $_.StartRange; "End" = $_.EndRange; "State" = $_.State} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DHCPv6Scopes {
    try {
        $scopes = Get-DhcpServerv6Scope -ErrorAction Stop | Select-Object Prefix, Name, State | Select-Object -First 50
        return $scopes | ForEach-Object { [PSCustomObject]@{"Prefix" = $_.Prefix; "Name" = $_.Name; "State" = $_.State} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DHCPReservations {
    try {
        $scopes = Get-DhcpServerv4Scope -ErrorAction Stop
        $reservations = [System.Collections.Generic.List[object]]::new()
        foreach ($scope in $scopes) {
            $reservations.AddRange(@(Get-DhcpServerv4Reservation -ScopeId $scope.ScopeId -ErrorAction SilentlyContinue | Select-Object -First 20))
        }
        return $reservations | ForEach-Object { [PSCustomObject]@{"ScopeID" = $_.ScopeId; "IP" = $_.IPAddress; "Name" = $_.Name; "Type" = $_.ReservationType} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# IIS FUNCTIONS
# ============================================================================

function Get-IISAppPools {
    try {
        Import-Module WebAdministration -ErrorAction Stop
        $pools = Get-ChildItem IIS:\AppPools -ErrorAction Stop | Select-Object Name, State, ManagedRuntimeVersion
        return $pools | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "State" = $_.State; "Runtime" = $_.ManagedRuntimeVersion} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "IIS: " + $_.Exception.Message})
    }
}

function Get-IISBindings {
    try {
        Import-Module WebAdministration -ErrorAction Stop
        $sites = Get-ChildItem IIS:\Sites -ErrorAction Stop
        $bindings = [System.Collections.Generic.List[object]]::new()
        foreach ($site in $sites) {
            $site.Bindings.Collection | ForEach-Object { $bindings.Add($_) }
        }
        return $bindings | Select-Object -First 50 | ForEach-Object { [PSCustomObject]@{"Protocol" = $_.Protocol; "IP" = $_.BindingInformation} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "IIS: " + $_.Exception.Message})
    }
}

# ============================================================================
# RDS FUNCTIONS
# ============================================================================

function Get-RDSSessionHosts {
    try {
        # -CollectionName ist Pflichtparameter (ohne ihn blockiert eine Eingabeaufforderung)
        $hosts = Get-RDSessionCollection -ErrorAction Stop | ForEach-Object { Get-RDSessionHost -CollectionName $_.CollectionName -ErrorAction Stop } | Select-Object SessionHost, NewConnectionAllowed | Select-Object -First 50
        return $hosts | ForEach-Object { [PSCustomObject]@{"Host" = $_.SessionHost; "NewConnections" = $_.NewConnectionAllowed} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "RDS: " + $_.Exception.Message})
    }
}

function Get-RDSActiveLicensing {
    try {
        # Get-RDLicenseConfiguration liefert nur Modus und Lizenzserver (keine Zähler) und setzt einen Connection Broker voraus
        $mode = "n/a"
        $licenseServers = @()
        try {
            $licensing = Get-RDLicenseConfiguration -ErrorAction Stop
            $mode = [string]$licensing.Mode
            $licenseServers = @($licensing.LicenseServer | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        } catch { }
        if ($licenseServers.Count -eq 0) { $licenseServers = @($env:COMPUTERNAME) }

        # Ausgestellte Lizenzen aus Win32_TSLicenseKeyPack des Lizenzservers (IssuedLicenses bzw. Total - Available)
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($server in $licenseServers) {
            try {
                $cimParams = @{ ClassName = "Win32_TSLicenseKeyPack"; ErrorAction = "Stop" }
                if ($server -notin @($env:COMPUTERNAME, "localhost", ".") -and $server -notlike "$($env:COMPUTERNAME).*") { $cimParams["ComputerName"] = $server }
                $keyPacks = @(Get-CimInstance @cimParams)
                if ($keyPacks.Count -eq 0) {
                    $data.Add([PSCustomObject]@{"Mode" = $mode; "LicenseServer" = $server; "Product" = "Keine Lizenzpakete installiert"; "Type" = $null; "TotalLicenses" = 0; "IssuedLicenses" = 0; "AvailableLicenses" = 0})
                    continue
                }
                foreach ($kp in $keyPacks) {
                    $issued = $kp.IssuedLicenses
                    if ($null -eq $issued) { $issued = [int64]$kp.TotalLicenses - [int64]$kp.AvailableLicenses }
                    $data.Add([PSCustomObject]@{
                        "Mode" = $mode
                        "LicenseServer" = $server
                        "Product" = $kp.ProductVersion
                        "Type" = $kp.TypeAndModel
                        "TotalLicenses" = $kp.TotalLicenses
                        "IssuedLicenses" = $issued
                        "AvailableLicenses" = $kp.AvailableLicenses
                    })
                }
            } catch {
                $data.Add([PSCustomObject]@{"Mode" = $mode; "LicenseServer" = $server; "Product" = "Fehler: $($_.Exception.Message)"; "Type" = $null; "TotalLicenses" = $null; "IssuedLicenses" = $null; "AvailableLicenses" = $null})
            }
        }
        return $data
    } catch {
        return @([PSCustomObject]@{"Fehler" = "RDS: " + $_.Exception.Message})
    }
}

# ============================================================================
# DFS FUNCTIONS
# ============================================================================

function Get-DFSNamespaces {
    try {
        $namespaces = Get-DfsnRoot -ErrorAction Stop | Select-Object Path, Type, State | Select-Object -First 50
        return $namespaces | ForEach-Object { [PSCustomObject]@{"Path" = $_.Path; "Type" = $_.Type; "State" = $_.State} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DFSReplicationGroups {
    try {
        $groups = Get-DfsReplicationGroup -ErrorAction Stop | Select-Object GroupName, State, Description | Select-Object -First 50
        return $groups | ForEach-Object { [PSCustomObject]@{"Name" = $_.GroupName; "State" = $_.State; "Description" = $_.Description} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# PRINT SERVER FUNCTIONS
# ============================================================================

function Get-PrintServers {
    try {
        $printers = Get-Printer -ErrorAction Stop | Select-Object Name, DriverName, Shared, Published | Select-Object -First 50
        return $printers | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Driver" = $_.DriverName; "Shared" = $_.Shared; "Published" = $_.Published} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-PrinterDrivers {
    try {
        $drivers = Get-PrinterDriver -ErrorAction Stop | Select-Object Name, Manufacturer, DriverVersion | Select-Object -First 50
        return $drivers | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Vendor" = $_.Manufacturer; "Version" = $_.DriverVersion} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# WSUS FUNCTIONS
# ============================================================================

function Get-WSUSConfiguration {
    try {
        $wsus = Get-WsusServer -ErrorAction Stop | Select-Object Name, PortNumber, ServerProtocolVersion
        return @([PSCustomObject]@{"Name" = $wsus.Name; "Port" = $wsus.PortNumber; "Protocol" = $wsus.ServerProtocolVersion})
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-WSUSComputerTargetGroups {
    try {
        $server = Get-WsusServer -ErrorAction Stop
        $groups = $server.GetComputerTargetGroups() | Select-Object Name | Select-Object -First 50
        return $groups | ForEach-Object { [PSCustomObject]@{"Group" = $_.Name} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-WSUSUpdates {
    param([int]$MaxResults = 200)
    try {
        $server = Get-WsusServer -ErrorAction Stop
        # Nur relevante Updates laden: nicht abgelehnt und von mindestens einem Computer benötigt
        # (GetUpdates() ohne Scope lädt den kompletten Katalog – auf großen WSUS-Servern Zehntausende Objekte)
        $scope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
        $scope.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::NotApproved -bor
            [Microsoft.UpdateServices.Administration.ApprovedStates]::LatestRevisionApproved -bor
            [Microsoft.UpdateServices.Administration.ApprovedStates]::HasStaleUpdateApprovals
        $scope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::NotInstalled -bor
            [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::Downloaded -bor
            [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::Failed -bor
            [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::InstalledPendingReboot

        $total = $server.GetUpdateCount($scope)
        if ($total -eq 0) {
            return @([PSCustomObject]@{"Title" = "Keine benötigten, nicht abgelehnten Updates gefunden"; "KB" = $null; "Classification" = $null; "Approved" = $null; "Arrival" = $null})
        }
        $updates = $server.GetUpdates($scope) | Sort-Object ArrivalDate -Descending | Select-Object -First $MaxResults
        $result = [System.Collections.Generic.List[object]]::new()
        $result.AddRange(@($updates | ForEach-Object {
            [PSCustomObject]@{
                "Title" = $_.Title
                "KB" = (@($_.KnowledgebaseArticles) | ForEach-Object { "KB$_" }) -join ", "
                "Classification" = $_.UpdateClassificationTitle
                "Approved" = $_.IsApproved
                "Arrival" = $_.ArrivalDate
            }
        }))
        if ($total -gt $result.Count) {
            $result.Add([PSCustomObject]@{"Title" = "… $($result.Count) von $total benötigten Updates angezeigt (neueste zuerst)"; "KB" = $null; "Classification" = $null; "Approved" = $null; "Arrival" = $null})
        }
        return $result
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# HYPER-V FUNCTIONS
# ============================================================================

function Get-HyperVVirtualMachines {
    try {
        $vms = Get-VM -ErrorAction Stop | Select-Object Name, State, MemoryAssigned, ProcessorCount | Select-Object -First 50
        return $vms | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "State" = $_.State; "RAM(GB)" = [Math]::Round($_.MemoryAssigned / 1GB, 2); "CPUs" = $_.ProcessorCount} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-HyperVSwitches {
    try {
        $switches = Get-VMSwitch -ErrorAction Stop | Select-Object Name, SwitchType, NetAdapterInterfaceDescription | Select-Object -First 50
        return $switches | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Type" = $_.SwitchType; "Adapter" = $_.NetAdapterInterfaceDescription} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-HyperVSnapshots {
    try {
        $snapshots = Get-VM -ErrorAction Stop | Get-VMSnapshot -ErrorAction Stop | Select-Object VMName, Name, CreationTime | Select-Object -First 50
        return $snapshots | ForEach-Object { [PSCustomObject]@{"VM" = $_.VMName; "Snapshot" = $_.Name; "Created" = $_.CreationTime} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# NRAS / NPS FUNCTIONS
# ============================================================================

function Get-NPASConfiguration {
    try {
        # NPS-Konfiguration (Dienst, Netzwerk- und Verbindungsanforderungsrichtlinien) – RADIUS-Clients liefert Get-NASClients
        $service = Get-Service -Name IAS -ErrorAction SilentlyContinue
        if ($null -eq $service) {
            return @([PSCustomObject]@{"Bereich" = "Dienst"; "Richtlinie" = $null; "Eigenschaft" = "Network Policy Server (IAS)"; "Wert" = "Nicht installiert"})
        }

        $data = New-Object System.Collections.Generic.List[Object]
        $data.Add([PSCustomObject]@{"Bereich" = "Dienst"; "Richtlinie" = $null; "Eigenschaft" = "Status"; "Wert" = [string]$service.Status})
        $data.Add([PSCustomObject]@{"Bereich" = "Dienst"; "Richtlinie" = $null; "Eigenschaft" = "Starttyp"; "Wert" = [string]$service.StartType})
        $radiusClients = @(Get-NpsRadiusClient -ErrorAction SilentlyContinue)
        $data.Add([PSCustomObject]@{"Bereich" = "RADIUS"; "Richtlinie" = $null; "Eigenschaft" = "Anzahl RADIUS-Clients"; "Wert" = $radiusClients.Count})

        # netsh-Ausgabe ist sprachabhängig: "Schlüssel = Wert"-Zeilen werden generisch übernommen; ein neuer
        # Richtlinienblock beginnt jeweils mit dem ersten Schlüssel des ersten Blocks (z.B. "Name")
        $sections = @(
            @{ Label = "Netzwerkrichtlinie"; Args = @("nps", "show", "np") },
            @{ Label = "Verbindungsanforderungsrichtlinie"; Args = @("nps", "show", "crp") }
        )
        foreach ($section in $sections) {
            $netshArgs = $section.Args
            $output = & netsh.exe @netshArgs 2>&1
            if ($LASTEXITCODE -ne 0) {
                $data.Add([PSCustomObject]@{"Bereich" = $section.Label; "Richtlinie" = $null; "Eigenschaft" = "Fehler"; "Wert" = (($output | Out-String).Trim())})
                continue
            }
            $firstKey = $null
            $policyName = $null
            foreach ($line in $output) {
                if ([string]$line -notmatch '^\s*([^=]+?)\s*=\s*(.*?)\s*$') { continue }
                $key = $Matches[1]
                $value = $Matches[2]
                if ($null -eq $firstKey) { $firstKey = $key }
                if ($key -eq $firstKey) { $policyName = $value }
                $data.Add([PSCustomObject]@{"Bereich" = $section.Label; "Richtlinie" = $policyName; "Eigenschaft" = $key; "Wert" = $value})
            }
            if ($null -eq $firstKey) {
                $data.Add([PSCustomObject]@{"Bereich" = $section.Label; "Richtlinie" = $null; "Eigenschaft" = "Information"; "Wert" = "Keine Richtlinien gefunden"})
            }
        }
        return $data.ToArray()
    } catch {
        return @([PSCustomObject]@{"Fehler" = "NPS: " + $_.Exception.Message})
    }
}

function Get-NASClients {
    try {
        $nasclients = Get-NpsRadiusClient -ErrorAction Stop | Select-Object Name, Address | Select-Object -First 50
        return $nasclients | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "IP" = $_.Address} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# KMS FUNCTIONS
# ============================================================================

function Get-KMSConfiguration {
    try {
        $kms = Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction Stop
        return @([PSCustomObject]@{"KMSHost" = $kms.IsKeyManagementServiceMachine; "Version" = $kms.Version; "VLActivationInterval" = $kms.VLActivationInterval})
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# WDS FUNCTIONS
# ============================================================================

function Get-WDSConfiguration {
    try {
        $wdsReg = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE" -ErrorAction SilentlyContinue
        if ($wdsReg) {
            return @([PSCustomObject]@{"Status" = "WDS Service existiert"; "Version" = $wdsReg.Version})
        } else {
            return @([PSCustomObject]@{"Status" = "WDS Service nicht gefunden"})
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# Ermittelt den konfigurierten WDS-Stammordner (RemoteInstall) aus der Registry, Fallback: C:\RemoteInstall
function Get-WDSRootPath {
    $root = $null
    try {
        $root = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WDSServer\Providers\WDSTFTP" -Name "RootFolder" -ErrorAction Stop).RootFolder
    } catch { }
    if ([string]::IsNullOrWhiteSpace($root)) { $root = "C:\RemoteInstall" }
    return $root
}

function Get-WDSBootImages {
    try {
        $wdsPath = Join-Path (Get-WDSRootPath) "Boot"
        if (Test-Path -LiteralPath $wdsPath) {
            # Images liegen in Unterordnern (z.B. Boot\x64\Images)
            $images = Get-ChildItem -Path $wdsPath -Filter "*.wim" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 50
            return $images | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Size(MB)" = [Math]::Round($_.Length / 1MB, 2)} }
        } else {
            return @([PSCustomObject]@{"Info" = "WDS Boot Images Pfad nicht gefunden"})
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-WDSInstallImages {
    try {
        $wdsPath = Join-Path (Get-WDSRootPath) "Images"
        if (Test-Path -LiteralPath $wdsPath) {
            # Images liegen in Bildgruppen-Unterordnern
            $images = Get-ChildItem -Path $wdsPath -Filter "*.wim" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 50
            return $images | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Size(MB)" = [Math]::Round($_.Length / 1MB, 2)} }
        } else {
            return @([PSCustomObject]@{"Info" = "WDS Install Images Pfad nicht gefunden"})
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# FILE SERVICES & SMB FUNCTIONS
# ============================================================================

function Get-FileSharePermissions {
    try {
        $shares = Get-SmbShare -ErrorAction Stop | Select-Object Name | Select-Object -First 20
        $perms = [System.Collections.Generic.List[object]]::new()
        foreach ($share in $shares) {
            $sharePerm = Get-SmbShareAccess -Name $share.Name -ErrorAction SilentlyContinue
            $perms.Add($sharePerm)
        }
        return $perms | Select-Object -First 100 | ForEach-Object { [PSCustomObject]@{"Share" = $_.Name; "Account" = $_.AccountName; "Access" = $_.AccessRight} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-FileServerQuotas {
    try {
        $quotas = Get-FsrmQuota -ErrorAction Stop | Select-Object Path, Size, SoftLimit | Select-Object -First 50
        return $quotas | ForEach-Object { [PSCustomObject]@{"Path" = $_.Path; "Size(MB)" = [Math]::Round($_.Size / 1MB, 2); "SoftLimit" = $_.SoftLimit} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ShadowCopies {
    try {
        $shadows = Get-CimInstance -ClassName Win32_ShadowCopy -ErrorAction Stop | Select-Object VolumeName, InstallDate, ID | Select-Object -First 50
        return $shadows | ForEach-Object { [PSCustomObject]@{"Volume" = $_.VolumeName; "Date" = $_.InstallDate; "ID" = $_.ID.Substring(0, [Math]::Min(20, $_.ID.Length))} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# EXTENDED AD FUNCTIONS
# ============================================================================

function Get-ADDomainControllerExtended {
    try {
        $dcs = Get-ADDomainController -Filter * -ErrorAction Stop
        if ($null -eq $dcs) {
            return @([PSCustomObject]@{"Information" = "Keine Domain Controller gefunden"})
        }
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($dc in $dcs) {
            $data.Add([ordered]@{
                "Name" = $dc.Name
                "Site" = $dc.Site
                "OS" = $dc.OperatingSystem
                "GC" = if($dc.IsGlobalCatalog) {"Ja"} else {"Nein"}
                "RODC" = if($dc.IsReadOnly) {"Ja"} else {"Nein"}
                "IPv4" = $dc.IPv4Address
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADDomainFunctionalLevel {
    try {
        $domain = Get-ADDomain -ErrorAction Stop
        $forest = Get-ADForest -ErrorAction Stop
        return @(
            [PSCustomObject]@{"Property" = "Domain Name"; "Value" = $domain.Name},
            [PSCustomObject]@{"Property" = "Domain Mode"; "Value" = $domain.DomainMode},
            [PSCustomObject]@{"Property" = "Forest Name"; "Value" = $forest.Name},
            [PSCustomObject]@{"Property" = "Forest Mode"; "Value" = $forest.ForestMode}
        )
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADSiteConfiguration {
    try {
        $sites = Get-ADReplicationSite -Filter * -ErrorAction Stop | Select-Object Name, Description | Select-Object -First 50
        return $sites | ForEach-Object { [PSCustomObject]@{"Site" = $_.Name; "Description" = $_.Description} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADGroupPolicySummary {
    try {
        $topGPOs = Get-GPO -All -ErrorAction Stop | Select-Object DisplayName, CreationTime | Sort-Object CreationTime -Descending | Select-Object -First 30
        return $topGPOs | ForEach-Object { [PSCustomObject]@{"Name" = $_.DisplayName; "Created" = $_.CreationTime} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADClusterInformation {
    try {
        $cluster = Get-Cluster -ErrorAction Stop
        $nodes = Get-ClusterNode -ErrorAction Stop | Select-Object Name, State | Select-Object -First 50
        return $nodes | ForEach-Object { [PSCustomObject]@{"Node" = $_.Name; "State" = $_.State; "Cluster" = $cluster.Name} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "Failover Clustering: " + $_.Exception.Message})
    }
}

# ============================================================================
# EXTENDED AD FUNCTIONS (ADDITIONAL)
# ============================================================================

function Get-ADUserAccounts {
    param([int]$StaleDays = 90)
    try {
        # Benutzerkonten-Übersicht (Kennzahlen statt Vollliste – bleibt auch in großen Domänen übersichtlich)
        $users = @(Get-ADUser -Filter * -Properties Enabled, LockedOut, PasswordNeverExpires, PasswordExpired, PasswordNotRequired, LastLogonDate -ErrorAction Stop)
        $cutoff = (Get-Date).AddDays(-$StaleDays)
        $enabled = @($users | Where-Object { $_.Enabled })
        $data = @(
            [ordered]@{"Kennzahl" = "Benutzerkonten gesamt"; "Anzahl" = $users.Count},
            [ordered]@{"Kennzahl" = "Aktiviert"; "Anzahl" = $enabled.Count},
            [ordered]@{"Kennzahl" = "Deaktiviert"; "Anzahl" = @($users | Where-Object { -not $_.Enabled }).Count},
            [ordered]@{"Kennzahl" = "Gesperrt"; "Anzahl" = @($users | Where-Object { $_.LockedOut }).Count},
            [ordered]@{"Kennzahl" = "Kennwort läuft nie ab (aktiviert)"; "Anzahl" = @($enabled | Where-Object { $_.PasswordNeverExpires }).Count},
            [ordered]@{"Kennzahl" = "Kennwort abgelaufen (aktiviert)"; "Anzahl" = @($enabled | Where-Object { $_.PasswordExpired }).Count},
            [ordered]@{"Kennzahl" = "Kein Kennwort erforderlich (aktiviert)"; "Anzahl" = @($enabled | Where-Object { $_.PasswordNotRequired }).Count},
            [ordered]@{"Kennzahl" = "Nie angemeldet (aktiviert)"; "Anzahl" = @($enabled | Where-Object { $null -eq $_.LastLogonDate }).Count},
            [ordered]@{"Kennzahl" = "Inaktiv > $StaleDays Tage (aktiviert)"; "Anzahl" = @($enabled | Where-Object { $null -ne $_.LastLogonDate -and $_.LastLogonDate -lt $cutoff }).Count}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADFSMORoles {
    try {
        $domain = Get-ADDomain -ErrorAction Stop
        $forest = Get-ADForest -ErrorAction Stop
        $data = @(
            [ordered]@{"FSMO-Rolle" = "PDC Emulator"; "Inhaber" = $domain.PDCEmulator},
            [ordered]@{"FSMO-Rolle" = "RID Master"; "Inhaber" = $domain.RIDMaster},
            [ordered]@{"FSMO-Rolle" = "Infrastructure Master"; "Inhaber" = $domain.InfrastructureMaster},
            [ordered]@{"FSMO-Rolle" = "Schema Master"; "Inhaber" = $forest.SchemaMaster},
            [ordered]@{"FSMO-Rolle" = "Domain Naming Master"; "Inhaber" = $forest.DomainNamingMaster}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADGroupAccounts {
    param([int]$MaxResults = 200)
    try {
        $groups = @(Get-ADGroup -Filter * -Properties Description -ErrorAction Stop | Sort-Object Name | Select-Object -First $MaxResults)
        if ($groups.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Gruppen gefunden"})
        }
        return $groups | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Scope" = $_.GroupScope; "Category" = $_.GroupCategory; "Description" = $_.Description} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADServiceAccounts {
    try {
        $accounts = @(Get-ADServiceAccount -Filter * -Properties Enabled, LastLogonDate, PrincipalsAllowedToRetrieveManagedPassword -ErrorAction Stop | Sort-Object Name | Select-Object -First 200)
        if ($accounts.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine verwalteten Dienstkonten (MSA/gMSA) gefunden"})
        }
        return $accounts | ForEach-Object {
            [PSCustomObject]@{
                "Name" = $_.Name
                "Typ" = if ($_.ObjectClass -eq "msDS-GroupManagedServiceAccount") {"gMSA"} elseif ($_.ObjectClass -eq "msDS-DelegatedManagedServiceAccount") {"dMSA"} else {"MSA"}
                "Enabled" = $_.Enabled
                "LastLogon" = $_.LastLogonDate
                "PasswordRetrievalAllowed" = (@($_.PrincipalsAllowedToRetrieveManagedPassword) | ForEach-Object { ($_ -split ',')[0] -replace '^CN=', '' }) -join ", "
            }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADComputerAccounts {
    param([int]$StaleDays = 90)
    try {
        $computers = @(Get-ADComputer -Filter * -Properties Enabled, LastLogonDate, OperatingSystem -ErrorAction Stop)
        $cutoff = (Get-Date).AddDays(-$StaleDays)
        $enabled = @($computers | Where-Object { $_.Enabled })
        $data = [System.Collections.Generic.List[object]]::new()
        $data.AddRange(@(
            [ordered]@{"Kennzahl" = "Computerkonten gesamt"; "Anzahl" = $computers.Count},
            [ordered]@{"Kennzahl" = "Aktiviert"; "Anzahl" = $enabled.Count},
            [ordered]@{"Kennzahl" = "Deaktiviert"; "Anzahl" = @($computers | Where-Object { -not $_.Enabled }).Count},
            [ordered]@{"Kennzahl" = "Nie angemeldet (aktiviert)"; "Anzahl" = @($enabled | Where-Object { $null -eq $_.LastLogonDate }).Count},
            [ordered]@{"Kennzahl" = "Inaktiv > $StaleDays Tage (aktiviert)"; "Anzahl" = @($enabled | Where-Object { $null -ne $_.LastLogonDate -and $_.LastLogonDate -lt $cutoff }).Count}
        ))
        foreach ($os in ($enabled | Group-Object { if ([string]::IsNullOrWhiteSpace($_.OperatingSystem)) { "(unbekannt)" } else { $_.OperatingSystem } } | Sort-Object Count -Descending)) {
            $data.Add([ordered]@{"Kennzahl" = "Betriebssystem: $($os.Name)"; "Anzahl" = $os.Count})
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADPasswordPolicy {
    try {
        $policy = Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop
        $data = [System.Collections.Generic.List[object]]::new()
        $data.AddRange(@(
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Minimale Kennwortlänge"; "Wert" = $policy.MinPasswordLength},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Komplexität erforderlich"; "Wert" = if ($policy.ComplexityEnabled) {"Ja"} else {"Nein"}},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Maximales Kennwortalter"; "Wert" = [string]$policy.MaxPasswordAge},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Minimales Kennwortalter"; "Wert" = [string]$policy.MinPasswordAge},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Kennwortchronik"; "Wert" = $policy.PasswordHistoryCount},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Umkehrbare Verschlüsselung"; "Wert" = if ($policy.ReversibleEncryptionEnabled) {"Ja"} else {"Nein"}},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Kontosperrungsschwelle"; "Wert" = $policy.LockoutThreshold},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Kontosperrdauer"; "Wert" = [string]$policy.LockoutDuration},
            [ordered]@{"Richtlinie" = "Default Domain Policy"; "Einstellung" = "Zurücksetzen des Sperrzählers nach"; "Wert" = [string]$policy.LockoutObservationWindow}
        ))
        # Fein abgestimmte Kennwortrichtlinien (FGPP)
        foreach ($fgpp in @(Get-ADFineGrainedPasswordPolicy -Filter * -ErrorAction SilentlyContinue | Sort-Object Precedence)) {
            $data.Add([ordered]@{"Richtlinie" = "FGPP: $($fgpp.Name)"; "Einstellung" = "Priorität / Min. Länge / Komplexität / Sperrschwelle"; "Wert" = "$($fgpp.Precedence) / $($fgpp.MinPasswordLength) / $($fgpp.ComplexityEnabled) / $($fgpp.LockoutThreshold)"})
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADReplicationSites {
    try {
        $sites = @(Get-ADReplicationSite -Filter * -Properties Description -ErrorAction Stop | Sort-Object Name)
        if ($sites.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Standorte gefunden"})
        }
        $subnets = @(Get-ADReplicationSubnet -Filter * -ErrorAction SilentlyContinue)
        $dcs = @(Get-ADDomainController -Filter * -ErrorAction SilentlyContinue)
        return $sites | ForEach-Object {
            $site = $_
            $siteSubnets = @($subnets | Where-Object { $_.Site -eq $site.DistinguishedName })
            $siteDcs = @($dcs | Where-Object { $_.Site -eq $site.Name })
            [PSCustomObject]@{
                "Site" = $site.Name
                "Description" = $site.Description
                "Subnets" = ($siteSubnets.Name -join ", ")
                "DC_Count" = $siteDcs.Count
                "DCs" = ($siteDcs.Name -join ", ")
            }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADReplicationSubnets {
    try {
        $subnets = @(Get-ADReplicationSubnet -Filter * -Properties Description, Location -ErrorAction Stop | Sort-Object Name | Select-Object -First 500)
        if ($subnets.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Subnetze definiert"})
        }
        return $subnets | ForEach-Object {
            [PSCustomObject]@{
                "Subnet" = $_.Name
                "Site" = if ($_.Site) { ($_.Site -split ',')[0] -replace '^CN=', '' } else { "(kein Standort)" }
                "Location" = $_.Location
                "Description" = $_.Description
            }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADReplicationSiteLinks {
    try {
        $links = @(Get-ADReplicationSiteLink -Filter * -Properties Cost, ReplicationFrequencyInMinutes, SitesIncluded, Description -ErrorAction Stop | Sort-Object Name)
        if ($links.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Standortverknüpfungen gefunden"})
        }
        return $links | ForEach-Object {
            [PSCustomObject]@{
                "SiteLink" = $_.Name
                "Cost" = $_.Cost
                "Interval(min)" = $_.ReplicationFrequencyInMinutes
                "Sites" = (@($_.SitesIncluded) | ForEach-Object { ($_ -split ',')[0] -replace '^CN=', '' }) -join ", "
                "Description" = $_.Description
            }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADOptionalFeatures {
    try {
        $features = Get-ADOptionalFeature -Filter * -ErrorAction Stop | Select-Object Name, @{Name='Status';Expression={if($_.EnabledScopes.Count -gt 0) {"Enabled"} else {"Disabled"}}} | Sort-Object Name | Select-Object -First 50
        if ($null -eq $features) {
            return @([PSCustomObject]@{"Information" = "Keine optionalen Features gefunden"})
        }
        return $features | ForEach-Object { [PSCustomObject]@{"Feature" = $_.Name; "Status" = $_.Status} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ADDCServiceHealth {
    try {
        $dcs = Get-ADDomainController -Filter * -ErrorAction Stop
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($dc in $dcs) {
            $states = [System.Collections.Generic.List[object]]::new()
            $reachable = $true
            foreach ($svcName in @("NTDS", "DFSR", "DNS", "KDC")) {
                try {
                    $svc = Get-Service -Name $svcName -ComputerName $dc.HostName -ErrorAction Stop
                    $states.Add("$($svcName):$($svc.Status)")
                } catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
                    # Dienst auf diesem DC nicht vorhanden (z.B. DNS nicht installiert)
                    $states.Add("$($svcName):n/a")
                } catch {
                    $reachable = $false
                    break
                }
            }
            $data.Add([ordered]@{
                "DC" = $dc.Name
                "Reachable" = if ($reachable) {"Yes"} else {"No"}
                "Services" = if ($reachable) { $states -join ", " } else { "Unable to check" }
            })
        }
        if ($data.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine DC-Gesundheitsdaten verfügbar"})
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# EXTENDED DNS FUNCTIONS (ADDITIONAL)
# ============================================================================

function Get-DNSResourceRecords {
    param([int]$MaxZones = 20, [int]$MaxPerZone = 50)
    try {
        $zones = @(Get-DnsServerZone -ErrorAction Stop | Where-Object { -not $_.IsAutoCreated -and $_.ZoneName -ne "TrustAnchors" } | Select-Object -First $MaxZones)
        $records = [System.Collections.Generic.List[object]]::new()
        foreach ($zone in $zones) {
            $zoneRecords = Get-DnsServerResourceRecord -ZoneName $zone.ZoneName -ErrorAction SilentlyContinue | Select-Object -First $MaxPerZone
            foreach ($rr in $zoneRecords) {
                # RecordData ist je Typ unterschiedlich (IPv4Address, HostNameAlias, NameServer, ...) – generisch ausgeben
                $rrData = @($rr.RecordData.CimInstanceProperties | Where-Object { $null -ne $_.Value -and "$($_.Value)" -ne "" } | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "; "
                $records.Add([PSCustomObject]@{"Zone" = $zone.ZoneName; "Name" = $rr.HostName; "Type" = $rr.RecordType; "TTL" = [string]$rr.TimeToLive; "Data" = $rrData})
            }
        }
        if ($records.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine DNS-Ressourcen-Einträge gefunden"})
        }
        return $records
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DNSServerStatistics {
    try {
        # Modulqualifiziert aufrufen – der Funktionsname verdeckt sonst das gleichnamige Cmdlet (Endlosrekursion)
        $stats = DnsServer\Get-DnsServerStatistics -ErrorAction Stop -WarningAction SilentlyContinue
        if ($null -eq $stats) {
            return @([PSCustomObject]@{"Information" = "Keine DNS-Statistiken verfügbar"})
        }
        # Statistiken stehen in Unterobjekten (TimeStatistics, QueryStatistics, ...); deren Eigenschaften generisch auflisten
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($section in @("TimeStatistics", "QueryStatistics", "RecursionStatistics", "ErrorStatistics", "CacheStatistics")) {
            $sub = $stats.$section
            if ($null -eq $sub) { continue }
            $props = if ($null -ne $sub.CimInstanceProperties) { $sub.CimInstanceProperties } else { $sub.PSObject.Properties }
            foreach ($p in $props) {
                if ($p.Name -eq "PSComputerName" -or $null -ne $p.Value.CimInstanceProperties) { continue }
                $data.Add([PSCustomObject]@{"Bereich" = $section; "Statistik" = $p.Name; "Wert" = [string]$p.Value})
            }
        }
        if ($data.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine DNS-Statistiken verfügbar"})
        }
        return $data
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DNSServerScavengingSettings {
    try {
        $scavenging = Get-DnsServerScavenging -ErrorAction Stop
        if ($null -eq $scavenging) {
            return @([PSCustomObject]@{"Information" = "Keine Scavenging-Einstellungen gefunden"})
        }
        return @(
            [PSCustomObject]@{"Setting" = "ScavengingState"; "Wert" = if ($scavenging.ScavengingState) {"Aktiviert"} else {"Deaktiviert"}},
            [PSCustomObject]@{"Setting" = "ScavengingInterval"; "Wert" = [string]$scavenging.ScavengingInterval},
            [PSCustomObject]@{"Setting" = "RefreshInterval"; "Wert" = [string]$scavenging.RefreshInterval},
            [PSCustomObject]@{"Setting" = "NoRefreshInterval"; "Wert" = [string]$scavenging.NoRefreshInterval},
            [PSCustomObject]@{"Setting" = "LastScavengeTime"; "Wert" = [string]$scavenging.LastScavengeTime}
        )
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DNSSecSettings {
    try {
        # Es gibt kein Get-DnsServerDnsSec – DNSSEC-Status je Zone über IsSigned, Details über Get-DnsServerDnsSecZoneSetting
        $zones = @(Get-DnsServerZone -ErrorAction Stop | Where-Object { -not $_.IsAutoCreated -and $_.ZoneType -eq "Primary" -and $_.ZoneName -ne "TrustAnchors" } | Select-Object -First 50)
        if ($zones.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine primären Zonen gefunden"})
        }
        return $zones | ForEach-Object {
            $zone = $_
            $row = [ordered]@{"Zone" = $zone.ZoneName; "Signiert" = if ($zone.IsSigned) {"Ja"} else {"Nein"}; "DenialOfExistence" = $null; "KeyMaster" = $null; "KSK" = $null; "ZSK" = $null; "RFC5011-Rollover" = $null}
            if ($zone.IsSigned) {
                $sec = Get-DnsServerDnsSecZoneSetting -ZoneName $zone.ZoneName -ErrorAction SilentlyContinue
                $keys = @(Get-DnsServerSigningKey -ZoneName $zone.ZoneName -ErrorAction SilentlyContinue)
                $row["DenialOfExistence"] = [string]$sec.DenialOfExistence
                $row["KeyMaster"] = $sec.KeyMasterServer
                $row["KSK"] = @($keys | Where-Object { [string]$_.KeyType -eq "KeySigningKey" }).Count
                $row["ZSK"] = @($keys | Where-Object { [string]$_.KeyType -eq "ZoneSigningKey" }).Count
                $row["RFC5011-Rollover"] = $sec.EnableRfc5011KeyRollover
            }
            [PSCustomObject]$row
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# EXTENDED DHCP FUNCTIONS (ADDITIONAL)
# ============================================================================

function Get-DHCPServerLeases {
    param([int]$MaxPerScope = 100, [int]$MaxTotal = 1000)
    try {
        $scopes = @(Get-DhcpServerv4Scope -ErrorAction Stop)
        $leases = [System.Collections.Generic.List[object]]::new()
        foreach ($scope in $scopes) {
            if ($leases.Count -ge $MaxTotal) { break }
            $leases.AddRange(@(Get-DhcpServerv4Lease -ScopeId $scope.ScopeId -ErrorAction SilentlyContinue | Select-Object -First $MaxPerScope))
        }
        if ($leases.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine aktiven DHCP-Leases gefunden"})
        }
        return $leases | Select-Object -First $MaxTotal | ForEach-Object { [PSCustomObject]@{"IP" = [string]$_.IPAddress; "Scope" = [string]$_.ScopeId; "Client" = $_.HostName; "ClientId" = $_.ClientId; "State" = $_.AddressState; "LeaseExpires" = $_.LeaseExpiryTime} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DHCPServerOptions {
    try {
        $options = Get-DhcpServerv4OptionValue -ErrorAction Stop | Sort-Object OptionId | Select-Object -First 50
        if ($null -eq $options) {
            return @([PSCustomObject]@{"Information" = "Keine DHCP-Server-Optionen gefunden"})
        }
        return $options | ForEach-Object { [PSCustomObject]@{"OptionID" = $_.OptionId; "Name" = $_.Name; "Value" = (@($_.Value) -join ", ")} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DHCPv4ScopeStatistics {
    try {
        $scopes = @(Get-DhcpServerv4Scope -ErrorAction Stop)
        if ($scopes.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine DHCP-Scopes gefunden"})
        }
        # DhcpServerv4ScopeStatistics: InUse/Free/Reserved/PercentageInUse (AddressesInUse gibt es nur in der Server-Statistik)
        $stats = @(Get-DhcpServerv4ScopeStatistics -ErrorAction SilentlyContinue)
        return $scopes | ForEach-Object {
            $scope = $_
            $s = $stats | Where-Object { [string]$_.ScopeId -eq [string]$scope.ScopeId } | Select-Object -First 1
            [PSCustomObject]@{
                "Scope" = [string]$scope.ScopeId
                "Name" = $scope.Name
                "InUse" = $s.InUse
                "Free" = $s.Free
                "Reserved" = $s.Reserved
                "PercentageInUse" = if ($null -ne $s) { [Math]::Round($s.PercentageInUse, 1) } else { $null }
            }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DHCPServerAuthorization {
    try {
        # In Active Directory autorisierte DHCP-Server
        $servers = @(Get-DhcpServerInDC -ErrorAction Stop | Sort-Object DnsName)
        if ($servers.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine autorisierten DHCP-Server in AD gefunden"})
        }
        $localNames = [System.Collections.Generic.List[object]]::new()
        $localNames.Add($env:COMPUTERNAME)
        try { $localNames.Add([System.Net.Dns]::GetHostEntry([string]::Empty).HostName) } catch { }
        return $servers | ForEach-Object {
            $name = [string]$_.DnsName
            [PSCustomObject]@{
                "Server" = $name
                "IP" = [string]$_.IPAddress
                "DieserServer" = if (@($localNames | Where-Object { $_ -and ($name -eq $_ -or $name -like "$_.*") }).Count -gt 0) {"Ja"} else {"Nein"}
            }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DHCPFailover {
    try {
        $failover = @(Get-DhcpServerv4Failover -ErrorAction Stop | Select-Object -First 50)
        if ($failover.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine DHCP-Failover-Konfiguration gefunden"})
        }
        return $failover | ForEach-Object { [PSCustomObject]@{"Name" = $_.Name; "Partner" = $_.PartnerServer; "State" = $_.State; "Mode" = $_.Mode; "Role" = $_.ServerRole; "Scopes" = (@($_.ScopeId) | ForEach-Object { [string]$_ }) -join ", "} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# HTML EXPORT FUNCTIONS
# ============================================================================

function Export-AuditResultsToHtml {
    param(
        [string]$Title,
        [PSObject[]]$Data,
        [string]$Category
    )
    
    try {
        if ($null -eq $Data -or $Data.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Keine Daten zum Exportieren vorhanden!", "Warnung", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
            return $false
        }
        
        # HTML-Encoding aller dynamischen Werte im Berichtskopf (Schutz vor HTML-Injection/XSS)
        $encTitle = [System.Net.WebUtility]::HtmlEncode($Title)
        $encCategory = [System.Net.WebUtility]::HtmlEncode($Category)
        $encServer = [System.Net.WebUtility]::HtmlEncode($env:COMPUTERNAME)
        $encDomain = [System.Net.WebUtility]::HtmlEncode([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName)
        
        # HTML Header mit modernem Styling
        $htmlHeader = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WindowsServer_Audit - $encTitle</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 14px;
            opacity: 0.9;
        }
        .content {
            padding: 30px;
        }
        .audit-info {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .audit-info p {
            margin: 5px 0;
            font-size: 14px;
            line-height: 1.6;
        }
        .audit-info strong {
            color: #667eea;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        thead {
            background: #f3f4f6;
        }
        th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 2px solid #667eea;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
        }
        tr:nth-child(even) {
            background: #f9fafb;
        }
        tr:hover {
            background: #eff6ff;
        }
        .footer {
            background: #f3f4f6;
            padding: 20px 30px;
            text-align: center;
            font-size: 12px;
            color: #6b7280;
            border-top: 1px solid #e5e7eb;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚙️ WindowsServer_Audit - Audit Bericht</h1>
            <p>Windows Server Audit Tool v$($script:AppVersion)</p>
        </div>
        <div class="content">
            <div class="audit-info">
                <p><strong>Kategorie:</strong> $encCategory</p>
                <p><strong>Prüfung:</strong> $encTitle</p>
                <p><strong>Server:</strong> $encServer</p>
                <p><strong>Domain:</strong> $encDomain</p>
                <p><strong>Erstellt:</strong> $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')</p>
                <p><strong>Ergebnisse:</strong> $($Data.Count) Einträge</p>
            </div>
"@

        # Tabelle mit Daten konvertieren (ConvertTo-Html kodiert Zellwerte selbst)
        $htmlTable = ($Data | ConvertTo-Html -Fragment -As Table) -join "`r`n"
        
        # HTML Footer
        $htmlFooter = @"
        </div>
        <div class="footer">
            <p>$($script:AppName) v$($script:AppVersion) © PhinIT | Generiert: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')</p>
        </div>
    </div>
</body>
</html>
"@

        # Dateiname mit Zeitstempel erstellen
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $safeTitle = ($Title -replace '[^a-zA-Z0-9äöüÄÖÜß_]', '_').Substring(0, [Math]::Min(30, $Title.Length))
        $fileName = "AuditReport_${safeTitle}_${timestamp}.html"
        
        # SaveFileDialog anzeigen
        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*"
        $dialog.FileName = $fileName
        $dialog.DefaultExt = "html"
        $dialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
        
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $fullContent = $htmlHeader + "`r`n" + $htmlTable + "`r`n" + $htmlFooter
            $fullContent | Out-File -FilePath $dialog.FileName -Encoding UTF8 -Force
            
            [System.Windows.MessageBox]::Show("HTML-Export erfolgreich!`n`nDatei: $($dialog.FileName)", "Erfolg", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
            
            # Optional: HTML-Datei im Standard-Browser öffnen
            try {
                Start-Process $dialog.FileName
            } catch { }
            
            return $true
        }
        
        return $false
    } catch {
        [System.Windows.MessageBox]::Show("HTML-Export Fehler: $_", "Fehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        return $false
    }
}

# ============================================================================
# EVENT HANDLERS
# ============================================================================

# System Information Buttons
$window.FindName("ButtonSystemInfo").Add_Click({
    Start-AuditJob -FunctionName "Get-SystemInformation" -Status "System Information wird geladen..."
})

$window.FindName("ButtonOSInfo").Add_Click({
    Start-AuditJob -FunctionName "Get-OSDetails" -Status "OS Details werden geladen..."
})

$window.FindName("ButtonHardwareInfo").Add_Click({
    Start-AuditJob -FunctionName "Get-HardwareSummary" -Status "Hardware Info wird geladen..."
})

$window.FindName("ButtonCPUInfo").Add_Click({
    Start-AuditJob -FunctionName "Get-CPUDetails" -Status "CPU Details werden geladen..."
})

$window.FindName("ButtonMemoryInfo").Add_Click({
    Start-AuditJob -FunctionName "Get-MemoryDetails" -Status "Memory Details werden geladen..."
})

$window.FindName("ButtonStorageInfo").Add_Click({
    Start-AuditJob -FunctionName "Get-StorageSummary" -Status "Storage Info wird geladen..."
})

# Network Buttons
$window.FindName("ButtonNetConfig").Add_Click({
    Start-AuditJob -FunctionName "Get-NetworkConfiguration" -Status "Netzwerk IP Konfiguration wird geladen..."
})

$window.FindName("ButtonNetAdapters").Add_Click({
    Start-AuditJob -FunctionName "Get-NetworkAdapters" -Status "Netzwerk Adapter werden geladen..."
})

$window.FindName("ButtonTCPConnections").Add_Click({
    Start-AuditJob -FunctionName "Get-ActiveConnections" -Status "Aktive Verbindungen werden geladen..."
})

$window.FindName("ButtonFirewallRules").Add_Click({
    Start-AuditJob -FunctionName "Get-FirewallRules" -Status "Firewall Regeln werden geladen..."
})

# Services Buttons
$window.FindName("ButtonAutomaticServices").Add_Click({
    Start-AuditJob -FunctionName "Get-AutomaticServices" -Status "Automatische Services werden geladen..."
})

$window.FindName("ButtonRunningServices").Add_Click({
    Start-AuditJob -FunctionName "Get-RunningServices" -Status "Laufende Services werden geladen..."
})

$window.FindName("ButtonScheduledTasks").Add_Click({
    Start-AuditJob -FunctionName "Get-ScheduledTasks" -Status "Geplante Tasks werden geladen..."
})

# Roles & Features Buttons
$window.FindName("ButtonInstalledFeatures").Add_Click({
    Start-AuditJob -FunctionName "Get-InstalledFeatures" -Status "Installierte Features werden geladen..."
})

$window.FindName("ButtonInstalledPrograms").Add_Click({
    Start-AuditJob -FunctionName "Get-InstalledPrograms" -Status "Installierte Programme werden geladen..."
})

$window.FindName("ButtonWindowsUpdates").Add_Click({
    Start-AuditJob -FunctionName "Get-WindowsUpdates" -Status "Windows Updates werden geladen..."
})

# Event Logs Buttons
$window.FindName("ButtonSystemEvents").Add_Click({
    Start-AuditJob -FunctionName "Get-SystemEvents" -Status "System Events werden geladen..."
})

$window.FindName("ButtonAppEvents").Add_Click({
    Start-AuditJob -FunctionName "Get-ApplicationEvents" -Status "Application Events werden geladen..."
})

$window.FindName("ButtonSecurityEvents").Add_Click({
    Start-AuditJob -FunctionName "Get-SecurityEvents" -Status "Security Events werden geladen..."
})

$window.FindName("ButtonFailedLogons").Add_Click({
    Start-AuditJob -FunctionName "Get-FailedLogons" -Status "Failed Logons werden geladen..."
})

$window.FindName("ButtonAccountLockouts").Add_Click({
    Start-AuditJob -FunctionName "Get-AccountLockouts" -Status "Account Lockouts werden geladen..."
})

# Security & Users Buttons
$window.FindName("ButtonLocalUsers").Add_Click({
    Start-AuditJob -FunctionName "Get-LocalUsers" -Status "Lokale Benutzer werden geladen..."
})

$window.FindName("ButtonLocalGroups").Add_Click({
    Start-AuditJob -FunctionName "Get-LocalGroups" -Status "Lokale Gruppen werden geladen..."
})

$window.FindName("ButtonPrivilegeAudit").Add_Click({
    Start-AuditJob -FunctionName "Get-PrivilegeAudit" -Status "Privilege Audit wird geladen..."
})

# Active Directory Buttons
$window.FindName("ButtonADDC").Add_Click({
    Start-AuditJob -FunctionName "Get-ADDomainControllers" -Status "AD Domain Controller werden geladen..."
})

$window.FindName("ButtonADDomain").Add_Click({
    Start-AuditJob -FunctionName "Get-ADDomainInfo" -Status "AD Domain Info wird geladen..."
})

$window.FindName("ButtonADForest").Add_Click({
    Start-AuditJob -FunctionName "Get-ADForestInfo" -Status "AD Forest Info wird geladen..."
})

$window.FindName("ButtonADOUs").Add_Click({
    Start-AuditJob -FunctionName "Get-ADOUs" -Status "AD OUs werden geladen..."
})

$window.FindName("ButtonADAdmins").Add_Click({
    Start-AuditJob -FunctionName "Get-ADDomainAdmins" -Status "AD Admins werden geladen..."
})

$window.FindName("ButtonADComputers").Add_Click({
    Start-AuditJob -FunctionName "Get-ADComputers" -Status "AD Computer werden geladen..."
})

$window.FindName("ButtonADReplStatus").Add_Click({
    Start-AuditJob -FunctionName "Get-ADReplicationStatus" -Status "AD Replication Status wird geladen..."
})

$window.FindName("ButtonADTrusts").Add_Click({
    Start-AuditJob -FunctionName "Get-ADTrusts" -Status "AD Trusts werden geladen..."
})

$window.FindName("ButtonADDCExtended").Add_Click({
    Start-AuditJob -FunctionName "Get-ADDomainControllerExtended" -Status "AD DC Extended wird geladen..."
})

$window.FindName("ButtonADFunctionalLevels").Add_Click({
    Start-AuditJob -FunctionName "Get-ADDomainFunctionalLevel" -Status "AD Functional Levels werden geladen..."
})

$window.FindName("ButtonADSites").Add_Click({
    Start-AuditJob -FunctionName "Get-ADSiteConfiguration" -Status "AD Sites werden geladen..."
})

$window.FindName("ButtonADGPO").Add_Click({
    Start-AuditJob -FunctionName "Get-ADGroupPolicySummary" -Status "AD GPOs werden geladen..."
})

$window.FindName("ButtonADClustering").Add_Click({
    Start-AuditJob -FunctionName "Get-ADClusterInformation" -Status "AD Clustering wird geladen..."
})

# DNS Buttons
$window.FindName("ButtonDNSConfig").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSConfiguration" -Status "DNS Konfiguration wird geladen..."
})

$window.FindName("ButtonDNSZones").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSZones" -Status "DNS Zones werden geladen..."
})

$window.FindName("ButtonDNSForwarders").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSForwarders" -Status "DNS Forwarders werden geladen..."
})

$window.FindName("ButtonDNSCache").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSCache" -Status "DNS Cache wird geladen..."
})

# DHCP Buttons
$window.FindName("ButtonDHCPConfig").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPConfiguration" -Status "DHCP Konfiguration wird geladen..."
})

$window.FindName("ButtonDHCPv4Scopes").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPv4Scopes" -Status "DHCP IPv4 Scopes werden geladen..."
})

$window.FindName("ButtonDHCPv6Scopes").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPv6Scopes" -Status "DHCP IPv6 Scopes werden geladen..."
})

$window.FindName("ButtonDHCPReservations").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPReservations" -Status "DHCP Reservations werden geladen..."
})

# IIS Buttons
$window.FindName("ButtonIISWebsites").Add_Click({
    Start-AuditJob -FunctionName "Get-IISWebsites" -Status "IIS Websites werden geladen..."
})

$window.FindName("ButtonIISAppPools").Add_Click({
    Start-AuditJob -FunctionName "Get-IISAppPools" -Status "IIS App Pools werden geladen..."
})

$window.FindName("ButtonIISBindings").Add_Click({
    Start-AuditJob -FunctionName "Get-IISBindings" -Status "IIS Bindings werden geladen..."
})

# RDS Buttons
$window.FindName("ButtonRDSCollections").Add_Click({
    Start-AuditJob -FunctionName "Get-RDSCollections" -Status "RDS Collections werden geladen..."
})

$window.FindName("ButtonRDSSessionHosts").Add_Click({
    Start-AuditJob -FunctionName "Get-RDSSessionHosts" -Status "RDS Session Hosts werden geladen..."
})

$window.FindName("ButtonRDSLicensing").Add_Click({
    Start-AuditJob -FunctionName "Get-RDSActiveLicensing" -Status "RDS Licensing wird geladen..."
})

# DFS Buttons
$window.FindName("ButtonDFSNamespaces").Add_Click({
    Start-AuditJob -FunctionName "Get-DFSNamespaces" -Status "DFS Namespaces werden geladen..."
})

$window.FindName("ButtonDFSReplication").Add_Click({
    Start-AuditJob -FunctionName "Get-DFSReplicationGroups" -Status "DFS Replication Groups werden geladen..."
})

# Print Server Buttons
$window.FindName("ButtonPrinters").Add_Click({
    Start-AuditJob -FunctionName "Get-PrintServers" -Status "Printers werden geladen..."
})

$window.FindName("ButtonPrinterDrivers").Add_Click({
    Start-AuditJob -FunctionName "Get-PrinterDrivers" -Status "Printer Drivers werden geladen..."
})

# WSUS Buttons
$window.FindName("ButtonWSUSConfig").Add_Click({
    Start-AuditJob -FunctionName "Get-WSUSConfiguration" -Status "WSUS Konfiguration wird geladen..."
})

$window.FindName("ButtonWSUSGroups").Add_Click({
    Start-AuditJob -FunctionName "Get-WSUSComputerTargetGroups" -Status "WSUS Computer Target Groups werden geladen..."
})

$window.FindName("ButtonWSUSUpdates").Add_Click({
    Start-AuditJob -FunctionName "Get-WSUSUpdates" -Status "WSUS Updates werden geladen..."
})

# Hyper-V Buttons
$window.FindName("ButtonHyperVVMs").Add_Click({
    Start-AuditJob -FunctionName "Get-HyperVVirtualMachines" -Status "Hyper-V VMs werden geladen..."
})

$window.FindName("ButtonHyperVSwitches").Add_Click({
    Start-AuditJob -FunctionName "Get-HyperVSwitches" -Status "Hyper-V Switches werden geladen..."
})

$window.FindName("ButtonHyperVSnapshots").Add_Click({
    Start-AuditJob -FunctionName "Get-HyperVSnapshots" -Status "Hyper-V Snapshots werden geladen..."
})

# NRAS/NPS Buttons
$window.FindName("ButtonNPASConfig").Add_Click({
    Start-AuditJob -FunctionName "Get-NPASConfiguration" -Status "NRAS/NPS Konfiguration wird geladen..."
})

$window.FindName("ButtonNASClients").Add_Click({
    Start-AuditJob -FunctionName "Get-NASClients" -Status "NAS Clients werden geladen..."
})

# KMS Buttons
$window.FindName("ButtonKMSConfig").Add_Click({
    Start-AuditJob -FunctionName "Get-KMSConfiguration" -Status "KMS Konfiguration wird geladen..."
})

# WDS Buttons
$window.FindName("ButtonWDSConfig").Add_Click({
    Start-AuditJob -FunctionName "Get-WDSConfiguration" -Status "WDS Konfiguration wird geladen..."
})

$window.FindName("ButtonWDSBootImages").Add_Click({
    Start-AuditJob -FunctionName "Get-WDSBootImages" -Status "WDS Boot Images werden geladen..."
})

$window.FindName("ButtonWDSInstallImages").Add_Click({
    Start-AuditJob -FunctionName "Get-WDSInstallImages" -Status "WDS Install Images werden geladen..."
})

# File Services Buttons
$window.FindName("ButtonFileShares").Add_Click({
    Start-AuditJob -FunctionName "Get-FileShares" -Status "File Shares werden geladen..."
})

$window.FindName("ButtonSharePermissions").Add_Click({
    Start-AuditJob -FunctionName "Get-FileSharePermissions" -Status "Share Permissions werden geladen..."
})

$window.FindName("ButtonFileQuotas").Add_Click({
    Start-AuditJob -FunctionName "Get-FileServerQuotas" -Status "File Quotas werden geladen..."
})

$window.FindName("ButtonShadowCopies").Add_Click({
    Start-AuditJob -FunctionName "Get-ShadowCopies" -Status "Shadow Copies werden geladen..."
})

# Export & Clear Buttons
# CSV-Button exportiert direkt als CSV (bisher Ja/Nein-Abfrage CSV/HTML – Schließen des Dialogs löste den HTML-Export aus)
$window.FindName("ButtonExportCSV").Add_Click({
    try {
        if ($null -eq $DataGridResults.ItemsSource -or $DataGridResults.ItemsSource.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Keine Daten zum Exportieren vorhanden!", "Fehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
            return
        }

        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Filter = "CSV Files (*.csv)|*.csv|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
        $dialog.DefaultExt = "csv"
        $dialog.FileName = "WindowsServer_Audit_Export_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $dialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")

        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $exportPath = $dialog.FileName

            # Daten zu CSV exportieren (mit Schutz vor CSV-/Formel-Injection)
            $DataGridResults.ItemsSource | ConvertTo-CsvSafeObject | Export-Csv -Path $exportPath -Encoding UTF8 -NoTypeInformation -Force

            Update-Status "CSV-Export erfolgreich: $exportPath"
            [System.Windows.MessageBox]::Show("CSV-Export erfolgreich abgeschlossen!`n`nDatei: $exportPath", "Erfolg", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        }
    } catch {
        Update-Status "Export Fehler: $_"
        Set-StatusIndicator -State Error
        [System.Windows.MessageBox]::Show("Fehler beim Export: $_", "Fehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})

$window.FindName("ButtonClearOutput").Add_Click({
    Clear-Output
    Update-Status "Output gelöscht"
    Set-StatusIndicator -State Ready
})

# Help / About / Website (Kopf- und Fußzeile wie ActiveDirectory_Audit)
$window.FindName("ButtonHelp").Add_Click({
    [System.Windows.MessageBox]::Show(
        "$($script:AppName) – Kurzanleitung`n`n" +
        "1. Audit-Kategorie in der linken Seitenleiste aufklappen.`n`n" +
        "2. Gewünschte Prüfung anklicken – das Audit läuft im Hintergrund, die Fußzeile zeigt Status und Laufzeit.`n`n" +
        "3. Ergebnisse in der Tabelle sortieren/markieren.`n`n" +
        "4. 'Export CSV' bzw. 'Export HTML' speichert die aktuellen Ergebnisse.`n`n" +
        "Rollen-Audits (AD, DNS, DHCP, IIS, RDS, WSUS …) benötigen die jeweilige Rolle bzw. das PowerShell-Modul auf dem Server.",
        "Help",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    ) | Out-Null
})

$window.FindName("ButtonAbout").Add_Click({
    [System.Windows.MessageBox]::Show(
        "$($script:AppName) v$($script:AppVersion) ($($script:AppDate))`n`n" +
        "Windows Server Audit Tool`n`n" +
        "• 120+ Audit-Befehle in strukturierten Kategorien`n" +
        "• Ausführung im Hintergrund (GUI bleibt bedienbar)`n" +
        "• Export als CSV und HTML`n`n" +
        "© PhinIT - www.phinit.de",
        "About $($script:AppName)",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    ) | Out-Null
})

$window.FindName("linkWebsite").Add_MouseLeftButtonUp({
    try { Start-Process -FilePath 'https://www.phinit.de' } catch { Update-Status "Website konnte nicht geöffnet werden: $($_.Exception.Message)" }
})

$window.FindName("ButtonExportHTML").Add_Click({
    try {
        if ($null -eq $DataGridResults.ItemsSource -or $DataGridResults.ItemsSource.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Keine Daten zum Exportieren vorhanden!", "Fehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
            return
        }
        
        # HTML Export
        $title = $script:LastAuditTitle
        if ([string]::IsNullOrWhiteSpace($title)) { $title = "Audit Results" }
        
        Export-AuditResultsToHtml -Title $title -Data $DataGridResults.ItemsSource -Category "Audit"
    } catch {
        Update-Status "Export Fehler: $_"
        [System.Windows.MessageBox]::Show("Fehler beim Export: $_", "Fehler", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})

# ============================================================================
# EXTENDED CERTIFICATE FUNCTIONS
# ============================================================================

function Get-InstalledCertificates {
    try {
        $certs = Get-ChildItem -Path Cert:\LocalMachine\My -ErrorAction Stop | Select-Object -First 50
        if ($null -eq $certs) {
            return @([PSCustomObject]@{"Information" = "Keine Zertifikate gefunden"})
        }
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($cert in $certs) {
            $data.Add([ordered]@{
                "Thumbprint" = $cert.Thumbprint.Substring(0, 16)
                "Subject" = $cert.Subject
                "Issuer" = $cert.Issuer
                "ValidFrom" = $cert.NotBefore
                "ValidTo" = $cert.NotAfter
                "DaysLeft" = ($cert.NotAfter - (Get-Date)).Days
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-CertificateAuthorities {
    try {
        $cas = Get-ChildItem -Path Cert:\LocalMachine\Root -ErrorAction Stop | Select-Object -First 50
        if ($null -eq $cas) {
            return @([PSCustomObject]@{"Information" = "Keine CAs gefunden"})
        }
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($ca in $cas) {
            $data.Add([ordered]@{
                "CA-Name" = $ca.Subject
                "Thumbprint" = $ca.Thumbprint.Substring(0, 16)
                "ValidFrom" = $ca.NotBefore
                "ValidTo" = $ca.NotAfter
                "Issuer" = $ca.Issuer
            })
        }
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ExpiringCertificates {
    try {
        $certs = Get-ChildItem -Path Cert:\LocalMachine\My -ErrorAction Stop
        $expiring = [System.Collections.Generic.List[object]]::new()
        foreach ($cert in $certs) {
            $daysLeft = ($cert.NotAfter - (Get-Date)).Days
            if ($daysLeft -le 90 -and $daysLeft -ge 0) {
                $expiring.Add([ordered]@{
                    "Subject" = $cert.Subject
                    "DaysLeft" = $daysLeft
                    "ExpiresOn" = $cert.NotAfter
                    "Status" = if ($daysLeft -le 30) {"KRITISCH"} else {"WARNUNG"}
                })
            }
        }
        if ($expiring.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine ablaufenden Zertifikate in den nächsten 90 Tagen"})
        }
        return $expiring | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

# ============================================================================
# MICROSOFT SERVER ROLES FUNCTIONS
# ============================================================================

function Get-SQLServerInfo {
    try {
        # Standard- und benannte Instanzen (MSSQLSERVER / MSSQL$<Instanz>) inkl. Agent, Browser, SSRS/SSAS/SSIS
        $services = @(Get-Service -Name "MSSQLSERVER", 'MSSQL$*', "SQLSERVERAGENT", 'SQLAgent$*', "SQLBrowser", "SQLWriter", "ReportServer*", "SQLServerReportingServices", "MSSQLServerOLAPService", 'MSOLAP$*', "MsDtsServer*" -ErrorAction SilentlyContinue | Sort-Object Name)
        if ($services.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "SQL Server nicht installiert"})
        }
        return $services | ForEach-Object { [PSCustomObject]@{"Service" = $_.Name; "DisplayName" = $_.DisplayName; "Status" = [string]$_.Status; "StartType" = [string]$_.StartType} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-ExchangeServerInfo {
    try {
        $exService = Get-Service -Name MSExchangeServiceHost -ErrorAction SilentlyContinue
        if ($null -eq $exService) {
            return @([PSCustomObject]@{"Information" = "Exchange Server nicht installiert"})
        }
        
        $data = @(
            [ordered]@{"Component" = "Exchange Service Host"; "Status" = $exService.Status},
            [ordered]@{"Component" = "Information Store"; "Status" = (Get-Service -Name MSExchangeIS -ErrorAction SilentlyContinue).Status},
            [ordered]@{"Component" = "Transport"; "Status" = (Get-Service -Name MSExchangeTransport -ErrorAction SilentlyContinue).Status}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-SharePointInfo {
    try {
        $spService = Get-Service -Name SPAdminV4 -ErrorAction SilentlyContinue
        if ($null -eq $spService) {
            return @([PSCustomObject]@{"Information" = "SharePoint nicht installiert"})
        }
        
        $data = @(
            [ordered]@{"Service" = "SP Admin"; "Status" = $spService.Status},
            [ordered]@{"Service" = "SP Timer"; "Status" = (Get-Service -Name SPTimerV4 -ErrorAction SilentlyContinue).Status}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-DomainControllerHealth {
    try {
        if ($null -eq (Get-Command dcdiag.exe -ErrorAction SilentlyContinue)) {
            return @([PSCustomObject]@{"Information" = "dcdiag nicht verfügbar (kein Domänencontroller bzw. RSAT AD DS nicht installiert)"})
        }
        # Ergebniszeilen beginnen mit Punkten: "......... DC1 passed test Connectivity" bzw. "... hat den Test ... bestanden."
        $output = & dcdiag.exe 2>&1
        $data = [System.Collections.Generic.List[object]]::new()
        foreach ($line in $output) {
            if ([string]$line -notmatch '^\s*\.{3,}\s*(.+?)\s*$') { continue }
            $text = $Matches[1]
            $result = if ($text -match 'failed|nicht bestanden') { "Fehler" } elseif ($text -match 'passed|bestanden') { "OK" } else { "Info" }
            $data.Add([PSCustomObject]@{"Ergebnis" = $result; "Test" = $text})
        }
        if ($data.Count -eq 0) {
            return @([PSCustomObject]@{"Ergebnis" = "Info"; "Test" = (($output | Select-Object -Last 5) -join " ").Trim()})
        }
        return $data
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-FirewallProfiles {
    try {
        $profiles = Get-NetFirewallProfile -All -ErrorAction Stop
        if ($null -eq $profiles) {
            return @([PSCustomObject]@{"Information" = "Firewall Status nicht verfügbar"})
        }
        # Enabled ist ein GpoBoolean (True/False/NotConfigured)
        return $profiles | ForEach-Object { [PSCustomObject]@{"Profile" = $_.Name; "Enabled" = switch ([string]$_.Enabled) { "True" {"Ja"} "False" {"Nein"} default {"Nicht konfiguriert"} }; "DefaultInbound" = [string]$_.DefaultInboundAction; "DefaultOutbound" = [string]$_.DefaultOutboundAction; "LogBlocked" = [string]$_.LogBlocked} }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-WindowsDefender {
    try {
        $defender = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
        if ($null -eq $defender) {
            return @([PSCustomObject]@{"Information" = "Microsoft Defender nicht verfügbar"})
        }
        $status = Get-MpComputerStatus -ErrorAction SilentlyContinue
        $data = @(
            [ordered]@{"Component" = "Service Status"; "Status" = [string]$defender.Status},
            [ordered]@{"Component" = "Antivirus"; "Status" = if ($status.AntivirusEnabled) {"Aktiviert"} else {"Deaktiviert"}},
            [ordered]@{"Component" = "Real-time Protection"; "Status" = if ($status.RealTimeProtectionEnabled) {"Aktiviert"} else {"Deaktiviert"}},
            [ordered]@{"Component" = "Signature Version"; "Status" = $status.AntivirusSignatureVersion},
            [ordered]@{"Component" = "Definitions Update"; "Status" = [string]$status.AntivirusSignatureLastUpdated},
            [ordered]@{"Component" = "Last Quick Scan"; "Status" = [string]$status.QuickScanEndTime},
            [ordered]@{"Component" = "Last Full Scan"; "Status" = [string]$status.FullScanEndTime}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-UserAccountControl {
    try {
        $uac = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ErrorAction Stop
        $adminPrompt = switch ($uac.ConsentPromptBehaviorAdmin) {
            0 {"Ohne Nachfrage erhöhen"}
            1 {"Anmeldeinformationen (sicherer Desktop)"}
            2 {"Zustimmung (sicherer Desktop)"}
            3 {"Anmeldeinformationen"}
            4 {"Zustimmung"}
            5 {"Zustimmung für Nicht-Windows-Binärdateien (Standard)"}
            default {[string]$uac.ConsentPromptBehaviorAdmin}
        }
        $data = @(
            [ordered]@{"Setting" = "User Account Control (EnableLUA)"; "Status" = if ($uac.EnableLUA -eq 1) {"Aktiviert"} else {"Deaktiviert"}},
            [ordered]@{"Setting" = "Eingabeaufforderung für Administratoren"; "Status" = $adminPrompt},
            [ordered]@{"Setting" = "Sicherer Desktop"; "Status" = if ($uac.PromptOnSecureDesktop -eq 0) {"Deaktiviert"} else {"Aktiviert"}},
            [ordered]@{"Setting" = "Admin-Genehmigungsmodus für integriertes Administratorkonto"; "Status" = if ($uac.FilterAdministratorToken -eq 1) {"Aktiviert"} else {"Deaktiviert"}}
        )
        return $data | ForEach-Object { [PSCustomObject]$_ }
    } catch {
        return @([PSCustomObject]@{"Fehler" = $_.Exception.Message})
    }
}

function Get-SystemBackupConfig {
    try {
        if ($null -eq (Get-Command Get-WBBackupSet -ErrorAction SilentlyContinue)) {
            return @([PSCustomObject]@{"Information" = "Windows Server-Sicherung nicht installiert (Feature Windows-Server-Backup)"})
        }
        $backups = @(Get-WBBackupSet -ErrorAction Stop | Sort-Object BackupTime -Descending | Select-Object -First 10)
        if ($backups.Count -eq 0) {
            return @([PSCustomObject]@{"Information" = "Keine Sicherungen vorhanden"})
        }
        return $backups | ForEach-Object {
            [PSCustomObject]@{
                "BackupTime" = $_.BackupTime
                "VersionId" = $_.VersionId
                "Target" = [string]$_.BackupTarget.Label
                "Volumes" = (@($_.Volume) | ForEach-Object { $_.MountPath }) -join ", "
                "RecoverableItems" = [string]$_.RecoverableItems
            }
        }
    } catch {
        return @([PSCustomObject]@{"Fehler" = "Windows Server-Sicherung: " + $_.Exception.Message})
    }
}

# PKI / Certificate Buttons
$window.FindName("ButtonInstalledCertificates").Add_Click({
    Start-AuditJob -FunctionName "Get-InstalledCertificates" -Status "Installierte Zertifikate werden geladen..."
})

$window.FindName("ButtonCertificateAuthorities").Add_Click({
    Start-AuditJob -FunctionName "Get-CertificateAuthorities" -Status "Zertifizierungsstellen werden geladen..."
})

$window.FindName("ButtonExpiringCertificates").Add_Click({
    Start-AuditJob -FunctionName "Get-ExpiringCertificates" -Status "Ablaufende Zertifikate werden geladen..."
})

# Erweiterte AD-Buttons
$window.FindName("ButtonADUsers").Add_Click({
    Start-AuditJob -FunctionName "Get-ADUserAccounts" -Status "AD Benutzerkonten werden geladen..."
})

$window.FindName("ButtonADFSMO").Add_Click({
    Start-AuditJob -FunctionName "Get-ADFSMORoles" -Status "AD FSMO-Rollen werden geladen..."
})

$window.FindName("ButtonADGroups").Add_Click({
    Start-AuditJob -FunctionName "Get-ADGroupAccounts" -Status "AD Gruppen werden geladen..."
})

$window.FindName("ButtonADServiceAccounts").Add_Click({
    Start-AuditJob -FunctionName "Get-ADServiceAccounts" -Status "AD Dienstkonten werden geladen..."
})

$window.FindName("ButtonADComputerSummary").Add_Click({
    Start-AuditJob -FunctionName "Get-ADComputerAccounts" -Status "AD Computerkonten-Übersicht wird geladen..."
})

$window.FindName("ButtonADPasswordPolicy").Add_Click({
    Start-AuditJob -FunctionName "Get-ADPasswordPolicy" -Status "AD Kennwortrichtlinien werden geladen..."
})

$window.FindName("ButtonADReplSites").Add_Click({
    Start-AuditJob -FunctionName "Get-ADReplicationSites" -Status "AD Replikationsstandorte werden geladen..."
})

$window.FindName("ButtonADReplSubnets").Add_Click({
    Start-AuditJob -FunctionName "Get-ADReplicationSubnets" -Status "AD Subnetze werden geladen..."
})

$window.FindName("ButtonADSiteLinks").Add_Click({
    Start-AuditJob -FunctionName "Get-ADReplicationSiteLinks" -Status "AD Standortverknüpfungen werden geladen..."
})

$window.FindName("ButtonADOptionalFeatures").Add_Click({
    Start-AuditJob -FunctionName "Get-ADOptionalFeatures" -Status "AD Optionale Features werden geladen..."
})

$window.FindName("ButtonADDCServiceHealth").Add_Click({
    Start-AuditJob -FunctionName "Get-ADDCServiceHealth" -Status "DC Dienststatus wird geladen..."
})

# Weitere Buttons (bislang ungenutzte Audit-Funktionen)
$window.FindName("ButtonFirewallProfiles").Add_Click({
    Start-AuditJob -FunctionName "Get-FirewallProfiles" -Status "Firewall Profile werden geladen..."
})

$window.FindName("ButtonServerBackup").Add_Click({
    Start-AuditJob -FunctionName "Get-SystemBackupConfig" -Status "Windows Server-Sicherungen werden geladen..."
})

$window.FindName("ButtonDefender").Add_Click({
    Start-AuditJob -FunctionName "Get-WindowsDefender" -Status "Microsoft Defender Status wird geladen..."
})

$window.FindName("ButtonUAC").Add_Click({
    Start-AuditJob -FunctionName "Get-UserAccountControl" -Status "UAC Einstellungen werden geladen..."
})

$window.FindName("ButtonADDcdiag").Add_Click({
    Start-AuditJob -FunctionName "Get-DomainControllerHealth" -Status "DC Diagnose (dcdiag) wird geladen..."
})

$window.FindName("ButtonDNSRecords").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSResourceRecords" -Status "DNS Ressourceneinträge werden geladen..."
})

$window.FindName("ButtonDNSStatistics").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSServerStatistics" -Status "DNS Statistiken werden geladen..."
})

$window.FindName("ButtonDNSScavenging").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSServerScavengingSettings" -Status "DNS Scavenging Einstellungen werden geladen..."
})

$window.FindName("ButtonDNSSec").Add_Click({
    Start-AuditJob -FunctionName "Get-DNSSecSettings" -Status "DNSSEC Zonen werden geladen..."
})

$window.FindName("ButtonDHCPAuthorized").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPServerAuthorization" -Status "Autorisierte DHCP Server werden geladen..."
})

$window.FindName("ButtonDHCPLeases").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPServerLeases" -Status "DHCP Leases werden geladen..."
})

$window.FindName("ButtonDHCPOptions").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPServerOptions" -Status "DHCP Serveroptionen werden geladen..."
})

$window.FindName("ButtonDHCPScopeStats").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPv4ScopeStatistics" -Status "DHCP Scope Statistiken werden geladen..."
})

$window.FindName("ButtonDHCPFailover").Add_Click({
    Start-AuditJob -FunctionName "Get-DHCPFailover" -Status "DHCP Failover wird geladen..."
})

$window.FindName("ButtonSQLServer").Add_Click({
    Start-AuditJob -FunctionName "Get-SQLServerInfo" -Status "SQL Server Dienste werden geladen..."
})

$window.FindName("ButtonExchange").Add_Click({
    Start-AuditJob -FunctionName "Get-ExchangeServerInfo" -Status "Exchange Server Dienste werden geladen..."
})

$window.FindName("ButtonSharePoint").Add_Click({
    Start-AuditJob -FunctionName "Get-SharePointInfo" -Status "SharePoint Dienste werden geladen..."
})

# Beim Schließen laufenden Hintergrund-Audit abbrechen
$window.Add_Closing({
    $script:AuditTimer.Stop()
    if ($null -ne $script:AuditJob) {
        try { [void]$script:AuditJob.PowerShell.BeginStop($null, $null) } catch { }
    }
})

# ============================================================================
# MAIN
# ============================================================================

[void]$window.ShowDialog()
# Nur abgeschlossene Aufträge freigeben – ein noch laufender (gestoppter) Runspace endet mit dem Prozess
if ($null -ne $script:AuditJob -and $script:AuditJob.Handle.IsCompleted) { Remove-AuditJob }
