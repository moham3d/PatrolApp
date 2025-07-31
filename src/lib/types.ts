export interface User {
  id: string;
  email: string;
  name: string;
  role: 'guard' | 'supervisor' | 'admin';
  site_id?: string;
  phone?: string;
}

export interface LoginCredentials {
  username: string;
  password: string;
}

export interface ApiResponse<T> {
  data: T;
  message?: string;
}

export interface Shift {
  id: string;
  user_id: string;
  site_id: string;
  start_time: string;
  end_time?: string;
  status: 'active' | 'completed';
}

export interface Checkpoint {
  id: string;
  site_id: string;
  name: string;
  qr_code?: string;
  nfc_id?: string;
  location: {
    lat: number;
    lng: number;
  };
}

export interface Incident {
  id: string;
  site_id: string;
  user_id: string;
  title: string;
  description: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  status: 'open' | 'investigating' | 'resolved';
  created_at: string;
  photos?: string[];
}

export interface Location {
  lat: number;
  lng: number;
  timestamp: string;
  accuracy?: number;
}

export interface SOSAlert {
  id: string;
  user_id: string;
  location: Location;
  status: 'active' | 'responding' | 'resolved';
  created_at: string;
}