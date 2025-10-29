import bcrypt from "bcryptjs";
import mongoose from "mongoose";
import address from "./Address.js";

const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, trim: true },
    gender: String,
    address: address.schema,
    password: { type: String },
    avatarUrl: String,
    isGoogleUser: { type: Boolean, default: false },
  },
  { timestamps: true }
);

// 🔐 Hash password before saving
userSchema.pre("save", async function (next) {
  if (!this.isModified("password") || !this.password) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});


// ✅ Password comparison method
userSchema.methods.matchPassword = async function (enteredPassword) {
  if (!this.password) return false;
  return await bcrypt.compare(enteredPassword, this.password);
};


const User = mongoose.model("User", userSchema);
export default User;
