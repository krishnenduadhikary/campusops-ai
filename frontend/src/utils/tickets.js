import { parseDate } from './date';

const PRIORITY_RANK = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 };

// Highest priority first, then nearest due time, then oldest first.
export function sortTickets(list) {
  return [...list].sort((a, b) => {
    const p = PRIORITY_RANK[a.priority] - PRIORITY_RANK[b.priority];
    if (p !== 0) return p;
    const da = parseDate(a.due_at)?.getTime() ?? Infinity;
    const db = parseDate(b.due_at)?.getTime() ?? Infinity;
    if (da !== db) return da - db;
    return (parseDate(a.created_at) ?? 0) - (parseDate(b.created_at) ?? 0);
  });
}