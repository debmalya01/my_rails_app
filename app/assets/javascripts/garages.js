// Fetch and render garages on page load

document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('garages-list');
  if (!container) return;

  fetch('/api/v1/garages', {
    headers: {
      'Accept': 'application/json',
      ...window.getApiAuthHeaders()
    }
  })
    .then(res => res.json())
    .then(data => {
      if (!Array.isArray(data)) {
        container.innerHTML = '<li class="list-group-item">No garages found.</li>';
        return;
      }
      if (data.length === 0) {
        container.innerHTML = '<li class="list-group-item">No garages available.</li>';
        return;
      }
      container.innerHTML = data.map(renderGarageItem).join('');
    })
    .catch(() => {
      container.innerHTML = '<li class="list-group-item text-danger">Failed to load garages.</li>';
    });
});

function renderGarageItem(garage) {
  return `
    <li class="list-group-item d-flex justify-content-between align-items-center">
      <a href="/garages/${garage.id}" class="text-decoration-none">${garage.garage_name || ''}</a>
      <span class="badge bg-secondary">${garage.bookings_count || 0} bookings</span>
    </li>
  `;
} 