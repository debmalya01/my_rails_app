// Fetch and render cars on page load

document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('cars-list');
  if (!container) return;

  // Create filter form
  const filterForm = document.createElement('form');
  filterForm.className = 'mb-3';
  filterForm.innerHTML = `
    <div class="row g-2 align-items-end">
      <div class="col-auto">
        <label for="filter-model" class="form-label mb-0">Model</label>
        <input type="text" id="filter-model" class="form-control form-control-sm" placeholder="e.g. Camry">
      </div>
      <div class="col-auto">
        <label for="filter-year" class="form-label mb-0">Year</label>
        <input type="number" id="filter-year" class="form-control form-control-sm" placeholder="e.g. 2020">
      </div>
      <div class="col-auto">
        <button type="submit" class="btn btn-sm btn-primary">Filter</button>
        <button type="button" id="clear-filters" class="btn btn-sm btn-secondary ms-2">Clear</button>
      </div>
    </div>
  `;
  container.parentNode.insertBefore(filterForm, container);

  // Create pagination container
  const paginationContainer = document.createElement('div');
  paginationContainer.className = 'mt-3';
  container.parentNode.insertBefore(paginationContainer, container.nextSibling);

  let currentFilters = {};
  let currentPage = 1;

  function updateUrl(page, filters) {
    let url = `/cars?page=${page}`;
    Object.keys(filters).forEach(key => {
      url += `&q[${key}]=${encodeURIComponent(filters[key])}`;
    });
    window.history.replaceState({}, '', url);
  }

  function fetchCars(page = 1, filters = {}) {
    currentPage = page;
    currentFilters = { ...filters };
    let url = `/api/v1/cars?page=${page}`;
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
        if (!data.cars || data.cars.length === 0) {
        container.innerHTML = '<div class="alert alert-info">No cars available.</div>';
          paginationContainer.innerHTML = '';
        return;
      }
        container.innerHTML = data.cars.map(renderCarCard).join('');
        renderPagination(data.meta, filters);
    })
    .catch(() => {
      container.innerHTML = '<div class="alert alert-danger">Failed to load cars.</div>';
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
      btn.onclick = () => fetchCars(Number(btn.dataset.page), currentFilters);
    });
  }

  filterForm.addEventListener('submit', function(e) {
    e.preventDefault();
    const model = document.getElementById('filter-model').value.trim();
    const year = document.getElementById('filter-year').value.trim();
    let filters = {};
    if (model) filters['model_eq'] = model;
    if (year) filters['year_eq'] = year;
    fetchCars(1, filters);
  });

  document.getElementById('clear-filters').addEventListener('click', function() {
    document.getElementById('filter-model').value = '';
    document.getElementById('filter-year').value = '';
    fetchCars(1, {});
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
        if (filterKey === 'model_eq') document.getElementById('filter-model').value = value;
        if (filterKey === 'year_eq') document.getElementById('filter-year').value = value;
      }
    }
    fetchCars(page, filters);
  }

  parseUrlParams();
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