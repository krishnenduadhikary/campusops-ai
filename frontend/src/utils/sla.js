import { parseDate } from './date';

const FINISHED = ['RESOLVED', 'CLOSED', 'CANCELLED', 'REJECTED'];

export function slaInfo(dueAt, status) {
  const due = parseDate(dueAt);
  if (!due) return { label: 'No SLA set', level: 'none' };
  if (FINISHED.includes(status)) return { label: 'Completed', level: 'none' };

  const mins = Math.round((due - new Date()) / 60000);
  const abs = Math.abs(mins);
  const hours = Math.floor(abs / 60);
  const text =
    hours >= 24 ? `${Math.floor(hours / 24)}d ${hours % 24}h`
    : hours > 0 ? `${hours}h ${abs % 60}m`
    : `${abs}m`;

  if (mins < 0) return { label: `Overdue by ${text}`, level: 'overdue' };
  if (mins <= 60) return { label: `Due in ${text}`, level: 'soon' };
  return { label: `Due in ${text}`, level: 'ok' };
}