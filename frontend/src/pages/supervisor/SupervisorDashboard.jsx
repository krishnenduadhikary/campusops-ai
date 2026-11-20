import { useEffect, useState } from 'react';
import DashboardLayout from '../../layouts/DashboardLayout';
import StatCard from '../../components/common/StatCard';
import TicketQueue from '../../components/staff/TicketQueue';
import { opsService } from '../../services/opsService';

export default function SupervisorDashboard() {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    opsService.overview().then(setStats).catch(() => {});
  }, []);

  const compliance = stats?.sla_compliance;

  return (
    <DashboardLayout title="Department Overview">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Open tickets" value={stats?.open ?? '-'} color="text-blue-600" />
        <StatCard label="Critical (active)" value={stats?.critical_active ?? '-'} color="text-red-600" />
        <StatCard label="SLA breaches" value={stats?.sla_breaches ?? '-'} color="text-orange-600" />
        <StatCard
          label="SLA compliance"
          value={compliance == null ? '—' : `${compliance}%`}
          color="text-green-600"
        />
      </div>

      <TicketQueue basePath="/supervisor" />
    </DashboardLayout>
  );
}