const PetugasService = require("../services/petugas.service");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs"); // gunakan bcryptjs
const SECRET = process.env.JWT_SECRET || "secret_default";

module.exports = {
  login: async (req, res) => {
    try {
      const { username, password } = req.body;

      if (!username || !password) {
        return res
          .status(400)
          .json({ success: false, message: "Username & password wajib" });
      }

      const petugas = await PetugasService.findByUsername(username);
      if (!petugas) {
        return res
          .status(401)
          .json({ success: false, message: "Username atau password salah" });
      }

      const match = await bcrypt.compare(password, petugas.password);
      if (!match) {
        return res
          .status(401)
          .json({ success: false, message: "Username atau password salah" });
      }

      const payload = {
        id_petugas: petugas.id_petugas,
        username: petugas.username,
      };

      const token = jwt.sign(payload, SECRET, { expiresIn: "8h" });

      res.json({
        success: true,
        message: "Login berhasil",
        token,
        data: payload,
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  },
};
