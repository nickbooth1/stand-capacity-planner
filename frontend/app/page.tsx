'use client';

import { useEffect, useState } from 'react';

interface HealthStatus {
  status: string;
  timestamp: string;
  database: string;
}

export default function Home() {
  const [health, setHealth] = useState<HealthStatus | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3002';
        const response = await fetch(`${apiUrl}/api/health`);
        const data = await response.json();
        setHealth(data);
        setError(null);
      } catch (err) {
        setError('Failed to connect to backend API');
        setHealth(null);
      }
    };

    checkHealth();
  }, []);

  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
      <h1>Stand Capacity Planner</h1>
      <p>Welcome to the Stand Capacity Planner application.</p>

      <section style={{ marginTop: '2rem', padding: '1rem', border: '1px solid #ccc', borderRadius: '8px' }}>
        <h2>System Status</h2>
        {error ? (
          <p style={{ color: 'red' }}>{error}</p>
        ) : health ? (
          <div>
            <p><strong>API Status:</strong> {health.status}</p>
            <p><strong>Database:</strong> {health.database}</p>
            <p><strong>Timestamp:</strong> {health.timestamp}</p>
          </div>
        ) : (
          <p>Checking system health...</p>
        )}
      </section>
    </main>
  );
}
