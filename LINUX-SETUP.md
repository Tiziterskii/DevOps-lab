# Instrukcje uruchomienia na serwerze Linux

## Krok 1: Przygotowanie serwera Linux

### Instalacja Docker i Docker Compose (jeśli nie zainstalowane):
```bash
# Aktualizacja systemu
sudo apt update
sudo apt upgrade -y

# Instalacja Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Dodanie użytkownika do grupy docker (aby nie używać sudo)
sudo usermod -aG docker $USER
# Wyloguj się i zaloguj ponownie, aby zmiany zaczęły działać

# Instalacja Docker Compose
sudo apt install -y docker-compose

# Sprawdzenie wersji
docker --version
docker-compose --version
```

## Krok 2: Sklonowanie repozytorium
```bash
git clone https://github.com/Tiziterskii/DevOps-lab.git
cd DevOps-lab
```

## Krok 3: Uruchomienie aplikacji
```bash
# Zbudowanie i uruchomienie wszystkich kontenerów
docker-compose up -d --build

# Sprawdzenie statusu
docker-compose ps

# Sprawdzenie logów (opcjonalne)
docker-compose logs -f
```

## Krok 4: Sprawdzenie IP serwera Linux
```bash
# Sprawdź IP swojego serwera Linux
hostname -I
# LUB
ip addr show
```

Przykładowy wynik: `192.168.1.100`

## Krok 5: Konfiguracja firewalla (jeśli aktywny)
```bash
# Sprawdź status firewalla
sudo ufw status

# Jeśli aktywny, otwórz porty
sudo ufw allow 3000/tcp    # Frontend
sudo ufw allow 8080/tcp    # Backend API
sudo ufw reload
```

## Krok 6: Dostęp z komputera Windows

Na swoim komputerze otwórz przeglądarkę i wejdź na:

### Frontend (Interfejs użytkownika):
```
http://192.168.1.100:3000
```
Zamień `192.168.1.100` na rzeczywisty IP twojego serwera Linux.

### Backend API (opcjonalne - do testów):
```
http://192.168.1.100:8080/api/products
```

## Rozwiązywanie problemów

### Sprawdź czy kontenery działają:
```bash
docker ps
```

### Sprawdź logi:
```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs sqlserver
```

### Restart kontenerów:
```bash
docker-compose restart
```

### Pełne zatrzymanie i ponowne uruchomienie:
```bash
docker-compose down
docker-compose up -d --build
```

### Sprawdź czy porty są otwarte:
```bash
# Na serwerze Linux
sudo netstat -tulpn | grep -E '3000|8080'

# Lub
sudo ss -tulpn | grep -E '3000|8080'
```

### Test z serwera Linux:
```bash
# Test API
curl http://localhost:8080/api/health
curl http://localhost:8080/api/products

# Test frontend
curl http://localhost:3000
```

## Zatrzymanie aplikacji
```bash
docker-compose down

# Zatrzymanie + usunięcie danych bazy
docker-compose down -v
```

## Wskazówki

1. **Połączenie VM w sieci NAT?** 
   - Zmień sieć VM na "Bridged Adapter" lub skonfiguruj Port Forwarding w VirtualBox/VMware

2. **Nie możesz połączyć się z serwera?**
   - Upewnij się, że firewall nie blokuje portów 3000 i 8080
   - Sprawdź czy serwer i komputer są w tej samej sieci

3. **Frontend pokazuje błąd połączenia z API?**
   - Sprawdź czy backend działa: `docker logs demowebservice-api`
   - Sprawdź czy możesz otworzyć: `http://IP_SERWERA:8080/api/health`

4. **SQL Server nie chce się uruchomić?**
   - SQL Server wymaga minimum 2GB RAM dla VM
   - Sprawdź logi: `docker logs demowebservice-db`
