# Config.psm1
# Configuration module for route XML processing

class Config {
    # Static properties
    static [string]$Version = "1.0.0"
    static [string]$RootPath
    static [hashtable]$Settings

    # Initialize configuration
    static [void] Initialize() {
        # Set root path
        [Config]::RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        
        # Define default settings
        [Config]::Settings = @{
            Paths = @{
                Data = Join-Path ([Config]::RootPath) "data"
                Current = Join-Path ([Config]::RootPath) "data\current"
                Archive = Join-Path ([Config]::RootPath) "data\archive"
                Delta = Join-Path ([Config]::RootPath) "data\delta"
                Logs = Join-Path ([Config]::RootPath) "logs"
            }
            Database = @{
                Path = Join-Path ([Config]::RootPath) "data\versions.db"
                ConnectionString = "Data Source={0};Version=3;"
            }
            FilePatterns = @{
                XmlInput = "NOR_NOR-Line-*.xml"
                EntityTypes = @(
                    "lines",
                    "routes",
                    "route_points",
                    "journey_patterns",
                    "stop_sequences",
                    "service_journeys",
                    "passing_times",
                    "dated_journeys"
                )
            }
            Logging = @{
                Enabled = $true
                Level = "Info" # Debug, Info, Warning, Error
                RetentionDays = 30
                TimeFormat = "yyyy-MM-dd HH:mm:ss"
            }
        }

        # Ensure directories exist
        [Config]::EnsureDirectories()
    }

    # Create required directories
    static [void] EnsureDirectories() {
        foreach ($path in [Config]::Settings.Paths.Values) {
            if (-not (Test-Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
                Write-Host "Created directory: $path"
            }
        }
    }

    # Get full path for a data file
    static [string] GetDataPath([string]$entityType, [string]$extension = "json") {
        return Join-Path ([Config]::Settings.Paths.Current) "$entityType.$extension"
    }

    # Get delta path for a specific timestamp
    static [string] GetDeltaPath([datetime]$timestamp) {
        $dateFolder = $timestamp.ToString("yyyyMMdd_HHmmss")
        return Join-Path ([Config]::Settings.Paths.Delta) $dateFolder
    }

    # Get archive path for a specific timestamp
    static [string] GetArchivePath([datetime]$timestamp) {
        $dateFolder = $timestamp.ToString("yyyyMMdd_HHmmss")
        return Join-Path ([Config]::Settings.Paths.Archive) $dateFolder
    }

    # Get database connection string
    static [string] GetDbConnectionString() {
        return [Config]::Settings.Database.ConnectionString -f [Config]::Settings.Database.Path
    }
}

# Initialize configuration when module is loaded
[Config]::Initialize()

# Export the Config class
Export-ModuleMember -Variable Config