import mongoose from "mongoose";

const connectDB = async () => {
  try {
    const uri =
      process.env.NODE_ENV === "production"
        ? process.env.MONGO_URI_PROD
        : process.env.NODE_ENV === "test"
        ? process.env.MONGO_URI
        : process.env.MONGO_URI_DEV;

    if (!uri) {
      throw new Error(
        `MongoDB URI not found for environment: ${process.env.NODE_ENV}`
      );
    }

    await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(
      `✅ MongoDB connected: ${
        process.env.NODE_ENV === "production" ? "Production" : "Development"
      } mode`
    );
  } catch (error) {
    console.error("❌ MongoDB connection error:", error.message);
    process.exit(1);
  }
};

export default connectDB;
