// Fetch and render a single car on page load

document.addEventListener('DOMContentLoaded', function() {
  const details = document.getElementById('car-details');
  const bookingsList = document.getElementById('car-bookings-list');
  const actions = document.getElementById('car-actions');
  if (!details || !bookingsList || !actions) return;

  // Extract car ID from URL: /cars/:id
  const match = window.location.pathname.match(/cars\/(\d+)/);
  const carId = match ? match[1] : null;
  if (!carId) {
    details.innerHTML = '<div class="alert alert-danger">Car not found in URL.</div>';
    return;
  }

  details.innerHTML = '<div class="text-center"><i class="fas fa-spinner fa-spin"></i> Loading car details...</div>';

  fetch(`/api/v1/cars/${carId}`, {
    headers: {
      'Accept': 'application/json',
      ...window.getApiAuthHeaders()
    }
  })
    .then(res => {
      if (!res.ok) throw res;
      return res.json();
    })
    .then(car => {
      details.innerHTML = renderCarCard(car);
      bookingsList.innerHTML = renderCarBookings(car.bookings || [], carId);
      actions.innerHTML = `<a href="/cars" class="btn btn-link mt-4">Back to Cars</a>`;
    })
    .catch(async err => {
      let errorMessage = 'Failed to load car.';
      if (err.status === 404) {
        errorMessage = 'Car not found.';
      } else if (err.status === 403) {
        errorMessage = 'You are not authorized to view this car.';
      } else if (err.json) {
        const data = await err.json();
        errorMessage = data.error || errorMessage;
      }

      details.innerHTML = `<div class="alert alert-danger">${errorMessage}</div>`;
    });

});

function renderCarCard(car) {
  if (!car) return '<div class="alert alert-danger">Car details missing.</div>';

  return `
    <div class="card h-100 shadow-sm">
      <div class="card-body">
        <h5 class="card-title">${car.make || ''} ${car.model || ''}</h5>
        <p class="card-text"><strong>Year:</strong> ${car.year || ''}</p>
      </div>
    </div>
  `;
}


function renderCarBookings(bookings, carId) {
  const bookingsHtml = bookings.length > 0 ? `
    <ul class="list-group">
      ${bookings.map(booking => `
        <li class="list-group-item d-flex justify-content-between align-items-center">
          <div>
            <strong>${booking.service_date ? formatDate(booking.service_date) : ''}</strong> –
            ${booking.notes ? truncate(booking.notes, 40) : 'No notes'}<br/>
            <small class="text-muted">Service Center: ${booking.service_center ? booking.service_center.garage_name : 'Not Assigned'}</small>
          </div>
          <a href="/bookings/${booking.id}" class="btn btn-sm btn-outline-secondary">View</a>
        </li>
      `).join('')}
    </ul>
  ` : '<p class="text-muted">No bookings available for this car.</p>';
  
  return `
    <div class="d-flex justify-content-between align-items-center mt-5 mb-3">
      <h2>Bookings for This Car</h2>
      <a href="/cars/${carId}/bookings/new" class="btn btn-primary">New Booking</a>
    </div>
    ${bookingsHtml}
  `;
}

function formatDate(dateStr) {
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
}

function truncate(str, n) {
  return str.length > n ? str.slice(0, n - 1) + '…' : str;
} 