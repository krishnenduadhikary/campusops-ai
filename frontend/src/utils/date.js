const HAS_TZ = /([zZ]|[+-]\d{2}:?\d{2})$/;

// Backend sends UTC timestamps without a timezone suffix.
export function parseDate(value) {
  if (!value) return null;
  return new Date(HAS_TZ.test(value) ? value : `${value}Z`);
}

export function formatDateTime(value) {
  const d = parseDate(value);
  return d ? d.toLocaleString() : '';
}