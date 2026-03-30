import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { PieceCard } from '../components/feed/PieceCard';
import { SafeArea } from '../components/layout/SafeArea';

const headerStyle = {
  position: 'sticky',
  top: 0,
  zIndex: 10,
  background: 'rgba(255,255,255,0.72)',
  backdropFilter: 'blur(16px)',
  padding: '12px 16px',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  borderBottom: '1px solid var(--slate-100)',
  marginLeft: -16,
  marginRight: -16,
  paddingLeft: 16,
  paddingRight: 16,
};

const tabStyle = (active) => ({
  padding: '8px 20px',
  borderRadius: 9999,
  fontSize: 14,
  fontWeight: 500,
  background: active ? 'var(--slate-900)' : 'transparent',
  color: active ? 'var(--white)' : 'var(--slate-600)',
  boxShadow: active ? '0 2px 8px rgba(15,23,42,0.1)' : 'none',
});

const feedItems = [
  { id: 1, title: 'Coastal Forms #3', storyPreview: 'A meditation on erosion and time...', artistName: 'Jordan Lee', medium: 'Oil', forSale: true, price: '2,400' },
  { id: 2, title: 'Studio Notes — January', storyPreview: 'Exploring new pigments...', artistName: 'Alex Chen', medium: 'Mixed Media', isProcess: true },
  { id: 3, title: 'Untitled (Series 12)', storyPreview: 'Minimalist study in light.', artistName: 'Sam Rivera', medium: 'Photography', forSale: false },
];

export function HomeFeedPage() {
  const [tab, setTab] = useState('foryou');

  return (
    <SafeArea style={{ paddingTop: 0 }}>
      <header style={headerStyle}>
        <h1 style={{ fontSize: 20, fontWeight: 700, color: 'var(--slate-900)' }}>Studio 3</h1>
        <div style={{ display: 'flex', gap: 16 }}>
          <Link to="/notifications" aria-label="Notifications" style={{ color: 'var(--slate-700)' }}>🔔</Link>
          <Link to="/chat" aria-label="Chat" style={{ color: 'var(--slate-700)' }}>💬</Link>
        </div>
      </header>

      <div style={{ display: 'flex', gap: 8, marginBottom: 16, marginTop: 12 }}>
        <button style={tabStyle(tab === 'foryou')} onClick={() => setTab('foryou')}>For You</button>
        <button style={tabStyle(tab === 'following')} onClick={() => setTab('following')}>Following</button>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {feedItems.map((item) => (
          <PieceCard key={item.id} {...item} />
        ))}
      </div>
    </SafeArea>
  );
}
