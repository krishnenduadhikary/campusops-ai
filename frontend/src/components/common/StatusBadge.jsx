const STYLES = {
  OPEN: 'bg-blue-100 text-blue-700',
  AI_PROCESSED: 'bg-indigo-100 text-indigo-700',
  ASSIGNED: 'bg-purple-100 text-purple-700',
  ACCEPTED: 'bg-cyan-100 text-cyan-700',
  IN_PROGRESS: 'bg-yellow-100 text-yellow-800',
  RESOLVED: 'bg-green-100 text-green-700',
  CLOSED: 'bg-gray-200 text-gray-700',
  CANCELLED: 'bg-gray-100 text-gray-500',
  REJECTED: 'bg-red-100 text-red-700',
  ESCALATED: 'bg-orange-100 text-orange-700',
};

export default function StatusBadge({ status }) {
  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${STYLES[status] || 'bg-gray-100 text-gray-600'}`}>
      {status?.replace('_', ' ')}
    </span>
  );
}