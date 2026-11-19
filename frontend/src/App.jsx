import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './pages/auth/Login';
import StudentDashboard from './pages/student/StudentDashboard';
import SubmitTicket from './pages/student/SubmitTicket';
import TicketDetail from './pages/student/TicketDetail';

function RoleRoute({ children, roles }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" />;
  if (roles && !roles.includes(user.role)) return <Navigate to="/login" />;
  return children;
}

const homeFor = (role) =>
  role === 'ADMIN' ? '/admin'
  : role === 'TECHNICIAN' ? '/technician'
  : role === 'SUPERVISOR' ? '/supervisor'
  : '/student';

function AppRoutes() {
  const { user } = useAuth();
  const studentRoles = ['STUDENT', 'ADMIN'];

  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      {/* Student */}
      <Route path="/student" element={
        <RoleRoute roles={studentRoles}><StudentDashboard /></RoleRoute>
      } />
      <Route path="/student/new" element={
        <RoleRoute roles={studentRoles}><SubmitTicket /></RoleRoute>
      } />
      <Route path="/student/tickets/:id" element={
        <RoleRoute roles={studentRoles}><TicketDetail /></RoleRoute>
      } />

      {/* Placeholders for later days */}
      <Route path="/admin" element={
        <RoleRoute roles={['ADMIN']}>
          <div className="p-8 text-2xl font-bold text-blue-600">🏫 Admin Dashboard — Coming Day 11</div>
        </RoleRoute>
      } />
      <Route path="/technician" element={
        <RoleRoute roles={['TECHNICIAN', 'ADMIN']}>
          <div className="p-8 text-2xl font-bold text-green-600">🔧 Technician Dashboard — Coming Day 10</div>
        </RoleRoute>
      } />
      <Route path="/supervisor" element={
        <RoleRoute roles={['SUPERVISOR', 'ADMIN']}>
          <div className="p-8 text-2xl font-bold text-purple-600">👔 Supervisor Dashboard — Coming Day 11</div>
        </RoleRoute>
      } />

      <Route path="/" element={
        user ? <Navigate to={homeFor(user.role)} /> : <Navigate to="/login" />
      } />
    </Routes>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Toaster position="top-right" />
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  );
}