import React from 'react';
import { House, MapPin, Warning, Users, ChartBar, SignOut } from '@phosphor-icons/react';
import { Button } from '@/components/ui/button';
import { useAuth } from '../hooks/use-auth';
import { cn } from '@/lib/utils';

interface BottomNavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export function BottomNavigation({ activeTab, onTabChange }: BottomNavigationProps) {
  const { user, logout } = useAuth();

  const getNavItems = () => {
    const baseItems = [
      { id: 'home', icon: House, label: 'Home' },
      { id: 'patrol', icon: MapPin, label: 'Patrol' },
      { id: 'incidents', icon: Warning, label: 'Incidents' },
    ];

    if (user?.role === 'supervisor' || user?.role === 'admin') {
      baseItems.push(
        { id: 'users', icon: Users, label: 'Users' },
        { id: 'analytics', icon: ChartBar, label: 'Analytics' }
      );
    }

    return baseItems;
  };

  const navItems = getNavItems();

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-card border-t border-border">
      <div className="grid grid-cols-4 md:grid-cols-6 h-16">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          
          return (
            <Button
              key={item.id}
              variant="ghost"
              size="sm"
              onClick={() => onTabChange(item.id)}
              className={cn(
                "flex flex-col items-center justify-center h-full rounded-none gap-1 text-xs",
                isActive ? "text-primary bg-primary/10" : "text-muted-foreground"
              )}
            >
              <Icon size={20} weight={isActive ? "fill" : "regular"} />
              <span className="text-xs">{item.label}</span>
            </Button>
          );
        })}
        
        <Button
          variant="ghost"
          size="sm"
          onClick={logout}
          className="flex flex-col items-center justify-center h-full rounded-none gap-1 text-xs text-muted-foreground hover:text-destructive"
        >
          <SignOut size={20} />
          <span className="text-xs">Logout</span>
        </Button>
      </div>
    </div>
  );
}