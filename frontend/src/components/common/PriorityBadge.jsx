const STYLES = {
  LOW: 'bg-gray-100 text-gray-600',
  MEDIUM: 'bg-blue-100 text-blue-700',
  HIGH: 'bg-orange-100 text-orange-700',
  CRITICAL: 'bg-red-100 text-red-700',
};

export default function PriorityBadge({ priority }) {
  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${STYLES[priority] || 'bg-gray-100 text-gray-600'}`}>
      {priority}
    </span>
  );
}