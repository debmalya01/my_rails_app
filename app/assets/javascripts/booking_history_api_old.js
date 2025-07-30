// Booking History API Integration
class BookingHistoryAPI {
  constructor() {
    this.baseURL = '/api/v1';
    this.currentPage = 1;
    this.pagination = null;
    this.init();
  }

  init() {
    // Automatically load booking history when page loads
    document.addEventListener('DOMContentLoaded', () => {
      this.loadBookingHistoryAPI(1);
    });
  }

  // Get access token from session storage or local storage
  getAccessToken() {
    return sessionStorage.getItem('access_token') || localStorage.getItem('access_token');
  }

  // Load booking history via API with pagination
  async loadBookingHistoryAPI(page = 1) {
    const token = this.getAccessToken();
    
    if (!token) {
      console.error('No access token found');
      this.displayError('Please log in to access your booking history');
      return;
    }

    // Show loading state
    this.showLoading();

    try {
      const response = await fetch(`${this.baseURL}/bookings/history?page=${page}&per_page=2`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        const data = await response.json();
        this.currentPage = page;
        this.pagination = data.pagination;
        
        // Parse the bookings JSON string
        const bookings = JSON.parse(data.bookings);
        this.displayBookings(bookings);
      } else {
        console.error('Failed to fetch booking history:', response.status);
        this.displayError('Failed to fetch booking history. Please try again.');
      }
    } catch (error) {
      console.error('Error fetching booking history:', error);
      this.displayError('Error fetching booking history. Please try again.');
    }
  }

  // Show loading state
  showLoading() {
    const container = document.getElementById('bookingHistoryContainer');
    
    if (container) {
      container.innerHTML = `
        <div class="text-center py-5">
          <div class="spinner-border" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          <p class="mt-3">Loading your booking history...</p>
        </div>
      `;
    }
  }

  // Display bookings from API response
  displayBookings(bookings) {
    const container = document.getElementById('bookingHistoryContainer');
    const statsContainer = document.getElementById('bookingStats');
    
    if (container) {
      const bookingsHTML = this.generateBookingsHTML(bookings);
      const paginationHTML = this.generatePaginationHTML();
      
      container.innerHTML = `
        ${bookingsHTML}
        ${paginationHTML}
      `;
    }
    
    // Update stats display
    if (statsContainer && this.pagination) {
      statsContainer.innerHTML = `
        <i class="fas fa-info-circle me-1"></i>
        ${this.pagination.total_count} total bookings
      `;
    }
  }

  // Generate pagination controls
  generatePaginationHTML() {
    if (!this.pagination || this.pagination.total_pages <= 1) {
      return '';
    }

    const { current_page, total_pages, prev_page, next_page, total_count } = this.pagination;
    
    return `
      <div class="d-flex justify-content-between align-items-center mt-4">
        <div class="pagination-info">
          <small class="text-muted">
            Showing page ${current_page} of ${total_pages} (${total_count} total bookings)
          </small>
        </div>
        
        <nav aria-label="Booking history pagination">
          <ul class="pagination pagination-sm mb-0">
            <li class="page-item ${!prev_page ? 'disabled' : ''}">
              <button class="page-link" ${prev_page ? `onclick="window.bookingHistoryAPI.loadBookingHistoryAPI(${prev_page})"` : 'disabled'}>
                <i class="fas fa-chevron-left"></i> Previous
              </button>
            </li>
            
            ${this.generatePageNumbers()}
            
            <li class="page-item ${!next_page ? 'disabled' : ''}">
              <button class="page-link" ${next_page ? `onclick="window.bookingHistoryAPI.loadBookingHistoryAPI(${next_page})"` : 'disabled'}>
                Next <i class="fas fa-chevron-right"></i>
              </button>
            </li>
          </ul>
        </nav>
      </div>
    `;
  }

  // Generate page numbers for pagination
  generatePageNumbers() {
    const { current_page, total_pages } = this.pagination;
    let pageNumbers = '';
    
    // Show up to 5 page numbers
    const maxPages = Math.min(5, total_pages);
    let startPage = Math.max(1, current_page - 2);
    let endPage = Math.min(total_pages, startPage + maxPages - 1);
    
    // Adjust start page if we're near the end
    if (endPage - startPage < maxPages - 1) {
      startPage = Math.max(1, endPage - maxPages + 1);
    }
    
    for (let i = startPage; i <= endPage; i++) {
      pageNumbers += `
        <li class="page-item ${i === current_page ? 'active' : ''}">
          <button class="page-link" onclick="window.bookingHistoryAPI.loadBookingHistoryAPI(${i})">
            ${i}
          </button>
        </li>
      `;
    }
    
    return pageNumbers;
  }

  // Display error message
  displayError(message) {
    const container = document.getElementById('bookingHistoryContainer');
    
    if (container) {
      container.innerHTML = `
        <div class="text-center py-5">
          <div class="mb-4">
            <i class="fas fa-exclamation-triangle fa-4x text-warning"></i>
          </div>
          <h4 class="text-muted">Unable to Load Booking History</h4>
          <p class="text-muted">${message}</p>
          <button class="btn btn-primary" onclick="window.location.reload()">
            <i class="fas fa-refresh me-2"></i>Try Again
          </button>
        </div>
      `;
    }
  }

