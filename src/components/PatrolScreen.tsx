import React, { useState, useEffect } from 'react';
import { QrCode, MapPin, CheckCircle, Clock, Plus } from '@phosphor-icons/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useAuth } from '../hooks/use-auth';
import apiService from '../lib/api';
import { Checkpoint, Shift } from '../lib/types';
import { toast } from 'sonner';

export function PatrolScreen() {
  const { user } = useAuth();
  const [checkpoints, setCheckpoints] = useState<Checkpoint[]>([]);
  const [currentShift, setCurrentShift] = useState<Shift | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [manualCheckpointId, setManualCheckpointId] = useState('');
  const [checkpointNotes, setCheckpointNotes] = useState('');
  const [isLoggingCheckpoint, setIsLoggingCheckpoint] = useState(false);
  const [isStartingShift, setIsStartingShift] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [shift, checkpointsData] = await Promise.all([
        apiService.getCurrentShift(),
        apiService.getCheckpoints(user?.site_id)
      ]);
      
      setCurrentShift(shift);
      setCheckpoints(checkpointsData);
    } catch (error) {
      console.error('Failed to load patrol data:', error);
      toast.error('Failed to load patrol data');
    } finally {
      setIsLoading(false);
    }
  };

  const handleStartShift = async () => {
    if (!user?.site_id) {
      toast.error('No site assigned to user');
      return;
    }

    setIsStartingShift(true);
    try {
      const shift = await apiService.startShift(user.site_id);
      setCurrentShift(shift);
      toast.success('Shift started successfully');
    } catch (error) {
      console.error('Failed to start shift:', error);
      toast.error('Failed to start shift');
    } finally {
      setIsStartingShift(false);
    }
  };

  const handleLogCheckpoint = async (checkpointId: string) => {
    if (!currentShift) {
      toast.error('No active shift. Please start a shift first.');
      return;
    }

    setIsLoggingCheckpoint(true);
    try {
      await apiService.logCheckpoint(checkpointId, checkpointNotes);
      setCheckpointNotes('');
      setManualCheckpointId('');
      toast.success('Checkpoint logged successfully');
    } catch (error) {
      console.error('Failed to log checkpoint:', error);
      toast.error('Failed to log checkpoint');
    } finally {
      setIsLoggingCheckpoint(false);
    }
  };

  const handleQRScan = () => {
    // In a real app, this would open camera for QR scanning
    toast.info('QR scanner would open here in a real implementation');
  };

  if (isLoading) {
    return (
      <div className="p-4">
        <div className="space-y-4">
          {[...Array(3)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardContent className="h-20 bg-muted/50" />
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 pb-20 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold">Patrol</h1>
        <p className="text-muted-foreground">
          {currentShift ? 'Manage your patrol route' : 'Start your shift to begin patrol'}
        </p>
      </div>

      {/* Shift Status */}
      {!currentShift ? (
        <Alert>
          <Clock size={16} />
          <AlertDescription className="flex items-center justify-between">
            <span>No active shift</span>
            <Button onClick={handleStartShift} disabled={isStartingShift} size="sm">
              {isStartingShift ? 'Starting...' : 'Start Shift'}
            </Button>
          </AlertDescription>
        </Alert>
      ) : (
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">Active Shift</CardTitle>
            <CardDescription>
              Started: {new Date(currentShift.start_time).toLocaleString()}
            </CardDescription>
          </CardHeader>
        </Card>
      )}

      {/* QR Scanner */}
      {currentShift && (
        <Card>
          <CardContent className="p-6">
            <Button 
              onClick={handleQRScan}
              className="w-full h-16 text-lg font-medium"
            >
              <QrCode size={24} className="mr-2" />
              Scan Checkpoint QR Code
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Manual Checkpoint Entry */}
      {currentShift && (
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Manual Checkpoint Entry</CardTitle>
            <CardDescription>
              Enter checkpoint ID manually if QR scanning is not available
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="checkpoint-id">Checkpoint ID</Label>
              <Input
                id="checkpoint-id"
                value={manualCheckpointId}
                onChange={(e) => setManualCheckpointId(e.target.value)}
                placeholder="Enter checkpoint ID"
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="notes">Notes (Optional)</Label>
              <Textarea
                id="notes"
                value={checkpointNotes}
                onChange={(e) => setCheckpointNotes(e.target.value)}
                placeholder="Add any notes about this checkpoint visit"
                rows={3}
              />
            </div>
            
            <Button
              onClick={() => handleLogCheckpoint(manualCheckpointId)}
              disabled={!manualCheckpointId || isLoggingCheckpoint}
              className="w-full"
            >
              {isLoggingCheckpoint ? 'Logging...' : 'Log Checkpoint'}
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Checkpoint List */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold">Assigned Checkpoints</h2>
        
        {checkpoints.length === 0 ? (
          <Card>
            <CardContent className="p-6 text-center">
              <MapPin size={48} className="mx-auto text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No checkpoints assigned</p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-3">
            {checkpoints.map((checkpoint) => (
              <Card key={checkpoint.id}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <h3 className="font-medium">{checkpoint.name}</h3>
                      <p className="text-sm text-muted-foreground">
                        ID: {checkpoint.id}
                      </p>
                      {checkpoint.qr_code && (
                        <Badge variant="outline" className="mt-1">
                          QR Available
                        </Badge>
                      )}
                    </div>
                    
                    {currentShift && (
                      <Dialog>
                        <DialogTrigger asChild>
                          <Button size="sm">
                            <Plus size={16} className="mr-1" />
                            Log Visit
                          </Button>
                        </DialogTrigger>
                        <DialogContent>
                          <DialogHeader>
                            <DialogTitle>Log Checkpoint Visit</DialogTitle>
                            <DialogDescription>
                              {checkpoint.name}
                            </DialogDescription>
                          </DialogHeader>
                          <div className="space-y-4">
                            <div className="space-y-2">
                              <Label htmlFor="dialog-notes">Notes</Label>
                              <Textarea
                                id="dialog-notes"
                                value={checkpointNotes}
                                onChange={(e) => setCheckpointNotes(e.target.value)}
                                placeholder="Add any notes about this checkpoint visit"
                                rows={3}
                              />
                            </div>
                            <Button
                              onClick={() => handleLogCheckpoint(checkpoint.id)}
                              disabled={isLoggingCheckpoint}
                              className="w-full"
                            >
                              {isLoggingCheckpoint ? 'Logging...' : 'Log Checkpoint'}
                            </Button>
                          </div>
                        </DialogContent>
                      </Dialog>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}