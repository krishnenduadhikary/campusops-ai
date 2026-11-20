import { useEffect, useState, useCallback } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import toast from 'react-hot-toast';
import DashboardLayout from '../../layouts/DashboardLayout';
import StatusBadge from '../../components/common/StatusBadge';
import PriorityBadge from '../../components/common/PriorityBadge';
import SlaBadge from '../../components/common/SlaBadge';
import StatusTimeline from '../../components/common/StatusTimeline';
import { ticketService } from '../../services/ticketService';
import { formatDateTime } from '../../utils/date';

export default function TechnicianTicketDetail() {
  const { id } = useParams();
  const [ticket, setTicket] = useState(null);
  const [history, setHistory] = useState([]);
  const [location, setLocation] = useState('');
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    try {
      const [t, h, locations] = await Promise.all([
        ticketService.get(id),
        ticketService.history(id),
        ticketService.locations().catch(() => []),
      ]);
      setTicket(t);
      setHistory(h);
      const loc = locations.find((l) => l.id === t.location_id);
      setLocation(loc ? `${loc.building}${loc.room ? ` - ${loc.room}` : ''}` : '');
    } catch {
      setError('Could not load this ticket');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  const run = async (action, successMessage) => {
    setBusy(true);
    try {
      await action();
      toast.success(successMessage);
      await load();
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Action failed');
    } finally {
      setBusy(false);
    }
  };

  const handleResolve = (e) => {
    e.preventDefault();
    if (!notes.trim()) return;
    run(() => ticketService.resolve(id, notes.trim()), 'Ticket resolved');
  };

  const buttonClass =
    'bg-blue-600 text-white px-5 py-2 rounded-lg font-medium hover:bg-blue-700 disabled:opacity-50';

  return (
    <DashboardLayout>
      <Link
        to="/technician"
        className="flex items-center gap-1 text-sm text-gray-600 hover:text-blue-600 mb-4"
      >
        <ArrowLeft size={16} /> Back to my work
      </Link>

      {loading && <p className="text-gray-500">Loading...</p>}
      {error && <p className="text-red-600">{error}</p>}

      {ticket && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 space-y-6">
            <div className="bg-white rounded-xl border p-6">
              <p className="text-xs text-gray-400">{ticket.ticket_number}</p>
              <h1 className="text-xl font-bold text-gray-800 mt-1">{ticket.title}</h1>
              <div className="flex flex-wrap gap-2 mt-3">
                <StatusBadge status={ticket.status} />
                <PriorityBadge priority={ticket.priority} />
                <SlaBadge dueAt={ticket.due_at} status={ticket.status} />
              </div>
              <p className="text-gray-700 mt-5 whitespace-pre-wrap">{ticket.description}</p>
              <div className="mt-5 text-sm text-gray-600 space-y-1">
                <p>Location: {location || 'Not set'}</p>
                {ticket.category && <p>Category: {ticket.category}</p>}
                <p>Submitted: {formatDateTime(ticket.created_at)}</p>
                {ticket.due_at && <p>Due: {formatDateTime(ticket.due_at)}</p>}
              </div>
            </div>

            {/* Actions */}
            <div className="bg-white rounded-xl border p-6">
              <h2 className="font-semibold text-gray-800 mb-3">Actions</h2>

              {ticket.status === 'ASSIGNED' && (
                <button
                  className={buttonClass}
                  disabled={busy}
                  onClick={() => run(() => ticketService.accept(id), 'Ticket accepted')}
                >
                  Accept ticket
                </button>
              )}

              {ticket.status === 'ACCEPTED' && (
                <button
                  className={buttonClass}
                  disabled={busy}
                  onClick={() => run(() => ticketService.start(id), 'Work started')}
                >
                  Start work
                </button>
              )}

              {ticket.status === 'IN_PROGRESS' && (
                <form onSubmit={handleResolve} className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700">
                    Resolution notes *
                  </label>
                  <textarea
                    className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    rows={3}
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    placeholder="What was the problem and what did you do?"
                    required
                  />
                  <button type="submit" className={buttonClass} disabled={busy}>
                    {busy ? 'Saving...' : 'Mark as resolved'}
                  </button>
                </form>
              )}

              {['RESOLVED', 'CLOSED'].includes(ticket.status) && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-sm font-medium text-green-800">Resolved</p>
                  <p className="text-sm text-green-700 mt-1">{ticket.resolution_notes}</p>
                </div>
              )}

              {['OPEN', 'AI_PROCESSED', 'ESCALATED', 'CANCELLED', 'REJECTED'].includes(
                ticket.status
              ) && (
                <p className="text-sm text-gray-500">
                  No action available for status {ticket.status.replace('_', ' ')}.
                </p>
              )}
            </div>
          </div>

          <div className="bg-white rounded-xl border p-6 h-fit">
            <h2 className="font-semibold text-gray-800 mb-4">Status timeline</h2>
            <StatusTimeline history={history} />
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}