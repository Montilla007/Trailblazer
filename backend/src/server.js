import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import morgan from "morgan";
import multer from "multer";

import connectDB from "./config/db.js";
import authRoutes from "./routes/authRoutes.js";
import userRoutes from "./routes/userRoutes.js";

// ✅ Load environment variables based on NODE_ENV
if (process.env.NODE_ENV === "test") {
  dotenv.config({ path: ".env.test" });
} else {
  dotenv.config();
}

const app = express();
const upload = multer();

// ✅ Connect to MongoDB
connectDB();

// ✅ Middleware
app.use(express.json());
app.use(cors());
app.use(upload.none());

// ✅ Logging only in development
if (process.env.NODE_ENV === "development") {
  app.use(morgan("dev"));
  console.log("🧩 Running in development mode");
}

// ✅ User and Auth routes
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);

// ✅ Root route
app.get("/", (_req, res) => {
  res.json({
    status: "OK",
    message: `Trailblazer Backend Running in ${process.env.NODE_ENV} mode 🚀`,
  });
});

// ✅ Use PORT from environment or fallback
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});

export default app;
