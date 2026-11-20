import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import DashboardLayout from '../../layouts/DashboardLayout';
import StatusBadge from '../../components/common/StatusBadge';
import PriorityBadge from '../../components/common/PriorityBadge';
import { ticketService } from '../../services/ticketService';
import { formatDateTime } from '../../utils/date';

export default function TicketDetail() {
  const { id } = useParams();
  const [ticket, setTicket] = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([ticketService.get(id), ticketService.history(id)])
      .then(([t, h]) => {
        setTicket(t);
        setHistory(h);
      })
      .catch(() => setError('Could not load this ticket'))
      .finally(() => setLoading(false));
  }, [id]);

  return (
    <DashboardLayout>
      <Link to="/student" className="flex items-center gap-1 text-sm text-gray-600 hover:text-blue-600 mb-4">
        <ArrowLeft size={16} /> Back to my tickets
      </Link>

      {loading && <p className="text-gray-500">Loading...</p>}
      {error && <p className="text-red-600">{error}</p>}

      {ticket && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Details */}
          <div className="lg:col-span-2 bg-white rounded-xl border p-6">
            <p className="text-xs text-gray-400">{ticket.ticket_number}</p>
            <h1 className="text-xl font-bold text-gray-800 mt-1">{ticket.title}</h1>
            <div className="flex gap-2 mt-3">
              <StatusBadge status={ticket.status} />
              <PriorityBadge priority={ticket.priority} />
              {ticket.category && (
                <span className="px-2 py-1 rounded-full text-xs bg-gray-100 text-gray-600">
                  {ticket.category}
                </span>
              )}
            </div>
            <p className="text-gray-700 mt-5 whitespace-pre-wrap">{ticket.description}</p>

            {ticket.resolution_notes && (
              <div className="mt-6 bg-green-50 border border-green-200 rounded-lg p-4">
                <p className="text-sm font-medium text-green-800">Resolution</p>
                <p className="text-sm text-green-700 mt-1">{ticket.resolution_notes}</p>
              </div>
            )}

            <div className="mt-6 text-xs text-gray-500 space-y-1">
              <p>Submitted: {formatDateTime(ticket.created_at)}</p>
              {ticket.due_at && <p>Expected by: {formatDateTime(ticket.due_at)}</p>}
            </div>
          </div>

          {/* Timeline */}
          <div className="bg-white rounded-xl border p-6">
            <h2 className="font-semibold text-gray-800 mb-4">Status timeline</h2>
            <ol className="relative border-l border-gray-200 ml-2 space-y-5">
              {history.map((h) => (
                <li key={h.id} className="ml-4">
                  <span className="absolute -left-1.5 w-3 h-3 bg-blue-500 rounded-full" />
                  <StatusBadge status={h.new_status} />
                  {h.comment && <p className="text-sm text-gray-600 mt-1">{h.comment}</p>}
                  <p className="text-xs text-gray-400 mt-1">
                    {formatDateTime(h.timestamp)}
                  </p>
                </li>
              ))}
            </ol>
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}