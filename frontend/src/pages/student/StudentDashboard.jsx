import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Plus } from 'lucide-react';
import DashboardLayout from '../../layouts/DashboardLayout';
import StatusBadge from '../../components/common/StatusBadge';
import PriorityBadge from '../../components/common/PriorityBadge';
import { ticketService } from '../../services/ticketService';
import { parseDate } from '../../utils/date';

const DONE = ['RESOLVED', 'CLOSED', 'CANCELLED', 'REJECTED'];

export default function StudentDashboard() {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    ticketService
      .list({ limit: 100 })
      .then((data) => setTickets(data.tickets))
      .catch(() => setError('Could not load tickets'))
      .finally(() => setLoading(false));
  }, []);

  const total = tickets.length;
  const active = tickets.filter((t) => !DONE.includes(t.status)).length;
  const resolved = tickets.filter((t) => t.status === 'RESOLVED' || t.status === 'CLOSED').length;

  return (
    <DashboardLayout title="My Tickets">
      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        <StatCard label="Total" value={total} color="text-gray-800" />
        <StatCard label="Active" value={active} color="text-blue-600" />
        <StatCard label="Resolved" value={resolved} color="text-green-600" />
      </div>

      {/* Header row */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-gray-700">All complaints</h2>
        <Link
          to="/student/new"
          className="flex items-center gap-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 text-sm font-medium"
        >
          <Plus size={16} /> New Complaint
        </Link>
      </div>

      {/* List */}
      {loading && <p className="text-gray-500">Loading...</p>}
      {error && <p className="text-red-600">{error}</p>}

      {!loading && !error && tickets.length === 0 && (
        <div className="bg-white rounded-xl border p-10 text-center text-gray-500">
          You have not submitted any complaints yet.
        </div>
      )}

      {tickets.length > 0 && (
        <div className="bg-white rounded-xl border divide-y">
          {tickets.map((t) => (
            <Link
              key={t.id}
              to={`/student/tickets/${t.id}`}
              className="flex items-center justify-between p-4 hover:bg-gray-50"
            >
              <div>
                <p className="text-xs text-gray-400">{t.ticket_number}</p>
                <p className="font-medium text-gray-800">{t.title}</p>
                <p className="text-xs text-gray-500 mt-1">
                  {parseDate(t.created_at)?.toLocaleDateString()}
                </p>
              </div>
              <div className="flex items-center gap-2">
                <PriorityBadge priority={t.priority} />
                <StatusBadge status={t.status} />
              </div>
            </Link>
          ))}
        </div>
      )}
    </DashboardLayout>
  );
}

function StatCard({ label, value, color }) {
  return (
    <div className="bg-white rounded-xl border p-5">
      <p className="text-sm text-gray-500">{label}</p>
      <p className={`text-3xl font-bold mt-1 ${color}`}>{value}</p>
    </div>
  );
}