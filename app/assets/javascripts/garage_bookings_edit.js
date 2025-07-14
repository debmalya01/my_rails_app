// Fetch and render garage booking edit form on page load

document.addEventListener('DOMContentLoaded', function() {
  const formContainer = document.getElementById('garage-booking-form');
  if (!formContainer) return;

  // Extract garage and booking IDs from URL: /garages/:garage_id/bookings/:id/edit
  const match = window.location.pathname.match(/garages\/(\d+)\/bookings\/(\d+)\/edit/);
  const garageId = match ? match[1] : null;
  const bookingId = match ? match[2] : null;
  
  if (!garageId || !bookingId) {
    formContainer.innerHTML = '<div class="alert alert-danger">Garage or booking not found in URL.</div>';
    return;
  }

  fetch(`/api/v1/garages/${garageId}/bookings/${bookingId}/edit`)
    .then(res => res.json())
    .then(booking => {
      formContainer.innerHTML = renderBookingForm(booking, garageId, bookingId);
      setupFormSubmission(garageId, bookingId);
    })
    .catch(() => {
      formContainer.innerHTML = '<div class="alert alert-danger">Failed to load booking.</div>';
    });
});

function renderBookingForm(booking, garageId, bookingId) {
  const statusOptions = [
    'pending', 'waiting_for_pickup', 'pickup_completed', 
    'in_service', 'ready_for_dropoff', 'dropped_off', 'cancelled'
  ];
  
  return `
    <form id="booking-status-form">
      <div class="mb-3">
        <label for="status" class="form-label">Status</label>
        <select id="status" name="booking[status]" class="form-control">
          ${statusOptions.map(status => `
            <option value="${status}" ${booking.status === status ? 'selected' : ''}>
              ${capitalize(status.replace(/_/g, ' '))}
            </option>
          `).join('')}
        </select>
      </div>
      <button type="submit" class="btn btn-success">Update</button>
    </form>
  `;
}

function setupFormSubmission(garageId, bookingId) {
  const form = document.getElementById('booking-status-form');
  if (!form) return;

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(form);
    const status = formData.get('booking[status]');
    
    fetch(`/api/v1/garages/${garageId}/bookings/${bookingId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
      },
      body: JSON.stringify({
        booking: { status: status }
      })
    })
    .then(res => res.json())
    .then(data => {
      if (data.error) {
        alert('Error: ' + data.error);
      } else {
        alert('Booking status updated successfully!');
        window.location.href = `/garages/${garageId}`;
      }
    })
    .catch(() => {
      alert('Failed to update booking status.');
    });
  });
}

function capitalize(str) {
  return str ? str.charAt(0).toUpperCase() + str.slice(1) : '';
} 