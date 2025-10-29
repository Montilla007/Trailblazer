import crypto from "crypto";
import User from "../models/User.js";
import generateToken from "../utils/generateToken.js";

// 🧾 REGISTER USER
export const registerUser = async (req, res) => {
  try {
    const { username, email, gender, address, password, confirmPassword } = req.body;

    // ✅ Validate required fields
    if (!username || !email || !gender || !address || !password || !confirmPassword) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // ✅ Check password match
    if (password !== confirmPassword) {
      return res.status(400).json({ message: "Passwords do not match" });
    }

    // ✅ Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    // ✅ Auto-generate avatar URL using Gravatar
    const avatarUrl = `https://www.gravatar.com/avatar/${crypto
      .createHash("md5")
      .update(email)
      .digest("hex")}?d=identicon`;

    // ✅ Create user
    const user = await User.create({
      username,
      email,
      gender,
      address,
      password,
      avatarUrl,
      isGoogleUser: false,
    });

    // ✅ Respond with token and user info
    res.status(201).json({
      _id: user._id,
      username: user.username,
      email: user.email,
      gender: user.gender,
      address: user.address,
      avatarUrl: user.avatarUrl,
      token: generateToken(user._id),
    });
  } catch (error) {
    console.error("Registration Error:", error);
    res.status(500).json({ message: "Server error during registration" });
  }
};

// 🔐 LOGIN USER
export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log("🧩 Login Attempt for:", email);

    const user = await User.findOne({ email });

    // ✅ User not found
    if (!user) {
      console.log("🚫 No user found for:", email);
      return res.status(401).json({ message: "User not found" });
    }

    // 🚫 Prevent Google-only login via password
    if (user.isGoogleUser || !user.password) {
      return res.status(400).json({
        message:
          "This account uses Google login. Please use 'Continue with Google' instead.",
      });
    }

    // ✅ Compare password
    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid password" });
    }

    // ✅ Login successful
    res.json({
      _id: user._id,
      username: user.username,
      email: user.email,
      gender: user.gender,
      address: user.address,
      avatarUrl: user.avatarUrl,
      token: generateToken(user._id),
    });
  } catch (error) {
    console.error("🧨 Login Error:", error);
    res.status(500).json({ message: "Server error during login" });
  }
};
