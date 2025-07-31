import React, { useState, useEffect } from 'react';
import { ChartBar, TrendUp, Shield, Warning, Users, MapPin } from '@phosphor-icons/react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { useAuth } from '../hooks/use-auth';
import { api } from '../lib/api';

interface AnalyticsData {
  totalIncidents: number;
  openIncidents: number;
  activeShifts: number;
  totalGuards: number;
  sitesCount: number;
  incidentsBySite: Array<{
    site_name: string;
    count: number;
    severity_breakdown: {
      critical: number;
      high: number;
      medium: number;
      low: number;
    };
  }>;
  recentAlerts: Array<{
    id: string;
    type: 'incident' | 'sos';
    message: string;
    time: string;
    severity?: string;
  }>;
}

export function AnalyticsScreen() {
  const { user } = useAuth();
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadAnalytics();
  }, []);

  const loadAnalytics = async () => {
    try {
      // In a real app, this would call api.getAnalyticsSummary()
      // For demo purposes, we'll use mock data
      const mockData: AnalyticsData = {
        totalIncidents: 23,
        openIncidents: 7,
        activeShifts: 12,
        totalGuards: 45,
        sitesCount: 8,
        incidentsBySite: [
          {
            site_name: 'North Tower',
            count: 8,
            severity_breakdown: { critical: 1, high: 2, medium: 3, low: 2 }
          },
          {
            site_name: 'East Gate',
            count: 6,
            severity_breakdown: { critical: 0, high: 1, medium: 2, low: 3 }
          },
          {
            site_name: 'South Entrance',
            count: 5,
            severity_breakdown: { critical: 1, high: 0, medium: 2, low: 2 }
          },
          {
            site_name: 'West Wing',
            count: 4,
            severity_breakdown: { critical: 0, high: 1, medium: 1, low: 2 }
          }
        ],
        recentAlerts: [
          {
            id: '1',
            type: 'sos',
            message: 'SOS alert from Guard John Smith',
            time: '10 minutes ago',
          },
          {
            id: '2',
            type: 'incident',
            message: 'High severity incident at North Tower',
            time: '25 minutes ago',
            severity: 'high'
          },
          {
            id: '3',
            type: 'incident',
            message: 'Medium severity incident at East Gate',
            time: '1 hour ago',
            severity: 'medium'
          }
        ]
      };

      setAnalytics(mockData);
    } catch (error) {
      console.error('Failed to load analytics:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'critical': return 'bg-red-500';
      case 'high': return 'bg-orange-500';
      case 'medium': return 'bg-yellow-500';
      case 'low': return 'bg-green-500';
      default: return 'bg-gray-500';
    }
  };

  if (user?.role !== 'supervisor' && user?.role !== 'admin') {
    return (
      <div className="p-4">
        <Card>
          <CardContent className="p-6 text-center">
            <Shield size={48} className="mx-auto text-muted-foreground mb-4" />
            <p className="text-muted-foreground">Access denied. Supervisor access required.</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="p-4">
        <div className="space-y-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardContent className="h-32 bg-muted/50" />
            </Card>
          ))}
        </div>
      </div>
    );
  }

  if (!analytics) {
    return (
      <div className="p-4">
        <Card>
          <CardContent className="p-6 text-center">
            <ChartBar size={48} className="mx-auto text-muted-foreground mb-4" />
            <p className="text-muted-foreground">Failed to load analytics data</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="p-4 pb-20 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold">Analytics Dashboard</h1>
        <p className="text-muted-foreground">
          Security operations overview and insights
        </p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Warning size={20} className="text-destructive" />
              <div>
                <p className="text-sm text-muted-foreground">Total Incidents</p>
                <p className="text-2xl font-bold">{analytics.totalIncidents}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <TrendUp size={20} className="text-orange-500" />
              <div>
                <p className="text-sm text-muted-foreground">Open Cases</p>
                <p className="text-2xl font-bold">{analytics.openIncidents}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Shield size={20} className="text-green-500" />
              <div>
                <p className="text-sm text-muted-foreground">Active Shifts</p>
                <p className="text-2xl font-bold">{analytics.activeShifts}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Users size={20} className="text-blue-500" />
              <div>
                <p className="text-sm text-muted-foreground">Total Guards</p>
                <p className="text-2xl font-bold">{analytics.totalGuards}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Recent Alerts */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Recent Alerts</CardTitle>
          <CardDescription>Latest security alerts and incidents</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {analytics.recentAlerts.map((alert) => (
            <div key={alert.id} className="flex items-center justify-between p-3 bg-muted/50 rounded-lg">
              <div className="flex items-center space-x-3">
                {alert.type === 'sos' ? (
                  <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse" />
                ) : (
                  <div className={`w-2 h-2 rounded-full ${getSeverityColor(alert.severity || 'medium')}`} />
                )}
                <div>
                  <p className="text-sm font-medium">{alert.message}</p>
                  <p className="text-xs text-muted-foreground">{alert.time}</p>
                </div>
              </div>
              <Badge variant={alert.type === 'sos' ? 'destructive' : 'outline'}>
                {alert.type.toUpperCase()}
              </Badge>
            </div>
          ))}
        </CardContent>
      </Card>

      {/* Incidents by Site */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Incidents by Site</CardTitle>
          <CardDescription>Security incident distribution across sites</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {analytics.incidentsBySite.map((site, index) => (
            <div key={index} className="space-y-2">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <MapPin size={16} className="text-muted-foreground" />
                  <span className="font-medium">{site.site_name}</span>
                </div>
                <Badge variant="outline">{site.count} incidents</Badge>
              </div>
              
              {/* Severity breakdown */}
              <div className="flex space-x-1 h-2 bg-muted rounded-full overflow-hidden">
                {site.severity_breakdown.critical > 0 && (
                  <div 
                    className="bg-red-500" 
                    style={{ width: `${(site.severity_breakdown.critical / site.count) * 100}%` }}
                  />
                )}
                {site.severity_breakdown.high > 0 && (
                  <div 
                    className="bg-orange-500" 
                    style={{ width: `${(site.severity_breakdown.high / site.count) * 100}%` }}
                  />
                )}
                {site.severity_breakdown.medium > 0 && (
                  <div 
                    className="bg-yellow-500" 
                    style={{ width: `${(site.severity_breakdown.medium / site.count) * 100}%` }}
                  />
                )}
                {site.severity_breakdown.low > 0 && (
                  <div 
                    className="bg-green-500" 
                    style={{ width: `${(site.severity_breakdown.low / site.count) * 100}%` }}
                  />
                )}
              </div>
              
              <div className="flex justify-between text-xs text-muted-foreground">
                <span>Critical: {site.severity_breakdown.critical}</span>
                <span>High: {site.severity_breakdown.high}</span>
                <span>Medium: {site.severity_breakdown.medium}</span>
                <span>Low: {site.severity_breakdown.low}</span>
              </div>
            </div>
          ))}
        </CardContent>
      </Card>

      {/* Site Coverage */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Site Coverage</CardTitle>
          <CardDescription>Security coverage across all sites</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-4 text-center">
            <div>
              <p className="text-2xl font-bold text-green-500">{analytics.sitesCount}</p>
              <p className="text-sm text-muted-foreground">Total Sites</p>
            </div>
            <div>
              <p className="text-2xl font-bold text-blue-500">{analytics.activeShifts}</p>
              <p className="text-sm text-muted-foreground">Active Coverage</p>
            </div>
          </div>
          
          <div className="mt-4">
            <div className="flex justify-between text-sm mb-2">
              <span>Coverage Rate</span>
              <span>{Math.round((analytics.activeShifts / analytics.sitesCount) * 100)}%</span>
            </div>
            <div className="w-full bg-muted rounded-full h-2">
              <div 
                className="bg-primary h-2 rounded-full transition-all duration-300" 
                style={{ width: `${(analytics.activeShifts / analytics.sitesCount) * 100}%` }}
              />
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}