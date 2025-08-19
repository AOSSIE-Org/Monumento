const { Client, Databases, ID, RelationshipType, RelationMutate, Permission, Role, Storage } = require('node-appwrite');
const { InputFile } = require('node-appwrite/file');
const sdk = require('node-appwrite');
const readline = require('readline');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function getApiKeyFromUser() {
  return new Promise((resolve) => {
    rl.question('Please enter your Appwrite API key: ', (apiKey) => {
      resolve(apiKey);
    });
  });
}

function getProjectIdFromUser() {
  return new Promise((resolve) => {
    rl.question('Please enter your Appwrite Project ID: ', (projectId) => {
      resolve(projectId);
    });
  });
}

async function setupAppwrite() {
  try {
    console.log('Follow the steps below to setup your Appwrite project:\n');
    console.log('1. Create a new Appwrite project. Remember the Project ID');
    console.log('2. Add Flutter platform to the project based on the device you are testing.');
    console.log('3. Get the API Key from Settings > Overview > API credentials > View API Keys > Create API key.\n  Give the following scopes: Database[all] Storage[all] \n');

    console.log('Starting Appwrite project setup...');

    const apiKey = await getApiKeyFromUser();
    const projectId = await getProjectIdFromUser();

    const client = new Client()
      .setEndpoint(process.env.APPWRITE_API_ENDPOINT || 'https://cloud.appwrite.io/v1')
      .setProject(projectId)
      .setKey(apiKey);

    const databases = new Databases(client);
    const storage = new Storage(client);
    const Functions = new sdk.Functions(client);

    const databaseId = 'dbmonumento';
    const database = await databases.create(
      databaseId,
      'Database'
    );

    console.log('Database created successfully:', database.$id);

    console.log('Creating collections...');
    await createCollections(databases, database.$id);

    // Create a single bucket for all media files instead of separate buckets
    console.log('Creating unified storage bucket for images and 3D models...');
    await createUnifiedMediaBucket(storage);

    console.log('Uploading 3D models...');
    const modelUrl = await uploadModel(projectId, storage, 'lib/scripts/assets/mount_rushmore.glb', 'mount_rushmore.glb');

    console.log('Adding sample monument data...');
    await addSampleMonumentData(databases, database.$id, modelUrl);

    console.log('Setting up Appwrite function from a Git repository...\n');
    await createAppwriteFunction(Functions, projectId);

    console.log('Appwrite project setup completed successfully! 🎉');
    rl.close();
  } catch (error) {
    console.error('Error setting up Appwrite project:', error);
    rl.close();
  }
}

// New unified bucket function that handles both images and 3D models
async function createUnifiedMediaBucket(storage) {
  try {
    const bucketId = 'mediaBucket';
    const bucket = await storage.createBucket(
      bucketId,
      'Media Bucket (Images & 3D Models)',
      [
        Permission.create(Role.any()),
        Permission.read(Role.any()),
        Permission.create(Role.users()),
        Permission.read(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users())
      ],
      false, // file security
      true, // enabled
      10 * 1024 * 1024, // 50MB max file size (Appwrite's maximum limit)
      ['jpg', 'jpeg', 'png', 'gif', 'webp', 'glb', 'gltf', 'obj', 'fbx', 'stl', 'usdz'] // Combined file types
    );

    console.log('Unified media storage bucket created successfully:', bucket.$id);
    return bucket;
  } catch (error) {
    console.error('Error creating unified media storage bucket:', error);
    throw error;
  }
}


// Remove the separate bucket creation functions since we're using a unified approach
// async function createImageBucket(storage) { ... } - REMOVED
// async function create3DModelsBucket(storage) { ... } - REMOVED

async function createCollections(databases, databaseId) {
  try {
    const monumentsCollection = await createMonumentsCollection(databases, databaseId);
    const localExpertsCollection = await createLocalExpertsCollection(databases, databaseId);
    const usersCollection = await createUsersCollection(databases, databaseId);
    const postsCollection = await createPostsCollection(databases, databaseId);
    const communitiesCollection = await createCommunitiesCollection(databases, databaseId);

    await setupMonumentsAttributes(databases, databaseId, monumentsCollection.$id);
    await setupLocalExpertsAttributes(databases, databaseId, localExpertsCollection.$id);
    await setupUsersAttributes(databases, databaseId, usersCollection.$id);
    await setupPostsAttributes(databases, databaseId, postsCollection.$id);
    await setupCommunitiesAttributes(databases, databaseId, communitiesCollection.$id);

    console.log('Collections created successfully:', monumentsCollection.$id);
  } catch (error) {
    console.error('Error creating collections:', error);
    throw error;
  }
}

