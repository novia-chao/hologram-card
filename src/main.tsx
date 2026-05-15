import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';
import { HologramCard } from './hologram-card';

import logo from './assets/imgs/logo.svg';
import image from './assets/imgs/clipboard.png';
import depth from './assets/imgs/clipboard-depth.png';
import shade from './assets/imgs/clipboard-depth-shade.png';

import ipadImage from './assets/imgs/ipad.png';
import ipadDepth from './assets/imgs/ipad-depth.png';
import ipadShade from './assets/imgs/ipad-depth-shade.png';

type Tab = 'ipad' | 'clipboard';

function App() {
  const [active, setActive] = useState<Tab>('ipad');
  const [color, setColor] = useState('#2B3AC1');
  const [text, setText] = useState('The future of work lives in Squint');
  const [radius, setRadius] = useState(32);
  const [cardWidth, setCardWidth] = useState(740);
  const [cardHeight, setCardHeight] = useState(533);

  return (
    <div className="layout">
      <main className="app">
        <div className="tabs">
          <button className={`tab ${active === 'ipad' ? 'tab--active' : ''}`} onClick={() => setActive('ipad')}>iPad</button>
          <button className={`tab ${active === 'clipboard' ? 'tab--active' : ''}`} onClick={() => setActive('clipboard')}>Clipboard</button>
        </div>
        <div className="card-wrapper">
          {active === 'clipboard' ? (
            <HologramCard images={{ image, depth, shade }} aspectRatio={cardWidth / cardHeight} width={cardWidth} color={color} borderRadius={radius}>
              <img src={logo} className="hologram-logo" alt="Squint" />
              {text || undefined}
            </HologramCard>
          ) : (
            <HologramCard images={{ image: ipadImage, depth: ipadDepth, shade: ipadShade }} aspectRatio={cardWidth / cardHeight} width={cardWidth} color={color} imagePosition="center bottom" imageFit="cover" borderRadius={radius}>
            <img src={logo} className="hologram-logo" alt="Squint" />
          </HologramCard>
          )}
        </div>
      </main>

      <aside className="panel">
        <h2 className="panel-title">Card Settings</h2>

        <div className="panel-group">
          <label className="panel-label">Background color</label>
          <div className="color-row">
            <input type="color" className="color-swatch" value={color} onChange={e => setColor(e.target.value)} />
            <input type="text" className="panel-input" value={color} onChange={e => setColor(e.target.value)} maxLength={7} />
          </div>
        </div>

        <div className="panel-group">
          <label className="panel-label">Tagline text</label>
          <input type="text" className="panel-input" value={text} onChange={e => setText(e.target.value)} placeholder="Leave empty to hide" />
        </div>

        <div className="panel-group">
          <label className="panel-label">Corner radius <span className="panel-value">{radius}px</span></label>
          <input type="range" className="panel-range" min={0} max={120} value={radius} onChange={e => setRadius(Number(e.target.value))} />
        </div>

        <div className="panel-group">
          <label className="panel-label">Width <span className="panel-value">{cardWidth}px</span></label>
          <input type="range" className="panel-range" min={300} max={900} value={cardWidth} onChange={e => setCardWidth(Number(e.target.value))} />
        </div>

        <div className="panel-group">
          <label className="panel-label">Height <span className="panel-value">{cardHeight}px</span></label>
          <input type="range" className="panel-range" min={300} max={900} value={cardHeight} onChange={e => setCardHeight(Number(e.target.value))} />
        </div>
      </aside>
    </div>
  );
}

const root = document.getElementById('root');
if (!root) throw new Error('Root element not found');

createRoot(root).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
