import React, { useState, useEffect } from 'react';
import { Warning, Plus, Clock, Eye, Filter } from '@phosphor-icons/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useAuth } from '../hooks/use-auth';
import apiService from '../lib/api';
import { Incident } from '../lib/types';
import { toast } from 'sonner';

export function IncidentsScreen() {
  const { user } = useAuth();
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [severityFilter, setSeverityFilter] = useState<string>('all');
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  
  // Create incident form state
  const [newIncident, setNewIncident] = useState({
    title: '',
    description: '',
    severity: 'medium' as const,
    site_id: user?.site_id || '',
    user_id: user?.id || '',
    status: 'open' as const
  });

  useEffect(() => {
    loadIncidents();
  }, [statusFilter, severityFilter]);

  const loadIncidents = async () => {
    try {
      const filters: any = {};
      if (statusFilter !== 'all') filters.status = statusFilter;
      if (user?.site_id) filters.site_id = user.site_id;
      
      const data = await apiService.getIncidents(filters);
      let filteredData = data;
      
      if (severityFilter !== 'all') {
        filteredData = data.filter(incident => incident.severity === severityFilter);
      }
      
      setIncidents(filteredData);
    } catch (error) {
      console.error('Failed to load incidents:', error);
      toast.error('Failed to load incidents');
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreateIncident = async () => {
    try {
      await apiService.createIncident(newIncident);
      setNewIncident({
        title: '',
        description: '',
        severity: 'medium',
        site_id: user?.site_id || '',
        user_id: user?.id || '',
        status: 'open'
      });
      setIsCreateDialogOpen(false);
      loadIncidents();
      toast.success('Incident reported successfully');
    } catch (error) {
      console.error('Failed to create incident:', error);
      toast.error('Failed to report incident');
    }
  };

  const handleUpdateIncidentStatus = async (incidentId: string, newStatus: string) => {
    try {
      await apiService.updateIncident(incidentId, { status: newStatus as any });
      loadIncidents();
      toast.success('Incident status updated');
    } catch (error) {
      console.error('Failed to update incident:', error);
      toast.error('Failed to update incident status');
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'critical': return 'bg-red-500 text-white';
      case 'high': return 'bg-orange-500 text-white';
      case 'medium': return 'bg-yellow-500 text-black';
      case 'low': return 'bg-green-500 text-white';
      default: return 'bg-gray-500 text-white';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open': return 'bg-red-100 text-red-800 border-red-200';
      case 'investigating': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'resolved': return 'bg-green-100 text-green-800 border-green-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const canUpdateStatus = user?.role === 'supervisor' || user?.role === 'admin';

  if (isLoading) {
    return (
      <div className="p-4">
        <div className="space-y-4">
          {[...Array(3)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardContent className="h-32 bg-muted/50" />
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 pb-20 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Incidents</h1>
          <p className="text-muted-foreground">
            Report and manage security incidents
          </p>
        </div>
        
        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus size={16} className="mr-2" />
              Report
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle>Report New Incident</DialogTitle>
              <DialogDescription>
                Provide details about the security incident
              </DialogDescription>
            </DialogHeader>
            
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="title">Incident Title</Label>
                <Input
                  id="title"
                  value={newIncident.title}
                  onChange={(e) => setNewIncident(prev => ({ ...prev, title: e.target.value }))}
                  placeholder="Brief description of the incident"
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="severity">Severity</Label>
                <Select 
                  value={newIncident.severity} 
                  onValueChange={(value) => setNewIncident(prev => ({ ...prev, severity: value as any }))}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="low">Low</SelectItem>
                    <SelectItem value="medium">Medium</SelectItem>
                    <SelectItem value="high">High</SelectItem>
                    <SelectItem value="critical">Critical</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={newIncident.description}
                  onChange={(e) => setNewIncident(prev => ({ ...prev, description: e.target.value }))}
                  placeholder="Detailed description of what happened"
                  rows={4}
                />
              </div>
              
              <Button 
                onClick={handleCreateIncident}
                className="w-full"
                disabled={!newIncident.title || !newIncident.description}
              >
                Report Incident
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <Filter size={20} />
            Filters
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Status</Label>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="open">Open</SelectItem>
                  <SelectItem value="investigating">Investigating</SelectItem>
                  <SelectItem value="resolved">Resolved</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label>Severity</Label>
              <Select value={severityFilter} onValueChange={setSeverityFilter}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Severity</SelectItem>
                  <SelectItem value="critical">Critical</SelectItem>
                  <SelectItem value="high">High</SelectItem>
                  <SelectItem value="medium">Medium</SelectItem>
                  <SelectItem value="low">Low</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Incidents List */}
      <div className="space-y-4">
        {incidents.length === 0 ? (
          <Card>
            <CardContent className="p-6 text-center">
              <Warning size={48} className="mx-auto text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No incidents found</p>
            </CardContent>
          </Card>
        ) : (
          incidents.map((incident) => (
            <Card key={incident.id}>
              <CardContent className="p-4">
                <div className="space-y-3">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="font-medium text-lg">{incident.title}</h3>
                      <p className="text-sm text-muted-foreground mt-1">
                        {incident.description}
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2 flex-wrap">
                    <Badge className={getSeverityColor(incident.severity)}>
                      {incident.severity.toUpperCase()}
                    </Badge>
                    <Badge variant="outline" className={getStatusColor(incident.status)}>
                      {incident.status.toUpperCase()}
                    </Badge>
                  </div>
                  
                  <div className="flex items-center justify-between text-sm text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <Clock size={14} />
                      {new Date(incident.created_at).toLocaleString()}
                    </span>
                    
                    {canUpdateStatus && incident.status !== 'resolved' && (
                      <Select 
                        value={incident.status} 
                        onValueChange={(value) => handleUpdateIncidentStatus(incident.id, value)}
                      >
                        <SelectTrigger className="w-auto h-8">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="open">Open</SelectItem>
                          <SelectItem value="investigating">Investigating</SelectItem>
                          <SelectItem value="resolved">Resolved</SelectItem>
                        </SelectContent>
                      </Select>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}