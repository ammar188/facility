import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
const BASE_URL = 'https://adryd-backend-production.up.railway.app/api/v1/';
const customBaseQuery = async (args, api, extraOptions) => {
  const result = await fetchBaseQuery({
    baseUrl: BASE_URL,
    prepareHeaders: (headers, { getState }) => {
      const token = getState().auth?.token;
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      headers.set('content-type', 'application/json');
      headers.set('accept', 'application/json');
      return headers;
    },
    timeout: 10000,
  })(args, api, extraOptions);

  // Handle parsing errors professionally
  if (result.error && result.error.status === 'PARSING_ERROR') {
    let errorMessage = 'Server error occurred';
    if (result.error.data && typeof result.error.data === 'string') {
      const htmlContent = result.error.data;
      if (htmlContent.includes('TypeError: Cannot convert undefined or null to object')) {
        errorMessage = 'Server configuration error. Please contact support.';
      } else if (htmlContent.includes('500')) {
        errorMessage = 'Internal server error. Please try again later.';
      } else if (htmlContent.includes('404')) {
        errorMessage = 'API endpoint not found. Please check the server configuration.';
      }
    }
    return {
      error: {
        status: result.error.originalStatus || 500,
        data: { message: errorMessage },
        error: errorMessage
      }
    };
  }

  return result;
};

export const authApi = createApi({
  reducerPath: 'authApi',
  baseQuery: customBaseQuery,
  tagTypes: ['User'],
  endpoints: (builder) => ({
    register: builder.mutation({
      query: (userData) => {
        const requiredFields = ['username', 'email', 'password', 'companyName', 'phoneNumber'];
        const missingFields = requiredFields.filter(field => !userData[field]);
        
        if (missingFields.length > 0) {
          throw new Error(`Missing required fields: ${missingFields.join(', ')}`);
        }
        
        const requestBody = {
          username: userData.username,
          email: userData.email,
          password: userData.password,
          companyName: userData.companyName,
          phoneNumber: userData.phoneNumber
        };
        
        return {
          url: 'auth/register',
          method: 'POST',
          body: requestBody,
        };
      },
      transformResponse: (response) => {
        // Handle successful registration response
        if (response.success && response.data) {
          return {
            success: true,
            message: response.message || 'Registration successful',
            data: response.data
          };
        }
        return response;
      },
      transformErrorResponse: (response) => {
        // Handle error responses professionally
        const errorMessage = response.data?.message || 
                           response.data?.error || 
                           'Registration failed. Please try again.';
        
        return {
          status: response.status,
          data: {
            message: errorMessage,
            errors: response.data?.errors || null
          }
        };
      },
      invalidatesTags: ['User'],
    }),
    
    // Login endpoint with professional response handling
    login: builder.mutation({
      query: (credentials) => ({
        url: 'auth/login',
        method: 'POST',
        body: credentials,
      }),
      transformResponse: (response) => {
        // Handle successful login response
        if (response?.success && response?.data) {
          return {
            success: true,
            data: {
              user: response?.data?.user,
              token: response?.data?.token,
              message: response?.message || 'Login successful'
            }
          };
        }
        return response;
      },
      transformErrorResponse: (response) => {
        // Handle error responses professionally
        const errorMessage = response.data?.message || 
                           response.data?.error || 
                           'Login failed. Please check your credentials.';
        
        return {
          status: response.status,
          data: {
            message: errorMessage,
            errors: response.data?.errors || null
          }
        };
      },
      invalidatesTags: ['User'],
    }), 
    // Logout endpoint
    logout: builder.mutation({
      query: () => ({
        url: '/auth/logout',
        method: 'POST',
      }),
      invalidatesTags: ['User'],
    }),
    // Get user profile
    getUserProfile: builder.query({
      query: () => '/auth/profile',
      providesTags: ['User'],
    }),
    // Forgot password
    forgotPassword: builder.mutation({
      query: (email) => ({
        url: 'auth/forgot-password',
        method: 'POST',
        body: { email },
      }),
      transformResponse: (response) => {
        // Handle successful forgot password response
        if (response?.success) {
          return {
            success: true,
            message: response.message || 'If the email exists, an OTP has been sent'
          };
        }
        return response;
      },
      transformErrorResponse: (response) => {
        // Handle error responses professionally
        const errorMessage = response.data?.message || 
                           response.data?.error || 
                           'Failed to send reset instructions. Please try again.';
        
        return {
          status: response.status,
          data: {
            message: errorMessage,
            errors: response.data?.errors || null
          }
        };
      },
    }),
    // Reset password
    resetPassword: builder.mutation({
      query: ({ token, password }) => ({
        url: 'auth/reset-password',
        method: 'POST',
        body: { token, password },
      }),
      transformResponse: (response) => {
        // Handle successful reset password response
        if (response?.success) {
          return {
            success: true,
            message: response.message || 'Password reset successfully'
          };
        }
        return response;
      },
      transformErrorResponse: (response) => {
        // Handle error responses professionally
        const errorMessage = response.data?.message || 
                           response.data?.error || 
                           'Failed to reset password. Please try again.';
        
        return {
          status: response.status,
          data: {
            message: errorMessage,
            errors: response.data?.errors || null
          }
        };
      },
    }),
    // Reset password with email and newPassword
    resetPasswordWithEmail: builder.mutation({
      query: ({ email, newPassword }) => ({
        url: 'auth/reset-password',
        method: 'POST',
        body: { email, newPassword },
      }),
      transformResponse: (response) => {
        // Handle successful reset password response
        if (response?.success) {
          return {
            success: true,
            message: response.message || 'Password reset successfully',
            data: response.data
          };
        }
        return response;
      },
      transformErrorResponse: (response) => {
        // Handle error responses professionally
        const errorMessage = response.data?.message || 
                           response.data?.error || 
                           'Failed to reset password. Please try again.';
        
        return {
          status: response.status,
          data: {
            message: errorMessage,
            errors: response.data?.errors || null
          }
        };
      },
    }),
    // Get listings with search
    getListings: builder.query({
      query: ({ search = '', limit = 20, offset = 0 }) => ({
        url: `listings?search=${search}&limit=${limit}&offset=${offset}`,
        method: 'GET',
      }),
      transformResponse: (response) => {
        // Handle successful listings response
        if (response?.success) {
          return {
            success: true,
            data: response.data,
            meta: response.meta,
            message: response.message || 'Listings fetched successfully'
          };
        }
        return response;
      },
      transformErrorResponse: (response) => {
        // Handle error responses professionally
        const errorMessage = response.data?.message || 
                           response.data?.error || 
                           'Failed to fetch listings. Please try again.';
        
        return {
          status: response.status,
          data: {
            message: errorMessage,
            errors: response.data?.errors || null
          }
        };
      },
    }),
  }),
});
export const {
  useRegisterMutation,
  useLoginMutation,
  useLogoutMutation,
  useGetUserProfileQuery,
  useForgotPasswordMutation,
  useResetPasswordMutation,
  useResetPasswordWithEmailMutation,
  useGetListingsQuery,
} = authApi;
