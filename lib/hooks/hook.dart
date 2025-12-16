import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  forgotPasswordRequest,
  loginRequest,
  logoutRequest,
  registerRequest,
  resetPasswordRequest,
  verifyRegistrationRequest,
} from './api';

import { clearTokens, setTokens } from './storage';

// 🔹 Login hook
export const useLogin = () => {
  return useMutation({
    mutationFn: loginRequest,
    onSuccess: async res => {
      const { accessToken, refreshToken, user } = res.data?.data || {};
      await setTokens(accessToken, refreshToken);
    },
  });
};

// 🔹 Logout hook
export const useLogout = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: logoutRequest,
    onSuccess: async () => {
      await clearTokens();
      qc.clear();
    },
  });
};

// 🔹 Register hooks
export const useRegister = () => {
  return useMutation({
    mutationFn: registerRequest,
  });
};

export const useVerifyRegistration = () => {
  return useMutation({
    mutationFn: verifyRegistrationRequest,
    onSuccess: async res => {
      const { accessToken, refreshToken, user } = res.data?.data || {};
      await setTokens(accessToken, refreshToken);
    },
  });
};
// 🔹 Forgot password hooks
export const useForgotPassword = () => {
  return useMutation({
    mutationFn: async payload => {
      console.log('[ForgotPassword] Sending request with payload:', payload);
      console.log('[ForgotPassword] API endpoint: /auth/forgot-password');
      try {
        const result = await forgotPasswordRequest(payload);
        console.log('[ForgotPassword] Response:', result);
        return result;
      } catch (error) {
        console.error('[ForgotPassword] Request failed:', error);
        throw error;
      }
    },
    onSuccess: res => {
      console.log('[ForgotPassword] Success:', res);
    },
    onError: err => {
      console.error('[ForgotPassword] Error details:', {
        message: err?.message,
        response: err?.response?.data,
        status: err?.response?.status,
        statusText: err?.response?.statusText,
      });
    },
  });
};

// 🔹 Reset password hook
export const useResetPassword = () => {
  return useMutation({
    mutationFn: async payload => {
      console.log('[ResetPassword] Sending request with payload:', payload);
      const result = await resetPasswordRequest(payload);
      console.log('[ResetPassword] Response:', result);
      return result;
    },
    onSuccess: async res => {
      console.log('[ResetPassword] Success:', res);
      const { accessToken, refreshToken, user } = res.data?.data || {};
      if (accessToken && refreshToken) {
        console.log('[ResetPassword] Saving tokens:', {
          accessToken,
          refreshToken,
        });
        await setTokens(accessToken, refreshToken);
      } else {
        console.warn('[ResetPassword] No tokens returned in response');
      }
    },
    onError: err => {
      console.error('[ResetPassword] Error:', err);
    },
  });
};