async function createLocalExpertsCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'localExperts',
    'localExperts',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
    ]
  );
}

async function setupLocalExpertsAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'destination',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'designation',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'expertId',
    255,
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'imageUrl',
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'name',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'phoneNumber',
    50,
    false,
    null,
    false
  );
}

async function createMonumentsCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'monuments',
    'monuments',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
      Permission.create(Role.users()),
    ]
  );
}

async function setupMonumentsAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'city',
    255,
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'communityId',
    255,
    true,
    null,
    false
  );

  await databases.createFloatAttribute(
    databaseId,
    collectionId,
    'coordinates',
    false,
    null,
    null,
    null,
    true
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'country',
    255,
    true,
    null,
    false
  );

  await databases.createBooleanAttribute(
    databaseId,
    collectionId,
    'has3DModel',
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'image',
    false,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'image_1x1_',
    false,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'images',
    false,
    null,
    true
  );

  await databases.createBooleanAttribute(
    databaseId,
    collectionId,
    'isPopular',
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'modelLink',
    false,
    null,
    false
  );

  await databases.createFloatAttribute(
    databaseId,
    collectionId,
    'rating',
    false,
    0.0,
    5.0,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'wikiPageId',
    255,
    false,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'wikipediaLink',
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'name',
    255,
    true,
    null,
    false
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'localExperts',
    RelationshipType.OneToMany,
    true,
    'localExperts',
    'monument',
    RelationMutate.SetNull,
  )
}

async function createUsersCollection(databases, databaseId) {
  const usersCollection = await databases.createCollection(
    databaseId,
    'users',
    'users',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
      Permission.create(Role.guests()),
      Permission.write(Role.users())
    ]
  );

  const checkInsCollection = await databases.createCollection(
    databaseId,
    'checkIns',
    'checkIns',
    [
      Permission.read(Role.any()),
      Permission.read(Role.users()),
      Permission.create(Role.users()),
      Permission.write(Role.users())
    ]
  );

  await databases.createStringAttribute(
    databaseId,
    checkInsCollection.$id,
    'monumentId',
    255,
    true
  );
  await databases.createStringAttribute(
    databaseId,
    checkInsCollection.$id,
    'title',
    255,
    false
  );
  await databases.createDatetimeAttribute(
    databaseId,
    checkInsCollection.$id,
    'timeStamp',
    true,
    null,
    false
  );

  await databases.createRelationshipAttribute(
    databaseId,
    checkInsCollection.$id,
    'users',
    RelationshipType.ManyToOne,
    true,
    'userId',
    'checkIns',
    RelationMutate.Cascade
  );

  console.log('Users collection and check-ins subcollection created successfully with check-in logic.');
  return usersCollection;
}

async function setupUsersAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'name',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'uid',
    255,
    true
  );

  await databases.createEmailAttribute(
    databaseId,
    collectionId,
    'email',
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'profilePictureUrl',
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'status',
    255,
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'username',
    50,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'searchParams',
    255,
    false,
    null,
    true
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'monuments',
    RelationshipType.ManyToMany,
    false,
    'savedMonuments',
    null,
    RelationMutate.SetNull
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'followers',
    255,
    false,
    null,
    true
  )

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'following',
    255,
    false,
    null,
    true
  )

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'posts',
    255,
    false,
    null,
    true,
  )
  await databases.createStringAttribute( 
  databaseId,
  collectionId,
  'myCommunities',
  255,
  false,
  null,
  true
  );

  await databases.createStringAttribute(
  databaseId,
  collectionId,
  'joinedCommunities',
  255,
  false,
  null,
  true
 );

  console.log('Waiting for user collection indexes to be ready...');
  await new Promise(resolve => setTimeout(resolve, 3000));
}