  // Generate HTML for bookings
  generateBookingsHTML(bookings) {
    if (!bookings || bookings.length === 0) {
      if (this.pagination && this.pagination.total_count > 0) {
        // There are bookings but none on this page (shouldn't happen with proper pagination)
        return `
          <div class="text-center py-5">
            <div class="mb-4">
              <i class="fas fa-search fa-4x text-muted"></i>
            </div>
            <h4 class="text-muted">No Bookings on This Page</h4>
            <p class="text-muted">Try navigating to a different page.</p>
          </div>
        `;
      } else {
        // No bookings at all
        return `
          <div class="text-center py-5">
            <div class="mb-4">
              <i class="fas fa-calendar-times fa-4x text-muted"></i>
            </div>
            <h4 class="text-muted">No Booking History</h4>
            <p class="text-muted">You haven't made any bookings yet.</p>
            <a href="/cars" class="btn btn-primary">
              <i class="fas fa-plus me-2"></i>Book a Service
            </a>
          </div>
        `;
      }
    }

    return `
      <div class="row">
        ${bookings.map(booking => this.generateBookingCard(booking)).join('')}
      </div>
    `;
  }

  // Generate individual booking card
  generateBookingCard(booking) {
    // Handle potential null/undefined values
    const status = booking.status || 'unknown';
    const statusBadgeClass = this.getStatusBadgeClass(status);
    const serviceDate = booking.service_date ? new Date(booking.service_date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }) : 'N/A';
    const createdDate = booking.created_at ? new Date(booking.created_at).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }) : 'N/A';

    return `
      <div class="col-md-6 mb-4">
        <div class="card h-100 shadow-sm">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h6 class="mb-0">
              <i class="fas fa-calendar me-2"></i>
              ${serviceDate}
            </h6>
            <span class="badge ${statusBadgeClass}">
              ${status.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
            </span>
          </div>
          
          <div class="card-body">
            <!-- Car Information -->
            ${booking.car ? `
              <div class="mb-3">
                <h6 class="card-subtitle mb-2 text-muted">
                  <i class="fas fa-car me-2"></i>Vehicle
                </h6>
                <p class="mb-1"><strong>${booking.car.make || 'Unknown'} ${booking.car.model || 'Model'}</strong></p>
                <small class="text-muted">Year: ${booking.car.year || 'N/A'}</small>
              </div>
            ` : ''}
            
            <!-- Service Center -->
            ${booking.service_center ? `
              <div class="mb-3">
                <h6 class="card-subtitle mb-2 text-muted">
                  <i class="fas fa-wrench me-2"></i>Service Center
                </h6>
                <p class="mb-1"><strong>${booking.service_center.garage_name || 'Unknown Garage'}</strong></p>
                <small class="text-muted">
                  <i class="fas fa-phone me-1"></i>${booking.service_center.phone || 'N/A'}
                </small>
              </div>
            ` : ''}
            
            <!-- Services -->
            <div class="mb-3">
              <h6 class="card-subtitle mb-2 text-muted">
                <i class="fas fa-cogs me-2"></i>Services
              </h6>
              ${booking.service_types && booking.service_types.length > 0 ? 
                booking.service_types.map(service => 
                  `<span class="badge bg-light text-dark me-1 mb-1">
                    ${service.name || 'Unknown Service'} - ₹${service.base_price || '0'}
                  </span>`
                ).join('') : 
                '<span class="text-muted">No services listed</span>'
              }
            </div>
            
            <!-- Location -->
            <div class="mb-3">
              <h6 class="card-subtitle mb-2 text-muted">
                <i class="fas fa-map-marker-alt me-2"></i>Service Location
              </h6>
              <small class="text-muted">Pincode: ${booking.pincode || 'N/A'}</small>
            </div>
            
            <!-- Notes -->
            ${booking.notes ? `
              <div class="mb-3">
                <h6 class="card-subtitle mb-2 text-muted">
                  <i class="fas fa-sticky-note me-2"></i>Notes
                </h6>
                <p class="text-muted small">${booking.notes}</p>
              </div>
            ` : ''}
            
            <!-- Invoice Information -->
            ${booking.invoice ? `
              <div class="mb-3">
                <h6 class="card-subtitle mb-2 text-muted">
                  <i class="fas fa-file-invoice-dollar me-2"></i>Invoice
                </h6>
                <p class="mb-1"><strong>Amount: ₹${booking.invoice.amount || '0'}</strong></p>
                <small class="text-muted">
                  Status: 
                  <span class="badge ${(booking.invoice.status === 'paid') ? 'bg-success' : 'bg-warning'}">
                    ${(booking.invoice.status || 'Unknown').replace(/\b\w/g, l => l.toUpperCase())}
                  </span>
                </small>
              </div>
            ` : ''}
          </div>
          
          <div class="card-footer text-muted d-flex justify-content-between align-items-center">
            <small>
              <i class="fas fa-clock me-1"></i>
              Booked on ${createdDate}
            </small>
            <small class="text-muted">ID: ${booking.id || 'N/A'}</small>
          </div>
        </div>
      </div>
    `;
  }

  // Get status badge class
  getStatusBadgeClass(status) {
    const statusClasses = {
      'pending': 'bg-warning',
      'waiting_for_pickup': 'bg-info',
      'pickup_completed': 'bg-primary',
      'in_service': 'bg-warning',
      'ready_for_dropoff': 'bg-success',
      'dropped_off': 'bg-success',
      'cancelled': 'bg-danger'
    };
    return statusClasses[status] || 'bg-secondary';
  }
}

// Initialize the BookingHistoryAPI when the script loads
window.bookingHistoryAPI = new BookingHistoryAPI();
