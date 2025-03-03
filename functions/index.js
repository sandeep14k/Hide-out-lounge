/* eslint-env node */
/* global require, exports */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");
const functions = require("firebase-functions");
// Initialize Firebase Admin
admin.initializeApp();


sgMail.setApiKey(functions.config().sendgrid.api_key);


exports.sendOrderEmail = onDocumentCreated("orders/{orderId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with event.");
    return;
  }

  const orderData = snapshot.data();
  const orderId = event.params.orderId;

  const adminEmails = [
    "shivamsingh58602@gmail.com",
    "hideoutlaunge@gmail.com",
    "anmolroy.26@gmail.com",
  ];

  const orderDate = orderData.orderDate ? orderData.orderDate.toDate() : "N/A";

  const msg = {
    to: adminEmails,
    from: "sandeepyujha@gmail.com", // Replace with your verified sender email in SendGrid
    subject: `New Order Placed - Order ID: ${orderId}`,
    text: `Order Details:
           Order ID: ${orderId}
           User ID: ${orderData.userId}
           Address: ${orderData.address}
           Total Amount: ₹${orderData.totalAmount}
           Payment Method: ${orderData.paymentMethod}
           Payment Status: ${orderData.paymentStatus}
           Order Status: ${orderData.orderStatus}
           Order Date: ${orderDate}

           Items:
           ${orderData.cartItems
             .map(
               (item) =>
                 `- ${item.Name} (Qty: ${item.Quantity}) - ₹${item.Total}`
             )
             .join("\n")}
    `,
    html: `<strong>Order Details:</strong>
           <p>Order ID: ${orderId}</p>
           <p>User ID: ${orderData.userId}</p>
           <p>Address: ${orderData.address}</p>
           <p>Total Amount: ₹${orderData.totalAmount}</p>
           <p>Payment Method: ${orderData.paymentMethod}</p>
           <p>Payment Status: ${orderData.paymentStatus}</p>
           <p>Order Status: ${orderData.orderStatus}</p>
           <p>Order Date: ${orderDate}</p>

           <strong>Items:</strong>
           <ul>
             ${orderData.cartItems
               .map(
                 (item) =>
                   `<li>${item.Name} (Qty: ${item.Quantity}) - ₹${item.Total}</li>`
               )
               .join("")}
           </ul>
    `,
  };

  try {
    await sgMail.send(msg);
    console.log("Email sent successfully for Order ID:", orderId);
  } catch (error) {
    console.error("Error sending email:", error);
  }
});
// eslint-disable-next-line no-undef
exports.api = onRequest({ region: "us-central1" }, (req, res) => {
  res.send("Health check passed");
});