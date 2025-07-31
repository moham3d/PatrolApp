import React, { useState, useEffect } from 'react';
import { 
  SirenSimple, 
  ClockClockwise, 
  MapPin, 
  Warning, 
  Users,
  ChartBar,
  Bell
} from '@phosphor-icons/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useAuth } from '../hooks/use-auth';
import apiService from '../lib/api';
import { Shift, SOSAlert } from '../lib/types';
import { toast } from 'sonner';

export function Dashboard() {
  const { user } = useAuth();
  const [currentShift, setCurrentShift] = useState<Shift | null>(null);
  const [isLoadingShift, setIsLoadingShift] = useState(true);
  const [sosAlerts, setSOSAlerts] = useState<SOSAlert[]>([]);
  const [isSOSLoading, setIsSOSLoading] = useState(false);

  useEffect(() => {
    loadCurrentShift();
    if (user?.role === 'supervisor' || user?.role === 'admin') {
      loadSOSAlerts();
    }
  }, [user]);

  const loadCurrentShift = async () => {
    try {
      const shift = await apiService.getCurrentShift();
      setCurrentShift(shift);
    } catch (error) {
      console.error('Failed to load current shift:', error);
    } finally {
      setIsLoadingShift(false);
    }
  };

  const loadSOSAlerts = async () => {
    try {
      const alerts = await apiService.getActiveSOSAlerts();
      setSOSAlerts(alerts);
    } catch (error) {
      console.error('Failed to load SOS alerts:', error);
    }
  };

  const handleSOS = async () => {
    setIsSOSLoading(true);
    
    try {
      // Get current location
      const position = await new Promise<GeolocationPosition>((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(resolve, reject, {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 60000
        });
      });

      const location = {
        lat: position.coords.latitude,
        lng: position.coords.longitude,
        timestamp: new Date().toISOString(),
        accuracy: position.coords.accuracy
      };

      await apiService.triggerSOS(location);
      toast.success('SOS alert sent successfully!');
      
      // Reload alerts if supervisor/admin
      if (user?.role === 'supervisor' || user?.role === 'admin') {
        loadSOSAlerts();
      }
    } catch (error) {
      console.error('SOS failed:', error);
      toast.error('Failed to send SOS alert. Please try again.');
    } finally {
      setIsSOSLoading(false);
    }
  };

  const handleEndShift = async () => {
    if (!currentShift) return;
    
    try {
      await apiService.endShift(currentShift.id);
      setCurrentShift(null);
      toast.success('Shift ended successfully');
    } catch (error) {
      console.error('Failed to end shift:', error);
      toast.error('Failed to end shift');
    }
  };

  const getShiftStatus = () => {
    if (isLoadingShift) return 'Loading...';
    if (!currentShift) return 'No active shift';
    return `Active since ${new Date(currentShift.start_time).toLocaleTimeString()}`;
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-card border-b border-border px-4 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl font-bold text-foreground">
              Welcome, {user?.name}
            </h1>
            <p className="text-sm text-muted-foreground capitalize">
              {user?.role} Dashboard
            </p>
          </div>
          <Badge variant="outline" className="capitalize">
            {user?.role}
          </Badge>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* SOS Alert Section */}
        <Card className="border-destructive/20 bg-destructive/5">
          <CardHeader className="pb-3">
            <CardTitle className="text-destructive text-lg flex items-center gap-2">
              <SirenSimple size={20} weight="fill" />
              Emergency
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Button
              onClick={handleSOS}
              disabled={isSOSLoading}
              className="w-full h-14 bg-destructive hover:bg-destructive/90 text-destructive-foreground font-bold text-lg"
            >
              {isSOSLoading ? 'Sending SOS...' : 'SOS - EMERGENCY'}
            </Button>
          </CardContent>
        </Card>

        {/* Shift Status */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center gap-2">
              <ClockClockwise size={20} />
              Shift Status
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">Current Shift:</span>
              <Badge variant={currentShift ? "default" : "secondary"}>
                {currentShift ? "Active" : "Inactive"}
              </Badge>
            </div>
            <p className="text-sm">{getShiftStatus()}</p>
            {currentShift && (
              <Button
                onClick={handleEndShift}
                variant="outline"
                className="w-full"
              >
                End Shift
              </Button>
            )}
          </CardContent>
        </Card>

        {/* Role-specific SOS Alerts for Supervisors/Admins */}
        {(user?.role === 'supervisor' || user?.role === 'admin') && sosAlerts.length > 0 && (
          <Alert variant="destructive">
            <Warning size={16} />
            <AlertDescription>
              {sosAlerts.length} active SOS alert{sosAlerts.length > 1 ? 's' : ''} requiring attention
            </AlertDescription>
          </Alert>
        )}

        {/* Quick Actions Grid */}
        <div className="grid grid-cols-2 gap-4">
          <Card className="cursor-pointer hover:bg-accent/50 transition-colors">
            <CardContent className="flex flex-col items-center justify-center p-6 text-center">
              <MapPin size={32} className="text-primary mb-2" />
              <span className="font-medium">Patrol</span>
            </CardContent>
          </Card>

          <Card className="cursor-pointer hover:bg-accent/50 transition-colors">
            <CardContent className="flex flex-col items-center justify-center p-6 text-center">
              <Warning size={32} className="text-primary mb-2" />
              <span className="font-medium">Incidents</span>
            </CardContent>
          </Card>

          {(user?.role === 'supervisor' || user?.role === 'admin') && (
            <>
              <Card className="cursor-pointer hover:bg-accent/50 transition-colors">
                <CardContent className="flex flex-col items-center justify-center p-6 text-center">
                  <Users size={32} className="text-primary mb-2" />
                  <span className="font-medium">Manage Users</span>
                </CardContent>
              </Card>

              <Card className="cursor-pointer hover:bg-accent/50 transition-colors">
                <CardContent className="flex flex-col items-center justify-center p-6 text-center">
                  <ChartBar size={32} className="text-primary mb-2" />
                  <span className="font-medium">Analytics</span>
                </CardContent>
              </Card>
            </>
          )}

          <Card className="cursor-pointer hover:bg-accent/50 transition-colors">
            <CardContent className="flex flex-col items-center justify-center p-6 text-center">
              <Bell size={32} className="text-primary mb-2" />
              <span className="font-medium">Messages</span>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}