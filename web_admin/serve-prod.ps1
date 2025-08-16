# Production Web Server Script for PatrolShield Admin
# This script serves the built Flutter web app for production

Write-Host "Starting PatrolShield Production Web Server..." -ForegroundColor Green

# Ensure we're in the right directory
Set-Location -Path $PSScriptRoot

# Check if the build directory exists
if (-not (Test-Path "build\web")) {
    Write-Host "Error: build\web directory not found. Please run 'flutter build web --release' first." -ForegroundColor Red
    exit 1
}

# Check if Python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python to serve the production build" -ForegroundColor Yellow
    exit 1
}

# Navigate to build directory
Set-Location -Path "build\web"

# Start the production server
Write-Host "Production server starting on http://localhost:8080..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

try {
    python -m http.server 8080
} catch {
    Write-Host "Error starting server: $_" -ForegroundColor Red
    exit 1
}