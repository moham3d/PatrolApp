import { LoginCredentials, User, ApiResponse, Shift, Incident, Location, SOSAlert, Checkpoint } from './types';

const API_BASE = 'https://api.millio.space';

class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const token = localStorage.getItem('auth_token');
  
  const config: RequestInit = {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  };

  try {
    const response = await fetch(`${API_BASE}${endpoint}`, config);
    
    if (!response.ok) {
      throw new ApiError(response.status, `HTTP ${response.status}: ${response.statusText}`);
    }
    
    return await response.json();
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }
    throw new ApiError(0, 'Network error occurred');
  }
}

export const api = {
  // Authentication
  async login(credentials: LoginCredentials): Promise<{ token: string; user: User }> {
    const response = await request<{ token: string; user: User }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials),
    });
    return response;
  },

  async getMe(): Promise<User> {
    return request<User>('/auth/me');
  },

  // Shifts
  async getCurrentShift(): Promise<Shift | null> {
    try {
      return await request<Shift>('/patrol/shifts/current');
    } catch (error) {
      if (error instanceof ApiError && error.status === 404) {
        return null;
      }
      throw error;
    }
  },

  async startShift(siteId: string): Promise<Shift> {
    return request<Shift>('/patrol/shifts', {
      method: 'POST',
      body: JSON.stringify({ site_id: siteId }),
    });
  },

  async endShift(shiftId: string): Promise<Shift> {
    return request<Shift>(`/patrol/shifts/${shiftId}/end`, {
      method: 'POST',
    });
  },

  async logCheckpoint(checkpointId: string, notes?: string): Promise<void> {
    return request('/patrol/shifts/logs', {
      method: 'POST',
      body: JSON.stringify({ 
        checkpoint_id: checkpointId, 
        notes,
        timestamp: new Date().toISOString()
      }),
    });
  },

  // Checkpoints
  async getCheckpoints(siteId?: string): Promise<Checkpoint[]> {
    const query = siteId ? `?site_id=${siteId}` : '';
    return request<Checkpoint[]>(`/patrol/checkpoints/${query}`);
  },

  // GPS & Emergency
  async sendLocation(location: Location): Promise<void> {
    return request('/gps/location', {
      method: 'POST',
      body: JSON.stringify(location),
    });
  },

  async triggerSOS(location: Location): Promise<SOSAlert> {
    return request<SOSAlert>('/gps/sos', {
      method: 'POST',
      body: JSON.stringify(location),
    });
  },

  async getActiveSOSAlerts(): Promise<SOSAlert[]> {
    return request<SOSAlert[]>('/gps/alerts/active');
  },

  // Incidents
  async getIncidents(filters?: { site_id?: string; status?: string }): Promise<Incident[]> {
    const params = new URLSearchParams();
    if (filters?.site_id) params.append('site_id', filters.site_id);
    if (filters?.status) params.append('status', filters.status);
    
    const query = params.toString() ? `?${params.toString()}` : '';
    return request<Incident[]>(`/patrol/incidents${query}`);
  },

  async createIncident(incident: Omit<Incident, 'id' | 'created_at'>): Promise<Incident> {
    return request<Incident>('/patrol/incidents', {
      method: 'POST',
      body: JSON.stringify(incident),
    });
  },

  async updateIncident(id: string, updates: Partial<Incident>): Promise<Incident> {
    return request<Incident>(`/incidents/${id}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    });
  },

  // Messages
  async getMessages(): Promise<any[]> {
    return request<any[]>('/messages/');
  },

  // Tasks
  async getTasks(): Promise<any[]> {
    return request<any[]>('/tasks/');
  },

  // Supervisor features
  async assignUserToSite(siteId: string, userId: string): Promise<void> {
    return request(`/sites/${siteId}/users/${userId}`, {
      method: 'POST',
    });
  },

  async getLiveLocations(): Promise<any[]> {
    return request<any[]>('/gps/location/current');
  },

  async getAnalyticsSummary(): Promise<any> {
    return request('/analytics/summary');
  },

  async getIncidentAnalytics(): Promise<any> {
    return request('/analytics/incidents/by-site');
  },
};