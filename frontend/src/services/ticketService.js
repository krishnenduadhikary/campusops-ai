import api from './api';

export const ticketService = {
  async list(params = {}) {
    const res = await api.get('/tickets/', { params });
    return res.data; // { total, tickets }
  },
  async get(id) {
    const res = await api.get(`/tickets/${id}`);
    return res.data;
  },
  async history(id) {
    const res = await api.get(`/tickets/${id}/history`);
    return res.data;
  },
  async create(data) {
    const res = await api.post('/tickets/', data);
    return res.data;
  },
  async locations() {
    const res = await api.get('/locations/');
    return res.data;
  },
};