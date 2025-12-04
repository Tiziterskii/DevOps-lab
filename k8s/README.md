# Wdrożenie projektu na Kubernetes (Minikube)

## Wymagania
- Ubuntu 25.04 VM z Docker
- Co najmniej 2 CPU, 4GB RAM dla Minikube
- Wolne 10GB miejsca na dysku

## Krok 1: Instalacja Minikube i kubectl na VM

### 1.1 Zainstaluj kubectl
```bash
# Pobierz kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Nadaj uprawnienia i przenieś do /usr/local/bin
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Sprawdź wersję
kubectl version --client
```

### 1.2 Zainstaluj Minikube
```bash
# Pobierz Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Zainstaluj
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Sprawdź wersję
minikube version
```

### 1.3 Uruchom klaster Minikube
```bash
# Start klastra (użyj Docker jako driver)
minikube start --driver=docker --cpus=2 --memory=4096

# Sprawdź status
minikube status

# Włącz kubectl do pracy z Minikube
kubectl cluster-info
kubectl get nodes
```

## Krok 2: Zbuduj obrazy Docker w kontekście Minikube

**WAŻNE:** Minikube ma własny daemon Docker. Musisz zbudować obrazy wewnątrz Minikube.

```bash
# Przejdź do katalogu projektu
cd ~/actions-runner/_work/DevOps-lab/DevOps-lab  # lub Twoja ścieżka

# Użyj Docker daemona Minikube
eval $(minikube docker-env)

# Zbuduj obrazy (to samo co w docker-compose, ale w Minikube)
docker build -f DockerfileBuild -t devops-lab-backend:latest .
docker build -f DockerfileFrontend -t devops-lab-frontend:latest .

# Sprawdź obrazy
docker images | grep devops-lab
```

**Uwaga:** Po zamknięciu sesji SSH, jeśli chcesz znowu używać Docker Minikube, uruchom ponownie `eval $(minikube docker-env)`.

## Krok 3: Wdróż aplikację na Kubernetes

### 3.1 Zastosuj manifesty Kubernetes
```bash
# Wdróż SQL Server (PVC + Deployment + Service)
kubectl apply -f k8s/sqlserver-deployment.yaml

# Wdróż Backend (Deployment + Service, 2 repliki)
kubectl apply -f k8s/backend-deployment.yaml

# Wdróż Frontend (Deployment + Service, NodePort 30080)
kubectl apply -f k8s/frontend-deployment.yaml
```

### 3.2 Sprawdź status wdrożenia
```bash
# Sprawdź pody
kubectl get pods

# Sprawdź serwisy
kubectl get svc

# Sprawdź deployment
kubectl get deployments

# Szczegóły poda (jeśli coś nie działa)
kubectl describe pod <nazwa-poda>

# Logi poda
kubectl logs <nazwa-poda>
```

Oczekiwany wynik po chwili:
```
NAME                         READY   STATUS    RESTARTS   AGE
backend-xxxxxxxxxx-xxxxx     1/1     Running   0          1m
backend-xxxxxxxxxx-xxxxx     1/1     Running   0          1m
frontend-xxxxxxxxxx-xxxxx    1/1     Running   0          1m
sqlserver-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
```

## Krok 4: Skalowanie serwisu (zadanie 5)

Backend już ma 2 repliki, ale możesz przeskalować dowolny serwis:

```bash
# Skaluj backend do 3 replik
kubectl scale deployment backend --replicas=3

# Skaluj frontend do 2 replik
kubectl scale deployment frontend --replicas=2

# Sprawdź wynik
kubectl get pods -l app=backend
kubectl get pods -l app=frontend
```

## Krok 5: Dostęp do aplikacji (zadanie 6)

### 5.1 Uzyskaj adres Minikube
```bash
# Pobierz IP Minikube
minikube ip
```

Przykładowy wynik: `192.168.49.2`

### 5.2 Otwórz aplikację w przeglądarce

Frontend jest wystawiony jako **NodePort** na porcie **30080**.

**Z VM:**
```bash
curl http://$(minikube ip):30080
```

**Z Windows (host):**
- Jeśli Minikube IP to `192.168.49.2`, otwórz w przeglądarce:
  ```
  http://192.168.49.2:30080
  ```
- Może być konieczne przekierowanie portów lub użycie `minikube service`:
  ```bash
  # Na VM uruchom tunel (pozostaw terminal otwarty)
  minikube service frontend --url
  ```
  To da Ci URL, który możesz użyć.

**Alternatywa - Port forwarding przez SSH (z Windows PowerShell):**
```powershell
ssh -L 30080:192.168.49.2:30080 titi@localhost -p 2222
```
Potem otwórz `http://localhost:30080` w przeglądarce Windows.

### 5.3 Sprawdź backend API
```bash
# Z VM
curl http://$(minikube ip):30080
curl http://backend:8080/api/health  # z poziomu poda
kubectl port-forward svc/backend 8080:8080  # lokalny dostęp
```

## Krok 6: Użyteczne komendy

```bash
# Restart poda
kubectl rollout restart deployment backend

# Sprawdź wszystkie zasoby
kubectl get all

# Usuń wszystko
kubectl delete -f k8s/

# Stop Minikube
minikube stop

# Usuń klaster
minikube delete

# Dashboard Kubernetes (w nowym terminalu)
minikube dashboard
```

## Troubleshooting

### Pody w stanie CrashLoopBackOff
```bash
kubectl logs <nazwa-poda>
kubectl describe pod <nazwa-poda>
```

### Brak miejsca na dysku
```bash
# Usuń nieużywane obrazy Docker w Minikube
eval $(minikube docker-env)
docker system prune -af
```

### Backend nie może połączyć się z SQL Server
- SQL Server potrzebuje czasu na start (healthcheck).
- Sprawdź logi: `kubectl logs <sqlserver-pod>`
- Zwiększ `initialDelaySeconds` w backend readiness probe.

### Dostęp z Windows nie działa
- Użyj `minikube service frontend --url` i skopiuj URL.
- Lub ustaw port forwarding: `kubectl port-forward svc/frontend 3000:80` (na VM), a potem SSH tunnel z Windows.

## Opcjonalnie: GitHub Actions CI/CD dla K8s

Możesz dodać do workflow krok wdrażający do Minikube:
```yaml
- name: Deploy to Minikube
  run: |
    kubectl apply -f k8s/
    kubectl rollout status deployment/backend
    kubectl rollout status deployment/frontend
```

---

## Podsumowanie zadań

✅ **Zadanie 1:** Instalacja Minikube + kubectl  
✅ **Zadanie 2:** Uruchomienie klastra K8s (`minikube start`)  
✅ **Zadanie 3:** Pliki konfiguracyjne (Deployment + Service) w `k8s/`  
✅ **Zadanie 4:** Zbudowanie i uruchomienie podów (`kubectl apply`)  
✅ **Zadanie 5:** Skalowanie backendu do 2+ replik (domyślnie 2, można `kubectl scale`)  
✅ **Zadanie 6:** Sprawdzenie adresu i połączenie (`minikube ip` + NodePort 30080)
