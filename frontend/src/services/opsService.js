import api from './api';

export const opsService = {
  async departments() {
    const res = await api.get('/departments/');
    return res.data;
  },
  async technicians() {
    const res = await api.get('/users/technicians');
    return res.data;
  },
  async overview() {
    const res = await api.get('/analytics/overview');
    return res.data;
  },
};