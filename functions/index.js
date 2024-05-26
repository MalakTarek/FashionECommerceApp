const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendProductNotification = functions.firestore
    .document("products/{pid}")
    .onCreate(async (snap, context) => {
        try {
            const product = snap.data();
            const pid = context.params.pid;
            // Fetch FCM tokens of shoppers
            const shoppersSnapshot = await admin.firestore().collection("users")
                .where("role", "==", "Shopper")
                .get();
            const tokens = shoppersSnapshot.docs
                .map(doc => doc.data().fcmToken)
                .filter(token => !!token);
            if (tokens.length > 0) {
                const payload = {
                    notification: {
                        title: "New Product Alert!",
                        body: `A new product "${product.name}" has been added by ${product.vendorName}. Check it out now!`
                    }
                };
                // Send notifications to shoppers
                const response = await admin.messaging().sendEachForMulticast({
                                                     tokens: tokens,
                                                     notification: payload.notification,
                                                 });
                logger.log(`Notifications sent to ${response.successCount} shoppers`);
            }
        } catch (error) {
            logger.error("Error sending product notification:", error);
        }
    });

exports.sendDiscountNotification = functions.firestore
    .document("products/{pid}")
    .onUpdate(async (change, context) => {
        try {
            const after = change.after.data();
            const before = change.before.data();

            // Check if the product has just been discounted
            if (after.isDiscounted && !before.isDiscounted) {
                const payload = {
                    notification: {
                        title: "Discount Alert!",
                        body: `The product "${after.name}" is now available at a discounted price.`
                    }
                };

                // Fetch FCM tokens of shoppers
                const shoppersSnapshot = await admin.firestore().collection("users")
                    .where("role", "==", "Shopper")
                    .get();

                const tokens = shoppersSnapshot.docs
                    .map(doc => doc.data().fcmToken)
                    .filter(token => !!token);  // Ensure no null/undefined tokens are included

                if (tokens.length > 0) {
                    // Send notifications to shoppers
                    const response = await admin.messaging().sendEachForMulticast({
                        tokens: tokens,
                        notification: payload.notification
                    });

                    logger.log(`Discount notifications sent to ${response.successCount} shoppers`);
                } else {
                    console.log("No tokens found for the specified user type");
                }
            }
        } catch (error) {
            console.error("Error processing discount update:", error);
        }
    });
exports.sendCommentNotification = functions.firestore
    .document("products/{pid}")
    .onUpdate(async (change, context) => {
        try {
            const after = change.after.data();
            const before = change.before.data();
            const pid = context.params.pid;

            // Compare the comments array to detect new comments
            const newComments = after.comments.filter(comment => !before.comments.includes(comment));
            if (newComments.length > 0) {
                const productDoc = await admin.firestore().collection("products").doc(pid).get();
                const product = productDoc.data();

                const vendorDoc = await admin.firestore().collection("users").doc(product.vendorId).get();
                const vendor = vendorDoc.data();
                const vendorToken = vendor.fcmToken;

                if (vendorToken) {
                    const payload = {
                        notification: {
                            title: "New Comment on Your Product",
                            body: `A new comment has been added to your product "${product.name}".`
                        }
                    };

                    // Send notification to the vendor
                    const response = await admin.messaging().sendMulticast({
                        tokens: [vendorToken],
                        notification: payload.notification
                    });

                         console.log(`Comment notification sent to vendor (${vendor.name}):`, response);
                }
            }
        } catch (error) {
            console.error("Error processing comment update:", error);
        }
    });