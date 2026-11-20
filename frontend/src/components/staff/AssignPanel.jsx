import { useState } from 'react';
import toast from 'react-hot-toast';
import { useAuth } from '../../context/AuthContext';
import { ticketService } from '../../services/ticketService';

export default function AssignPanel({ ticket, departments, technicians, onAssigned }) {
  const { user } = useAuth();

  const currentTech = technicians.find((t) => t.id === ticket.assigned_to);
  const [departmentId, setDepartmentId] = useState(
    String(ticket.assigned_department || user.department_id || departments[0]?.id || '')
  );
  const [technicianId, setTechnicianId] = useState(currentTech ? String(currentTech.id) : '');
  const [busy, setBusy] = useState(false);

  const options = technicians.filter((t) => String(t.department_id) === departmentId);

  const changeDepartment = (e) => {
    setDepartmentId(e.target.value);
    setTechnicianId('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setBusy(true);
    try {
      await ticketService.assign(ticket.id, {
        department_id: Number(departmentId),
        technician_id: technicianId ? Number(technicianId) : null,
      });
      toast.success('Ticket assigned');
      onAssigned();
    } catch (err) {
      const detail = err.response?.data?.detail;
      toast.error(typeof detail === 'string' ? detail : 'Could not assign ticket');
    } finally {
      setBusy(false);
    }
  };

  const inputClass =
    'w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500';

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Department</label>
        <select className={inputClass} value={departmentId} onChange={changeDepartment} required>
          {departments.map((d) => (
            <option key={d.id} value={d.id}>{d.name}</option>
          ))}
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Technician</label>
        <select
          className={inputClass}
          value={technicianId}
          onChange={(e) => setTechnicianId(e.target.value)}
        >
          <option value="">Department queue (any technician can accept)</option>
          {options.map((t) => (
            <option key={t.id} value={t.id}>
              {t.name} ({t.active_tickets} active)
            </option>
          ))}
        </select>
      </div>

      {ticket.assigned_department && (
        <p className="text-xs text-gray-500">
          Reassigning resets the ticket to ASSIGNED, so the technician has to accept it again.
        </p>
      )}

      <button
        type="submit"
        disabled={busy}
        className="bg-blue-600 text-white px-5 py-2 rounded-lg font-medium hover:bg-blue-700 disabled:opacity-50"
      >
        {busy ? 'Saving...' : ticket.assigned_department ? 'Reassign ticket' : 'Assign ticket'}
      </button>
    </form>
  );
}