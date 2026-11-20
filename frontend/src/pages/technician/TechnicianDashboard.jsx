import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import DashboardLayout from '../../layouts/DashboardLayout';
import StatusBadge from '../../components/common/StatusBadge';
import PriorityBadge from '../../components/common/PriorityBadge';
import SlaBadge from '../../components/common/SlaBadge';
import { ticketService } from '../../services/ticketService';
import { parseDate } from '../../utils/date';

const TABS = [
  { key: 'new', label: 'New', statuses: ['ASSIGNED', 'ACCEPTED'] },
  { key: 'progress', label: 'In progress', statuses: ['IN_PROGRESS', 'ESCALATED'] },
  { key: 'done', label: 'Completed', statuses: ['RESOLVED', 'CLOSED'] },
];
const PRIORITY_RANK = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 };

function sortTickets(list) {
  return [...list].sort((a, b) => {
    const p = PRIORITY_RANK[a.priority] - PRIORITY_RANK[b.priority];
    if (p !== 0) return p;
    const da = parseDate(a.due_at)?.getTime() ?? Infinity;
    const db = parseDate(b.due_at)?.getTime() ?? Infinity;
    return da - db;
  });
}

export default function TechnicianDashboard() {
  const [tickets, setTickets] = useState([]);
  const [locMap, setLocMap] = useState({});
  const [tab, setTab] = useState('new');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([
      ticketService.list({ limit: 100 }),
      ticketService.locations().catch(() => []),
    ])
      .then(([data, locations]) => {
        setTickets(data.tickets);
        setLocMap(
          Object.fromEntries(
            locations.map((l) => [l.id, `${l.building}${l.room ? ` - ${l.room}` : ''}`])
          )
        );
      })
      .catch(() => setError('Could not load tickets'))
      .finally(() => setLoading(false));
  }, []);

  const current = TABS.find((t) => t.key === tab);
  const visible = sortTickets(tickets.filter((t) => current.statuses.includes(t.status)));
  const countFor = (key) =>
    tickets.filter((t) => TABS.find((x) => x.key === key).statuses.includes(t.status)).length;

  const now = new Date();
  const overdue = tickets.filter(
    (t) =>
      ['ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'ESCALATED'].includes(t.status) &&
      parseDate(t.due_at) &&
      parseDate(t.due_at) < now
  ).length;

  return (
    <DashboardLayout title="My Work">
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        <StatCard label="New" value={countFor('new')} color="text-blue-600" />
        <StatCard label="In progress" value={countFor('progress')} color="text-yellow-600" />
        <StatCard label="Overdue" value={overdue} color="text-red-600" />
      </div>

      <div className="flex gap-2 mb-4">
        {TABS.map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={`px-4 py-2 rounded-lg text-sm font-medium ${
              tab === t.key
                ? 'bg-blue-600 text-white'
                : 'bg-white border text-gray-600 hover:bg-gray-50'
            }`}
          >
            {t.label} ({countFor(t.key)})
          </button>
        ))}
      </div>

      {loading && <p className="text-gray-500">Loading...</p>}
      {error && <p className="text-red-600">{error}</p>}

      {!loading && !error && visible.length === 0 && (
        <div className="bg-white rounded-xl border p-10 text-center text-gray-500">
          No tickets here.
        </div>
      )}

      {visible.length > 0 && (
        <div className="bg-white rounded-xl border divide-y">
          {visible.map((t) => (
            <Link
              key={t.id}
              to={`/technician/tickets/${t.id}`}
              className="flex items-center justify-between p-4 hover:bg-gray-50"
            >
              <div>
                <p className="text-xs text-gray-400">{t.ticket_number}</p>
                <p className="font-medium text-gray-800">{t.title}</p>
                <p className="text-xs text-gray-500 mt-1">
                  {locMap[t.location_id] || 'Location not set'}
                </p>
              </div>
              <div className="flex flex-wrap items-center justify-end gap-2">
                <PriorityBadge priority={t.priority} />
                <StatusBadge status={t.status} />
                <SlaBadge dueAt={t.due_at} status={t.status} />
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