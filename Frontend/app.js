// Automatyczne określenie URL API na podstawie hostname
const API_URL = `http://${window.location.hostname}:8080/api`;

// Sprawdzenie połączenia z backend
async function checkHealth() {
    const statusText = document.getElementById('status-text');
    const statusDiv = document.getElementById('status');
    
    try {
        const response = await fetch(`${API_URL}/health`);
        if (response.ok) {
            statusText.textContent = 'Połączono z API ✓';
            statusDiv.classList.add('connected');
        } else {
            throw new Error('API niedostępne');
        }
    } catch (error) {
        statusText.textContent = 'Brak połączenia z API ✗';
        statusDiv.classList.remove('connected');
    }
}

// Pobranie wszystkich produktów
async function loadProducts() {
    const loading = document.getElementById('loading');
    const error = document.getElementById('error');
    const productsDiv = document.getElementById('products');

    loading.style.display = 'block';
    error.style.display = 'none';
    productsDiv.innerHTML = '';

    try {
        const response = await fetch(`${API_URL}/products`);
        if (!response.ok) throw new Error('Nie udało się pobrać produktów');
        
        const products = await response.json();
        loading.style.display = 'none';

        if (products.length === 0) {
            productsDiv.innerHTML = '<p class="no-products">Brak produktów w bazie danych.</p>';
            return;
        }

        products.forEach(product => {
            const productCard = createProductCard(product);
            productsDiv.appendChild(productCard);
        });
    } catch (err) {
        loading.style.display = 'none';
        error.textContent = `Błąd: ${err.message}`;
        error.style.display = 'block';
    }
}

// Utworzenie karty produktu
function createProductCard(product) {
    const card = document.createElement('div');
    card.className = 'product-card';
    card.innerHTML = `
        <div class="product-header">
            <h3>${product.name}</h3>
            <span class="product-price">${product.price.toFixed(2)} PLN</span>
        </div>
        <p class="product-description">${product.description}</p>
        <div class="product-footer">
            <span class="product-stock">📦 Stan: ${product.stock} szt.</span>
            <button class="btn btn-danger btn-sm" onclick="deleteProduct(${product.id})">Usuń</button>
        </div>
    `;
    return card;
}

// Dodanie nowego produktu
document.getElementById('productForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const product = {
        name: document.getElementById('name').value,
        description: document.getElementById('description').value,
        price: parseFloat(document.getElementById('price').value),
        stock: parseInt(document.getElementById('stock').value)
    };

    try {
        const response = await fetch(`${API_URL}/products`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(product)
        });

        if (!response.ok) throw new Error('Nie udało się dodać produktu');

        // Reset formularza i odświeżenie listy
        e.target.reset();
        await loadProducts();
        showNotification('Produkt został dodany!', 'success');
    } catch (err) {
        showNotification(`Błąd: ${err.message}`, 'error');
    }
});

// Usunięcie produktu
async function deleteProduct(id) {
    if (!confirm('Czy na pewno chcesz usunąć ten produkt?')) return;

    try {
        const response = await fetch(`${API_URL}/products/${id}`, {
            method: 'DELETE'
        });

        if (!response.ok) throw new Error('Nie udało się usunąć produktu');

        await loadProducts();
        showNotification('Produkt został usunięty!', 'success');
    } catch (err) {
        showNotification(`Błąd: ${err.message}`, 'error');
    }
}

// Powiadomienie
function showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 100);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Inicjalizacja
checkHealth();
loadProducts();
setInterval(checkHealth, 30000); // Sprawdzaj połączenie co 30s
