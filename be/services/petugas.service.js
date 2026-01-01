// services/petugas.service.js
const prisma = require("../prisma");

class PetugasService {
  async findByUsername(username) {
    if (!username) return null;
    return prisma.petugas.findUnique({
      where: { username },
    });
  }

  // kalau kamu punya fungsi lain (getAll, create, dll.)
  // bisa ditambah di sini pakai prisma.petugas.*
}

module.exports = new PetugasService();
