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
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div>
        <h2>${garage.garage_name || ''} – Bookings</h2>
        <p>📞 ${garage.phone || ''} | Pincode: ${garage.pincode || ''}</p>
      </div>
      <div>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#vehicleBrandsModal">
          Manage Vehicle Brands
        </button>
      </div>
    </div>
    ${renderVehicleBrandsModal()}
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

function renderVehicleBrandsModal() {
  return `
    <!-- Vehicle Brands Modal -->
    <div class="modal fade" id="vehicleBrandsModal" tabindex="-1" aria-labelledby="vehicleBrandsModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="vehicleBrandsModalLabel">Manage Vehicle Brands</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div id="vehicle-brands-loading" class="text-center">
              <div class="spinner-border" role="status">
                <span class="visually-hidden">Loading...</span>
              </div>
            </div>
            <div id="vehicle-brands-content" style="display: none;">
              <p class="text-muted">Select the vehicle brands your garage can service:</p>
              <div id="vehicle-brands-list" class="row"></div>
              <div id="vehicle-brands-error" class="alert alert-danger" style="display: none;"></div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            <button type="button" id="save-vehicle-brands" class="btn btn-primary" style="display: none;">
              <span id="save-spinner" class="spinner-border spinner-border-sm me-2" style="display: none;"></span>
              Save Changes
            </button>
          </div>
        </div>
      </div>
    </div>
  `;
}

// Vehicle brands management functionality
let vehicleBrandsModalInitialized = false;

function initializeVehicleBrandsModal() {
  if (vehicleBrandsModalInitialized) return;
  vehicleBrandsModalInitialized = true;
  
  // Use event delegation for dynamically created modal
  document.addEventListener('click', function(event) {
    if (event.target.matches('[data-bs-target="#vehicleBrandsModal"]')) {
      // Small delay to ensure modal is rendered
      setTimeout(() => {
        loadVehicleBrands();
      }, 100);
    }
    
    if (event.target.id === 'save-vehicle-brands') {
      saveVehicleBrands();
    }
  });
}

function loadVehicleBrands() {
  console.log('Loading vehicle brands...');
  const loadingDiv = document.getElementById('vehicle-brands-loading');
  const contentDiv = document.getElementById('vehicle-brands-content');
  const errorDiv = document.getElementById('vehicle-brands-error');
  const saveBtn = document.getElementById('save-vehicle-brands');
  
  if (loadingDiv) loadingDiv.style.display = 'block';
  if (contentDiv) contentDiv.style.display = 'none';
  if (saveBtn) saveBtn.style.display = 'none';
  if (errorDiv) errorDiv.style.display = 'none';
  
  const headers = {
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  };
  
  // Add OAuth token if available, otherwise rely on session authentication
  const authHeaders = window.getApiAuthHeaders();
  Object.assign(headers, authHeaders);
  
  // Add CSRF token for session-based requests
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  if (csrfToken) {
    headers['X-CSRF-Token'] = csrfToken;
  }
  
  console.log('Request headers:', headers);
  
  fetch('/api/v1/garage-vehicle-brands', {
    method: 'GET',
    headers: headers,
    credentials: 'same-origin'
  })
  .then(res => {
    console.log('API Response status:', res.status);
    console.log('API Response headers:', res.headers);
    
    if (!res.ok) {
      throw new Error(`HTTP ${res.status}: ${res.statusText}`);
    }
    
    const contentType = res.headers.get('content-type');
    if (!contentType || !contentType.includes('application/json')) {
      throw new Error('Response is not JSON');
    }
    
    return res.json();
  })
  .then(data => {
    console.log('API Response data:', data);
    if (data.error) {
      throw new Error(data.error);
    }
    renderVehicleBrandsList(data.vehicle_brands, data.selected_brand_ids);
    if (loadingDiv) loadingDiv.style.display = 'none';
    if (contentDiv) contentDiv.style.display = 'block';
    if (saveBtn) saveBtn.style.display = 'inline-block';
  })
  .catch(error => {
    console.error('Error loading vehicle brands:', error);
    if (loadingDiv) loadingDiv.style.display = 'none';
    if (errorDiv) {
      errorDiv.textContent = error.message || 'Failed to load vehicle brands';
      errorDiv.style.display = 'block';
    }
    if (contentDiv) contentDiv.style.display = 'block';
  });
}

function renderVehicleBrandsList(brands, selectedIds) {
  console.log('Rendering brands:', brands.length, 'Selected:', selectedIds.length);
  const listDiv = document.getElementById('vehicle-brands-list');
  if (!listDiv) {
    console.error('vehicle-brands-list element not found');
    return;
  }
  
  listDiv.innerHTML = brands.map(brand => `
    <div class="col-md-4 col-sm-6 mb-3">
      <div class="form-check p-3 border rounded ${selectedIds.includes(brand.id) ? 'border-primary bg-light' : ''}">
        <input class="form-check-input" type="checkbox" value="${brand.id}" 
               id="brand_${brand.id}" ${selectedIds.includes(brand.id) ? 'checked' : ''}>
        <label class="form-check-label fw-medium" for="brand_${brand.id}">
          ${brand.name}
        </label>
      </div>
    </div>
  `).join('');
}

function saveVehicleBrands() {
  const saveBtn = document.getElementById('save-vehicle-brands');
  const saveSpinner = document.getElementById('save-spinner');
  const errorDiv = document.getElementById('vehicle-brands-error');
  
  if (saveSpinner) saveSpinner.style.display = 'inline-block';
  if (saveBtn) saveBtn.disabled = true;
  if (errorDiv) errorDiv.style.display = 'none';
  
  const selectedBrands = Array.from(document.querySelectorAll('#vehicle-brands-list input:checked'))
    .map(input => parseInt(input.value));
  
  console.log('Saving selected brands:', selectedBrands);
  
  const saveHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  };
  
  // Add OAuth token if available, otherwise rely on session authentication
  const authHeaders = window.getApiAuthHeaders();
  Object.assign(saveHeaders, authHeaders);
  
  // Add CSRF token for session-based requests
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  if (csrfToken) {
    saveHeaders['X-CSRF-Token'] = csrfToken;
  }
  
  fetch('/api/v1/garage-vehicle-brands', {
    method: 'PATCH',
    headers: saveHeaders,
    credentials: 'same-origin',
    body: JSON.stringify({
      vehicle_brand_ids: selectedBrands
    })
  })
  .then(res => res.json())
  .then(data => {
    if (data.error) {
      throw new Error(data.error);
    }
    
    // Close modal and show success message
    const modalElement = document.getElementById('vehicleBrandsModal');
    if (modalElement) {
      const modal = bootstrap.Modal.getInstance(modalElement) || new bootstrap.Modal(modalElement);
      modal.hide();
    }
    
    // Show success notification
    showNotification('Vehicle brands updated successfully!', 'success');
  })
  .catch(error => {
    console.error('Error saving vehicle brands:', error);
    if (errorDiv) {
      errorDiv.textContent = error.message || 'Failed to update vehicle brands';
      errorDiv.style.display = 'block';
    }
  })
  .finally(() => {
    if (saveSpinner) saveSpinner.style.display = 'none';
    if (saveBtn) saveBtn.disabled = false;
  });
}

function showNotification(message, type = 'info') {
  const alertDiv = document.createElement('div');
  alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
  alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
  alertDiv.innerHTML = `
    ${message}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  `;
  
  document.body.appendChild(alertDiv);
  
  // Auto-remove after 5 seconds
  setTimeout(() => {
    if (alertDiv.parentNode) {
      alertDiv.remove();
    }
  }, 5000);
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  initializeVehicleBrandsModal();
}); 