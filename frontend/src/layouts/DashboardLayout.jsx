import { LogOut } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function DashboardLayout({ title, children }) {
  const { user, logout } = useAuth();

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b">
        <div className="max-w-6xl mx-auto px-4 h-16 flex items-center justify-between">
          <span className="text-xl font-bold text-blue-600">🏫 CampusOps AI</span>
          <div className="flex items-center gap-4">
            <div className="text-right">
              <p className="text-sm font-medium text-gray-800">{user?.name}</p>
              <p className="text-xs text-gray-500">{user?.role}</p>
            </div>
            <button
              onClick={logout}
              className="flex items-center gap-1 text-sm text-gray-600 hover:text-red-600"
            >
              <LogOut size={16} /> Logout
            </button>
          </div>
        </div>
      </header>
      <main className="max-w-6xl mx-auto px-4 py-8">
        {title && <h1 className="text-2xl font-bold text-gray-800 mb-6">{title}</h1>}
        {children}
      </main>
    </div>
  );
}