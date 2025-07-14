// Fetch and render a single garage on page load

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

  fetch(`/api/v1/garages/${garageId}`)
    .then(res => res.json())
    .then(data => {
      if (!data || !data.garage) {
        tableContainer.innerHTML = '<div class="alert alert-danger">Failed to load garage.</div>';
        return;
      }
      details.innerHTML = renderGarageDetails(data.garage);
      if (!data.bookings || data.bookings.length === 0) {
        tableContainer.innerHTML = '<div class="alert alert-info">No bookings available for this garage.</div>';
        return;
      }
      tableContainer.innerHTML = renderBookingsTable(data.bookings, garageId);
    })
    .catch(() => {
      tableContainer.innerHTML = '<div class="alert alert-danger">Failed to load garage.</div>';
    });
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