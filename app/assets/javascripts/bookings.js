// Fetch and render bookings on page load

document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('bookings-list');
  if (!container) return;

  fetch('/api/v1/bookings', {
    headers: {
      'Accept': 'application/json',
      ...window.getApiAuthHeaders()
    }
  })
    .then(res => res.json())
    .then(data => {
      if (!Array.isArray(data)) {
        container.innerHTML = '<div class="alert alert-warning">No bookings found.</div>';
        return;
      }
      if (data.length === 0) {
        container.innerHTML = '<div class="alert alert-info">No bookings available.</div>';
        return;
      }
      container.innerHTML = data.map(renderBookingCard).join('');
    })
    .catch(() => {
      container.innerHTML = '<div class="alert alert-danger">Failed to load bookings.</div>';
    });
});

function renderBookingCard(booking) {
  // Fallbacks for nested objects
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
        <div class="mt-3">
          <a href="/bookings/${booking.id}" class="btn btn-outline-primary btn-sm">Show this booking</a>
        </div>
      </div>
    </div>
  `;
}

function formatDate(dateStr) {
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
}

function capitalize(str) {
  return str ? str.charAt(0).toUpperCase() + str.slice(1) : '';
} 