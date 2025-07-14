// Handle car form (new/edit) via API

document.addEventListener('DOMContentLoaded', function() {
  const formContainer = document.getElementById('car-form');
  if (!formContainer) return;

  // Check if it's new or edit based on URL
  const isEdit = window.location.pathname.includes('/edit');
  const carId = isEdit ? window.location.pathname.match(/cars\/(\d+)\/edit/)?.[1] : null;

  // First fetch vehicle brands for the dropdown
  fetch('/api/v1/vehicle_brands')
    .then(res => res.json())
    .then(brands => {
      if (isEdit && carId) {
        // Fetch existing car data for edit
        return fetch(`/api/v1/cars/${carId}/edit`)
          .then(res => res.json())
          .then(car => renderCarForm(car, brands, true, carId));
      } else {
        // New car form - fetch car data with current user
        return fetch('/api/v1/cars/new')
          .then(res => res.json())
          .then(data => renderCarForm(data.car, brands, false, null, null, data.current_user));
      }
    })
    .then(formHtml => {
      formContainer.innerHTML = formHtml;
      setupFormSubmission(isEdit, carId);
    })
    .catch(() => {
      formContainer.innerHTML = '<div class="alert alert-danger">Failed to load form data.</div>';
    });
});

function renderCarForm(car, brands, isEdit, carId, carId2, currentUser) {
  return `
    <form id="car-form-element">
      <div class="mb-3">
        <label class="form-label">User</label>
        <input type="text" class="form-control" value="${currentUser ? currentUser.name : (car.user ? car.user.name : '')}" disabled>
      </div>
      
      <div class="mb-3">
        <label for="vehicle_brand_id" class="form-label">Car Brand</label>
        <select id="vehicle_brand_id" name="car[vehicle_brand_id]" class="form-control" required>
          <option value="">Select Brand</option>
          ${brands.map(brand => `
            <option value="${brand.id}" ${car.vehicle_brand_id == brand.id ? 'selected' : ''}>
              ${brand.name}
            </option>
          `).join('')}
        </select>
      </div>

      <div class="mb-3">
        <label for="model" class="form-label">Model</label>
        <input type="text" id="model" name="car[model]" class="form-control" value="${car.model || ''}" required>
      </div>

      <div class="mb-3">
        <label for="year" class="form-label">Year</label>
        <input type="number" id="year" name="car[year]" class="form-control" value="${car.year || ''}" required>
      </div>

      <div class="mb-3">
        <label for="registration_number" class="form-label">Registration Number</label>
        <input type="text" id="registration_number" name="car[registration_number]" class="form-control" value="${car.registration_number || ''}" required>
      </div>

      <div class="mt-4">
        <button type="submit" class="btn btn-primary">${isEdit ? 'Update Car' : 'Create Car'}</button>
        <a href="/cars" class="btn btn-secondary ms-2">Cancel</a>
      </div>
    </form>
  `;
}

function setupFormSubmission(isEdit, carId) {
  const form = document.getElementById('car-form-element');
  if (!form) return;

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(form);
    const carData = {
      car: {
        vehicle_brand_id: formData.get('car[vehicle_brand_id]'),
        model: formData.get('car[model]'),
        year: formData.get('car[year]'),
        registration_number: formData.get('car[registration_number]')
      }
    };
    
    const url = isEdit ? `/api/v1/cars/${carId}` : '/api/v1/cars';
    const method = isEdit ? 'PATCH' : 'POST';
    
    fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
      },
      body: JSON.stringify(carData)
    })
    .then(res => res.json())
    .then(data => {
      if (data.error) {
        alert('Error: ' + data.error);
      } else {
        alert(isEdit ? 'Car updated successfully!' : 'Car created successfully!');
        window.location.href = `/cars/${data.id || carId}`;
      }
    })
    .catch(() => {
      alert('Failed to save car.');
    });
  });
} 