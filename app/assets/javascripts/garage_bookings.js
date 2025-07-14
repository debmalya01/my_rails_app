// Fetch and render garage bookings on page load

document.addEventListener('DOMContentLoaded', function() {
  const title = document.getElementById('garage-bookings-title');
  const tableContainer = document.getElementById('garage-bookings-table');
  if (!title || !tableContainer) return;

  // Extract garage_id from URL: /garages/:garage_id/garage_bookings
  const match = window.location.pathname.match(/garages\/(\d+)\/garage_bookings/);
  const garageId = match ? match[1] : null;
  if (!garageId) {
    tableContainer.innerHTML = '<div class="alert alert-danger">Garage not found in URL.</div>';
    return;
  }

  fetch(`/api/v1/garages/${garageId}/garage_bookings`)
    .then(res => res.json())
    .then(data => {
      if (!data || !Array.isArray(data.bookings)) {
        tableContainer.innerHTML = '<div class="alert alert-warning">No bookings found.</div>';
        return;
      }
      title.textContent = `Bookings for ${data.garage ? data.garage.garage_name : ''}`;
      if (data.bookings.length === 0) {
        tableContainer.innerHTML = '<div class="alert alert-info">No bookings available.</div>';
        return;
      }
      tableContainer.innerHTML = renderBookingsTable(data.bookings, garageId);
    })
    .catch(() => {
      tableContainer.innerHTML = '<div class="alert alert-danger">Failed to load bookings.</div>';
    });
});

function renderBookingsTable(bookings, garageId) {
  return `
    <table class="table">
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
            <td><a href="/garages/${garageId}/bookings/${booking.id}/edit" class="btn btn-sm btn-primary">Update Status</a></td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
}

function capitalize(str) {
  return str ? str.charAt(0).toUpperCase() + str.slice(1) : '';
} 