// middlewares/auth.js
const jwt = require("jsonwebtoken");
const prisma = require("../prisma");
const SECRET = process.env.JWT_SECRET || "secret_default";

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || "";
    const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;

    if (!token) {
      return res.status(401).json({ success: false, message: "Token wajib" });
    }

    const payload = jwt.verify(token, SECRET);

    const petugas = await prisma.petugas.findUnique({
      where: { id_petugas: payload.id_petugas },
    });

    if (!petugas) {
      return res.status(401).json({ success: false, message: "Token invalid" });
    }

    req.user = petugas;
    next();
  } catch (err) {
    console.error("Auth middleware error:", err);
    return res
      .status(401)
      .json({ success: false, message: "Token invalid / expired" });
  }
};
