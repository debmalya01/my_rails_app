// Fetch and render a single booking on page load

document.addEventListener('DOMContentLoaded', function() {
  const details = document.getElementById('booking-details');
  const actions = document.getElementById('booking-actions');
  if (!details || !actions) return;

  // Extract booking ID from URL: /bookings/:id
  const match = window.location.pathname.match(/bookings\/(\d+)/);
  const bookingId = match ? match[1] : null;
  if (!bookingId) {
    details.innerHTML = '<div class="alert alert-danger">Booking not found in URL.</div>';
    return;
  }

  fetch(`/api/v1/bookings/${bookingId}`, {
    headers: {
      'Accept': 'application/json',
      ...window.getApiAuthHeaders()
    }
  })
    .then(res => {
      if (!res.ok) {
        if (res.status === 403) {
          throw new Error('403');
        } else if (res.status === 404) {
          throw new Error('404');
        } else {
          throw new Error('unknown');
        }
      }
      return res.json();
    })
    .then(booking => {
      window.currentBookingData = booking;
      details.innerHTML = renderBookingCard(booking);
      actions.innerHTML = renderBookingActions(booking);
    })
    .catch(error => {
      if (error.message === '403') {
        details.innerHTML = '<div class="alert alert-warning">⛔ You are not authorized to view this booking.</div>';
      } else if (error.message === '404') {
        details.innerHTML = '<div class="alert alert-danger">🚫 Booking not found.</div>';
      } else {
        details.innerHTML = '<div class="alert alert-danger">⚠️ Failed to load booking due to an unknown error.</div>';
      }
    });

});

function renderBookingCard(booking) {
  const car = booking.car || {};
  const serviceCenter = booking.service_center || {};
  const serviceTypes = booking.service_types || [];
  const invoice = booking.invoice;

  return `
    <div class="card shadow-sm mb-4">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Booking Details</h5>
      </div>
      <div class="card-body">
        <div class="row mb-2">
          <div class="col-md-6">
            <strong>Car:</strong> ${car.make || ''} - ${car.model || ''}
          </div>
          <div class="col-md-6">
            <strong>Service Date:</strong> ${booking.service_date ? formatDate(booking.service_date) : ''}
          </div>
        </div>
        <div class="mb-3">
          <strong>Notes:</strong>
          <p class="mb-1">${booking.notes || 'No notes provided.'}</p>
        </div>
        <div class="row mb-3">
          <div class="col-md-4">
            <strong>Service Center:</strong><br>
            ${serviceCenter.garage_name || 'Not assigned'}
          </div>
          <div class="col-md-4">
            <strong>Phone:</strong><br>
            ${serviceCenter.phone || ''}
          </div>
        </div>
        <div>
          <strong>Selected Services:</strong>
          ${serviceTypes.length > 0 ? `
            <ul class="list-group mt-2">
              ${serviceTypes.map(stype => `
                <li class="list-group-item d-flex justify-content-between align-items-center">
                  ${stype.name}
                  <span class="badge bg-secondary">₹${stype.base_price}</span>
                </li>
              `).join('')}
            </ul>
          ` : '<p class="text-muted mt-2">No services selected.</p>'}
        </div>
        ${invoice ? `
          <div class="mt-4">
            <button class="btn btn-outline-primary" type="button" data-bs-toggle="collapse" data-bs-target="#invoice-details-${booking.id}">
              View Invoice
            </button>
          </div>
          <div id="invoice-details-${booking.id}" class="collapse mt-3">
            <h3>Invoice</h3>
            <p><strong>Amount:</strong> ₹${invoice.amount}</p>
            <p><strong>Status:</strong> ${capitalize(invoice.status)}</p>
            <p><strong>Issued on:</strong> ${invoice.issued_at ? formatDate(invoice.issued_at) : ''}</p>
          </div>
        ` : '<p class="mt-3">No invoice has been generated yet.</p>'}
      </div>
    </div>
  `;
}

function renderBookingActions(booking) {
  const carId = booking.car ? booking.car.id : '';
  return `
    <a href="/bookings/${booking.id}/edit" class="btn btn-outline-primary">✏️ Edit this booking</a>
    <a href="/cars/${carId}" class="btn btn-outline-secondary">⬅️ Back to Car</a>
    <button type="button" class="btn btn-danger" onclick="deleteBooking(${booking.id})">🗑️ Destroy this booking</button>
  `;
}

function formatDate(dateStr) {
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
}

function capitalize(str) {
  return str ? str.charAt(0).toUpperCase() + str.slice(1) : '';
}

function deleteBooking(bookingId) {
  if (!confirm('Are you sure you want to delete this booking?')) {
    return;
  }
  
  // Get car ID from the current page data
  const carId = window.currentBookingData?.car?.id;
  
  fetch(`/api/v1/bookings/${bookingId}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
      ...window.getApiAuthHeaders()
    }
  })
  .then(res => {
    if (!res.ok) {
      if (res.status === 403) throw new Error('403');
      else if (res.status === 404) throw new Error('404');
      else throw new Error('unknown');
    }
    return res.text().then(text => text ? JSON.parse(text) : {});
  })
  .then(data => {
    alert('Booking deleted successfully!');
    if (carId) {
      window.location.href = `/cars/${carId}`;
    } else {
      window.location.href = '/bookings';
    }
  })
  .catch(error => {
    if (error.message === '403') {
      alert('You are not authorized to delete this booking.');
    } else if (error.message === '404') {
      alert('Booking not found.');
    } else {
      alert('Failed to delete booking.');
    }
  });
} 