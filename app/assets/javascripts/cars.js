// Fetch and render cars on page load

document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('cars-list');
  if (!container) return;

  fetch('/api/v1/cars', {
    headers: {
      'Accept': 'application/json',
      ...window.getApiAuthHeaders()
    }
  })
    .then(res => res.json())
    .then(data => {
      if (!Array.isArray(data)) {
        container.innerHTML = '<div class="alert alert-warning">No cars found.</div>';
        return;
      }
      if (data.length === 0) {
        container.innerHTML = '<div class="alert alert-info">No cars available.</div>';
        return;
      }
      container.innerHTML = data.map(renderCarCard).join('');
    })
    .catch(() => {
      container.innerHTML = '<div class="alert alert-danger">Failed to load cars.</div>';
    });
});

function renderCarCard(car) {
  const brand = car.vehicle_brand ? car.vehicle_brand.name : '';
  return `
    <div class="col-md-4 mb-4">
      <div class="card h-100 shadow-sm">
        <div class="card-body">
          <h5 class="card-title">${brand} ${car.model || ''}</h5>
          <p class="card-text"><strong>Year:</strong> ${car.year || ''}</p>
          <a href="/cars/${car.id}" class="btn btn-outline-primary btn-sm">View Details</a>
        </div>
      </div>
    </div>
  `;
} 