async function createPostsCollection(databases, databaseId) {
  const postsCollection = await databases.createCollection(
    databaseId,
    'posts',
    'posts',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
      Permission.write(Role.users()),
    ]
  );

  const postLikesCollection = await databases.createCollection(
    databaseId,
    'postLikes',
    'postLikes',
    [
      Permission.read(Role.any()),
      Permission.read(Role.users()),
      Permission.create(Role.users()),
      Permission.update(Role.users()),
      Permission.delete(Role.users()),
    ]
  );

  return postsCollection;
}

async function createCommunitiesCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'communities',
    'communities',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
      Permission.create(Role.users()),
      Permission.update(Role.users()),
      Permission.delete(Role.users())
    ]
  );
}

async function setupCommunitiesAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'name',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'description',
    1000,
    false,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'coverImageUrl',
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'createdByUserId',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'adminIds',
    255,
    false,
    null,
    true
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'memberIds',
    255,
    false,
    null,
    true
  );

  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'membersCount',
    false,
    0,
    null,
    0,
    false
  );

  await databases.createDatetimeAttribute(
    databaseId,
    collectionId,
    'createdAt',
    true,
    null,
    false
  );

  await databases.createBooleanAttribute(
    databaseId,
    collectionId,
    'isActive',
    false,
    true,
    false
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'users',
    RelationshipType.ManyToOne,
    true,
    'creator',
    'createdCommunities',
    RelationMutate.SetNull
  );
   // ADD THIS to track posts count
  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'postsCount',
    false,
    0,
    null,
    0,
    false
  );
}

async function setupPostsAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'title',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'location',
    255,
    false,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'imageUrl',
    false,
    null,
    false
  );

  await databases.createDatetimeAttribute(
    databaseId,
    collectionId,
    'timeStamp',
    true,
    null,
    false
  );

  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'postType',
    true,
    null,
    null,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'postByUid',
    255,
    true,
    null,
    false
  );

  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'likesCount',
    true,
    0,
    null,
    null,
    false
  );

  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'commentsCount',
    true,
    0,
    null,
    null,
    false
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'users',
    RelationshipType.ManyToOne,
    false,
    'author',
    null,
    RelationMutate.SetNull
  );
    // ADD THIS NEW ATTRIBUTE for community posts
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'communityId',
    255,
    false, // not required (posts can be personal or community posts)
    null,
    false
  );

  // ADD THIS to track post counts for communities  
  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'isFromCommunity',
    false,
    0,
    1,
    0,
    false
  );


  await setupPostLikesAttributes(databases, databaseId, 'postLikes');

  await new Promise(resolve => setTimeout(resolve, 3000));
}

async function setupPostLikesAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'userId',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'postId',
    255,
    true,
    null,
    false
  );

  await databases.createBooleanAttribute(
    databaseId,
    collectionId,
    'liked',
    true,
    null,
    false
  );

  await databases.createDatetimeAttribute(
    databaseId,
    collectionId,
    'timestamp',
    true,
    null,
    false
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'posts',
    RelationshipType.ManyToOne,
    true,
    'post',
    null,
    RelationMutate.Cascade
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'users',
    RelationshipType.ManyToOne,
    true,
    'user',
    null,
    RelationMutate.Cascade
  );
}

async function createAppwriteFunction(Functions, projectId) {
  try {
    const functionId = 'password-reset';
    const functionName = 'password reset Function';
    
    console.log('\nCreating function...');
    
    const result = await Functions.create(
      functionId,
      functionName,
      "node-22",
      ["any"],
      [],
      '',
      30,
      true,
      true,
      "src/main.js",
      "npm install",
    );
    
    console.log('Function created successfully:', result.$id);

    const codePath = path.join(__dirname, 'functions', 'code.tar.gz');
    let codeBuffer;
    try {
        console.log(`Reading function code from: ${codePath}`);
        codeBuffer = fs.readFileSync(codePath);
    } catch (readError) {
        console.error(`Error reading function code archive at ${codePath}:`, readError);
        throw readError;
    }

    const deployment = await Functions.createDeployment(
      functionId,
      InputFile.fromBuffer(codeBuffer, 'code.tar.gz'),
      true,
      "src/main.js",
      "npm install"
    );

    console.log('\nAdding Environment variables...');
    const variables = await Functions.createVariable(
      functionId,
      'APPWRITE_PROJECT_ID',
      projectId
    );
    
    console.log('Deployment created successfully!');
    console.log('Function is now being built and deployed. You can check the status in the Appwrite console.');
    
    rl.close();
    return result;
  } catch (error) {
    console.error('Error creating Appwrite function:', error);
    rl.close();
  }
}

