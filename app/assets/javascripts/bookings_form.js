// Handle booking form (new/edit) via API

document.addEventListener('DOMContentLoaded', function() {
  const formContainer = document.getElementById('booking-form');
  const titleElement = document.getElementById('booking-title');
  const backLink = document.getElementById('back-link');
  const actionsContainer = document.getElementById('booking-actions');
  
  if (!formContainer) return;

  // Check if it's new or edit based on URL
  const isEdit = window.location.pathname.includes('/edit');
  const bookingId = isEdit ? window.location.pathname.match(/bookings\/(\d+)\/edit/)?.[1] : null;
  const carId = window.location.pathname.match(/cars\/(\d+)\/bookings/)?.[1] || 
                window.location.pathname.match(/bookings\/(\d+)\/edit/)?.[1] || null;

  // First fetch service types for the checkboxes
  fetch('/api/v1/service_types', {
    headers: {
      'Accept': 'application/json',
      ...window.getApiAuthHeaders()
    }
  })
    .then(res => res.json())
    .then(serviceTypes => {
      if (isEdit && bookingId) {
        // Fetch existing booking data for edit
        return fetch(`/api/v1/bookings/${bookingId}/edit`, {
          headers: {
            'Accept': 'application/json',
            ...window.getApiAuthHeaders()
          }
        })
          .then(res => res.json())
          .then(booking => {
            updatePageElements(booking, isEdit);
            return renderBookingForm(booking, serviceTypes, true, bookingId);
          });
      } else if (carId) {
        // New booking form - fetch car data
        return fetch(`/api/v1/cars/${carId}`, {
          headers: {
            'Accept': 'application/json',
            ...window.getApiAuthHeaders()
          }
        })
          .then(res => res.json())
          .then(car => {
            updatePageElements(car, isEdit);
            return renderBookingForm({ car: car }, serviceTypes, false, null, carId);
          });
      } else {
        return renderBookingForm({}, serviceTypes, false);
      }
    })
    .then(formHtml => {
      formContainer.innerHTML = formHtml;
      setupFormSubmission(isEdit, bookingId, carId);
    })
    .catch(() => {
      formContainer.innerHTML = '<div class="alert alert-danger">Failed to load form data.</div>';
    });
});

function updatePageElements(data, isEdit) {
  const titleElement = document.getElementById('booking-title');
  const backLink = document.getElementById('back-link');
  const actionsContainer = document.getElementById('booking-actions');
  
  if (titleElement) {
    const carName = data.car ? `${data.car.vehicle_brand ? data.car.vehicle_brand.name : ''} ${data.car.model}` : '';
    titleElement.textContent = isEdit ? 'Update Booking' : `New Booking for ${carName}`;
  }
  
  if (backLink && data.car) {
    backLink.href = `/cars/${data.car.id}`;
  }
  
  if (actionsContainer && data.car) {
    actionsContainer.innerHTML = `
      <a href="/bookings/${data.id || ''}" class="btn btn-outline-primary">📄 Show this Booking</a>
      <a href="/cars/${data.car.id}" class="btn btn-outline-secondary">⬅️ Back to Car</a>
    `;
  }
}

function renderBookingForm(booking, serviceTypes, isEdit, bookingId, carId) {
  const car = booking.car || {};
  // Extract service type IDs from the service_types array or use service_type_ids
  const selectedServiceTypeIds = booking.service_types ? 
    booking.service_types.map(st => st.id) : 
    (booking.service_type_ids || []);
  
  return `
    <form id="booking-form-element">
      <div class="mb-3">
        <label for="service_date" class="form-label">Service Date</label>
        <input type="date" id="service_date" name="booking[service_date]" class="form-control" 
               value="${booking.service_date || ''}" style="max-width: 300px;" required>
      </div>

      <div class="mb-3">
        <label class="form-label d-block">Select Services</label>
        <div class="d-flex flex-wrap gap-3">
          ${serviceTypes.map(serviceType => `
            <div class="form-check me-3">
              <input type="checkbox" id="service_type_${serviceType.id}" 
                     name="booking[service_type_ids][]" value="${serviceType.id}" 
                     class="form-check-input" 
                     ${selectedServiceTypeIds.includes(serviceType.id) ? 'checked' : ''}>
              <label for="service_type_${serviceType.id}" class="form-check-label">
                ${serviceType.name}
              </label>
            </div>
          `).join('')}
        </div>
      </div>

      <div class="mb-3">
        <label for="notes" class="form-label">Notes</label>
        <textarea id="notes" name="booking[notes]" rows="3" class="form-control" 
                  style="max-width: 500px;">${booking.notes || ''}</textarea>
      </div>

      <div class="mb-4">
        <label for="pincode" class="form-label">Your Pincode</label>
        <input type="text" id="pincode" name="booking[pincode]" class="form-control" 
               value="${booking.pincode || ''}" required style="max-width: 300px;">
      </div>

      <button type="submit" class="btn btn-primary">
        ${isEdit ? 'Update Booking' : 'Book Service'}
      </button>
    </form>
  `;
}

function setupFormSubmission(isEdit, bookingId, carId) {
  const form = document.getElementById('booking-form-element');
  if (!form) return;

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(form);
    const serviceTypeIds = [];
    formData.getAll('booking[service_type_ids][]').forEach(id => {
      if (id) serviceTypeIds.push(parseInt(id));
    });
    
    const bookingData = {
      booking: {
        service_date: formData.get('booking[service_date]'),
        notes: formData.get('booking[notes]'),
        pincode: formData.get('booking[pincode]'),
        service_type_ids: serviceTypeIds
      }
    };
    
    const url = isEdit ? `/api/v1/bookings/${bookingId}` : `/api/v1/cars/${carId}/bookings`;
    const method = isEdit ? 'PATCH' : 'POST';
    
    fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
        ...window.getApiAuthHeaders()
      },
      body: JSON.stringify(bookingData)
    })
    .then(res => res.json())
    .then(data => {
      if (data.error) {
        alert('Error: ' + data.error);
      } else {
        alert(isEdit ? 'Booking updated successfully!' : 'Booking created successfully!');
        window.location.href = `/bookings/${data.id || bookingId}`;
      }
    })
    .catch(() => {
      alert('Failed to save booking.');
    });
  });
} 