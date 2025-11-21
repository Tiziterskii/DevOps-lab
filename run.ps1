# Skrypt PowerShell do zarządzania aplikacją DemoWebService

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  DemoWebService Manager" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

function Show-Menu {
    Write-Host "Wybierz opcję:" -ForegroundColor Yellow
    Write-Host "1. Uruchom wszystkie kontenery (docker-compose up)"
    Write-Host "2. Zatrzymaj wszystkie kontenery (docker-compose down)"
    Write-Host "3. Przebuduj i uruchom (docker-compose up --build)"
    Write-Host "4. Pokaż status kontenerów"
    Write-Host "5. Pokaż logi wszystkich kontenerów"
    Write-Host "6. Pokaż logi backend"
    Write-Host "7. Pokaż logi frontend"
    Write-Host "8. Pokaż logi bazy danych"
    Write-Host "9. Otwórz aplikację w przeglądarce"
    Write-Host "10. Build pojedynczego kontenera backend (zgodnie z wymaganiami)"
    Write-Host "0. Wyjście"
    Write-Host ""
}

function Start-AllContainers {
    Write-Host "Uruchamianie kontenerów..." -ForegroundColor Green
    docker-compose up -d
    Write-Host ""
    Write-Host "✓ Kontenery uruchomione!" -ForegroundColor Green
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Backend API: http://localhost:8080/api" -ForegroundColor Cyan
}

function Stop-AllContainers {
    Write-Host "Zatrzymywanie kontenerów..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✓ Kontenery zatrzymane!" -ForegroundColor Green
}

function Rebuild-Containers {
    Write-Host "Przebudowywanie i uruchamianie kontenerów..." -ForegroundColor Green
    docker-compose up -d --build
    Write-Host "✓ Kontenery przebudowane i uruchomione!" -ForegroundColor Green
}

function Show-Status {
    Write-Host "Status kontenerów:" -ForegroundColor Cyan
    docker-compose ps
}

function Show-AllLogs {
    Write-Host "Wyświetlanie logów wszystkich kontenerów..." -ForegroundColor Cyan
    docker-compose logs --tail=50
}

function Show-BackendLogs {
    Write-Host "Wyświetlanie logów backend..." -ForegroundColor Cyan
    docker-compose logs backend --tail=50 -f
}

function Show-FrontendLogs {
    Write-Host "Wyświetlanie logów frontend..." -ForegroundColor Cyan
    docker-compose logs frontend --tail=50 -f
}

function Show-DatabaseLogs {
    Write-Host "Wyświetlanie logów bazy danych..." -ForegroundColor Cyan
    docker-compose logs sqlserver --tail=50 -f
}

function Open-Application {
    Write-Host "Otwieranie aplikacji w przeglądarce..." -ForegroundColor Cyan
    Start-Process "http://localhost:3000"
    Start-Process "http://localhost:8080/api/products"
}

function Build-SingleBackend {
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "Build pojedynczego kontenera backend" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "1. docker build -t demowebbuild -f DockerfileBuild ." -ForegroundColor Yellow
    docker build -t demowebbuild -f DockerfileBuild .
    
    Write-Host ""
    Write-Host "✓ Obraz zbudowany!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Aby uruchomić kontener, użyj jednej z poniższych komend:" -ForegroundColor Cyan
    Write-Host "2. docker run -itd -p 8080:8080 demowebbuild" -ForegroundColor Yellow
    Write-Host "   LUB" -ForegroundColor White
    Write-Host "3. docker run -itd -p 8080:8080 --name demowebbuild demowebbuild" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "UWAGA: Pojedynczy kontener backend nie będzie działał bez bazy danych!" -ForegroundColor Red
    Write-Host "       Zalecane jest użycie docker-compose (opcja 1 z menu)." -ForegroundColor Red
}

# Główna pętla menu
do {
    Write-Host ""
    Show-Menu
    $choice = Read-Host "Wybór"
    Write-Host ""

    switch ($choice) {
        "1" { Start-AllContainers }
        "2" { Stop-AllContainers }
        "3" { Rebuild-Containers }
        "4" { Show-Status }
        "5" { Show-AllLogs }
        "6" { Show-BackendLogs }
        "7" { Show-FrontendLogs }
        "8" { Show-DatabaseLogs }
        "9" { Open-Application }
        "10" { Build-SingleBackend }
        "0" { 
            Write-Host "Do widzenia!" -ForegroundColor Green
            break 
        }
        default { 
            Write-Host "Nieprawidłowy wybór!" -ForegroundColor Red 
        }
    }

    if ($choice -ne "0" -and $choice -ne "6" -and $choice -ne "7" -and $choice -ne "8") {
        Write-Host ""
        Read-Host "Naciśnij Enter, aby kontynuować"
        Clear-Host
    }
} while ($choice -ne "0")
