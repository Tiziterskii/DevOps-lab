#!/bin/bash

# Quick Start Script dla serwera Linux
# Uruchamia aplikację DemoWebService z 3 kontenerami

echo "========================================"
echo "  DemoWebService - Linux Quick Start"
echo "========================================"
echo ""

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Sprawdzenie czy Docker jest zainstalowany
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker nie jest zainstalowany!${NC}"
    echo "Zainstaluj Docker: sudo apt install docker.io"
    exit 1
fi

# Sprawdzenie czy Docker Compose jest zainstalowany
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose nie jest zainstalowany!${NC}"
    echo "Zainstaluj Docker Compose: sudo apt install docker-compose"
    exit 1
fi

echo -e "${GREEN}✓ Docker i Docker Compose są zainstalowane${NC}"
echo ""

# Budowanie i uruchamianie kontenerów
echo -e "${CYAN}Budowanie i uruchamianie kontenerów...${NC}"
docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Kontenery zostały uruchomione!${NC}"
    echo ""
    
    # Czekanie na inicjalizację
    echo -e "${YELLOW}Czekanie na inicjalizację bazy danych (10 sekund)...${NC}"
    sleep 10
    
    # Wyświetlenie statusu
    echo ""
    echo -e "${CYAN}Status kontenerów:${NC}"
    docker-compose ps
    
    # Pobranie IP serwera
    echo ""
    echo -e "${CYAN}Adres IP serwera:${NC}"
    SERVER_IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}$SERVER_IP${NC}"
    
    # Informacje o dostępie
    echo ""
    echo -e "${GREEN}========================================"
    echo "  Aplikacja jest gotowa!"
    echo -e "========================================${NC}"
    echo ""
    echo -e "${CYAN}Frontend (interfejs użytkownika):${NC}"
    echo -e "  ${GREEN}http://${SERVER_IP}:3000${NC}"
    echo ""
    echo -e "${CYAN}Backend API:${NC}"
    echo -e "  ${GREEN}http://${SERVER_IP}:8080/api/products${NC}"
    echo ""
    echo -e "${YELLOW}Otwórz powyższe linki w przeglądarce na swoim komputerze!${NC}"
    echo ""
    
    # Test API
    echo -e "${CYAN}Test API...${NC}"
    sleep 3
    HEALTH_CHECK=$(curl -s http://localhost:8080/api/health 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ API działa poprawnie!${NC}"
    else
        echo -e "${YELLOW}⚠ API może jeszcze się inicjalizować...${NC}"
    fi
    
else
    echo ""
    echo -e "${RED}✗ Wystąpił błąd podczas uruchamiania kontenerów${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}Przydatne komendy:${NC}"
echo "  docker-compose ps              - Status kontenerów"
echo "  docker-compose logs -f         - Logi wszystkich kontenerów"
echo "  docker-compose logs backend    - Logi backend"
echo "  docker-compose down            - Zatrzymanie aplikacji"
echo ""
