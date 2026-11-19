import { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import toast from 'react-hot-toast';
import DashboardLayout from '../../layouts/DashboardLayout';
import { ticketService } from '../../services/ticketService';

const CATEGORIES = [
  ['IT', 'IT & Network'],
  ['ELECTRICAL', 'Electrical'],
  ['PLUMBING', 'Plumbing'],
  ['CIVIL', 'Civil & Infrastructure'],
  ['HOUSEKEEPING', 'Housekeeping'],
  ['SECURITY', 'Security'],
  ['CANTEEN', 'Canteen & Mess'],
  ['HORTICULTURE', 'Horticulture'],
  ['OTHER', 'Other'],
];

export default function SubmitTicket() {
  const navigate = useNavigate();
  const [locations, setLocations] = useState([]);
  const [form, setForm] = useState({
    title: '',
    description: '',
    category: '',
    location_id: '',
  });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    ticketService.locations().then(setLocations).catch(() => {});
  }, []);

  const set = (field) => (e) => setForm({ ...form, [field]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const payload = {
        title: form.title,
        description: form.description,
        category: form.category || null,
        location_id: form.location_id ? Number(form.location_id) : null,
      };
      const ticket = await ticketService.create(payload);
      toast.success(`Complaint ${ticket.ticket_number} submitted`);
      navigate(`/student/tickets/${ticket.id}`);
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Could not submit complaint');
    } finally {
      setSubmitting(false);
    }
  };

  const inputClass =
    'w-full border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500';

  return (
    <DashboardLayout title="New Complaint">
      <form onSubmit={handleSubmit} className="bg-white rounded-xl border p-6 max-w-2xl space-y-5">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Title *</label>
          <input
            className={inputClass}
            value={form.title}
            onChange={set('title')}
            placeholder="e.g. WiFi not working in Lab 3"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Description *</label>
          <textarea
            className={inputClass}
            rows={4}
            value={form.description}
            onChange={set('description')}
            placeholder="Describe the problem in detail"
            required
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
            <select className={inputClass} value={form.category} onChange={set('category')}>
              <option value="">Not sure (AI will suggest later)</option>
              {CATEGORIES.map(([value, label]) => (
                <option key={value} value={value}>{label}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
            <select className={inputClass} value={form.location_id} onChange={set('location_id')}>
              <option value="">Select location</option>
              {locations.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.building}{l.room ? ` - ${l.room}` : ''}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex items-center gap-3 pt-2">
          <button
            type="submit"
            disabled={submitting}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg font-medium hover:bg-blue-700 disabled:opacity-50"
          >
            {submitting ? 'Submitting...' : 'Submit Complaint'}
          </button>
          <Link to="/student" className="text-gray-600 hover:underline text-sm">Cancel</Link>
        </div>
      </form>
    </DashboardLayout>
  );
}