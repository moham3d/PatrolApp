import React, { createContext, useContext, useEffect, useState } from 'react';
import { jwtDecode } from 'jwt-decode';
import { User } from '../lib/types';
import { api } from '../lib/api';
import { useKV } from '@github/spark/hooks';

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
  error: string | null;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: React.ReactNode;
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useKV<string | null>("auth_token", null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const initAuth = async () => {
      if (token) {
        try {
          // Check if token is expired
          const decoded: any = jwtDecode(token);
          if (decoded.exp * 1000 > Date.now()) {
            const userData = await api.getMe();
            setUser(userData);
          } else {
            setToken(null);
          }
        } catch (error) {
          console.error('Auth initialization error:', error);
          setToken(null);
        }
      }
      
      setIsLoading(false);
    };

    initAuth();
  }, [token]);

  const login = async (username: string, password: string) => {
    setIsLoading(true);
    setError(null);
    
    try {
      console.log('Attempting login for username:', username);
      const response = await api.login({ username, password });
      
      setToken(response.token);
      setUser(response.user);
      console.log('Login successful:', response.user);
    } catch (error) {
      console.error('Login error:', error);
      const message = error instanceof Error ? error.message : 'Login failed';
      setError(message);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    setError(null);
  };

  return (
    <AuthContext.Provider value={{
      user,
      token,
      login,
      logout,
      isLoading,
      error
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}