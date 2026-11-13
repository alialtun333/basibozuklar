const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();

// ============================================================
// ORTAK FONKSİYON: Token listesine bildirim gönder
// ============================================================
async function sendNotification(tokens, title, body) {
    if (!tokens || tokens.length === 0) {
        console.log("Gönderilecek token yok.");
        return;
    }

    const message = {
        notification: { title: title, body: body },
        tokens: tokens,
    };

    try {
        const response = await getMessaging().sendEachForMulticast(message);
        console.log(`✅ ${response.successCount} başarılı, ${response.failureCount} başarısız.`);
    } catch (error) {
        console.error("❌ Bildirim gönderme hatası:", error);
    }
}

// ============================================================
// 1. YENİ DUYURU
// ============================================================
exports.sendAnnouncementNotification = onDocumentCreated("announcements/{announcementId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;

    const announcement = snapshot.data();
    const usersSnapshot = await db.collection("users").get();
    const tokens = [];
    
    usersSnapshot.forEach(doc => {
        const userData = doc.data();
        if (userData.fcmToken) tokens.push(userData.fcmToken);
    });

    await sendNotification(tokens, `📢 Yeni Duyuru: ${announcement.title}`, announcement.content);
    return null;
});

// ============================================================
// 2. YENİ MESAJ
// ============================================================
exports.sendMessageNotification = onDocumentCreated("messages/{messageId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;

    const msg = snapshot.data();
    
    // Mesajı alan kişinin token'ını bul
    const receiverDoc = await db.collection("users").doc(msg.toEmail).get();
    if (!receiverDoc.exists) return null;

    const receiverData = receiverDoc.data();
    if (!receiverData.fcmToken) return null;

    // Gönderenin adını bul (opsiyonel, mesajda yazması için)
    const senderDoc = await db.collection("users").doc(msg.fromEmail).get();
    const senderName = senderDoc.exists ? senderDoc.data().name : "Bir kullanıcı";

    // Mesajı kısalt
    const shortText = msg.text.length > 40 ? msg.text.substring(0, 40) + "..." : msg.text;

    await sendNotification([receiverData.fcmToken], `💬 ${senderName}`, shortText);
    return null;
});

// ============================================================
// 3. YENİ OYUN
// ============================================================
exports.sendNewGameNotification = onDocumentCreated("games/{gameId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;

    const game = snapshot.data();
    
    // Sadece yeni oluşturulan aktif oyunlar için bildirim at (geçmişe taşınmış olanlar için değil)
    if (game.teamsAssigned) return null;

    const usersSnapshot = await db.collection("users").get();
    const tokens = [];
    
    usersSnapshot.forEach(doc => {
        const userData = doc.data();
        if (userData.fcmToken) tokens.push(userData.fcmToken);
    });

    const dateStr = new Date(game.gameDate).toLocaleDateString('tr-TR');
    await sendNotification(tokens, `🎯 Yeni Oyun: ${game.title}`, `Tarih: ${dateStr}. Anket şimdi açıldı, katılmayı unutma!`);
    return null;
});

// ============================================================
// 4. TAKIM ATANDI (Oyun güncellendiğinde tetiklenir)
// ============================================================
exports.sendTeamAssignedNotification = onDocumentUpdated("games/{gameId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Sadece takımlar YENİ atandıysa bildirim gönder
    if (!before.teamsAssigned && after.teamsAssigned) {
        const usersSnapshot = await db.collection("users").get();
        const userMap = {};
        usersSnapshot.forEach(doc => { userMap[doc.id] = doc.data(); });

        // Her oyuncu için ayrı bildirim hazırla
        for (const [email, team] of Object.entries(after.assignments)) {
            const userData = userMap[email];
            if (userData && userData.fcmToken && team !== '-') {
                const title = `🛡️ Takımın Belli Oldu: ${team}`;
                const body = `${after.title} oyunu için takımın ${team} olarak atandı. İyi oyunlar!`;
                await sendNotification([userData.fcmToken], title, body);
            }
        }
    }
    return null;
});