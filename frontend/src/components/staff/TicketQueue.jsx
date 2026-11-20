import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import StatusBadge from '../common/StatusBadge';
import PriorityBadge from '../common/PriorityBadge';
import SlaBadge from '../common/SlaBadge';
import { ticketService } from '../../services/ticketService';
import { opsService } from '../../services/opsService';
import { parseDate } from '../../utils/date';
import { sortTickets } from '../../utils/tickets';

const ACTIVE = ['ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'ESCALATED'];
const FINISHED = ['RESOLVED', 'CLOSED', 'CANCELLED', 'REJECTED'];

function isAtRisk(t) {
  const due = parseDate(t.due_at);
  if (!due || !ACTIVE.includes(t.status)) return false;
  return due - new Date() <= 60 * 60 * 1000; // overdue or due within an hour
}

const TABS = [
  { key: 'unassigned', label: 'Unassigned', match: (t) => ['OPEN', 'AI_PROCESSED'].includes(t.status) },
  { key: 'active', label: 'Active', match: (t) => ACTIVE.includes(t.status) },
  { key: 'risk', label: 'SLA risk', match: isAtRisk },
  { key: 'done', label: 'Completed', match: (t) => FINISHED.includes(t.status) },
];

export default function TicketQueue({ basePath }) {
  const [tickets, setTickets] = useState([]);
  const [names, setNames] = useState({ locations: {}, technicians: {} });
  const [tab, setTab] = useState('unassigned');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([
      ticketService.list({ limit: 100 }),
      ticketService.locations().catch(() => []),
      opsService.technicians().catch(() => []),
    ])
      .then(([data, locations, technicians]) => {
        setTickets(data.tickets);
        setNames({
          locations: Object.fromEntries(
            locations.map((l) => [l.id, `${l.building}${l.room ? ` - ${l.room}` : ''}`])
          ),
          technicians: Object.fromEntries(technicians.map((t) => [t.id, t.name])),
        });
      })
      .catch(() => setError('Could not load tickets'))
      .finally(() => setLoading(false));
  }, []);

  const current = TABS.find((t) => t.key === tab);
  const visible = sortTickets(tickets.filter(current.match));

  const assignee = (t) => {
    if (t.assigned_to) return names.technicians[t.assigned_to] || `User #${t.assigned_to}`;
    return t.assigned_department ? 'Department queue' : 'Not assigned';
  };

  return (
    <div>
      <div className="flex flex-wrap gap-2 mb-4">
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
            {t.label} ({tickets.filter(t.match).length})
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
              to={`${basePath}/tickets/${t.id}`}
              className="flex items-center justify-between p-4 hover:bg-gray-50"
            >
              <div>
                <p className="text-xs text-gray-400">{t.ticket_number}</p>
                <p className="font-medium text-gray-800">{t.title}</p>
                <p className="text-xs text-gray-500 mt-1">
                  {names.locations[t.location_id] || 'Location not set'} · {assignee(t)}
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
    </div>
  );
}