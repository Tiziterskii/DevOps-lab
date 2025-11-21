# 🚀 Szybki Start - DemoWebService

## Najszybszy sposób uruchomienia

### Opcja 1: Automatyczny skrypt (Rekomendowane)
```powershell
.\run.ps1
```
Wybierz opcję **1** aby uruchomić wszystkie kontenery.

### Opcja 2: Docker Compose (Ręcznie)
```powershell
docker-compose up -d
```

### Opcja 3: Pojedynczy kontener backend (zgodnie z wymaganiami)
```powershell
# Krok 1: Build
docker build -t demowebbuild -f DockerfileBuild .

# Krok 2: Run (wybierz jedną z poniższych)
docker run -itd -p 8080:8080 demowebbuild
# LUB
docker run -itd -p 8080:8080 --name demowebbuild demowebbuild
```

**⚠️ UWAGA**: Opcja 3 nie będzie działać bez bazy danych! Użyj opcji 1 lub 2.

---

## Dostęp do aplikacji

Po uruchomieniu otwórz w przeglądarce:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api/products

---

## Szybkie testy

### Test API w PowerShell:
```powershell
Invoke-WebRequest -Uri http://localhost:8080/api/products
```

### Test API w przeglądarce:
Otwórz: http://localhost:8080/api/products

---

## Zatrzymanie aplikacji

```powershell
docker-compose down
```

---

## Więcej informacji

Pełna dokumentacja znajduje się w pliku **README.md**
