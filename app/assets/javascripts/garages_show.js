// Fetch and render a single garage and its bookings with filtering and pagination

document.addEventListener('DOMContentLoaded', function() {
  const details = document.getElementById('garage-details');
  const tableContainer = document.getElementById('garage-bookings-table');
  if (!details || !tableContainer) return;

  // Extract garage ID from URL: /garages/:id
  const match = window.location.pathname.match(/garages\/(\d+)/);
  const garageId = match ? match[1] : null;
  if (!garageId) {
    tableContainer.innerHTML = '<div class="alert alert-danger">Garage not found in URL.</div>';
    return;
  }

  // Create filter form (status only)
  const filterForm = document.createElement('form');
  filterForm.className = 'mb-3';
  filterForm.innerHTML = `
    <div class="row g-2 align-items-end">
      <div class="col-auto">
        <label for="filter-status" class="form-label mb-0">Status</label>
        <select id="filter-status" class="form-select form-select-sm">
          <option value="">All</option>
          <option value="pending">Pending</option>
          <option value="waiting_for_pickup">Waiting for Pickup</option>
          <option value="pickup_completed">Pickup Completed</option>
          <option value="in_service">In Service</option>
          <option value="ready_for_dropoff">Ready for Dropoff</option>
          <option value="dropped_off">Dropped Off</option>
          <option value="cancelled">Cancelled</option>
        </select>
      </div>
      <div class="col-auto">
        <button type="submit" class="btn btn-sm btn-primary">Filter</button>
        <button type="button" id="clear-filters" class="btn btn-sm btn-secondary ms-2">Clear</button>
      </div>
    </div>
  `;
  tableContainer.parentNode.insertBefore(filterForm, tableContainer);

  // Create pagination container
  const paginationContainer = document.createElement('div');
  paginationContainer.className = 'mt-3';
  tableContainer.parentNode.insertBefore(paginationContainer, tableContainer.nextSibling);

  let currentFilters = {};
  let currentPage = 1;

  function updateUrl(page, filters) {
    let url = `/garages/${garageId}?page=${page}`;
    Object.keys(filters).forEach(key => {
      url += `&q[${key}]=${encodeURIComponent(filters[key])}`;
    });
    window.history.replaceState({}, '', url);
  }

  function fetchBookings(page = 1, filters = {}) {
    currentPage = page;
    currentFilters = { ...filters };
    let url = `/api/v1/garages/${garageId}/bookings?page=${page}`;
    Object.keys(filters).forEach(key => {
      url += `&q[${key}]=${encodeURIComponent(filters[key])}`;
    });
    updateUrl(page, filters);

    fetch(url, {
    headers: {
      'Accept': 'application/json',
      ...window.getApiAuthHeaders()
    }
  })
    .then(res => res.json())
    .then(data => {
      if (!data || !data.garage) {
        tableContainer.innerHTML = '<div class="alert alert-danger">You are not authorized to access this garage.</div>';
          paginationContainer.innerHTML = '';
        return;
      }
      details.innerHTML = renderGarageDetails(data.garage);
      if (!data.bookings || data.bookings.length === 0) {
        tableContainer.innerHTML = '<div class="alert alert-info">No bookings available for this garage.</div>';
          paginationContainer.innerHTML = '';
        return;
      }
      tableContainer.innerHTML = renderBookingsTable(data.bookings, garageId);
        renderPagination(data.meta, filters);
    })
    .catch(() => {
      tableContainer.innerHTML = '<div class="alert alert-danger">Failed to load garage.</div>';
        paginationContainer.innerHTML = '';
    });
  }

  function renderPagination(meta, filters) {
    if (!meta || meta.total_pages <= 1) {
      paginationContainer.innerHTML = '';
      return;
    }
    let html = '';
    for (let i = 1; i <= meta.total_pages; i++) {
      html += `<button class="btn btn-sm ${i === meta.current_page ? 'btn-primary' : 'btn-outline-primary'} mx-1" data-page="${i}">${i}</button>`;
    }
    paginationContainer.innerHTML = html;
    Array.from(paginationContainer.querySelectorAll('button')).forEach(btn => {
      btn.onclick = () => fetchBookings(Number(btn.dataset.page), currentFilters);
    });
  }

  filterForm.addEventListener('submit', function(e) {
    e.preventDefault();
    const status = document.getElementById('filter-status').value;
    let filters = {};
    if (status) filters['status_eq'] = status;
    fetchBookings(1, filters);
  });

  document.getElementById('clear-filters').addEventListener('click', function() {
    document.getElementById('filter-status').value = '';
    fetchBookings(1, {});
  });

  // On page load, parse filters/page from URL
  function parseUrlParams() {
    const params = new URLSearchParams(window.location.search);
    const page = parseInt(params.get('page')) || 1;
    let filters = {};
    for (const [key, value] of params.entries()) {
      if (key.startsWith('q[') && key.endsWith(']')) {
        const filterKey = key.slice(2, -1);
        filters[filterKey] = value;
        if (filterKey === 'status_eq') document.getElementById('filter-status').value = value;
      }
    }
    fetchBookings(page, filters);
  }

  parseUrlParams();
});

function renderGarageDetails(garage) {
  return `
    <h2>${garage.garage_name || ''} – Bookings</h2>
    <p>📞 ${garage.phone || ''} | Pincode: ${garage.pincode || ''}</p>
  `;
}

function renderBookingsTable(bookings, garageId) {
  return `
    <table class="table table-bordered mt-4">
      <thead>
        <tr>
          <th>Car</th>
          <th>Service Date</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        ${bookings.map(booking => `
          <tr>
            <td>${booking.car ? (booking.car.vehicle_brand ? booking.car.vehicle_brand.name : booking.car.make || '') : ''} - ${booking.car ? booking.car.model : ''}</td>
            <td>${booking.service_date || ''}</td>
            <td>${booking.status ? capitalize(booking.status) : ''}</td>
            <td>
              <a href="/garages/${garageId}/bookings/${booking.id}/edit" class="btn btn-sm btn-outline-primary">Edit Status</a>
            </td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
}

function capitalize(str) {
  return str ? str.charAt(0).toUpperCase() + str.slice(1) : '';
} 