async function addSampleMonumentData(databases, databaseId) {
  try {
    console.log('Adding sample monument data...');

    // Wait to ensure indexes are created before adding documents
    console.log('Waiting for collections to be fully ready...');
    await new Promise(resolve => setTimeout(resolve, 5000));

    // Since we're now using fixed IDs, we can directly use them without querying
    const monumentsCollectionId = 'monuments';
    const localExpertsCollectionId = 'localExperts';
    const usersCollectionId = 'users';

    console.log('Using monuments collection ID:', monumentsCollectionId);
    console.log('Using localExperts collection ID:', localExpertsCollectionId);
    console.log('Using users collection ID:', usersCollectionId);



    // Sample monument data matching the schema defined in setupMonumentsAttributes
    const monumentData = [{
      city: "NA",
      communityId: "8zDOMVBZHO38gGLODH1d",
      coordinates: [43.8789472, -103.459825],
      country: "South Dakota",
      has3DModel: true,
      image: "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      image_1x1_: "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      images: [
        "https://i0.wp.com/gregdisch.com/wp-content/uploads/2021/01/Mount-Rushmore-National-Memorial-20140915-_MG_7930.jpg?ssl=1",
        "https://www.nps.gov/moru/learn/historyculture/images/Hall-of-Records-2017-2_1.jpg?maxwidth=1300&maxheight=1300&autorotate=false",
        "https://regal-holidays.net/wp-content/uploads/2019/07/hawa-mahal-441563_1920.jpg",
        "https://regal-holidays.net/wp-content/uploads/2019/07/architecture-3187940_1920.jpg"
      ],
      isPopular: true,
      modelLink: modelUrl,
      name: "Mount Rushmore National Memorial",
      rating: 3.9,
      wikiPageId: '185973',
      wikipediaLink: "https://en.wikipedia.org/wiki/Mount_Rushmore"
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
    }];
    for (const monument of monumentData) {
      const createdDocument = await databases.createDocument(
        databaseId,
        'monuments',
        ID.unique(),
        monument
      );
      console.log('Sample monument document created successfully:', createdDocument.$id);
    }
  
    // Create local experts that relate to the monument by destination name
    const localExperts = [
      {
        destination: "Mount Rushmore National Memorial",
        designation: "Local Guide",
        expertId: "A98DB973KW",
        imageUrl: "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
        name: "Thomas Baker",
        phoneNumber: "+911234567890"
      },
      {
        destination: "Mount Rushmore National Memorial",
        designation: "Freelance Photographer",
        expertId: "NKCRKENUII",
        imageUrl: "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
        name: "Andrew Harris",
        phoneNumber: "+910987654321"
      }
    ];

    for (const expert of localExperts) {
      const createdExpert = await databases.createDocument(
        databaseId,
        localExpertsCollectionId,  // Using the fixed ID
        ID.unique(),
        expert
      );
      console.log(`Local expert document created successfully: ${createdExpert.$id}`);
    }

  } catch (error) {
    console.error('Error adding sample monument data:', error);
    throw error;
  }
}

async function uploadModel(projectId, storage, modelPath, fileName) {
  try {
    console.log(`Uploading model ${fileName}. This may take some time depending on file size...`);

    // Check if the file exists
    if (!fs.existsSync(modelPath)) {
      console.error(`3D model file not found at: ${modelPath}`);
      return null;
    }

    // Upload the file to the 3D models bucket
    const file = await storage.createFile(
      'modelsBucket',
      ID.unique(),
      InputFile.fromPath(modelPath, fileName),
    );
    
    const fileUrl = `https://cloud.appwrite.io/v1/storage/buckets/modelsBucket/files/${file.$id}/view?project=${projectId}&mode=admin`;

    console.log(`${fileName} 3D model uploaded successfully:`, file.$id);

    return fileUrl;
  } catch (error) {
    console.error(`Error uploading ${fileName} 3D model:`, error);
    return null;
  }
}


setupAppwrite();