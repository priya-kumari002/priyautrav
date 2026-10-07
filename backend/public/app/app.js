const API = window.location.origin;
const STORAGE = {
  token: 'priyashifter_token',
  draft: 'priyashifter_draft',
};

function loadDraft() {
  try {
    return JSON.parse(sessionStorage.getItem(STORAGE.draft) || '{}');
  } catch {
    return {};
  }
}

function saveDraft(draft) {
  sessionStorage.setItem(STORAGE.draft, JSON.stringify(draft));
}

const state = {
  phone: '',
  token: localStorage.getItem(STORAGE.token) || '',
  draft: loadDraft(),
};

function show(id) {
  document.querySelectorAll('.screen').forEach((s) => s.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  window.scrollTo(0, 0);
}

function parseApiError(data, status) {
  if (status === 401) return 'Session expired. Please login again.';
  if (data?.error) return data.error;
  if (Array.isArray(data?.errors) && data.errors.length) {
    return data.errors.map((e) => e.msg || e.message).filter(Boolean).join('. ');
  }
  return 'Request failed. Check all fields and try again.';
}

async function api(path, opts = {}) {
  const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
  if (state.token) headers.Authorization = `Bearer ${state.token}`;
  const res = await fetch(`${API}${path}`, { ...opts, headers });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = new Error(parseApiError(data, res.status));
    err.status = res.status;
    throw err;
  }
  return data;
}

function setErr(id, msg) {
  const el = document.getElementById(id);
  if (el) el.textContent = msg || '';
}

function setLoading(btn, loading) {
  if (!btn) return;
  btn.disabled = loading;
  btn.dataset.label = btn.dataset.label || btn.textContent;
  btn.textContent = loading ? 'Please wait…' : btn.dataset.label;
}

document.getElementById('btn-send-otp').onclick = async () => {
  const btn = document.getElementById('btn-send-otp');
  setErr('err-signin', '');
  const phone = document.getElementById('phone').value.replace(/\D/g, '');
  if (phone.length !== 10) return setErr('err-signin', 'Enter valid 10 digit number');
  try {
    setLoading(btn, true);
    const data = await api('/api/auth/send-otp', { method: 'POST', body: JSON.stringify({ phone, countryCode: '+91' }) });
    state.phone = phone;
    document.getElementById('otp-hint').textContent = `Code sent to +91 ${phone}`;
    document.getElementById('dev-otp').textContent = data.devOtp ? `Dev OTP: ${data.devOtp}` : '';
    show('screen-otp');
  } catch (e) {
    setErr('err-signin', e.message);
  } finally {
    setLoading(btn, false);
  }
};

document.getElementById('btn-verify').onclick = async () => {
  const btn = document.getElementById('btn-verify');
  setErr('err-otp', '');
  const otp = document.getElementById('otp').value.trim();
  if (otp.length !== 4) return setErr('err-otp', 'Enter 4 digit OTP');
  try {
    setLoading(btn, true);
    const data = await api('/api/auth/verify-otp', {
      method: 'POST',
      body: JSON.stringify({ phone: state.phone, otp, countryCode: '+91' }),
    });
    state.token = data.token;
    localStorage.setItem(STORAGE.token, state.token);
    await loadHome();
    show('screen-home');
  } catch (e) {
    setErr('err-otp', e.message);
  } finally {
    setLoading(btn, false);
  }
};

async function loadHome() {
  setErr('err-home', '');
  const grid = document.getElementById('transport-grid');
  grid.innerHTML = '<p class="muted">Loading…</p>';
  try {
    const list = await api('/api/catalog/transports');
    grid.innerHTML = '';
    list.forEach((t) => {
      const b = document.createElement('button');
      b.type = 'button';
      b.className = 'tile';
      b.innerHTML = `<span class="tile-icon">${iconFor(t.code)}</span><span>${t.label}</span>`;
      b.onclick = () => {
        state.draft.transportCode = t.code;
        state.draft.transportLabel = t.label;
        saveDraft(state.draft);
        show('screen-location');
      };
      grid.appendChild(b);
    });
  } catch (e) {
    grid.innerHTML = '';
    if (e.status === 401) {
      logout();
      return;
    }
    setErr('err-home', e.message);
  }
}

