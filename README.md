# DemoWebService - Full Stack Application w Docker
<!-- Automatyczne pobieranie na serwie linux test -->
Kompletna aplikacja webowa składająca się z 3 kontenerów Docker połączonych wirtualną siecią.

## 🏗️ Architektura

```
┌─────────────────────────────────────┐
│   Frontend (Nginx + HTML/JS)       │
│         Port 3000                   │
└──────────────┬──────────────────────┘
               │
               │ demo-network
               ▼
┌─────────────────────────────────────┐
│   Backend (ASP.NET Core Web API)    │
│         Port 8080                   │
└──────────────┬──────────────────────┘
               │
               │ demo-network
               ▼
┌─────────────────────────────────────┐
│   Database (SQL Server 2022)        │
│         Port 1433                   │
└─────────────────────────────────────┘
```

## 📦 Komponenty

### 1. **Frontend** (Port 3000)
- Nginx Alpine jako serwer HTTP
- Interfejs użytkownika HTML/CSS/JavaScript
- Komunikacja z API przez AJAX
- Zarządzanie produktami (CRUD)

### 2. **Backend** (Port 8080)
- ASP.NET Core 9.0 Web API
- Entity Framework Core
- RESTful API endpoints
- CORS enabled

### 3. **Database** (Port 1433)
- SQL Server 2022 Express
- Persistence poprzez Docker volume
- Health check
- Automatyczna inicjalizacja

## 🚀 Uruchomienie

### 🐧 Na serwerze Linux (deployment produkcyjny)

**Szczegółowe instrukcje**: Zobacz [LINUX-SETUP.md](LINUX-SETUP.md)

**Quick Start:**
```bash
# Sklonuj repo
git clone https://github.com/Tiziterskii/DevOps-lab.git
cd DevOps-lab

# Uruchom automatyczny skrypt
chmod +x start-linux.sh
./start-linux.sh

# LUB manualnie
docker-compose up -d --build

# Sprawdź IP serwera
hostname -I

# Otwórz w przeglądarce na swoim komputerze:
# http://TWOJ_IP_SERWERA:3000
```

### 💻 Lokalnie na Windows (development)

### Docker Compose (Rekomendowane)

#### Uruchomienie wszystkich 3 kontenerów:
```bash
docker-compose up -d
```

#### Sprawdzenie statusu kontenerów:
```bash
docker-compose ps
```

#### Wyświetlenie logów:
```bash
# Wszystkie kontenery
docker-compose logs -f

# Konkretny kontener
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f sqlserver
```

#### Zatrzymanie i usunięcie kontenerów:
```bash
docker-compose down
```

#### Zatrzymanie + usunięcie wolumenów (dane bazy):
```bash
docker-compose down -v
```

#### Przebudowanie i uruchomienie:
```bash
docker-compose up -d --build
```

### Pojedyncze kontenery (zgodnie z wymaganiami)

#### 1. Backend (demowebbuild):
```bash
# Build
docker build -t demowebbuild -f DockerfileBuild .

# Run (opcja 1)
docker run -itd -p 8080:8080 demowebbuild

# Run (opcja 2 - z nazwą)
docker run -itd -p 8080:8080 --name demowebbuild demowebbuild
```

**Uwaga:** Pojedynczy kontener backend nie będzie działał bez bazy danych!

## 🌐 Dostęp do aplikacji

Po uruchomieniu docker-compose:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api
- **Swagger (w development)**: http://localhost:8080/openapi/v1.json
- **Database**: localhost:1433 (sa / YourStrong@Passw0rd)

## 📡 API Endpoints

### Products

| Metoda | Endpoint | Opis |
|--------|----------|------|
| GET | `/api/products` | Pobierz wszystkie produkty |
| GET | `/api/products/{id}` | Pobierz produkt po ID |
| POST | `/api/products` | Utwórz nowy produkt |
| PUT | `/api/products/{id}` | Zaktualizuj produkt |
| DELETE | `/api/products/{id}` | Usuń produkt |
| GET | `/api/health` | Health check |

### Przykłady żądań:

#### Pobierz wszystkie produkty:
```bash
curl http://localhost:8080/api/products
```

```powershell
Invoke-WebRequest -Uri http://localhost:8080/api/products
```

#### Dodaj nowy produkt:
```bash
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Nowy Produkt","description":"Opis","price":99.99,"stock":10}'
```

```powershell
$body = @{
    name = "Nowy Produkt"
    description = "Opis produktu"
    price = 99.99
    stock = 10
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8080/api/products `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

