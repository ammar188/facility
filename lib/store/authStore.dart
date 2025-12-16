// src/store/authStore.ts
import type { User } from '@supabase/supabase-js';
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { supabase } from '../services/supabase';

// --------------------
// Types
// --------------------
interface AuthState {
  user: User | null;
  loading: boolean;
  referrerCode: string | null;
  setUser: (user: User | null) => void;
  setReferrerCode: (code: string | null) => void;
  initializeSession: () => Promise<void>;
  logout: () => Promise<void>;
}

// --------------------
// Store
// --------------------
export const useAuthStore = create<AuthState>()(
  persist(
    set => ({
      user: null,
      loading: true,
      referrerCode: null,

      // ✅ Set user manually (after login/register)
      setUser: user => set({ user }),

      // ✅ Set referral code when user comes via referral link
      setReferrerCode: code => set({ referrerCode: code }),

      // ✅ Load Supabase session on app startup
      initializeSession: async () => {

        try {
          const { data, error } = await supabase.auth.refreshSession();

          if (error) {
            console.error('[Auth] Session error:', error);
          } else {
            console.log('[Auth] Raw session:', data);
          }

          const session = data.session;
          const user = session?.user ?? null;

          console.log('[Auth] session.user:', user);

          const hasPassword = user?.user_metadata?.has_password === true;

          console.log('[Auth] user_metadata:', user?.user_metadata);
          console.log('[Auth] hasPassword:', hasPassword);

          const isFullyOnboarded = hasPassword;
          console.log('[Auth] isFullyOnboarded:', isFullyOnboarded);

          set({
            user: isFullyOnboarded ? user : null,
            loading: false,
          });

          console.log(
            `[Auth] Final state -> user: ${
              isFullyOnboarded ? 'LOGGED-IN' : 'NOT LOGGED-IN'
            }, loading: false`,
          );
        } catch (err) {
          console.error('[Auth] initializeSession exception:', err);
          set({ user: null, loading: false });
          console.log('[Auth] Final state -> user: null, loading: false');
        }
      },

      // ✅ Logout user
      logout: async () => {
        try {
          await supabase.auth.signOut();
        } catch (err) {
          console.error('Logout error:', err);
        } finally {
          set({ user: null, referrerCode: null });
        }
      },
    }),
    {
      name: 'auth-storage',
      partialize: state => ({
        user: state.user,
        referrerCode: state.referrerCode,
      }), // persist user + referral code
    },
  ),
);
