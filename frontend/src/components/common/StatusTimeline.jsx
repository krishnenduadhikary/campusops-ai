import StatusBadge from './StatusBadge';
import { formatDateTime } from '../../utils/date';

export default function StatusTimeline({ history }) {
  return (
    <ol className="relative border-l border-gray-200 ml-2 space-y-5">
      {history.map((h) => (
        <li key={h.id} className="ml-4">
          <span className="absolute -left-1.5 w-3 h-3 bg-blue-500 rounded-full" />
          <StatusBadge status={h.new_status} />
          {h.comment && <p className="text-sm text-gray-600 mt-1">{h.comment}</p>}
          <p className="text-xs text-gray-400 mt-1">{formatDateTime(h.timestamp)}</p>
        </li>
      ))}
    </ol>
  );
}