## 🔧 Technologie

### Backend
- ASP.NET Core 9.0
- Entity Framework Core 9.0
- SQL Server Driver
- Minimal APIs

### Frontend
- HTML5
- CSS3 (Responsive Design)
- Vanilla JavaScript (ES6+)
- Fetch API

### Infrastructure
- Docker & Docker Compose
- Nginx Alpine
- SQL Server 2022 Express
- Bridge Network

## 📁 Struktura projektu

```
DevOps-lab/
├── Backend/                    # Aplikacja ASP.NET Core
│   ├── Models/                 # Modele danych
│   │   └── Product.cs
│   ├── Data/                   # DbContext
│   │   └── AppDbContext.cs
│   ├── Program.cs              # Entry point + API endpoints
│   ├── Backend.csproj          # Plik projektu
│   └── appsettings.json        # Konfiguracja (connection string)
├── Frontend/                   # Aplikacja frontendowa
│   ├── index.html              # Główna strona
│   ├── app.js                  # Logika aplikacji
│   └── styles.css              # Style CSS
├── DockerfileBuild             # Dockerfile dla backend
├── DockerfileFrontend          # Dockerfile dla frontend
├── docker-compose.yml          # Orkiestracja 3 kontenerów
├── nginx.conf                  # Konfiguracja Nginx
├── .dockerignore               # Ignorowane pliki
└── README.md                   # Dokumentacja
```

## 🔍 Debugowanie

### Sprawdzenie sieci Docker:
```bash
docker network ls
docker network inspect devops-lab_demo-network
```

### Sprawdzenie wolumenów:
```bash
docker volume ls
docker volume inspect devops-lab_sqldata
```

### Wejście do kontenera:
```bash
# Backend
docker exec -it demowebservice-api bash

# Frontend
docker exec -it demowebservice-frontend sh

# Database
docker exec -it demowebservice-db bash
```

### Test połączenia z bazą danych:
```bash
docker exec -it demowebservice-db /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "YourStrong@Passw0rd" -C \
  -Q "SELECT name FROM sys.databases"
```

## 🛠️ Rozwiązywanie problemów

### Backend nie może połączyć się z bazą:
1. Sprawdź czy SQL Server jest healthy: `docker-compose ps`
2. Zaczekaj 10-20 sekund na pełną inicjalizację bazy
3. Sprawdź logi: `docker-compose logs sqlserver`

### Frontend nie może połączyć się z Backend:
1. Sprawdź czy backend działa: `curl http://localhost:8080/api/health`
2. Sprawdź konfigurację CORS w `Program.cs`
3. Sprawdź logi: `docker-compose logs backend`

### Brak uprawnień do Docker:
```bash
# Windows: Uruchom PowerShell jako Administrator
# Linux: Dodaj użytkownika do grupy docker
sudo usermod -aG docker $USER
```

## 📊 Dane testowe

Aplikacja automatycznie tworzy bazę danych z przykładowymi produktami:
- Laptop (1200 PLN, 10 szt.)
- Mouse (25.99 PLN, 50 szt.)
- Keyboard (89.99 PLN, 30 szt.)

## 🔐 Bezpieczeństwo

⚠️ **UWAGA**: To jest aplikacja demonstracyjna!

Nie używaj w produkcji bez:
- Zmiany domyślnych haseł
- Konfiguracji HTTPS
- Proper authentication & authorization
- Rate limiting
- Input validation
- SQL injection protection (EF Core zapewnia to automatycznie)

## 📝 Notatki

- Wszystkie kontenery są połączone wirtualną siecią `demo-network` typu bridge
- Dane bazy SQL Server są przechowywane w wolumenie Docker `sqldata`
- Backend automatycznie czeka na gotowość bazy danych (health check)
- Frontend jest dostępny przez Nginx na porcie 3000
- Backend API działa na porcie 8080 zgodnie z wymaganiami

## 🎯 Spełnione wymagania

✅ **Zadanie 1**: Prosty web serwis w ASP.NET Core  
✅ **Zadanie 2**: Dockerfile umożliwiający build i uruchomienie:
   - `docker build -t demowebbuild -f DockerfileBuild .`
   - `docker run -itd -p 8080:8080 demowebbuild`
   - `docker run -itd -p 8080:8080 --name demowebbuild demowebbuild`

✅ **Zadanie 3**: Docker Compose z 3 kontenerami:
   - Frontend (Nginx)
   - Backend (ASP.NET Core)
   - Database (SQL Server)
   - Połączone wirtualną siecią `demo-network`
