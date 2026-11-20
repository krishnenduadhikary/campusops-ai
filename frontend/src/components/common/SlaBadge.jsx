import { slaInfo } from '../../utils/sla';

const STYLES = {
  overdue: 'bg-red-100 text-red-700',
  soon: 'bg-orange-100 text-orange-700',
  ok: 'bg-green-100 text-green-700',
  none: 'bg-gray-100 text-gray-500',
};

export default function SlaBadge({ dueAt, status }) {
  const { label, level } = slaInfo(dueAt, status);
  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${STYLES[level]}`}>
      {label}
    </span>
  );
}