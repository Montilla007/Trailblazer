import express from "express";
import {
    deleteUser,
    getUserById,
    getUsers,
    updateUser,
} from "../controllers/userController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

// Protected routes
router.get("/", protect, getUsers);
router.get("/:id", protect, getUserById);
router.put("/:id", protect, updateUser);
router.delete("/:id", protect, deleteUser);

export default router;
