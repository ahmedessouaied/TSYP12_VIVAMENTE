// src/main.jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import Patient from './pages/Patient';
import Patients from './pages/Patients';
import './index.css'; // Import Tailwind and global CSS styles
import Home from './pages/Home'; 
// Define routes for the router
const router = createBrowserRouter([
  { path: '/', element: <Home /> } , 
  {path:'/Patients',element:<Patients/>}, 
  {path:'/Patient/:id',element:<Patient/>}
]);

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
