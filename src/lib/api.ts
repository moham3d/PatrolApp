import { LoginCredentials, User, ApiResponse, Shift, Incident, Location, SOSAlert, Checkpoint } from './types';

const API_BASE = 'https://api.millio.space';

class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  // Get token from Spark KV
  const token = await spark.kv.get<string>('auth_token');
  
  const config: RequestInit = {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  };

  console.log('Making request to:', `${API_BASE}${endpoint}`);
  console.log('Request config:', { 
    method: config.method,
    headers: config.headers,
    body: config.body 
  });

  try {
    const response = await fetch(`${API_BASE}${endpoint}`, config);
    
    if (!response.ok) {
      let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
      
      try {
        const errorData = await response.json();
        if (errorData.detail) {
          errorMessage = Array.isArray(errorData.detail) ? 
            errorData.detail.map((err: any) => err.msg).join(', ') : 
            errorData.detail;
        } else if (errorData.message) {
          errorMessage = errorData.message;
        }
      } catch {
        // If we can't parse JSON, stick with the original error message
      }
      
      throw new ApiError(response.status, errorMessage);
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
    console.log('Attempting login with:', { username: credentials.username });
    console.log('Request body:', JSON.stringify(credentials));
    
    // Try multiple request formats to debug the API
    const formats = [
      {
        name: 'JSON',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials)
      },
      {
        name: 'Form URL Encoded',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(credentials).toString()
      },
      {
        name: 'Form Data',
        headers: {},
        body: (() => {
          const formData = new FormData();
          formData.append('username', credentials.username);
          formData.append('password', credentials.password);
          return formData;
        })()
      }
    ];

    for (const format of formats) {
      try {
        console.log(`Trying ${format.name} format...`);
        const response = await fetch(`${API_BASE}/auth/login`, {
          method: 'POST',
          headers: format.headers,
          body: format.body,
        });

        const responseText = await response.text();
        console.log(`${format.name} - Status:`, response.status);
        console.log(`${format.name} - Response:`, responseText);

        if (response.ok) {
          const data = JSON.parse(responseText);
          console.log('Login successful with', format.name, ':', { userId: data.user?.id, role: data.user?.role });
          return data;
        }
      } catch (error) {
        console.error(`${format.name} failed:`, error);
      }
    }

    // If all formats fail, throw the last error
    throw new ApiError(422, 'Login failed with all request formats');
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