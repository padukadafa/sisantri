const admin = require("firebase-admin");
const XLSX = require("xlsx");
const { v4: uuidv4 } = require("uuid");
const path = require("path");

admin.initializeApp({
  credential: admin.credential.cert(require("./belajar-login-system-firebase-adminsdk-vbat2-5f415066e7.json")),
});

const auth = admin.auth();
const firestore = admin.firestore();
async function generateUniqueEmail(name, auth) {
  function baseEmail() {
    const parts = name.toLowerCase().split(/\s+/);
    const first = parts[0];
    const lastInitial = parts.length > 1 ? parts[parts.length - 1][0] : "x";
    const random3 = Math.floor(100 + Math.random() * 900);
    return `${first}.${random3}@ppmaw.my.id`;
  }

  let email;

  while (true) {
    email = baseEmail();
    try {
      // Jika email ada → userRecord berisi profil user
      await auth.getUserByEmail(email);
      console.log(`Email duplikat ditemukan (${email}), generate ulang...`);
      // lanjut ulang loop
    } catch (err) {
      if (err.code === "auth/user-not-found") {
        // Email benar-benar unik
        return email;
      } else {
        throw err;
      }
    }
  }
}
function generatePassword() {
  return "Santri@" + uuidv4().substring(0, 3);
}

async function importSantri() {
  const filePath = path.join(__dirname, "data_santri.xlsx");
  const workbook = XLSX.readFile(filePath);

  const sheetName = workbook.SheetNames[0];
  const sheet = workbook.Sheets[sheetName];

  let rows = XLSX.utils.sheet_to_json(sheet, { defval: "" });

  console.log("Total santri:", rows.length);

  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];

    const nama = row.nama || row.Nama || row.nama_santri || row.NAMA;
    if (!nama) {
      console.log(`Baris ${i + 1} dilewati (kolom nama tidak ada).`);
      continue;
    }

    const email = await generateUniqueEmail(nama, auth);
    const password = generatePassword();

    try {
      // === Create User in Firebase Auth ===
      const userRecord = await auth.createUser({
        email,
        password,
        displayName: nama,
      });

      // === Save to Firestore ===
      await firestore.collection("users").doc(userRecord.uid).set({
        id: userRecord.uid,
        nama,
        email,
        deviceTokens: [],
        fotoProfil: null,
        poin: 0,
        role: "santri",
        rfidCardId: null,
        statusAktif: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // === Save password to Excel row ===
      rows[i].password = password;

      console.log(`SUKSES → ${nama} | ${email} | password: ${password}`);
    } catch (err) {
      console.log(`GAGAL → ${nama}:`, err.message);
      rows[i].password = "GAGAL";
    }
  }

  // === Write updated data to new Excel file ===
  const newSheet = XLSX.utils.json_to_sheet(rows);
  const newWorkbook = XLSX.utils.book_new();

  XLSX.utils.book_append_sheet(newWorkbook, newSheet, sheetName);

  const outputFile = path.join(__dirname, "data_santri_hasil.xlsx");
  XLSX.writeFile(newWorkbook, outputFile);

  console.log(`\nImport selesai! File hasil: ${outputFile}`);
}

importSantri();
