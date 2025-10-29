import mongoose from "mongoose";
import request from "supertest";
import app from "../src/server.js"; // Adjust path if needed

describe("Auth Flow (Register → Login → Delete)", () => {
  let token;
  let userId;
  const timestamp = Date.now();
  const testUser = {
    username: "TestUser",
    email: `test.${timestamp}@test.com`,
    password: "Password123!",
    confirmPassword: "Password123!",
    gender: "Male",
    address: {
      number: "340",
      barangay: "Namolan",
      city: "Lingayen",
      province: "Pangasinan",
      postalCode: "2401",
    },
  };

  // 🧹 Disconnect Mongo after all tests
  afterAll(async () => {
    await mongoose.connection.close();
  });

  // 🧪 Register
  it("should register a new user successfully", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send(testUser)
      .expect(201);

    expect(res.body).toHaveProperty("_id");
    expect(res.body).toHaveProperty("token");
    expect(res.body.email).toBe(testUser.email);

    token = res.body.token;
    userId = res.body._id;
  });

  // 🔑 Login
  it("should login successfully with the registered user", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({
        email: testUser.email,
        password: testUser.password,
      })
      .expect(200);

    expect(res.body).toHaveProperty("token");
    expect(res.body.email).toBe(testUser.email);
  });

  // ❌ Delete user
  it("should delete the user after testing", async () => {
    const res = await request(app)
      .delete(`/api/users/${userId}`)
      .set("Authorization", `Bearer ${token}`)
      .expect(200);

    expect(res.body.message).toMatch(/deleted/i);
  });
});
