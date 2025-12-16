import axios from 'axios';
import apiClient from '../../services/apiClient';

const rawAxios = axios.create({
  baseURL: 'https://adryd-backend-production.up.railway.app/api/v1/',
});

// 🔹 Auth APIs
export const loginRequest = credentials =>
  apiClient.post('/auth/login', credentials);

export const refreshTokenRequest = refreshToken =>
  rawAxios.post('/auth/refresh', { refreshToken });

// 🔹 Registration APIs
export const registerRequest = data => apiClient.post('/auth/register', data);

export const verifyRegistrationRequest = data =>
  apiClient.post('/auth/register/verify', data);

// 🔹 Forgot password APIs
export const forgotPasswordRequest = data =>
  apiClient.post('/auth/forgot-password', data);

export const resetPasswordRequest = data =>
  apiClient.post('/auth/reset-password', data);

// 🔹 Logout (local only since backend doesn’t track tokens)
export const logoutRequest = async () => {
  const { clearTokens } = await import('./storage');
  await clearTokens();
  return { success: true, message: 'Logged out' };
};
