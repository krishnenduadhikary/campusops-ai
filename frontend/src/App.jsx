import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './pages/auth/Login';

function RoleRoute({ children, roles }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" />;
  if (roles && !roles.includes(user.role)) return <Navigate to="/login" />;
  return children;
}

function AppRoutes() {
  const { user } = useAuth();

  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/admin" element={
        <RoleRoute roles={['ADMIN']}>
          <div className="p-8 text-2xl font-bold text-blue-600">
            🏫 Admin Dashboard — Coming Day 11
          </div>
        </RoleRoute>
      } />
      <Route path="/technician" element={
        <RoleRoute roles={['TECHNICIAN', 'ADMIN']}>
          <div className="p-8 text-2xl font-bold text-green-600">
            🔧 Technician Dashboard — Coming Day 10
          </div>
        </RoleRoute>
      } />
      <Route path="/supervisor" element={
        <RoleRoute roles={['SUPERVISOR', 'ADMIN']}>
          <div className="p-8 text-2xl font-bold text-purple-600">
            👔 Supervisor Dashboard — Coming Day 11
          </div>
        </RoleRoute>
      } />
      <Route path="/student" element={
        <RoleRoute roles={['STUDENT', 'ADMIN']}>
          <div className="p-8 text-2xl font-bold text-orange-600">
            🎓 Student Dashboard — Coming Day 9
          </div>
        </RoleRoute>
      } />
      <Route path="/" element={
        user ? <Navigate to={
          user.role === 'ADMIN' ? '/admin' :
          user.role === 'TECHNICIAN' ? '/technician' :
          user.role === 'SUPERVISOR' ? '/supervisor' : '/student'
        } /> : <Navigate to="/login" />
      } />
    </Routes>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  );
}