import React from 'react';
import ReactDOM from 'react-dom/client';
import { ExperimentCenterUI } from './apps/ExperimentCenterUI';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
        <div className="h-screen w-screen bg-black overflow-hidden">
            <ExperimentCenterUI />
        </div>
    </React.StrictMode>
);
