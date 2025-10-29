import mongoose from "mongoose";

const addressSchema = new mongoose.Schema(
    {
        number: {
            type: String
        },
        street: {
            type: String,
        },
        barangay: {
            type: String,
        },
        city: {
            type: String,
            required: true,
        },
        province: {
            type: String,
            required: true,
        },
        zipCode: {
            type: String,
        }
})

const Address = mongoose.model("Address", addressSchema);
export default Address;