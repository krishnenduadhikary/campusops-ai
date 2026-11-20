import { useEffect, useState, useCallback } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import DashboardLayout from '../../layouts/DashboardLayout';
import StatusBadge from '../../components/common/StatusBadge';
import PriorityBadge from '../../components/common/PriorityBadge';
import SlaBadge from '../../components/common/SlaBadge';
import StatusTimeline from '../../components/common/StatusTimeline';
import AssignPanel from '../../components/staff/AssignPanel';
import { useAuth } from '../../context/AuthContext';
import { ticketService } from '../../services/ticketService';
import { opsService } from '../../services/opsService';
import { formatDateTime } from '../../utils/date';

const FINISHED = ['RESOLVED', 'CLOSED', 'CANCELLED', 'REJECTED'];

export default function StaffTicketDetail() {
  const { id } = useParams();
  const { user } = useAuth();
  const backTo = user.role === 'ADMIN' ? '/admin' : '/supervisor';

  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    try {
      const [ticket, history, locations, departments, technicians] = await Promise.all([
        ticketService.get(id),
        ticketService.history(id),
        ticketService.locations().catch(() => []),
        opsService.departments(),
        opsService.technicians(),
      ]);
      setData({ ticket, history, locations, departments, technicians });
    } catch {
      setError('Could not load this ticket');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  const ticket = data?.ticket;
  const location = data?.locations.find((l) => l.id === ticket?.location_id);
  const department = data?.departments.find((d) => d.id === ticket?.assigned_department);
  const technician = data?.technicians.find((t) => t.id === ticket?.assigned_to);

  return (
    <DashboardLayout>
      <Link
        to={backTo}
        className="flex items-center gap-1 text-sm text-gray-600 hover:text-blue-600 mb-4"
      >
        <ArrowLeft size={16} /> Back to dashboard
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
                <p>Location: {location ? `${location.building}${location.room ? ` - ${location.room}` : ''}` : 'Not set'}</p>
                {ticket.category && <p>Category: {ticket.category}</p>}
                <p>Department: {department?.name || 'Not assigned'}</p>
                <p>
                  Technician:{' '}
                  {technician?.name ||
                    (ticket.assigned_to ? `User #${ticket.assigned_to}` : department ? 'Department queue' : 'Not assigned')}
                </p>
                <p>Submitted: {formatDateTime(ticket.created_at)}</p>
                {ticket.due_at && <p>Due: {formatDateTime(ticket.due_at)}</p>}
              </div>

              {ticket.resolution_notes && (
                <div className="mt-5 bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-sm font-medium text-green-800">Resolution</p>
                  <p className="text-sm text-green-700 mt-1">{ticket.resolution_notes}</p>
                </div>
              )}
            </div>

            {!FINISHED.includes(ticket.status) && (
              <div className="bg-white rounded-xl border p-6">
                <h2 className="font-semibold text-gray-800 mb-4">
                  {ticket.assigned_department ? 'Reassign' : 'Assign'}
                </h2>
                <AssignPanel
                  ticket={ticket}
                  departments={data.departments}
                  technicians={data.technicians}
                  onAssigned={load}
                />
              </div>
            )}
          </div>

          <div className="bg-white rounded-xl border p-6 h-fit">
            <h2 className="font-semibold text-gray-800 mb-4">Status timeline</h2>
            <StatusTimeline history={data.history} />
          </div>
        </div>
      )}
    </DashboardLayout>
  );
}