
// Import Firebase Admin SDK
const admin = require('firebase-admin');

// Load configuration from environment variables or a config file if desired.
const serviceAccount = require('./serviceAccountKey.json'); // Update with your key file path

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Sample monument data
const monumentsData = [
    {
      "city": "NA",
      "communityId": "8zDOMVBZHO38gGLODH1d",
      "coordinates": [43.8789472, -103.459825],
      "country": "South Dakota",
      "has3DModel": true,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      "image_1x1_":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      "images": [
        "https://i0.wp.com/gregdisch.com/wp-content/uploads/2021/01/Mount-Rushmore-National-Memorial-20140915-_MG_7930.jpg?ssl=1",
        "https://www.nps.gov/moru/learn/historyculture/images/Hall-of-Records-2017-2_1.jpg?maxwidth=1300&maxheight=1300&autorotate=false",
        "https://regal-holidays.net/wp-content/uploads/2019/07/hawa-mahal-441563_1920.jpg",
        "https://regal-holidays.net/wp-content/uploads/2019/07/architecture-3187940_1920.jpg",
      ],
      "isPopular": true,
      "localExperts": [
        {
          "designation": "Local Guide",
          "expertId": "A98DB973KW",
          "imageUrl":
              "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
          "name": "Thomas Baker",
          "phoneNumber": "+911234567890"
        },
        {
          "designation": "Freelance Photographer",
          "expertId": "NKCRKENUII",
          "imageUrl":
              "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
          "name": "Andrew Harris",
          "phoneNumber": "+910987654321"
        }
      ],
      "modelLink":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Fmount_rushmore%2Fscene?alt=media&token=522ada26-b7ae-4ef0-b682-dc595d6bf732",
      "name": "Mount Rushmore National Memorial",
      "rating": 3.9,
      "wikiPageId": "185973",
      "wikipediaLink": "https://en.wikipedia.org/wiki/Mount_Rushmore"
    },
  ];
(async () => {
  try {
    console.log('Starting to populate the monuments collection...');

    const batch = db.batch();

    monumentsData.forEach(monument => {
      // Create a new doc reference
      const docRef = db.collection('monuments').doc();
      // Set the id field inside the document to the docRef ID
      const monumentWithId = { ...monument, id: docRef.id };
      batch.set(docRef, monumentWithId);
    });

    await batch.commit();

    console.log('Monuments collection populated successfully.');
    process.exit(0);
  } catch (error) {
    console.error('Error populating monuments:', error);
    process.exit(1);
  }
})();
