import React, { useState } from 'react';
import { SafeArea } from '../components/layout/SafeArea';

const coverStyle = {
  height: 120,
  background: 'linear-gradient(180deg, var(--slate-100) 0%, var(--slate-50) 100%)',
  marginLeft: -16,
  marginRight: -16,
  marginTop: -44,
};

const avatarStyle = {
  width: 80,
  height: 80,
  borderRadius: '50%',
  border: '3px solid var(--white)',
  boxShadow: '0 2px 16px rgba(15,23,42,0.08)',
  background: 'var(--slate-300)',
  marginTop: -40,
  marginBottom: 12,
};

const tabUnderline = (active) => ({
  paddingBottom: 8,
  marginRight: 24,
  fontSize: 15,
  fontWeight: 500,
  color: active ? 'var(--slate-900)' : 'var(--slate-500)',
  borderBottom: active ? '2px solid var(--slate-900)' : '2px solid transparent',
});

const gridCell = (sold) => ({
  aspectRatio: '1',
  borderRadius: 8,
  background: 'var(--slate-100)',
  position: 'relative',
  overflow: 'hidden',
  ...(sold ? { opacity: 0.7 } : {}),
});

export function ProfilePage() {
  const [tab, setTab] = useState('pieces');
  const [insightsOpen, setInsightsOpen] = useState(false);

  const stats = [
    { label: 'Saves', value: '—' },
    { label: 'Likes', value: '—' },
    { label: 'Inquiries', value: '—' },
    { label: 'Sales', value: '—' },
  ];

  return (
    <SafeArea style={{ paddingTop: 0 }}>
      <div style={coverStyle} />
      <div style={{ paddingLeft: 0, paddingRight: 0 }}>
        <div style={{ ...avatarStyle, marginLeft: 16 }} />
        <h1 style={{ fontSize: 20, fontWeight: 700, color: 'var(--slate-900)', marginBottom: 4 }}>Jordan Lee</h1>
        <p style={{ fontSize: 13, color: 'var(--slate-400)', marginBottom: 8 }}>Los Angeles, CA</p>
        <p style={{ fontSize: 14, color: 'var(--slate-600)', marginBottom: 12, lineHeight: 1.4 }}>
          Painter. Coastal forms and quiet color. Two lines of bio here and then{' '}
          <button style={{ color: 'var(--slate-500)', fontSize: 13 }}>more</button>
        </p>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 24 }}>
          <button
            style={{
              height: 44,
              padding: '0 20px',
              borderRadius: 9999,
              border: '1.5px solid var(--slate-300)',
              background: 'var(--white)',
              fontSize: 14,
              fontWeight: 500,
            }}
          >
            Edit Profile
          </button>
          <button style={{ padding: 10, color: 'var(--slate-700)' }} aria-label="Share">↗</button>
        </div>
      </div>

      <div style={{ display: 'flex', borderBottom: '1px solid var(--slate-200)', marginBottom: 16 }}>
        <button style={tabUnderline(tab === 'pieces')} onClick={() => setTab('pieces')}>Pieces</button>
        <button style={tabUnderline(tab === 'process')} onClick={() => setTab('process')}>Process</button>
      </div>

      {tab === 'pieces' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 2 }}>
          {[1, 2, 3, 4, 5, 6].map((i) => {
            const sold = i === 2;
            return (
              <div key={i} style={gridCell(sold)}>
                {sold && (
                  <div
                    style={{
                      position: 'absolute',
                      inset: 0,
                      background: 'rgba(15,23,42,0.5)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: 12,
                      fontWeight: 600,
                      color: 'var(--white)',
                    }}
                  >
                    Sold
                  </div>
                )}
                {i === 1 && (
                  <div
                    style={{
                      position: 'absolute',
                      bottom: 6,
                      left: 6,
                      padding: '4px 8px',
                      borderRadius: 8,
                      background: 'rgba(15,23,42,0.55)',
                      backdropFilter: 'blur(12px)',
                      fontSize: 10,
                      fontWeight: 600,
                      color: 'var(--white)',
                    }}
                  >
                    $2,400
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {tab === 'process' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {[1, 2].map((i) => (
            <div key={i} style={{ borderRadius: 16, overflow: 'hidden', aspectRatio: '4/3', background: 'var(--slate-100)' }} />
          ))}
        </div>
      )}

      <div style={{ marginTop: 32 }}>
        <button
          style={{
            width: '100%',
            padding: 16,
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            background: 'rgba(255,255,255,0.72)',
            backdropFilter: 'blur(16px)',
            border: '1px solid rgba(255,255,255,0.45)',
            borderRadius: 20,
            marginBottom: 12,
          }}
          onClick={() => setInsightsOpen((o) => !o)}
        >
          <span style={{ fontSize: 16, fontWeight: 600 }}>Your Insights</span>
          <span>{insightsOpen ? '−' : '+'}</span>
        </button>
        {insightsOpen && (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
            {stats.map(({ label, value }) => (
              <div
                key={label}
                style={{
                  padding: 16,
                  background: 'rgba(255,255,255,0.72)',
                  backdropFilter: 'blur(16px)',
                  border: '1px solid rgba(255,255,255,0.45)',
                  borderRadius: 20,
                }}
              >
                <div style={{ fontSize: 20, fontWeight: 700, color: 'var(--slate-900)' }}>{value}</div>
                <div style={{ fontSize: 12, color: 'var(--slate-500)' }}>{label}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </SafeArea>
  );
}
