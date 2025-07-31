import React, { useState, useEffect } from 'react';
import { Users, Plus, Shield, MapPin } from '@phosphor-icons/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { useAuth } from '../hooks/use-auth';
import apiService from '../lib/api';
import { toast } from 'sonner';

interface UserData {
  id: string;
  name: string;
  email: string;
  role: string;
  site_id?: string;
  status: 'active' | 'inactive';
}

interface Site {
  id: string;
  name: string;
  location: string;
}

export function UsersScreen() {
  const { user } = useAuth();
  const [users, setUsers] = useState<UserData[]>([]);
  const [sites, setSites] = useState<Site[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedUserId, setSelectedUserId] = useState('');
  const [selectedSiteId, setSelectedSiteId] = useState('');
  const [isAssigning, setIsAssigning] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      // In a real app, these would be separate API calls
      // For demo purposes, we'll use mock data
      setUsers([
        {
          id: '1',
          name: 'John Smith',
          email: 'john@example.com',
          role: 'guard',
          site_id: 'site1',
          status: 'active'
        },
        {
          id: '2',
          name: 'Sarah Connor',
          email: 'sarah@example.com',
          role: 'guard',
          site_id: 'site2',
          status: 'active'
        },
        {
          id: '3',
          name: 'Mike Johnson',
          email: 'mike@example.com',
          role: 'supervisor',
          status: 'active'
        }
      ]);

      setSites([
        { id: 'site1', name: 'North Tower', location: 'Downtown Complex' },
        { id: 'site2', name: 'East Gate', location: 'Industrial Area' },
        { id: 'site3', name: 'South Entrance', location: 'Mall Center' }
      ]);
    } catch (error) {
      console.error('Failed to load users:', error);
      toast.error('Failed to load users');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAssignUser = async () => {
    if (!selectedUserId || !selectedSiteId) {
      toast.error('Please select both user and site');
      return;
    }

    setIsAssigning(true);
    try {
      await apiService.assignUserToSite(selectedSiteId, selectedUserId);
      
      // Update local state
      setUsers(prev => prev.map(u => 
        u.id === selectedUserId 
          ? { ...u, site_id: selectedSiteId }
          : u
      ));
      
      setSelectedUserId('');
      setSelectedSiteId('');
      toast.success('User assigned to site successfully');
    } catch (error) {
      console.error('Failed to assign user:', error);
      toast.error('Failed to assign user to site');
    } finally {
      setIsAssigning(false);
    }
  };

  const getSiteName = (siteId: string) => {
    const site = sites.find(s => s.id === siteId);
    return site ? site.name : 'Unassigned';
  };

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'admin': return 'bg-purple-100 text-purple-800 border-purple-200';
      case 'supervisor': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'guard': return 'bg-green-100 text-green-800 border-green-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
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
          {[...Array(3)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardContent className="h-24 bg-muted/50" />
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
          <h1 className="text-2xl font-bold">User Management</h1>
          <p className="text-muted-foreground">
            Manage user assignments and permissions
          </p>
        </div>
      </div>

      {/* Site Assignment */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg flex items-center gap-2">
            <MapPin size={20} />
            Assign User to Site
          </CardTitle>
          <CardDescription>
            Assign guards and supervisors to specific sites
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Select User</Label>
              <Select value={selectedUserId} onValueChange={setSelectedUserId}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose a user" />
                </SelectTrigger>
                <SelectContent>
                  {users.filter(u => u.role !== 'admin').map(user => (
                    <SelectItem key={user.id} value={user.id}>
                      {user.name} ({user.role})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2">
              <Label>Select Site</Label>
              <Select value={selectedSiteId} onValueChange={setSelectedSiteId}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose a site" />
                </SelectTrigger>
                <SelectContent>
                  {sites.map(site => (
                    <SelectItem key={site.id} value={site.id}>
                      {site.name} - {site.location}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          
          <Button 
            onClick={handleAssignUser}
            disabled={!selectedUserId || !selectedSiteId || isAssigning}
            className="w-full"
          >
            {isAssigning ? 'Assigning...' : 'Assign User to Site'}
          </Button>
        </CardContent>
      </Card>

      {/* Users List */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold">All Users</h2>
        
        {users.length === 0 ? (
          <Card>
            <CardContent className="p-6 text-center">
              <Users size={48} className="mx-auto text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No users found</p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-3">
            {users.map((userData) => (
              <Card key={userData.id}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <h3 className="font-medium">{userData.name}</h3>
                        <Badge variant="outline" className={getRoleColor(userData.role)}>
                          {userData.role.toUpperCase()}
                        </Badge>
                        <Badge variant={userData.status === 'active' ? 'default' : 'secondary'}>
                          {userData.status.toUpperCase()}
                        </Badge>
                      </div>
                      
                      <p className="text-sm text-muted-foreground mb-1">
                        {userData.email}
                      </p>
                      
                      <div className="flex items-center gap-1 text-sm">
                        <MapPin size={14} className="text-muted-foreground" />
                        <span className="text-muted-foreground">
                          Site: {userData.site_id ? getSiteName(userData.site_id) : 'Not assigned'}
                        </span>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* Sites Information */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold">Available Sites</h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {sites.map((site) => {
            const assignedUsers = users.filter(u => u.site_id === site.id);
            
            return (
              <Card key={site.id}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-base">{site.name}</CardTitle>
                  <CardDescription>{site.location}</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">Assigned Users:</span>
                      <Badge variant="outline">{assignedUsers.length}</Badge>
                    </div>
                    
                    {assignedUsers.length > 0 && (
                      <div className="space-y-1">
                        {assignedUsers.map(user => (
                          <div key={user.id} className="text-xs text-muted-foreground">
                            • {user.name} ({user.role})
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>
    </div>
  );
}