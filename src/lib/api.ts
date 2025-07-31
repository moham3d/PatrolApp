import axios from 'axios';

// Dynamic API base URL detection
const API_BASE_URL = window.location.hostname === 'localhost' 
  ? 'http://localhost:8000' 
  : 'https://api.millio.space';

class ApiService {
  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add request interceptor to include auth token from Spark KV
    this.client.interceptors.request.use(
      async (config) => {
        const token = await spark.kv.get<string>('auth_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Add response interceptor to handle auth errors
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          await spark.kv.delete('auth_token');
          window.location.reload();
        }
        return Promise.reject(error);
      }
    );
  }

  // Authentication
  async login(username, password) {
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);
    
    const response = await this.client.post('/auth/login', formData, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
    
    if (response.data.access_token) {
      await spark.kv.set('auth_token', response.data.access_token);
    }
    
    return response.data;
  }

  async getCurrentUser() {
    const response = await this.client.get('/auth/me');
    return response.data;
  }

  async logout() {
    await spark.kv.delete('auth_token');
    window.location.reload();
  }

  // Users
  async getUsers(skip = 0, limit = 100) {
    const response = await this.client.get(`/users/?skip=${skip}&limit=${limit}`);
    return response.data;
  }

  async createUser(userData) {
    const response = await this.client.post('/users/', userData);
    return response.data;
  }

  async getUser(userId) {
    const response = await this.client.get(`/users/${userId}`);
    return response.data;
  }

  async updateUser(userId, userData) {
    const response = await this.client.put(`/users/${userId}`, userData);
    return response.data;
  }

  async deleteUser(userId) {
    const response = await this.client.delete(`/users/${userId}`);
    return response.data;
  }

  // Roles
  async getRoles(skip = 0, limit = 100) {
    const response = await this.client.get(`/roles/?skip=${skip}&limit=${limit}`);
    return response.data;
  }

  async createRole(roleData) {
    const response = await this.client.post('/roles/', roleData);
    return response.data;
  }

  async getRole(roleId) {
    const response = await this.client.get(`/roles/${roleId}`);
    return response.data;
  }

  async updateRole(roleId, roleData) {
    const response = await this.client.put(`/roles/${roleId}`, roleData);
    return response.data;
  }

  async deleteRole(roleId) {
    const response = await this.client.delete(`/roles/${roleId}`);
    return response.data;
  }

  async getPermissions() {
    const response = await this.client.get('/permissions/');
    return response.data;
  }

  // Sites
  async getSites() {
    const response = await this.client.get('/sites/');
    return response.data;
  }

  async createSite(siteData) {
    const response = await this.client.post('/sites/', siteData);
    return response.data;
  }

  async getSite(siteId) {
    const response = await this.client.get(`/sites/${siteId}`);
    return response.data;
  }

  async updateSite(siteId, siteData) {
    const response = await this.client.put(`/sites/${siteId}`, siteData);
    return response.data;
  }

  async deleteSite(siteId) {
    const response = await this.client.delete(`/sites/${siteId}`);
    return response.data;
  }

  // Locations
  async getLocations(siteId = null) {
    const url = siteId ? `/sites/locations/` : '/sites/locations/';
    const response = await this.client.get(url);
    return response.data;
  }

  async createLocation(locationData) {
    const { site_id, ...locationPayload } = locationData;
    const response = await this.client.post(`/sites/${site_id}/locations/`, locationPayload);
    return response.data;
  }

  async getLocation(locationId) {
    const response = await this.client.get(`/sites/locations/${locationId}`);
    return response.data;
  }

  async updateLocation(locationId, locationData) {
    const response = await this.client.put(`/sites/locations/${locationId}`, locationData);
    return response.data;
  }

  async deleteLocation(locationId) {
    const response = await this.client.delete(`/sites/locations/${locationId}`);
    return response.data;
  }

  // Areas
  async getAreas() {
    const response = await this.client.get('/sites/areas/');
    return response.data;
  }

  async createArea(locationId, areaData) {
    const response = await this.client.post(`/sites/locations/${locationId}/areas/`, areaData);
    return response.data;
  }

  async getArea(areaId) {
    const response = await this.client.get(`/sites/areas/${areaId}`);
    return response.data;
  }

  async updateArea(areaId, areaData) {
    const response = await this.client.put(`/sites/areas/${areaId}`, areaData);
    return response.data;
  }

  async deleteArea(areaId) {
    const response = await this.client.delete(`/sites/areas/${areaId}`);
    return response.data;
  }

  // Site user assignments
  async getSiteUsers(siteId) {
    const response = await this.client.get(`/sites/${siteId}/users`);
    return response.data;
  }

  async assignUserToSite(siteId, userId) {
    const response = await this.client.post(`/sites/${siteId}/users/${userId}`);
    return response.data;
  }

  async unassignUserFromSite(siteId, userId) {
    const response = await this.client.delete(`/sites/${siteId}/users/${userId}`);
    return response.data;
  }

  async getAvailableUsersForSite(siteId) {
    const response = await this.client.get(`/sites/${siteId}/available-users`);
    return response.data;
  }

  // Incidents
  async getIncidents(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/incidents/?${queryString}`);
    return response.data;
  }

  async createIncident(incidentData) {
    const response = await this.client.post('/incidents/', incidentData);
    return response.data;
  }

  async getIncident(incidentId) {
    const response = await this.client.get(`/incidents/${incidentId}`);
    return response.data;
  }

  async updateIncident(incidentId, incidentData) {
    const response = await this.client.put(`/incidents/${incidentId}`, incidentData);
    return response.data;
  }

  async deleteIncident(incidentId) {
    const response = await this.client.delete(`/incidents/${incidentId}`);
    return response.data;
  }

  // Patrol Incidents
  async getPatrolIncidents() {
    const response = await this.client.get('/patrol/incidents/');
    return response.data;
  }

  async createPatrolIncident(incidentData) {
    const response = await this.client.post('/patrol/incidents/', incidentData);
    return response.data;
  }

  async getPatrolIncident(incidentId) {
    const response = await this.client.get(`/patrol/incidents/${incidentId}`);
    return response.data;
  }

  async updatePatrolIncident(incidentId, incidentData) {
    const response = await this.client.put(`/patrol/incidents/${incidentId}`, incidentData);
    return response.data;
  }

  async deletePatrolIncident(incidentId) {
    const response = await this.client.delete(`/patrol/incidents/${incidentId}`);
    return response.data;
  }

  // Patrol
  async getPatrols(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/patrol/${queryString ? '?' + queryString : ''}`);
    return response.data;
  }

  async createPatrol(patrolData) {
    const response = await this.client.post('/patrol/', patrolData);
    return response.data;
  }

  // Patrol Checkpoints
  async getCheckpoints(siteId = null) {
    const queryString = siteId ? `?site_id=${siteId}` : '';
    const response = await this.client.get(`/patrol/checkpoints/${queryString}`);
    return response.data;
  }

  async createCheckpoint(checkpointData) {
    const response = await this.client.post('/patrol/checkpoints/', checkpointData);
    return response.data;
  }

  async getCheckpoint(checkpointId) {
    const response = await this.client.get(`/patrol/checkpoints/${checkpointId}`);
    return response.data;
  }

  async updateCheckpoint(checkpointId, checkpointData) {
    const response = await this.client.put(`/patrol/checkpoints/${checkpointId}`, checkpointData);
    return response.data;
  }

  async deleteCheckpoint(checkpointId) {
    const response = await this.client.delete(`/patrol/checkpoints/${checkpointId}`);
    return response.data;
  }

  // Patrol Shift Logs
  async getShiftLogs() {
    const response = await this.client.get('/patrol/shifts/logs/');
    return response.data;
  }

  async createShiftLog(shiftLogData) {
    const response = await this.client.post('/patrol/shifts/logs/', shiftLogData);
    return response.data;
  }

  async getShiftLog(logId) {
    const response = await this.client.get(`/patrol/shifts/logs/${logId}`);
    return response.data;
  }

  async updateShiftLog(logId, logData) {
    const response = await this.client.put(`/patrol/shifts/logs/${logId}`, logData);
    return response.data;
  }

  async deleteShiftLog(logId) {
    const response = await this.client.delete(`/patrol/shifts/logs/${logId}`);
    return response.data;
  }

  // GPS
  async recordLocation(locationData) {
    const response = await this.client.post('/gps/location', locationData);
    return response.data;
  }

  async getCurrentLocations(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/gps/location/current${queryString ? '?' + queryString : ''}`);
    return response.data;
  }

  async getLocationHistory(guardId, params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/gps/location/history/${guardId}${queryString ? '?' + queryString : ''}`);
    return response.data;
  }

  async triggerSosAlert({ latitude, longitude, message }) {
    const params = new URLSearchParams({ latitude, longitude, message });
    const response = await this.client.post(`/gps/sos?${params.toString()}`);
    return response.data;
  }

  async getActiveAlerts(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/gps/alerts/active${queryString ? '?' + queryString : ''}`);
    return response.data;
  }

  async acknowledgeAlert(alertId) {
    const response = await this.client.put(`/gps/alerts/${alertId}/acknowledge`);
    return response.data;
  }

  // Messages
  async getMessages() {
    const response = await this.client.get('/messages/');
    return response.data;
  }

  async sendMessage(messageData) {
    const response = await this.client.post('/messages/', messageData);
    return response.data;
  }

  async getMessage(messageId) {
    const response = await this.client.get(`/messages/${messageId}`);
    return response.data;
  }

  async markMessageAsRead(messageId) {
    const response = await this.client.put(`/messages/${messageId}/read`);
    return response.data;
  }

  async deleteMessage(messageId) {
    const response = await this.client.delete(`/messages/${messageId}`);
    return response.data;
  }

  async getSentMessages(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/messages/sent/${queryString ? '?' + queryString : ''}`);
    return response.data;
  }

  async getUnreadMessages() {
    const response = await this.client.get('/messages/unread/');
    return response.data;
  }

  async getSosMessages(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/messages/sos/${queryString ? '?' + queryString : ''}`);
    return response.data;
  }

  // Tasks
  async getTasks() {
    const response = await this.client.get('/tasks/');
    return response.data;
  }

  async createTask(taskData) {
    const response = await this.client.post('/tasks/', taskData);
    return response.data;
  }

  async getTask(taskId) {
    const response = await this.client.get(`/tasks/${taskId}`);
    return response.data;
  }

  async updateTask(taskId, taskData) {
    const response = await this.client.put(`/tasks/${taskId}`, taskData);
    return response.data;
  }

  async deleteTask(taskId) {
    const response = await this.client.delete(`/tasks/${taskId}`);
    return response.data;
  }

  // Reports
  async getReportsSummary() {
    const response = await this.client.get('/reports/');
    return response.data;
  }

  async createReport(reportData) {
    const response = await this.client.post('/reports/', reportData);
    return response.data;
  }

  async getIncidentReports(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    const response = await this.client.get(`/reports/incidents/?${queryString}`);
    return response.data;
  }

  // Analytics
  async getAnalyticsSummary() {
    const response = await this.client.get('/analytics/summary');
    return response.data;
  }

  async getAnalyticsOverview() {
    const response = await this.client.get('/analytics/');
    return response.data;
  }

  async getIncidentCountBySite() {
    const response = await this.client.get('/analytics/incidents/by-site');
    return response.data;
  }

  async getIncidentCount() {
    const response = await this.client.get('/analytics/incidents/count');
    return response.data;
  }

  async getUserCount() {
    const response = await this.client.get('/analytics/users/count');
    return response.data;
  }

  // Notifications
  async getNotifications() {
    const response = await this.client.get('/notifications/');
    return response.data;
  }

  async createNotification(notificationData) {
    const response = await this.client.post('/notifications/', notificationData);
    return response.data;
  }

  async markNotificationAsRead(notificationId) {
    const response = await this.client.put(`/notifications/${notificationId}/read`);
    return response.data;
  }

  async deleteNotification(notificationId) {
    const response = await this.client.delete(`/notifications/${notificationId}`);
    return response.data;
  }

  // Visitors
  async getVisitors() {
    const response = await this.client.get('/visitors/');
    return response.data;
  }

  async createVisitor(visitorData) {
    const response = await this.client.post('/visitors/', visitorData);
    return response.data;
  }

  async getVisitor(visitorId) {
    const response = await this.client.get(`/visitors/${visitorId}`);
    return response.data;
  }

  async updateVisitor(visitorId, visitorData) {
    const response = await this.client.put(`/visitors/${visitorId}`, visitorData);
    return response.data;
  }

  async deleteVisitor(visitorId) {
    const response = await this.client.delete(`/visitors/${visitorId}`);
    return response.data;
  }

  // Root & Health
  async root() {
    const response = await this.client.get('/');
    return response.data;
  }

  async healthCheck() {
    const response = await this.client.get('/health');
    return response.data;
  }

  // Additional convenience methods for UI compatibility
  async getCurrentShift() {
    try {
      // This may not exist in the backend API, so we'll try patrol shifts first
      const response = await this.client.get('/patrol/shifts/current');
      return response.data;
    } catch (error) {
      if (error?.response?.status === 404) {
        return null; // No active shift
      }
      throw error;
    }
  }

  async getActiveSOSAlerts() {
    return this.getActiveAlerts();
  }

  async triggerSOS(location) {
    return this.triggerSosAlert({
      latitude: location.latitude,
      longitude: location.longitude,
      message: location.message || 'Emergency SOS Alert'
    });
  }

  async endShift(shiftId) {
    try {
      const response = await this.client.post(`/patrol/shifts/${shiftId}/end`);
      return response.data;
    } catch (error) {
      console.error('End shift failed:', error);
      throw error;
    }
  }

  async startShift(siteId) {
    try {
      const response = await this.client.post('/patrol/shifts', { site_id: siteId });
      return response.data;
    } catch (error) {
      console.error('Start shift failed:', error);
      throw error;
    }
  }

  async logCheckpoint(checkpointId, notes) {
    return this.createShiftLog({
      checkpoint_id: checkpointId,
      notes: notes,
      timestamp: new Date().toISOString()
    });
  }
}

export default new ApiService();