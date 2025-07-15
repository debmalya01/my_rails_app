// Dual login: after Devise login, also request a token and store it

document.addEventListener('DOMContentLoaded', function() {
  const dualLoginForm = document.getElementById('dual-login-form');
  if (dualLoginForm){
    // On submit, store credentials in sessionStorage for token fetch after redirect
    dualLoginForm.addEventListener('submit', function(e) {
      const email = document.getElementById('dual-login-email').value;
      const password = document.getElementById('dual-login-password').value;
      console.log('[DualLogin] About to store:', email, password);
      sessionStorage.setItem('dual_login_email', email);
      sessionStorage.setItem('dual_login_password', password);
      // Prevent default, then submit programmatically to guarantee storage
      e.preventDefault();
      setTimeout(() => {
        dualLoginForm.submit();
        console.log('[DualLogin] Form submitted programmatically after storing credentials.');
      }, 0);
      console.log('[DualLogin] Credentials stored in sessionStorage.');
      console.log('email:', sessionStorage.getItem('dual_login_email'));
      console.log('password:', sessionStorage.getItem('dual_login_password'));
    });
  } 

  // After login, if credentials are in sessionStorage and user is logged in, request token
  if (window.location.pathname !== '/users/sign_in' && 
    sessionStorage.getItem('dual_login_email') && 
    sessionStorage.getItem('dual_login_password')
  ) {
    const email = sessionStorage.getItem('dual_login_email');
    const password = sessionStorage.getItem('dual_login_password');
    sessionStorage.removeItem('dual_login_email');
    sessionStorage.removeItem('dual_login_password');
    console.log('[DualLogin] Retrieved from sessionStorage:', email, password);
    console.log('[DualLogin] Attempting token fetch for:', email);

    // TODO: Replace with your actual client_id and client_secret
    const client_id = 'LpY-ZnLlDOSzYI8smtc8POcZaXfHWgYj9wk7GVQjXPM';
    const client_secret = '_CvejnOYy4KeHRJbxcHrn2rINag7wD_p7RWnIUJGmtI';

    const params = new URLSearchParams();
    params.append('grant_type', 'password');
    params.append('username', email);
    params.append('password', password);
    params.append('client_id', client_id);
    params.append('client_secret', client_secret);

    fetch('/oauth/token', {
      method: 'POST',
      headers: { 'Accept': 'application/json' },
      body: params
    })
    .then(res => res.json())
    .then(data => {
      const errorDiv = document.getElementById('dual-login-token-error');
      const successDiv = document.getElementById('dual-login-token-success');
      if (data.access_token) {
        sessionStorage.setItem('access_token', data.access_token);
        if (successDiv) successDiv.textContent = 'API token login successful!';
        if (errorDiv) errorDiv.textContent = '';
        console.log('[DualLogin] API Access Token:', data.access_token);
      } else {
        if (errorDiv) errorDiv.textContent = data.error_description || 'API token login failed';
        if (successDiv) successDiv.textContent = '';
        console.log('[DualLogin] Token fetch failed:', data);
      }
    })
    .catch((err) => {
      const errorDiv = document.getElementById('dual-login-token-error');
      if (errorDiv) errorDiv.textContent = 'Network error during API token login.';
      console.log('[DualLogin] Network error during token fetch:', err);
    });
  }
});

// Helper to get Authorization header for API requests
window.getApiAuthHeaders = function() {
  const token = sessionStorage.getItem('access_token');
  return token ? { 'Authorization': 'Bearer ' + token } : {};
}; 