function iconFor(code) {
  const map = { two_wheeler: '🏍️', mini_truck: '🚐', three_wheeler: '🛺', big_truck: '🚛' };
  return map[code] || '📦';
}

document.getElementById('btn-back-loc').onclick = () => show('screen-home');
document.getElementById('btn-back-order').onclick = () => show('screen-location');

document.getElementById('btn-loc-continue').onclick = () => {
  const pickup = document.getElementById('pickup').value.trim();
  const dropoff = document.getElementById('dropoff').value.trim();
  if (pickup.length < 3 || dropoff.length < 3) {
    setErr('err-loc', 'Enter pickup and drop-off (min 3 characters)');
    return;
  }
  setErr('err-loc', '');
  state.draft.pickup = pickup;
  state.draft.dropoff = dropoff;
  saveDraft(state.draft);
  document.getElementById('transport-chip').textContent = state.draft.transportLabel || 'Transport';
  document.getElementById('route-summary').textContent = `${pickup} → ${dropoff}`;
  show('screen-order');
};

document.getElementById('btn-save').onclick = async () => {
  const btn = document.getElementById('btn-save');
  setErr('err-order', '');

  const payload = {
    transportCode: state.draft.transportCode,
    pickupAddress: state.draft.pickup,
    dropoffAddress: state.draft.dropoff,
    senderName: document.getElementById('sender-name').value.trim(),
    senderPhone: document.getElementById('sender-phone').value.replace(/\D/g, ''),
    receiverName: document.getElementById('receiver-name').value.trim(),
    receiverPhone: document.getElementById('receiver-phone').value.replace(/\D/g, ''),
    vehicleBodyType: document.querySelector('input[name="body"]:checked')?.value || 'open',
    receiverIsSelf: false,
    remarks: document.getElementById('remarks').value.trim() || undefined,
  };

  if (!payload.transportCode) return setErr('err-order', 'Select transport from home screen first');
  if (!payload.pickupAddress || !payload.dropoffAddress) return setErr('err-order', 'Add pickup and drop-off locations');
  if (payload.senderName.length < 2) return setErr('err-order', 'Sender name required');
  if (payload.senderPhone.length !== 10) return setErr('err-order', 'Sender phone must be 10 digits');
  if (payload.receiverName.length < 2) return setErr('err-order', 'Receiver name required');
  if (payload.receiverPhone.length !== 10) return setErr('err-order', 'Receiver phone must be 10 digits');

  try {
    setLoading(btn, true);
    const result = await api('/api/bookings', { method: 'POST', body: JSON.stringify(payload) });
    document.getElementById('done-id').textContent = result.id ? `Booking #${result.id}` : '';
    sessionStorage.removeItem(STORAGE.draft);
    state.draft = {};
    show('screen-done');
  } catch (e) {
    if (e.status === 401) {
      logout();
      setErr('err-signin', e.message);
      return;
    }
    setErr('err-order', e.message);
  } finally {
    setLoading(btn, false);
  }
};

document.getElementById('btn-new').onclick = () => {
  loadHome();
  show('screen-home');
};

document.getElementById('btn-logout').onclick = () => {
  if (confirm('Logout from priyashifter?')) logout();
};

function logout() {
  localStorage.removeItem(STORAGE.token);
  sessionStorage.removeItem(STORAGE.draft);
  state.token = '';
  state.draft = {};
  show('screen-signin');
}

if (state.token) {
  loadHome()
    .then(() => show('screen-home'))
    .catch(() => logout());
} else {
  show('screen-signin');
}
