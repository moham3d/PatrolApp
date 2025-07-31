import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

export function ApiDebugger() {
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  const testApiConnection = async () => {
    setLoading(true);
    try {
      const res = await fetch('https://api.millio.space/openapi.json');
      if (res.ok) {
        const data = await res.json();
        // Look for login endpoint definition
        const paths = data.paths;
        const loginPath = paths['/auth/login'];
        if (loginPath && loginPath.post) {
          const requestBody = loginPath.post.requestBody;
          setResponse(`Login endpoint found!\nExpected format: ${JSON.stringify(requestBody, null, 2)}`);
        } else {
          setResponse('Login endpoint not found in API spec');
        }
      } else {
        setResponse(`Error: ${res.status} ${res.statusText}`);
      }
    } catch (error) {
      setResponse(`Network error: ${error}`);
    }
    setLoading(false);
  };

  const testLogin = async () => {
    setLoading(true);
    try {
      const testPayloads = [
        { username: 'test', password: 'test' },
        { email: 'test@test.com', password: 'test' },
        { login: 'test', password: 'test' }
      ];

      let results = 'Testing different login payloads:\n\n';
      
      for (const payload of testPayloads) {
        try {
          const res = await fetch('https://api.millio.space/auth/login', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload),
          });
          
          const data = await res.text();
          results += `Payload: ${JSON.stringify(payload)}\nStatus: ${res.status}\nResponse: ${data}\n\n`;
        } catch (err) {
          results += `Payload: ${JSON.stringify(payload)}\nError: ${err}\n\n`;
        }
      }
      
      setResponse(results);
    } catch (error) {
      setResponse(`Network error: ${error}`);
    }
    setLoading(false);
  };

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle>API Debugger</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex gap-2">
          <Button onClick={testApiConnection} disabled={loading}>
            Check API Spec
          </Button>
          <Button onClick={testLogin} disabled={loading}>
            Test Login
          </Button>
        </div>
        
        <div className="bg-muted p-4 rounded-md">
          <pre className="text-sm whitespace-pre-wrap font-mono max-h-96 overflow-auto">
            {response || 'No response yet...'}
          </pre>
        </div>
      </CardContent>
    </Card>
  );
}