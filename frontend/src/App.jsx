import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './pages/auth/Login';
import StudentDashboard from './pages/student/StudentDashboard';
import SubmitTicket from './pages/student/SubmitTicket';
import TicketDetail from './pages/student/TicketDetail';
import TechnicianDashboard from './pages/technician/TechnicianDashboard';
import TechnicianTicketDetail from './pages/technician/TechnicianTicketDetail';
import SupervisorDashboard from './pages/supervisor/SupervisorDashboard';
import AdminDashboard from './pages/admin/AdminDashboard';
import StaffTicketDetail from './pages/staff/StaffTicketDetail';

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
           <Route path="/supervisor" element={
        <RoleRoute roles={['SUPERVISOR', 'ADMIN']}><SupervisorDashboard /></RoleRoute>
      } />
      <Route path="/supervisor/tickets/:id" element={
        <RoleRoute roles={['SUPERVISOR', 'ADMIN']}><StaffTicketDetail /></RoleRoute>
      } />
      <Route path="/admin" element={
        <RoleRoute roles={['ADMIN']}><AdminDashboard /></RoleRoute>
      } />
      <Route path="/admin/tickets/:id" element={
        <RoleRoute roles={['ADMIN']}><StaffTicketDetail /></RoleRoute>
      } />
            <Route path="/technician" element={
        <RoleRoute roles={['TECHNICIAN', 'ADMIN']}><TechnicianDashboard /></RoleRoute>
      } />
      <Route path="/technician/tickets/:id" element={
        <RoleRoute roles={['TECHNICIAN', 'ADMIN']}><TechnicianTicketDetail /></RoleRoute>
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