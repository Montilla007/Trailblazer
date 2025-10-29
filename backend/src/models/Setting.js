import mongoose from "mongoose";

const settingsSchema = new mongoose.Schema({
  theme: {
    type: String,
    enum: ["light", "dark", "system"],
    default: "system",
  },
  accessibility: {
    textToSpeech: { type: Boolean, default: false },
    highContrast: { type: Boolean, default: false },
    largeText: { type: Boolean, default: false },
  },
  notifications: {
    enabled: { type: Boolean, default: true },
  },
});
export default mongoose.model("Setting", settingsSchema);
