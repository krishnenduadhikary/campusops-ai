import { useEffect, useState } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import StatCard from '../../components/common/StatCard';
import TicketQueue from '../../components/staff/TicketQueue';
import { opsService } from '../../services/opsService';

function Panel({ title, children }) {
  return (
    <div className="bg-white rounded-xl border p-6">
      <h2 className="font-semibold text-gray-800 mb-4">{title}</h2>
      {children}
    </div>
  );
}

function CategoryBars({ items }) {
  const max = Math.max(...items.map((i) => i.count), 1);
  return (
    <div className="space-y-3">
      {items.map((i) => (
        <div key={i.category}>
          <div className="flex justify-between text-sm text-gray-700 mb-1">
            <span>{i.category}</span>
            <span>{i.count}</span>
          </div>
          <div className="h-2 bg-gray-100 rounded-full">
            <div
              className="h-2 bg-blue-500 rounded-full"
              style={{ width: `${(i.count / max) * 100}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}

export default function AdminDashboard() {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    opsService.overview().then(setStats).catch(() => {});
  }, []);

  const compliance = stats?.sla_compliance;
  const avg = stats?.avg_resolution_hours;

  return (
    <DashboardLayout title="Campus Overview">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Total tickets" value={stats?.total ?? '-'} />
        <StatCard label="Open" value={stats?.open ?? '-'} color="text-blue-600" />
        <StatCard label="Unassigned" value={stats?.unassigned ?? '-'} color="text-purple-600" />
        <StatCard label="Resolved" value={stats?.resolved ?? '-'} color="text-green-600" />
        <StatCard label="Critical (active)" value={stats?.critical_active ?? '-'} color="text-red-600" />
        <StatCard label="SLA breaches" value={stats?.sla_breaches ?? '-'} color="text-orange-600" />
        <StatCard
          label="SLA compliance"
          value={compliance == null ? '—' : `${compliance}%`}
          color="text-green-600"
        />
        <StatCard label="Avg resolution" value={avg == null ? '—' : `${avg} h`} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <Panel title="Top categories">
          {stats?.top_categories?.length ? (
            <CategoryBars items={stats.top_categories} />
          ) : (
            <p className="text-sm text-gray-500">No data yet.</p>
          )}
        </Panel>

        <Panel title="Department performance">
          {stats?.by_department?.length ? (
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-gray-500">
                  <th className="pb-2 font-medium">Department</th>
                  <th className="pb-2 font-medium text-right">Total</th>
                  <th className="pb-2 font-medium text-right">Open</th>
                  <th className="pb-2 font-medium text-right">Breaches</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {stats.by_department.map((d) => (
                  <tr key={d.department}>
                    <td className="py-2 text-gray-800">{d.department}</td>
                    <td className="py-2 text-right">{d.total}</td>
                    <td className="py-2 text-right">{d.open}</td>
                    <td className="py-2 text-right text-orange-600">{d.breaches}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p className="text-sm text-gray-500">No data yet.</p>
          )}
        </Panel>
      </div>

      <h2 className="text-lg font-semibold text-gray-700 mb-4">All tickets</h2>
      <TicketQueue basePath="/admin" />
    </DashboardLayout>
  );
}