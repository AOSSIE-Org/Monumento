
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
    {
      "city": "Giza",
      "communityId": "CcZ53rufrehIx5i4fbGN",
      "coordinates": [29.97648, 31.131302],
      "country": "Egypt",
      "has3DModel": false,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FGiza.png?alt=media&token=76420521-e8a7-46d9-9cc4-b8be5ae1ebc7",
      "image_1x1_":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FGiza%2Fimgonline-com-ua-compressed-W4vsKzVTICIHlf.jpeg?alt=media&token=27d92ebe-c255-4d58-9752-b5401faff76e",
      "images": [
        "https://lp-cms-production.imgix.net/2020-11/GettyRF_1085205362.jpg?w=1440&h=810&fit=crop&auto=format&q=75",
        "https://www.wendywutours.com.au/resource/upload/2137/giza-ban.jpg.webp",
        "https://www.explore.com/img/gallery/your-guide-to-visiting-the-pyramids-of-giza/l-intro-1674535909.jpg",
        "https://www.lecole.edu.pk/wp-content/uploads/2022/01/1.png",
        "https://i.abcnewsfe.com/a/07d0083f-5f8c-4b76-8aae-f2507398c021/giza-pyramid_1706875367155_hpMain.jpg?w=1500",
        "https://assets.bwbx.io/images/users/iqjWHBFdfxIU/iodekmLE06o8/v1/-1x-1.jpg"
      ],
      "isPopular": true,
      "localExperts": [],
      "modelLink":
          "",
      "name": "Pyramids of Giza",
      "rating": 4.2,
      "wikiPageId": "12224",
      "wikipediaLink": "https://en.wikipedia.org/wiki/Great_Pyramid_of_Giza"
    },
    {
      "city": "Rome",
      "communityId": "b6rPdMDApEWAbxhaO5jS",
      "coordinates": [41.890251, 12.492373],
      "country": "Italy",
      "has3DModel": false,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FColosseum.png?alt=media&token=b46e63f0-02ed-4bb5-a308-06ddad19bf1a",
      "image_1x1_":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FColosseum%2Fcolosseum%20(1).jpeg?alt=media&token=55402c38-8d6a-4229-a47e-8c3ebd93bfba",
      "images": [],
      "isPopular": true,
      "localExperts": [],
      "modelLink":"",
      "name": "Colosseum",
      "rating": 4.3,
      "wikiPageId": "49603",
      "wikipediaLink": "https://en.wikipedia.org/wiki/Colosseum"
    },
    {
      "city": "Agra",
      "communityId": "owE15hBtG73FltftN90F",
      "coordinates": [27.173891, 78.042068],
      "country": "India",
      "has3DModel": false,
      "image":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FTajMahal.png?alt=media&token=281d8197-04f7-49d9-854b-a09b659c0b48",
      "image_1x1_":
          "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FTajMahal%2Fimgonline-com-ua-compressed-m5aDSdvCuUC.jpeg?alt=media&token=0c5793df-7f74-4e26-bcfb-b2577ebd2f20",
      "images": [
        "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Taj_Mahal_%28Edited%29.jpeg/1200px-Taj_Mahal_%28Edited%29.jpeg",
        "https://th-thumbnailer.cdn-si-edu.com/GOqbtvN67IuyrUZ_rRi5q67Lsi4=/fit-in/1600x0/https://tf-cmsv2-smithsonianmag-media.s3.amazonaws.com/filer/9b/14/9b14dbbf-77ac-4bcf-9078-c765c709d5e9/taj_mahal_at_morning_from_south-east.jpg",
        "https://lh3.googleusercontent.com/ci/AL18g_TQxTxxdrU1mZntTjKLa8A_qoXpZg3B_KmtktOh_f-vCXreXVKEo5VkodWyW4mrpOws1LHumeY",
        "https://media.istockphoto.com/id/486312253/photo/taj-mahal-agra-india.jpg?s=612x612&w=0&k=20&c=qHlt87Hk1JWkUGGtAaRYPSXE53VcwPUUtVxYNbQC-u4=",
        "https://media.istockphoto.com/id/629735190/photo/tomb-in-taj-mahal-agra-india.jpg?s=612x612&w=0&k=20&c=oLosYvacRxu5L0eEK-XiMK-P9og5-NQ5cfBCiYsVopg=",
        "https://media.istockphoto.com/id/469462492/photo/taj-mahal-in-the-fog-at-sunrise.jpg?s=612x612&w=0&k=20&c=_2CAnoW-0wCabMO_GBGOMPODA0YgYq9s-6TfT8UwnJA="
      ],
      "isPopular": true,
      "localExperts": [],
      "modelLink":"",
      "name": "Taj Mahal",
      "rating": 4.1,
      "wikiPageId": "82976",
      "wikipediaLink": "https://en.wikipedia.org/wiki/Taj_Mahal"
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
