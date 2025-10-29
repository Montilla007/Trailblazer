import mongoose from "mongoose";

const coordinateSchema = new mongoose.Schema({
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now },
});

const trailSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    name: { type: String, default: "Unnamed Trail" },
    description: { type: String },
    coordinates: [coordinateSchema],
    startedAt: { type: Date, default: Date.now },
    endedAt: { type: Date },
    note: { type: String },
    isAutoTracked: { type: Boolean, default: false },
    distance: { type: Number, default: 0 }, // in meters
  },
  { timestamps: true }
);

export default mongoose.model("Trail", trailSchema);
